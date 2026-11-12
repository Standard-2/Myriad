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
	},
}
