# [am-serv00-github-action](https://github.com/amclubs/am-serv00-github-action)
通过GitHub Action 实现serv00、socks5、vmess、x-ui面板、哪吒面板、节点等在serv00里部署的程序保活、serv00帐号保活,并可TG通过

#
▶️ **新人[YouTube](https://youtube.com/@AM_CLUB)** 需要您的支持，请务必帮我**点赞**、**关注**、**打开小铃铛**，***十分感谢！！！*** ✅
</br>🎁 不要只是下载或Fork。请 **follow** 我的GitHub、给我所有项目一个 **Star** 星星（拜托了）！你的支持是我不断前进的动力！ 💖
</br>✅**解锁更多技术请点击进入 YouTube频道[【@AM_CLUB】](https://youtube.com/@AM_CLUB) 、[【个人博客】](https://am.809098.xyz)** 、TG群[【AM科技 | 分享交流群】](https://t.me/AM_CLUBS) 、获取免费节点[【进群发送关键字: 订阅】](https://t.me/AM_CLUBS)


#
- [部署视频教程](https://youtu.be/zkGGklEaO2I)
- huggingface部署青龙面板定时保活教程：[点击进入观看](https://youtu.be/J4lcIwBowmM)
- VLESS免费节点部署视频教程：[点击进入观看](https://youtu.be/dPH63nITA0M) 
- Trojan免费节点部署视频教程：[点击进入观看](https://youtu.be/uh27CVVi6HA) 
- serv00所有部署教程：[点击进入观看](https://www.youtube.com/playlist?list=PLGVQi7TjHKXaVlrHP9Du61CaEThYCQaiY)
- Cloudflare部署免费节点所有视频教程：[点击进入观看](https://www.youtube.com/playlist?list=PLGVQi7TjHKXbrY0Pk8gm3T7m8MZ-InquF) 

## 一、实现serv00帐号定时保活（keep_serv00_ssh.yml），默认每5天定时保活
找到项目点 Settings -> 左边点 Secrets and variables -> 点 Actions -> 在 Secrets 增加下面变量,根据自己的数据填 
- 帐号信息变量（必填）：SSH_ACCOUNTS 
```
[
  {"ip": "s8.com", "username": "test", "password": "tzCOu"},
  {"ip": "s9.com", "username": "abc", "password": "yTev"}
]
```
- TG通知变量（非必填）：CHAT_ID
```
1282345
```
- TG通知变量（非必填）：TG_TOKEN
```
803xx8165:AAEOwpSKbxxxpFyuZbbi
```

## 二、实现serv00、socks5、vmess节点等自动外部保活（keep_serv00.yml），默认每5小时保活
找到项目点 Settings -> 左边点 Secrets and variables -> 点 Actions -> 在 Secrets 增加下面变量,根据自己的数据填
- 应用信息变量（必填）：SERVERS_JSON
```
{
    "s8.serv00.com,username1,password1":"s5,10000",
    "s9.serv00.com,username2,password2":"s5,20000;x-ui,30000",
    "s11.serv00.com,username3,password3":"nezha-dashboard,40000;vmess,50000,vmess.abc.xyz,token"
}

```
1、格式为："IP/域名,用户名,密码":"s5(socket5标识符),socket5端口;vmess(服务标识符),vmess端口,Argo隧道域名,Argo隧道token或json;nezha-dashboard(服务标识符),vmess端口"
- 例如：部署一台服务器，socks5一个应用
```
{
    "s8.serv00.com,username1,password1":"s5,10000"
}
```
- 例如：部署一台服务器，socks5、vmess两个应用
```
{
    "s8.serv00.com,username1,password1":"s5,10000;vmess,50000,vmess.abc.xyz,token"
}
```
- 例如：部署三台服务器，服务器一部署了nezha-dashboard，服务器二部署了socks5、x-ui，服务器三部署了x-ui、nezha-dashboard、vmess
```
{
    "s8.serv00.com,username1,password1":"nezha-dashboard,10000",
    "s9.serv00.com,username2,password2":"s5,20000;x-ui,30000",
    "s11.serv00.com,username3,password3":"x-ui,30000;nezha-dashboard,40000;vmess,50000,vmess.abc.xyz,token"
}
```

- TG通知变量（非必填）：CHAT_ID
```
1282345
```
- TG通知变量（非必填）：TG_TOKEN
```
803xx8165:AAEOwpSKbxxxpFyuZbbi
```

## 三、Telegram获取token 和chat_id 的方式
### 1、加入 BotFather 机器人
点击网址https://t.me/BotFather ，打开与它的聊天界面。

### 2、创建 bot 并获取 token
- 2.1 创建机器人
输入 /newbot 回车
显示：Alright, a new bot. How are we going to call it? Please choose a name for your bot.

- 2.2 输入机器人的名称
比如输入 acmlubs_bot 回车
显示：Good. Now let’s choose a username for your bot. It must end in bot. Like this, for example: TetrisBot or acmlubs_bot.

- 2.3 输入唯一的机器人用户名
格式为 acmlubs_bot 或 acmlubsbot 必须以bot结尾。
失败后显示：Sorry, xxxxxxxxxx
成功后显示：
Done! Congratulations on your new bot. You will find it at t.me/acmlubs_bot. You can now add a description, about section and profile picture for your bot, see /help for a list of commands. By the way, when you’ve finished creating your cool bot, ping our Bot Support if you want a better username for it. Just make sure the bot is fully operational before you do this.

Use this token to access the HTTP API:
5xxx337:AAxxx3ApRGg
Keep your token secure and store it safely, it can be used by anyone to control your bot.

- 2.4 提取token
2.3中HTTP API 下面一行就是需要的token。

### 3、获取chat_id
- 3.1先测试一下
浏览器中输入：https://api.telegram.org/bot{token}/getUpdates 回车
其中：{token}为2.4中获取的token，包括大括号。
显示：{
“ok”: true,
“result”: []
}
如果显示error，说明有错误。

- 3.2 获取chat_id
- 3.2.1 在你生成的机器人中（本例为acmlubs_bot的机器人）随意输入一个词语，比如“Hello World”。如果获取群的，把（本例为acmlubs_bot的机器人）加入群，然后在群里发 hello @amclubs_bot 信息
- 3.2.2 重新在浏览器中输入https://api.telegram.org/bot{token}/getUpdates
其中：{token}为2.4中获取的token，包括大括号。
- 3.2.3 在显示的ok页中找到”chat”: {“id”: 1234567，”first_name”…….其中id后的数字即为需要的chat_id(如果是群的chat_id是负数来的)。

- 3.3 curl 测试一下获取到的taken和chat_id
在vps中输入命令

curl -s -X POST https://api.telegram.org/bot{token}/sendMessage -d chat_id={chatId} -d text="Hello World"
其中：{token}、{chatId}分别为获取的token和chatid，包括大括号。

- 3.4 成功与否
Telegrame客户端中的acmlubs_bot收到”Hello World”，就成功了！

  # 
 <center><details><summary><strong> [点击展开] 赞赏支持 ~🧧</strong></summary>
 *我非常感谢您的赞赏和支持，它们将极大地激励我继续创新，持续产生有价值的工作。*
  
 - **USDT-TRC20:** `TWTxUyay6QJN3K4fs4kvJTT8Zfa2mWTwDD`
  
 </details></center>

 #
 免责声明:
 - 1、该项目设计和开发仅供学习、研究和安全测试目的。请于下载后 24 小时内删除, 不得用作任何商业用途, 文字、数据及图片均有所属版权, 如转载须注明来源。
 - 2、使用本程序必循遵守部署服务器所在地区的法律、所在国家和用户所在国家的法律法规。对任何人或团体使用该项目时产生的任何后果由使用者承担。
 - 3、作者不对使用该项目可能引起的任何直接或间接损害负责。作者保留随时更新免责声明的权利，且不另行通知。
 
