--!nocheck
--!nolint

return {
	global = "getrawmetatable",
	cases = {
		{
			id = "__metatable",
			run = function(self)
				local tempTable = {}
				local tempUsedata = newproxy(true)

				local calledTableNamecall, calledUserdataNamecall = false, false
				local usedataMETA, newTableMETA

				newTableMETA = {
					__namecall = function()
						calledTableNamecall = true
					end,
					__metatable = {
						__index = function() end,
					},
				}

				setmetatable(tempTable, newTableMETA)
				pcall(setmetatable, tempUsedata, newTableMETA.__metatable)

				if pcall(table.clone, tempTable) then
					return {
						status = 500,
						message = "The table is not actually protected by __metatable",
					}
				end

				usedataMETA = getmetatable(tempUsedata)

				usedataMETA.__namecall = function()
					calledUserdataNamecall = true
				end

				usedataMETA.__metatable = newTableMETA.__metatable
				pcall(setmetatable, tempUsedata, usedataMETA.__metatable)

				self._tempTable = tempTable
				self._tempUsedata = tempUsedata
				self._newTableMETA = newTableMETA
				self._usedataMETA = usedataMETA
				self._calledTableNamecall = calledTableNamecall
				self._calledUserdataNamecall = calledUserdataNamecall
				self._ready = true
				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "namecall",
			run = function(self)
				if not self._ready then
					return { status = 200, message = `Passed` }
				end

				if self._calledTableNamecall or self._calledUserdataNamecall then
					return {
						status = 500,
						message = "The method is called so that it will surely return an error and the function will be obtained",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "table",
			run = function(self)
				if not self._ready then
					return { status = 200, message = `Passed` }
				end

				if getrawmetatable(self._tempTable) ~= self._newTableMETA then
					return {
						status = 500,
						message = "Returned a different metatable for table",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "newproxy",
			run = function(self)
				if not self._ready then
					return { status = 200, message = `Passed` }
				end

				if getrawmetatable(self._tempUsedata) ~= self._usedataMETA then
					return {
						status = 500,
						message = "Returned a different metatable for newproxy",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "__index",
			run = function(self)
				local rawGameMt = getrawmetatable(game)
				local __index

				xpcall(function()
					return game[{}]
				end, function()
					for StackLevel = 2, 10 do
						local func, name, line = debug.info(StackLevel, "fnl")
						if func and name == "" and line == -1 then
							for _ = 1, 5 do
								if not pcall(func, game, "Name") then
									return
								end
							end

							__index = func
							break
						end
					end
				end)

				self._rawGameMt = rawGameMt
				self._looked = true

				if not __index then
					return {
						status = 500,
						message = "Failed to get __index",
					}
				end

				self._index = __index
				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "result type",
			run = function(self)
				if not self._looked then
					return { status = 200, message = `Passed` }
				end

				if type(self._rawGameMt) ~= "table" then
					return {
						status = 500,
						message = "Didn't return a table",
					}
				end

				self._gameTable = true
				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "original __index",
			run = function(self)
				if not self._gameTable or not self._index then
					return { status = 200, message = `Passed` }
				end

				if self._rawGameMt.__index ~= self._index then
					return {
						status = 500,
						message = "The __index is not the original",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "game",
			run = function(self)
				if not self._gameTable then
					return { status = 200, message = `Passed` }
				end

				if self._rawGameMt ~= getrawmetatable(game) then
					return {
						status = 500,
						message = "Returned a different metatable for game",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "metamethods",
			run = function(self)
				if not self._gameTable then
					return { status = 200, message = `Passed` }
				end

				local rawGameMt = self._rawGameMt
				local methods = {
					__add = "add",
					__sub = "sub",
					__mul = "mul",
					__div = "div",
					__mod = "mod",
					__pow = "pow",
					__unm = "unm",
					__idiv = "idiv",
					__band = "band",
					__bor = "bor",
					__bxor = "bxor",
					__bnot = "bnot",
					__shl = "shl",
					__shr = "shr",
					__concat = "concat",
					__len = "len",
					__eq = "eq",
					__lt = "lt",
					__le = "le",
					__call = "call",
				}

				for method, name in pairs(methods) do
					if rawGameMt[method] then
						return {
							status = 500,
							message = `Found {name} metamethod in the raw meta table`,
						}
					end
				end

				return { status = 200, message = `Passed` }
			end,
		},
	},
}
