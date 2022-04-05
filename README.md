> 提醒： 濫用可能導致賬戶被BAN！！！   
  
* 使用[xray](https://github.com/XTLS/Xray-core)+caddy同時部署通過ws傳輸的vmess vless trojan shadowsocks socks等協議  
* 支持tor網絡，且可通過自定義網絡配置文件啓動xray和caddy來按需配置各種功能  
* 支持存儲自定義文件,目錄及賬號密碼均爲AUUID,客戶端務必使用TLS連接  
  
[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://dashboard.heroku.com/new?template=https://github.com/castelenl/agoku)  
  
### 服務端
點擊上面紫色`Deploy to Heroku`，會跳轉到heroku app創建頁面，填上app的名字、選擇節點、按需修改部分參數和AUUID後點擊下面deploy創建app即可開始部署  
如出現錯誤，可以多嘗試幾次，待部署完成後頁面底部會顯示Your app was successfully deployed  
  * 點擊Manage App可在Settings下的Config Vars項**查看和重新設置參數**  
  * 點擊Open app跳轉[歡迎頁面](/etc/CADDYIndexPage.md)域名即爲heroku分配域名，格式爲`appname.herokuapp.com`，用於客戶端  
  * 默認協議密碼爲$UUID，WS路徑爲$UUID-[vmess|vless|trojan|ss|socks]格式
  
### 客戶端
* **務必替換所有的appname.herokuapp.com爲heroku分配的項目域名**  
* **務必替換所有的8f91b6a0-e8ee-11ea-adc1-0242ac120002爲部署時設置的AUUID**  
  
<details>
<summary>xray</summary>

```bash
* 客戶端下載：https://github.com/XTLS/Xray-core/releases
* 代理協議：vless 或 vmess
* 地址：appname.herokuapp.com
* 端口：443
* 默認UUID：8f91b6a0-e8ee-11ea-adc1-0242ac120002
* 加密：none
* 傳輸協議：ws
* 僞裝類型：none
* 路徑：/8f91b6a0-e8ee-11ea-adc1-0242ac120002-vless // 默認vless使用/$uuid-vless，vmess使用/$uuid-vmess
* 底層傳輸安全：tls
```
</details>
  
<details>
<summary>trojan-go</summary>

```bash
* 客戶端下載: https://github.com/p4gefau1t/trojan-go/releases
{
    "run_type": "client",
    "local_addr": "127.0.0.1",
    "local_port": 1080,
    "remote_addr": "appname.herokuapp.com",
    "remote_port": 443,
    "password": [
        "8f91b6a0-e8ee-11ea-adc1-0242ac120002"
    ],
    "websocket": {
        "enabled": true,
        "path": "/8f91b6a0-e8ee-11ea-adc1-0242ac120002-trojan",
        "host": "appname.herokuapp.com"
    }
}
```
</details>
  
<details>
<summary>shadowsocks</summary>

```bash
* 客戶端下載：https://github.com/shadowsocks/shadowsocks-windows/releases/
* 服務器地址: appname.herokuapp.com
* 端口: 443
* 密碼：password
* 加密：chacha20-ietf-poly1305
* 插件程序：xray-plugin_windows_amd64.exe  //需將插件https://github.com/shadowsocks/xray-plugin/releases下載解壓後放至shadowsocks同目錄
* 插件選項: tls;host=appname.herokuapp.com;path=/8f91b6a0-e8ee-11ea-adc1-0242ac120002-ss
```
</details>
  
<details>
<summary>cloudflare workers example</summary>

```js
const SingleDay = 'appname.herokuapp.com'
const DoubleDay = 'appname.herokuapp.com'
addEventListener(
    "fetch",event => {
    
        let nd = new Date();
        if (nd.getDate()%2) {
            host = SingleDay
        } else {
            host = DoubleDay
        }
        
        let url=new URL(event.request.url);
        url.hostname=host;
        let request=new Request(url,event.request);
        event. respondWith(
            fetch(request)
        )
    }
)
```
</details>
  
> [更多來自熱心網友PR的使用教程](/tutorial)
