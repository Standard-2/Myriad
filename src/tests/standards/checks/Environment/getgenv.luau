--!nocheck
--!nolint

return {
	global = "getgenv",
	cases = {
		{
			id = "getfenv",
			run = function(self)
				getfenv().MYRI = "Hello, World!"
				getgenv().MYRI1 = "Hello, World!"
				getgenv().MYRI2 = 123456789
				self._ready = true

				if getgenv().MYRI == "Hello, World!" then
					return {
						status = 500,
						message = "getfenv affected getgenv",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "myri1",
			run = function(self)
				if not self._ready then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if getgenv().MYRI1 ~= "Hello, World!" then
					return {
						status = 500,
						message = "MYRI1 not found or unexpected value",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "myri2",
			run = function(self)
				if not self._ready then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if getgenv().MYRI2 ~= 123456789 then
					return {
						status = 500,
						message = "MYRI2 not found or unexpected value",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "shared",
			run = function(self)
				local key = "n" .. string.gsub(tostring({}), "[^%w]", "")
				local caller = getfenv()
				local shared = getgenv()
				shared[key] = "spruce"

				local visible = caller[key]
				caller[key] = nil
				local keptCaller = caller[key]
				local keptShared = shared[key]
				shared[key] = nil
				local clearedCaller = caller[key]
				local clearedShared = shared[key]

				if visible ~= "spruce" then
					return {
						status = 500,
						message = "Shared value was not visible to the caller",
					}
				end

				if keptCaller ~= "spruce" or keptShared ~= "spruce" then
					return {
						status = 500,
						message = "Clearing the caller global cleared the shared value",
					}
				end

				if clearedCaller ~= nil or clearedShared ~= nil then
					return {
						status = 500,
						message = "Clearing the shared value left it visible",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "scope",
			run = function(self)
				local shared = getgenv()
				local owner = getfenv(getgenv)
				if owner == shared then
					return {
						status = 500,
						message = "getgenv environment is the table it returns",
					}
				end

				if owner ~= getfenv() then
					return {
						status = 500,
						message = "getgenv environment is not the caller environment",
					}
				end

				local key = "n" .. string.gsub(tostring({}), "[^%w]", "")
				getfenv(0)[key] = "drift"
				owner[key] = "drift"
				local leaked = shared[key] == "drift"
				getfenv(0)[key] = nil
				owner[key] = nil

				if leaked then
					return {
						status = 500,
						message = "Environment write was visible on getgenv",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
	},
}
