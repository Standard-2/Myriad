--!nocheck
--!nolint

return {
	global = "isreadonly",
	cases = {
		{
			id = "writable",
			run = function(self)
				--// Functionality test
				local originalTable = {}

				if isreadonly(originalTable) then
					return {
						status = 500,
						message = "Writable table is assumed read-only",
					}
				end

				self._table = originalTable
				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "frozen",
			run = function(self)
				local originalTable = self._table
				if not originalTable then
					return { status = 200, message = `Passed` }
				end

				table.freeze(originalTable)

				if not isreadonly(originalTable) then
					return {
						status = 500,
						message = "Table assumed writable after being set as read-only",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
	},
}
