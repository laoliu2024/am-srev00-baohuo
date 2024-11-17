#!/bin/bash

# 定义颜色代码
green="\033[32m"
yellow="\033[33m"
red="\033[31m"
purple() { echo -e "\033[35m$1\033[0m"; }
re="\033[0m"

# 打印欢迎信息
echo ""
purple "=== serv00 | AM科技 一键保活脚本 ===\n"
echo -e "${green}脚本地址：${re}${yellow}https://github.com/amclubs/am-serv00-github-action${re}\n"
echo -e "${green}YouTube频道：${re}${yellow}https://youtube.com/@AM_CLUBS${re}\n"
echo -e "${green}个人博客：${re}${yellow}https://am.809098.xyz${re}\n"
echo -e "${green}TG反馈群组：${re}${yellow}https://t.me/AM_CLUBS${re}\n"
purple "=== 转载请著名出处 AM科技，请勿滥用 ===\n"

base_url="https://raw.githubusercontent.com/amclubs"

# 发送 Telegram 消息的函数
send_telegram_message() {
    local message="$1"
    response=$(curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" -d "chat_id=$CHAT_ID" -d "text=$message")

    # 检查响应
    if [[ $(echo "$response" | jq -r '.ok') == "true" ]]; then
        echo "::info::Telegram消息发送成功: $message"
    else
        echo "::error::Telegram消息发送失败: $response"
    fi
}

# 检查是否传入了参数
if [ "$#" -lt 1 ]; then
    echo "用法: $0 <servers.json> [<TG_TOKEN> <CHAT_ID>]"
    echo "请确保将账户信息以 JSON 格式保存在指定的文件中。"
    exit 1
fi

# 读取 JSON 文件
servers_json=$(<"$1")
declare -A servers
TG_TOKEN="$2"
CHAT_ID="$3"

# 解析 JSON
while IFS= read -r line; do
    key=$(echo "$line" | jq -r '.key')
    value=$(echo "$line" | jq -r '.value')
    #echo "原始数据: $line"

    if [[ -n "$key" && -n "$value" ]]; then
        key=$(echo "$key" | tr -d '"')
        value=$(echo "$value" | tr -d '"')
        IFS=',' read -r domain username password <<< "$key"
        # 直接存储原始 value 字符串
        servers["$domain,$username,$password"]="$value"

        #echo "Key: $key"
        #echo "Value: $value"
    fi
done <<< "$(echo "$servers_json" | jq -c 'to_entries | .[] | {key: .key, value: .value}')"


# 最大检测失败次数
max_fail=3

# 获取脚本 URL
get_script_url() {
    case $1 in
        s5) echo "${base_url}/am-serv00-socks5/main/am_restart_s5.sh" ;;
        vmess) echo "${base_url}/am-serv00-vmess/main/am_restart_vmess.sh" ;;
        nezha-dashboard) echo "${base_url}/am-serv00-nezha/main/am_restart_dashboard.sh" ;;
		nezha-agent) echo "${base_url}/am-serv00-nezha/main/am_restart_agent.sh" ;;
        x-ui) echo "${base_url}/am-serv00-x-ui/main/am_restart_x_ui.sh" ;;
        *) echo "${base_url}/am-serv00-socks5/main/am_restart_s5.sh" ;;
    esac
}

# 检查端口是否打开
check_port() {
    nc -zv "$1" "$2" >/dev/null 2>&1
}

# 检查 Argo 隧道是否在线
check_argo() {
    local http_code
    http_code=$(curl -o /dev/null -s -w "%{http_code}" "https://$1")
    echo "HTTP Code: $http_code"
    if [ "$http_code" -eq 404 ]; then
        return 0  # 视为在线
    else
        return 1  # 视为不在线
    fi
}

# 远程执行脚本
execute_remote_script() {
    local script_url token=""
    script_url=$(get_script_url "$4")

    if [[ "$4" == "vmess" ]]; then
        token="${5}"  
    fi

    local ssh_command="$2@$1"  
    echo "通过 SSH 连接 $ssh_command 并执行下载脚本 bash <(curl -Ls $script_url) $token ..."
    sshpass -p "$3" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -tt "$ssh_command" "bash <(curl -Ls $script_url) $token"
}
# 远程执行脚本
execute_remote_script() {
    local script_url token=""
    script_url=$(get_script_url "$4")

    if [[ "$4" == "vmess" ]]; then
        token="${5}"  
    fi

    local ssh_command="$2@$1"  
    echo "通过 SSH 连接 $ssh_command 并执行下载脚本 bash <(curl -Ls $script_url) $token ..."
    if [ -n "$TG_TOKEN" ] && [ -n "$CHAT_ID" ]; then
        send_telegram_message "🔴服务正在重启: $server 用户名: $username 端口: $port 服务: $service"
    fi
    
    # 使用 sshpass 执行命令并检查返回值
    if ! sshpass -p "$3" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -tt "$ssh_command" "bash <(curl -Ls $script_url) $token"; then
        # 如果传入了 TG_TOKEN 和 CHAT_ID，发送 Telegram 通知
        if [ -n "$TG_TOKEN" ] && [ -n "$CHAT_ID" ]; then
            echo "远程执行失败，准备发送 Telegram 通知..."
            send_telegram_message "🔴服务重启失败: $server 用户名: $username 端口: $port 服务: $service"
        fi
    else
        if [ -n "$TG_TOKEN" ] && [ -n "$CHAT_ID" ]; then
            echo "远程执行失败，准备发送 Telegram 通知..."
            send_telegram_message "🟢服务重启成功: $server 用户名: $username 端口: $port 服务: $service"
        fi
        echo "远程执行成功"
    fi
}


# 打印状态信息
print_status() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${re}"
}

# 遍历每个服务器和服务
for server_info in "${!servers[@]}"; do
    IFS=',' read -r server username password <<< "$server_info"
    services=${servers[$server_info]}

    # 将服务字符串分割成数组
    IFS=';' read -r -a service_array <<< "$services"

    for service_info in "${service_array[@]}"; do
        IFS=',' read -r service port argo_domain token <<< "$service_info"

        # 确保打印信息正确
        print_status "$re" "检测服务器: $server 用户名: $username 端口: $port 服务: $service ..."

        fail_count=0
        for attempt in {1..3}; do
            if check_port "$server" "$port"; then
                print_status "$green" "端口 $port 在 $server 正常"
                break
            else
                fail_count=$((fail_count + 1))
                print_status "$red" "第 $attempt 次检测失败，端口 $port 不通"
                sleep 5
            fi
        done

        if [[ "$service" == "vmess" ]]; then
            argo_fail_count=0
            print_status "$re" "开始检测 Argo 隧道..."
            for argo_attempt in {1..3}; do
                echo "Argo 隧道域名: $argo_domain"
                if check_argo "$argo_domain"; then
                    print_status "$green" "Argo 隧道在线"
                    break
                else
                    argo_fail_count=$((argo_fail_count + 1))
                    print_status "$red" "第 $argo_attempt 次检测 Argo 隧道失败"
                    sleep 5
                fi
            done

            if [[ $argo_fail_count -eq $max_fail ]]; then
                print_status "$red" "Argo 隧道状态: 连续 $max_fail 次检测失败"
            fi
        fi

        if [[ $fail_count -eq $max_fail ]] || [[ "$service" == "vmess" && $argo_fail_count -eq $max_fail ]]; then
            print_status "$red" "服务器状态: $server 用户名: $username 端口: $port 服务: $service 连续 $max_fail 次检测失败，执行远程操作..."
            execute_remote_script "$server" "$username" "$password" "$service" "$token"
            print_status "$green" "执行远程操作完毕"
        else
            print_status "$re" "服务器状态: $server 用户名: $username 端口: $port 服务: $service 检测成功"
        fi

        echo "----------------------------"
    done
done

print_status "$re" "所有服务器检测完毕"
