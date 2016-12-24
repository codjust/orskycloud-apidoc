define({ "api": [
  {
    "type": "POST",
    "url": "http://hcwzq.cn/api/getDeviceData.json?uid=*&did=*[&StartTime=*][&EndTime=*]",
    "title": "getDeviceData",
    "name": "getDeviceData",
    "group": "All",
    "version": "1.0.1",
    "description": "<p>获取指定设备的全部传感器数据</p>",
    "parameter": {
      "fields": {
        "Parameter": [
          {
            "group": "Parameter",
            "type": "string",
            "optional": false,
            "field": "uid",
            "description": "<p>唯一ID值，32位md5</p>"
          },
          {
            "group": "Parameter",
            "type": "string",
            "optional": false,
            "field": "did",
            "description": "<p>唯一设备ID值，32位md5</p>"
          },
          {
            "group": "Parameter",
            "type": "string",
            "optional": true,
            "field": "StartTime",
            "description": "<p>选择数据区间，开始时间，默认：2015-09-01 00:00:00，格式：2015-09-01 00:00:00</p>"
          },
          {
            "group": "Parameter",
            "type": "string",
            "optional": true,
            "field": "EndTime",
            "description": "<p>选择数据区间，结束时间，默认：当前时间，格式：2015-09-01 00:00:00</p>"
          },
          {
            "group": "Parameter",
            "type": "json",
            "optional": false,
            "field": "response",
            "description": "<p>响应数据</p>"
          }
        ],
        "response": [
          {
            "group": "response",
            "type": "string",
            "optional": false,
            "field": "Message",
            "description": "<p>响应信息，接口请求success或failed返回相关信息</p>"
          },
          {
            "group": "response",
            "type": "bool",
            "optional": false,
            "field": "Successful",
            "description": "<p>是否成功。通过该字段可以判断请求是否到达.</p>"
          }
        ]
      },
      "examples": [
        {
          "title": "Example:",
          "content": "POST http://hcwzq.cn/api/getDeviceData.json?uid=c81e728d9d4c2f636f067f89cc14862c&did=eccbc87e4b5ce2fe28308fd9f2a7baf3&StartTime=2016-09-01 00:00:00&EndTime=2016-10-01 00:00:00",
          "type": "json"
        }
      ]
    },
    "success": {
      "examples": [
        {
          "title": "Success-Response:",
          "content": "HTTP/1.1 200 OK\n{\n\"1\":[{\n\t\"timestamp\":\"2016-10-20 14:50:30\",\n\t\"sensor\":\"weight\",\n\t\"value\":56\n}],\n\"Message\":\"success\",\n\"Successful\":true\n}",
          "type": "json"
        }
      ]
    },
    "error": {
      "examples": [
        {
          "title": "Error-Response:",
          "content": "HTTP/1.1 200 OK  \n{\n    \"Successful\":false,\n    \"Message\": \"uid error or did error or not exist\"\n}",
          "type": "json"
        }
      ]
    },
    "filename": "api/getDeviceData.lua",
    "groupTitle": "All"
  }
] });
