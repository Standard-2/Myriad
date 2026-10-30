--!nocheck

local UserInputService = game:GetService("UserInputService")

local NAMES = {
	Windows = "windows",
	UWP = "uwp",
	Android = "android",
	IOS = "ios",
	OSX = "macos",
	XBoxOne = "console",
	PS3 = "console",
	PS4 = "console",
	PS5 = "console",
}

return function()
	local ok, value = pcall(function()
		return UserInputService:GetPlatform()
	end)
	if not ok or value == nil then
		return "unknown"
	end

	local name = string.gsub(tostring(value), "^Enum%.Platform%.", "")
	return NAMES[name] or "unknown"
end
