--[[
@apiDefine Response
@apiParam(response){string} Message 响应信息，接口请求success或failed返回相关信息
@apiParam(response){bool} Successful 是否成功。通过该字段可以判断请求是否到达.
--]]
--[[
@apiDefine Request
@apiParam(request){string} name  传感器标示
@apiParam(request){string} unit  单位
@apiParam(request){string} designation  传感器名称
--]]
--[[
@api {POST} http://hcwzq.cn/api/addnewsensor.json?uid=***&did=***  addnewsensor
@apiName addnewsensor
@apiGroup All
@apiVersion 1.0.1
@apiDescription 添加新传感器

@apiParam {string} uid 唯一用户ID，32位md5值
@apiParam {string} did 唯一设备ID，32位md5值
@apiParam {json} request 请求体，需要添加的传感器信息插入到请求体中  
@apiUse Request
@apiParam {json} response 响应数据
@apiUse Response


@apiParamExample Example:
POST http://hcwzq.cn/api/addnewsensor.json?uid=c81e728d9d4c2f636f067f89cc14862c&did=eccbc87e4b5ce2fe28308fd9f2a7baf3
{
    "name": "TestSensor",
    "unit" : "M",
    "designation":"测试传感器"
}

@apiSuccessExample {json} Success-Response:
HTTP/1.1 200 OK
{
"Message":"add sensor success",
"Successful":true
}

@apiErrorExample {json} Error-Response:
HTTP/1.1 200 OK  
{
    "Successful":false,
    "Message": "sensor alreadey exist"
}

--]]
local common = require "lua.comm.common"
local redis  = require "lua.db_redis.db_base"
local red    = redis:new()
-- 添加新传感器
-- curl '127.0.0.1/api/addnewsensor.json?uid=001&did=002' -d '{"name":"newsensor","designation":"test","unit": "kg"}'
-- {
--         "unit": "kg",
--         "name": "weight",
--         "createTime": "2016-9-12 00:00:00",
--         "designation": "体重"
-- }
ngx.req.read_body()
local args = ngx.req.get_uri_args()
local post_args = ngx.req.get_body_data()

local uid = args.uid
local did = args.did

if not uid or not did or not post_args then
	ngx.log(ngx.ERR, uid, did)
	ngx.log(ngx.ERR,"uid or did is nil")
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local post_data = common.json_decode(post_args)
if common.check_body_table(post_data, {name="", designation="", unit=""}) == false then
	ngx.log(ngx.ERR,"post body format error")
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local response = {}
response.Successful = true
response.Message    = "add sensor success"

local res, err = red:hget("uid:" .. uid, "did:" .. did)
if err then
	ngx.log(ngx.ERR, "redis hget data failed")
	ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE)
end

if res == nil then
	response.Successful = false
	response.Message    = "uid error or did error or not exist uid or did"
	ngx.say(common.json_encode(response))
	return
end

local red_data = common.json_decode(res)
for k, v in pairs(red_data["Sensor"]) do
	if post_data["name"] == v["name"] then
		response.Successful = false
		response.Message    = "sensor already exist"
		break
	end
end

if response.Successful then
	table.insert(red_data["Sensor"], post_data)
	red:hset("uid:" .. uid, "did:" .. did, common.json_encode(red_data))
end

ngx.say(common.json_encode(response))
