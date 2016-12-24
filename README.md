#orskycloud-apidoc


Contents
=========
* [Description](#description)
* [Install apidoc tool](#install-apidoc-tool)
* [Edit orskycloud API document](#edit-orskycloud-api-document)

Description
=========
使用apidoc工具为orskycloud编写自动化API文档。<br>
[Back to TOC](#contents)

Install apidoc tool
========
(1)安装npm包管理工具
```shell
    sudo apt-get install npm
```
(2)安装nodejs
```shell
    sudo apt-get install nodejs
```
如果终端输入:node -v会输出版本号则说明安装成功。<br>
(3)安装apidoc工具
官网：[http://apidocjs.com](http://apidocjs.com)
```shell
    npm install apidoc -g
```
一般默认会安装在：/usr/local/lib/node_modules/apidoc 目录下。<br>
(4)测试apidoc
```shell
    cd /usr/local/lib/node_modules/apidoc
    apidoc -i explame -o doc
```
查看doc目录，里面会生成静态的html文件，直接浏览器打开即可。<br>
[Back to TOC](#contents)


Edit orskycloud API document
=======
(1)准备好lua文件和json配置文件
```shell
    mkdir orskycloud-apidoc
    cd orskycloud-apidoc
    mkdir api doc
    touch apidoc.json
```
apidoc.json:
```json
     {                                                                                                                                          
    "name":"orskycloud API",                                                                                                               
    "version":"1.0.0",                                                                                                 
    "title":"ORSkyCloud API Document",
    "description":"ORSkyCloud开发者指南"
    }                                                                                                                                          
```

api/test.lua
```lua
--[[
@apiDefine Response
@apiParam(response){string} Message 响应信息，接口请求success或failed返回相关信息
@apiParam(response){bool} Successful 是否成功。通过该字段可以判断请求是否到达.
--]]
--[[
@api {POST} http://hcwzq.cn/api/getalldevicesensor.json?uid=* getalldevicesensor
@apiName getalldevicesensor
@apiGroup All
@apiVersion 1.0.1
@apiDescription 获取用户所有设备和传感器信息

@apiParam {string} uid 唯一ID，32位md5值
@apiParam {json} response 响应数据
@apiUse Response


@apiParamExample Example:
POST http://hcwzq.cn/api/getalldevicesensor.json?uid=c81e728d9d4c2f636f067f89cc14862c

@apiSuccessExample {json} Success-Response:
HTTP/1.1 200 OK
{"1":[{
    "createTime":"2016-12-19 23:07:12",
    "deviceName":"Test1",
    "description":"description1",
    "Sensor":[{
        "createTime":"2016-9-12 00:00:00",
        "unit":"kg",
        "name":"weight",
        "designation":"体重"}]
}],
"Message":"success",
"Successful":true
}

@apiErrorExample {json} Error-Response:
HTTP/1.1 200 OK  
{
        "Successful":false,
        "Message": "Device not create yet"
}

--]]
```
注意：lua的注释要用--[[ --]]<br>
[Back to TOC](#contents)


效果图
-------
![alt text](https://github.com/huchangwei/orskycloud-apidoc/blob/master/image/doc1.png)
![alt text](https://github.com/huchangwei/orskycloud-apidoc/blob/master/image/doc2.png)

[Back to TOC](#contents)

