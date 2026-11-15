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
	},
}
