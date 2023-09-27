local uci = require "luci.model.uci".cursor()
local http = require "luci.http"

module("luci.controller.usbmodem", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/usbmodem") then
		return
	end

	local page = entry({ "admin", "network", "usbmodem" }, alias("admin", "network", "usbmodem", "config"), _("USB Modem Server"), 60)
	page.dependent = true
	page.acl_depends = { "luci-app-usbmodem" }

	entry({ "admin", "network", "usbmodem", "config" }, cbi("usbmodem"), "配置", 80).leaf = true
	entry({ "admin", "network", "usbmodem", "status" }, template("usbmodem/status"), "状态", 81).leaf = true
	entry({ "admin", "network", "usbmodem", "sms" }, template("usbmodem/sms"), "短信", 82).leaf = true
	--entry({ "admin", "network", "usbmodem", "lock" }, template("usbmodem/lock"), "锁频", 83).leaf = true
	entry({ "admin", "network", "usbmodem", "at" }, template("usbmodem/at"), "AT", 84).leaf = true

	entry({ "admin", "network", "usbmodem", "read_sms" }, call("readSms"), nil).leaf = true
	entry({ "admin", "network", "usbmodem", "send_sms" }, call("sendSms"), nil).leaf = true
	entry({ "admin", "network", "usbmodem", "delete_sms" }, call("deleteSms"), nil).leaf = true

	entry({ "admin", "network", "usbmodem", "send_at" }, call("sendAt"), nil).leaf = true

	entry({ "admin", "network", "usbmodem", "modem_status" }, call("status"), nil).leaf = true
end

-- 删除短信
function deleteSms()
	local devv = tostring(uci:get("usbmodem", "@service[0]", "readport"))
	local s = http.formvalue("idx")
	for d in s:gmatch("%d+") do
		os.execute("sms_tool -d " .. devv .. " delete " .. d .. "")
	end
end

-- 读取短信
function readSms()
	local sim = { }
	local devv = tostring(uci:get("usbmodem", "@service[0]", "readport"))
	local smsmem = tostring(uci:get("usbmodem", "@service[0]", "storage"))
	local statusb = luci.util.exec("sms_tool -s" .. smsmem .. " -d ".. devv .. " status")
	local usex = string.sub (statusb, 23, 27)
	local max = statusb:match('[^: ]+$')
	sim["use"] = string.match(usex, '%d+')
	sim["count"] = string.match(usex, '%d+')
	sim["all"] = string.match(max, '%d+')
	luci.http.prepare_content("application/json")
	luci.http.write_json(sim)
end

-- 发送短信
function sendSms()
	local devv = tostring(uci:get("usbmodem", "@service[0]", "readport"))
	local phone = http.formvalue("phone")
	local msg = http.formvalue("msg")

	if phone and msg then
		local odpall = io.popen("sms_tool -d " .. devv .. " send " .. phone .." '".. msg .."'")
		local odp =  odpall:read("*a")
		odpall:close()
		luci.http.write(tostring(odp))
	else
		luci.http.write_json(http.formvalue())
	end
end

-- 发送指令
function sendAt()
	local devv = tostring(uci:get("usbmodem", "@service[0]", "readport"))
	local at_code = http.formvalue("code")
	if at_code then
		local odpall = io.popen("sms_tool -d " .. devv .. " at "  ..at_code:gsub("[$]", "\\\$"):gsub("\"", "\\\"").." 2>&1")
		local odp =  odpall:read("*a")
		odpall:close()
		http.write(tostring(odp))
	else
		http.write_json(http.formvalue())
	end
end

-- 获取状态
function status()
	if luci.sys.call("usbmodem.sh status") == 0 then
		leasefile="/tmp/usbmodem_status.log"
		local fd = io.open(leasefile, "r")
		if not fd then return end
		while true do
			local ln = fd:read("*l")
			if not ln then
				break
			end
			luci.http.write(ln)
			luci.http.write("|")
		end
		fd:close()
	else
		luci.http.write("")
	end

end
