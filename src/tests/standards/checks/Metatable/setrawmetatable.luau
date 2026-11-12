--!nocheck
--!nolint

return {
	global = "setrawmetatable",
	dependencies = {
		checks = {
			{ id = "Metatable.getrawmetatable", message = "Dependency 'getrawmetatable' dosen't work properly." },
		},
	},
	cases = {
		{
			id = "metatable identity",
			run = function(self)
				local sillyString = "Netflix CE on top!"
				local randomString = ""

				for _ = 1, 32 do
					randomString ..= string.char(math.random(1, 255))
				end

				local originalStringMETA = getrawmetatable(randomString)
				local toSetMETA = table.clone(originalStringMETA)

				toSetMETA.__type = "MYRIAD"
				toSetMETA.__call = function(self)
					if self == randomString then
						return sillyString
					end
				end

				local success, returnedObject = pcall(setrawmetatable, randomString, toSetMETA)

				if not success then
					return {
						status = 500,
						message = `Unable to change the metatable of a string: {returnedObject}`,
					}
				elseif getrawmetatable(randomString) ~= toSetMETA then
					return {
						status = 500,
						message = "The meta table did not change to the new one",
					}
				end

				self._randomString = randomString
				self._originalStringMETA = originalStringMETA
				self._sillyString = sillyString
				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "__type",
			run = function(self)
				local randomString = self._randomString
				local originalStringMETA = self._originalStringMETA
				if not randomString or not originalStringMETA then
					return { status = 200, message = "Passed" }
				end

				if typeof(randomString) ~= "MYRIAD" then
					-- It is important to change this because it is impossible for setmetatable
					pcall(setrawmetatable, randomString, originalStringMETA)
					self._randomString = nil
					self._originalStringMETA = nil
					return {
						status = 500,
						message = "The __type parameter could not be set in the string",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "__call",
			run = function(self)
				local randomString = self._randomString
				local originalStringMETA = self._originalStringMETA
				local sillyString = self._sillyString
				if not randomString or not originalStringMETA then
					return { status = 200, message = "Passed" }
				end

				local success, result = pcall(randomString)
				pcall(setrawmetatable, randomString, originalStringMETA)

				if not success then
					return {
						status = 500,
						message = "failed to set __call",
					}
				elseif result ~= sillyString then
					return {
						status = 500,
						message = `failed to set __call: {result} ~= {sillyString}`,
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
	},
}
