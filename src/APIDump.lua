local f = string.format

local HTTP = game:GetService("HttpService")

return {
	GetLatest = function()
		local STUDIO_VERSION = HTTP:GetAsync("https://rprxy.deta.dev/setup/versionQTStudio")
		local API_RAW = HTTP:GetAsync(f("https://rprxy.deta.dev/setup/%s-API-Dump.json", STUDIO_VERSION))
		local API_DATA = HTTP:JSONDecode(API_RAW)
		
		return API_DATA
	end,
}