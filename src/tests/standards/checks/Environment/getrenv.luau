--!nocheck
--!nolint

return {
	global = "getrenv",
	cases = {
		{
			id = "myrird1",
			run = function(self)
				getrenv().MYRIR1 = "Hello, World!"
				getrenv().MYRIR2 = 123456789
				self._ready = true

				if getrenv().MYRIR1 ~= "Hello, World!" then
					return {
						status = 500,
						message = "MYRIR1 not found or unexpected value",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "myrird2",
			run = function(self)
				if not self._ready then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if getrenv().MYRIR2 ~= 123456789 then
					return {
						status = 500,
						message = "MYRIR2 not found or unexpected value",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "game",
			run = function(self)
				if getrenv().game ~= game then
					return {
						status = 500,
						message = "game not found or unexpected value",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "print",
			run = function(self)
				if getrenv().print ~= print then
					return {
						status = 500,
						message = "print not found or unexpected value",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "g",
			run = function(self)
				if getrenv()._G == _G then
					return {
						status = 500,
						message = "_G in roblox environment shouldn't match the executor's",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "write",
			run = function(self)
				local previous = warn
				local ok, err = pcall(function()
					getrenv().warn = "cedar-mark"
				end)
				local seen = warn
				getrenv().warn = previous

				if not ok then
					return {
						status = 0,
						message = tostring(err),
					}
				end

				if seen ~= "cedar-mark" then
					return {
						status = 500,
						message = "Assigning getrenv().warn did not change warn",
					}
				end

				if warn ~= previous then
					return {
						status = 500,
						message = "warn was not restored",
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
