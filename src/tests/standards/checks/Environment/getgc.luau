--!nocheck
--!nolint

return {
	global = "getgc",
	cases = {
		{
			id = "function",
			run = function(self)
				local originalTable = {}
				local function originalFunction() end
				task.wait(0.1)

				local check1
				local check2
				for _, value in pairs(getgc(true)) do
					if value == originalFunction then
						check1 = true
					elseif value == originalTable then
						check2 = true
					end
				end

				self._foundTable = check2 == true
				self._scanned = true

				if not check1 then
					return {
						status = 500,
						message = "Original function not found",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "table",
			run = function(self)
				if not self._scanned then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if not self._foundTable then
					return {
						status = 500,
						message = "Original table not found",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "default",
			run = function(self)
				local bag = {}
				local function live() end

				task.wait(0.1)

				local sawFunction = false
				local sawTable = false
				for _, value in pairs(getgc()) do
					if value == live then
						sawFunction = true
					elseif value == bag then
						sawTable = true
					end
				end

				if not sawFunction then
					return {
						status = 500,
						message = "Original function not found",
					}
				end

				if sawTable then
					return {
						status = 500,
						message = "Table was included when includeTables was omitted",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "false",
			run = function(self)
				local bag = {}
				local function live() end

				task.wait(0.1)

				local sawFunction = false
				local sawTable = false
				for _, value in pairs(getgc(false)) do
					if value == live then
						sawFunction = true
					elseif value == bag then
						sawTable = true
					end
				end

				if not sawFunction then
					return {
						status = 500,
						message = "Original function not found",
					}
				end

				if sawTable then
					return {
						status = 500,
						message = "Table was included when includeTables was false",
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
