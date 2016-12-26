--[[
@apiDefine Response
@apiParam(response){string} Message 响应信息，接口请求success或failed返回相关信息
@apiParam(response){bool} Successful 是否成功。通过该字段可以判断请求是否到达.
--]]
--[[
@apiDefine Request
@apiParam(request){string} sensor 传感器标识
@apiParam(request){string} value 数据值，数据类型可以是int,string等
--]]
--[[
@api {POST} http://hcwzq.cn/api/uploadData.json?uid=***&did=*** uploadData
@apiName uploadData
@apiGroup All
@apiVersion 1.0.1
@apiDescription 上传指定设备的传感器数据

@apiParam {string} uid 唯一ID，32位md5值
@apiParam {string} did 唯一ID，32位md5值
@apiParam {json} request 请求体，需要上传的数据添加到请求体中  
@apiUse Request
@apiParam {json} response 响应数据
@apiUse Response


@apiParamExample Example:
POST http://hcwzq.cn/api/uploadData.json?uid=c81e728d9d4c2f636f067f89cc14862c&did=eccbc87e4b5ce2fe28308fd9f2a7baf3
[
    {
        "sensor": "weight",
        "value" : 59
    },
    {
        "sensor": "height",
        "value": "12"
    }
]

@apiSuccessExample {json} Success-Response:
HTTP/1.1 200 OK
{
"Message":"upload success",
"Successful":true
}

@apiErrorExample {json} Error-Response:
HTTP/1.1 200 OK  
{
    "Successful":false,
    "Message": "device id not exist or user not exist"
}

--]]
local comm  = require("lua.comm.common")
local redis = require("lua.db_redis.db_base")
local red   = redis:new()
local db_h  = require("lua.db_redis.db")
--ÉÏ´«Êý¾Ý
-- ½âÎöPOSTÇëÇó£¬¸ù¾ÝÇëÇóÊý¾Ý¶Ôredis½øÐÐ²Ù×÷
--ÇëÇóÑùÀý£ºcurl -i '127.0.0.1/api/uploadData.json?uid=1&did=3'

-- ÓÃ»§ÉÏ´«Êý¾Ý¸ñÊ½£º
-- URL£º  127.0.0.1/api/uploadData.json?uid=""&&did=
-- Êý¾Ý£º
--   [
--         {
--             "sensor": "weight",
--             "value": 78
--         },
--         {
--             "sensor": "heart",
--             "value": 78
--         }
--     ]
-- }

-- ·µ»ØÐÅÏ¢£º
-- {
--    "Successful": false,
--    "Message": "Invalid device ID"
-- }


-- curl -i '127.0.0.1/api/uploadData.json?uid=001&did=001' -d '[{"sensor": "weight","value": 78},{"sensor": "heart","value": 78}]'

local args = ngx.req.get_uri_args()

local uid = args.uid
local did = args.did

--uid ²ÎÊýµÄºÏ·¨ÐÔÐ£ÑéÔÚaccess½×¶Î´¦Àí£¬½Ó¿Ú²»ÁíÍâ½â¾ö
if not uid or not did then
	ngx.log(ngx.WARN,"bad request args uid,did:",uid,did)
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end

ngx.req.read_body()
local body = ngx.req.get_body_data()
if body == nil then
	ngx.log(ngx.WARN,"request body is nil")
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local post_args = comm.json_decode(body)
if comm.check_args(post_args,{}) == false then
	ngx.log(ngx.WARN, "error request body,probably is not a table")
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local response = {}

local res, err = red:hget("uid:" .. uid, "did:" .. did)
if err then
	ngx.log(ngx.WARN, "redis hget uid:"..uid.."error")
	ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE)
end

if res == nil then
   response.Successful = false
   response.Message = "device id not exist or user not exist"
   ngx.say(comm.json_encode(response))
   return
end

local data = comm.json_decode(res)
if db_h.check_data_sersor(data,post_args) == false then
   response.Successful = false
   response.Message = "post data exist error sensor name"
   ngx.say(comm.json_encode(response))
	return
end

--´¦ÀíuploadÊý¾Ý
for k, _ in pairs(post_args) do
    post_args[k]["timestamp"] = ngx.localtime()
    table.insert(data["data"], post_args[k])
    ngx.log(ngx.INFO, "deal with upload data")
end

local res, err = red:hset("uid:"..uid,"did:"..did,comm.json_encode(data))
if err then
  ngx.log(ngx.ERR, "redis hset failed.")
  ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE)
end
if res == 1 or res == 0 then
  response.Successful = true
  response.Message = "upload success"
end
ngx.log(ngx.WARN, "right request args uid :", uid)
ngx.say(comm.json_encode(response))

