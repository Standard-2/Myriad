--!nocheck
--!nolint

return {
	global = "setreadonly",
	cases = {
		{
			id = "frozen",
			run = function(self)
				local originalTable = table.freeze({
					MYRIAD = "MYRI",
				})

				local freezeSuccess, message = pcall(function()
					originalTable.MYRIAD = "MYRIAD"
				end)
				local writeSuccess, message = pcall(function()
					setreadonly(originalTable, false)
					originalTable.MYRIAD = "MYRIAD"
				end)
				local reFreezeSuccess, message = pcall(function()
					setreadonly(originalTable, true)
					originalTable.MYRIAD = "MYRIAD"
				end)

				self._freezeSuccess = freezeSuccess
				self._writeSuccess = writeSuccess
				self._reFreezeSuccess = reFreezeSuccess
				self._message = message
				self._ready = true

				if freezeSuccess then
					return {
						status = 500,
						message = "Frozen table writable (???): " .. message,
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "unwritable",
			run = function(self)
				if not self._ready then
					return { status = 200, message = `Passed` }
				end

				if not self._writeSuccess then
					return {
						status = 500,
						message = "Table unwritable after readonly was disabled: " .. self._message,
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "refreeze",
			run = function(self)
				if not self._ready then
					return { status = 200, message = `Passed` }
				end

				if self._reFreezeSuccess then
					return {
						status = 500,
						message = "Table writable after readonly was enabled: " .. self._message,
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
	},
}
