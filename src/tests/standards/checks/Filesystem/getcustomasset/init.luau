--!nocheck
--!nolint

local assets = require("@self/assets.luau")

return {
	global = "getcustomasset",
	dependencies = {
		checks = {
			"Filesystem.writefile",
			"Filesystem.isfile",
			"Filesystem.delfile",
		},
	},
	cases = {
		{
			id = "write",
			run = function(self)
				self._files = {}
				local HttpService = game:GetService("HttpService")
				for _, assetObj in ipairs(assets) do
					local guid = HttpService:GenerateGUID(false):gsub("-", "")
					local filename = guid .. "." .. assetObj.ext
					local entry = {
						filename = filename,
						assetObj = assetObj,
					}
					table.insert(self._files, entry)
					local writeSuccess, writeError = pcall(function()
						writefile(filename, assetObj.data)
					end)
					if not writeSuccess then
						return {
							status = 0,
							message = `Failed to write setup file for getcustomasset ({assetObj.ext}): {writeError}`,
						}
					end
					entry.wrote = true
				end
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "isfile",
			run = function(self)
				if type(self._files) ~= "table" then
					return {
						status = 200,
						message = "Passed",
					}
				end
				for _, entry in ipairs(self._files) do
					if entry.wrote then
						local assetObj = entry.assetObj
						if not isfile(entry.filename) then
							return {
								status = 0,
								message = `Writefile failed silently for {assetObj.ext} (file does not exist)`,
							}
						end
						entry.exists = true
					end
				end
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "getcustomasset throw",
			run = function(self)
				if type(self._files) ~= "table" then
					return {
						status = 200,
						message = "Passed",
					}
				end
				for _, entry in ipairs(self._files) do
					if entry.exists then
						local assetObj = entry.assetObj
						task.wait(0.05)
						local success, assetUrl = pcall(function()
							return getcustomasset(entry.filename)
						end)
						if not success then
							return {
								status = 500,
								message = `getcustomasset threw an error for {assetObj.ext}: {assetUrl}`,
							}
						end
						entry.assetUrl = assetUrl
						entry.loaded = true
					end
				end
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "url type",
			run = function(self)
				if type(self._files) ~= "table" then
					return {
						status = 200,
						message = "Passed",
					}
				end
				for _, entry in ipairs(self._files) do
					if entry.loaded then
						local assetObj = entry.assetObj
						local assetUrl = entry.assetUrl
						if type(assetUrl) ~= "string" then
							return {
								status = 500,
								message = `Asset URL for {assetObj.ext} is not of type string, got {type(assetUrl)}`,
							}
						end
						entry.typed = true
					end
				end
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "short url",
			run = function(self)
				if type(self._files) ~= "table" then
					return {
						status = 200,
						message = "Passed",
					}
				end
				for _, entry in ipairs(self._files) do
					if entry.typed then
						local assetObj = entry.assetObj
						local assetUrl = entry.assetUrl
						if #assetUrl < 5 then
							return {
								status = 500,
								message = `Asset string for {assetObj.ext} is unrealistically short`,
							}
						end
						entry.urlOk = true
					end
				end
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "font",
			run = function(self)
				if type(self._files) ~= "table" then
					return {
						status = 200,
						message = "Passed",
					}
				end
				for _, entry in ipairs(self._files) do
					if entry.urlOk then
						local assetObj = entry.assetObj
						local assetUrl = entry.assetUrl
						local instance
						if assetObj.type == "Font" then
							instance = Instance.new("TextLabel")
							local fontSuccess = pcall(function()
								instance.FontFace = Font.new(assetUrl)
							end)
							if not fontSuccess then
								return {
									status = 500,
									message = `Failed to create Font object for {assetObj.ext} with URL: {assetUrl}`,
								}
							end
						else
							instance = Instance.new(assetObj.type)
							instance[assetObj.prop] = assetUrl
						end
						entry.instance = instance
					end
				end
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "preload",
			run = function(self)
				if type(self._files) ~= "table" then
					return {
						status = 200,
						message = "Passed",
					}
				end
				local ContentProvider = game:GetService("ContentProvider")
				for _, entry in ipairs(self._files) do
					if entry.instance then
						local assetObj = entry.assetObj
						local instance = entry.instance
						local preloadSuccess, preloadErr = pcall(function()
							ContentProvider:PreloadAsync({ instance })
						end)
						if not preloadSuccess then
							return {
								status = 500,
								message = `ContentProvider failed to preload {assetObj.ext}: {preloadErr}`,
							}
						end
					end
				end
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
		{
			id = "delete",
			run = function(self)
				if type(self._files) ~= "table" then
					return {
						status = 200,
						message = "Passed",
					}
				end
				for _, entry in ipairs(self._files) do
					if entry.filename then
						pcall(function()
							delfile(entry.filename)
						end)
					end
				end
				return {
					status = 200,
					message = "Passed",
				}
			end,
		},
	},
}
