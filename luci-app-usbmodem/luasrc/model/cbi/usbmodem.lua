local dev1
local try_devices1 = nixio.fs.glob("/dev/tty[A-Z][A-Z]*")

mp = Map("usbmodem")
mp.title = translate("USB Modem Server")
mp.description = translate("Modem Server For OpenWrt")

s = mp:section(TypedSection, "service", "")
s.anonymous = true

s:tab("modem", translate("模组配置"))
s:tab("sms", translate("短信配置"))

enabled = s:taboption("modem", Flag, "enabled", translate("Enable"))
enabled.default = 0
enabled.rmempty = false

device = s:taboption("modem", Value, "device", translate("Modem device"))
device.rmempty = false

local device_suggestions = nixio.fs.glob("/dev/cdc-wdm*")

if device_suggestions then
	local node
	for node in device_suggestions do
		device:value(node)
	end
end

apn = s:taboption("modem", Value, "apn", translate("APN"))
apn.rmempty = true

pincode = s:taboption("modem", Value, "pincode", translate("PIN"))
pincode.rmempty = true

username = s:taboption("modem", Value, "username", translate("PAP/CHAP username"))
username.rmempty = true

password = s:taboption("modem", Value, "password", translate("PAP/CHAP password"))
password.rmempty = true

auth = s:taboption("modem", Value, "auth", translate("Authentication Type"))
auth.rmempty = true
auth:value("", translate("-- Please choose --"))
auth:value("both", "PAP/CHAP (both)")
auth:value("pap", "PAP")
auth:value("chap", "CHAP")
auth:value("none", "NONE")

tool = s:taboption("modem", Value, "tool", translate("Tools"))
tool:value("quectel-cm", "quectel-cm")
tool.rmempty = true


-- 短信配置
dev1 = s:taboption("sms", Value, "readport", translate("短信配置端口"))
if try_devices1 then
	local node
	for node in try_devices1 do
		dev1:value(node, node)
	end
end

mem = s:taboption("sms", ListValue, "storage", "短信存储位置", "消息存储在特定位置（例如，SIM卡或模组存储器上），但根据设备类型的不同，也可以使用其他区域。")
mem.default = "SM"
mem:value("SM", "SIM卡")
mem:value("ME", "模组")
mem.rmempty = true

return mp
