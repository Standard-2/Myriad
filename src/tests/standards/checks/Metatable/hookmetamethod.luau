--!nocheck
--!nolint

return {
	global = "hookmetamethod",
	cases = {
		{
			id = "table result",
			run = function(self)
				local tempTable = {}
				local originalTable__index = function()
					return 1
				end

				local tableMETA = {
					__index = originalTable__index,
				}

				setmetatable(tempTable, tableMETA)

				local tableHooked = false
				hookmetamethod(tempTable, "__index", function(...)
					tableHooked = true
					self._tableHooked = true
					return 2
				end)

				self._tempTable = tempTable
				self._tableMETA = tableMETA
				self._originalTable__index = originalTable__index
				self._tableHooked = tableHooked
				self._tableReady = true

				if tempTable.MYRIAD ~= 2 then
					return {
						status = 500,
						message = "No changes have been made to the results in a table",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "table hook",
			run = function(self)
				if not self._tableReady then
					return { status = 200, message = "Passed" }
				end

				if self._tableMETA.__index ~= self._originalTable__index then
					return {
						status = 500,
						message = "__index has been replaced instead of making a hook in a table",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "table metatable",
			run = function(self)
				if not self._tableReady then
					return { status = 200, message = "Passed" }
				end

				if getmetatable(self._tempTable) ~= self._tableMETA then
					return {
						status = 500,
						message = "The metatable was changed instead of doing the hook",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "table call",
			run = function(self)
				if not self._tableReady then
					return { status = 200, message = "Passed" }
				end

				if self._originalTable__index() ~= 2 or self._tableHooked ~= true then
					return {
						status = 500,
						message = "A strange action was performed. Was the __index function not hooked?",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "get __index",
			run = function(self)
				local RunService = game:GetService("RunService")

				local function getgame__index(Object)
					local __index

					xpcall(function()
						return game[{}]
					end, function()
						__index = debug.info(2, "f")
					end)

					return __index
				end

				self._RunService = RunService
				self._getgame__index = getgame__index

				local __index = getgame__index()
				if not __index then
					return {
						status = 500,
						message = "Failed to get __index",
					}
				end

				self._index = __index
				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "game hook",
			run = function(self)
				local __index = self._index
				local getgame__index = self._getgame__index
				local RunService = self._RunService
				if not __index or not getgame__index or not RunService then
					return { status = 200, message = "Passed" }
				end

				local state = { hooked = false }
				local originalCall
				originalCall = hookmetamethod(game, "__index", function(...)
					state.hooked = true
					return originalCall(...)
				end)
				self._state = state

				local _ = RunService.Heartbeat

				-- Making a C->L hook and leaving it there worsens performance
				task.delay(0.1, pcall, hookmetamethod, game, "__index", originalCall)

				if getgame__index() ~= __index then
					return {
						status = 500,
						message = "__index has been replaced instead of making a hook",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
		{
			id = "hooked",
			run = function(self)
				local state = self._state
				if not state then
					return { status = 200, message = "Passed" }
				end

				if not state.hooked then
					return {
						status = 500,
						message = "Failed to hook __index metamethod",
					}
				end

				return { status = 200, message = "Passed" }
			end,
		},
	},
}
