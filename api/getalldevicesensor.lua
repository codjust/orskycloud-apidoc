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


-- 获取用户所有设备和传感器信息,没有返回提示信息

-- curl '127.0.0.1/api/getalldevicesensor.json?uid=001'
local common = require "lua.comm.common"
local redis  = require "lua.db_redis.db_base"
local red    = redis:new()

local args = ngx.req.get_uri_args()
local uid  = args.uid
if not uid then
	ngx.log(ngx.ERR,"request uid is nil")
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local response = {}
response.Successful = true
response.Message    = "success"

local uid_list, err = red:get("UserList")
if err then
	ngx.log(ngx.ERR, "redis get failed.")
	ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE)
end
local tb_uid = common.split(uid_list, "#")
local id_t
for _, id in pairs(tb_uid) do
	if id == uid then
		id_t = id
		break
	end
end
if id_t ~= uid then
	ngx.log(ngx.ERR, "error uid or uid not exist.", id_t)
	response.Successful = false
	response.Message    = "error uid or uid not exist."
	ngx.say(common.json_encode(response))
	return
end

local device_list, err = red:hget("uid:" .. uid, "device")
if err then
	ngx.log(ngx.ERR, "redis hget error")
	ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE)
end

if not device_list then
	ngx.log(ngx.ERR, "Device list is nil")
	response.Successful = false
	response.Message    = "Device not create yet"
	ngx.say(common.json_encode(response))
	return
end

local dev_list = common.split(device_list, "#")
local ret_info = {}
for _, v in ipairs(dev_list) do
	local dev_t, err = red:hget("uid:" .. uid, "did:" .. v)
	if err then
		ngx.log(ngx.ERR, "redis hget error")
		ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE)
	end
	local dev_temp = common.json_decode(dev_t)
	dev_temp["data"] = nil
	table.insert(ret_info, dev_temp)
end

table.insert(response, ret_info)
ngx.say(common.json_encode(response))




