--!nocheck
--!nolint

return {
	global = "debug.getupvalues",
	dependencies = {
		globals = {
			{ name = "loadstring", message = "Dependency 'loadstring' not found" },
		},
	},
	aliases = {
		"getupvalues",
	},
	cases = {
		{
			id = "opt0-compile",
			run = function(self)
				--// Functionality test
				local Up1, Up2, Up3, Up4, Up5, Up6, Up7, Up8, Up9, Up10 =
					time(), "Myriad", newproxy(), {}, game, newproxy(), Enum, warn, print, workspace

				coroutine.isyieldable(Up1, Up2, Up6) -- optimize 2 can make those locals cease to exist

				local opt0Function = loadstring(
					[[
		--!optimize 0
		local Up1, Up2, Up3, Up4, Up5, Up6, Up7, Up8, Up9, Up10 = ...
		local function originalFunction()
		    local _1, _2, _3, _4, _5, _6, _7, _8 = Up1, Up2, Up3, Up4, Up5, Up6, Up7, Up8
		    local function protoFunction()
		        local _9 = Up9
		    end

		    return function() end
		end

		return originalFunction
	]],
					"=MYRIAD-getupvalues"
				)(Up1, Up2, Up3, Up4, Up5, Up6, Up7, Up8, Up9, Up10, _G)

				if type(opt0Function) ~= "function" then
					return {
						status = 500,
						message = "[!optimize 0] - Failed to compile test function with loadstring",
					}
				end

				self._opt0 = opt0Function
				self._opt0Order = {
					Up1,
					Up2,
					Up3,
					Up4,
					Up5,
					Up6,
					Up7,
					Up8,
					Up9,
				}

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "opt0-table",
			run = function(self)
				if type(self._opt0) ~= "function" then
					return { status = 200, message = "Passed" }
				end

				local opt0upvalues = debug.getupvalues(self._opt0)
				if type(opt0upvalues) ~= "table" then
					return {
						status = 500,
						message = "[!optimize 0] - debug.getupvalues did not return a table",
					}
				end

				self._opt0Upvalues = opt0upvalues
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "opt0-expected",
			run = function(self)
				if type(self._opt0Upvalues) ~= "table" or type(self._opt0Order) ~= "table" then
					return { status = 200, message = "Passed" }
				end

				local opt0upvalues = self._opt0Upvalues
				local opt0upvaluesOrder = self._opt0Order
				local pFlag, pV = false, nil

				for i, v in ipairs(opt0upvaluesOrder) do
					if not table.find(opt0upvalues, v) then
						pFlag = true
						pV = v

						break
					end
				end

				if pFlag then
					return {
						status = 500,
						message = `[!optimize 0] - Expected upvalue was not found: {pV}`,
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "opt0-unexpected",
			run = function(self)
				if type(self._opt0Upvalues) ~= "table" or type(self._opt0Order) ~= "table" then
					return { status = 200, message = "Passed" }
				end

				local opt0upvalues = self._opt0Upvalues
				local opt0upvaluesOrder = self._opt0Order
				local p2Flag, p2I = false, 0

				for i, v in ipairs(opt0upvalues) do
					if not table.find(opt0upvaluesOrder, v) then
						p2Flag = true
						p2I = i

						break
					end
				end

				if p2Flag then
					return {
						status = 500,
						message = `[!optimize 0] - Unexpected upvalue at index {p2I}`,
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "opt0-count",
			run = function(self)
				if type(self._opt0Upvalues) ~= "table" or type(self._opt0Order) ~= "table" then
					return { status = 200, message = "Passed" }
				end

				local opt0upvalues = self._opt0Upvalues
				local opt0upvaluesOrder = self._opt0Order
				if #opt0upvalues ~= #opt0upvaluesOrder then
					return {
						status = 500,
						message = `[!optimize 0] - Upvalue count is not {#opt0upvaluesOrder}, it's {#opt0upvalues}`,
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "opt1-compile",
			run = function(self)
				local Up1, Up2, Up3, Up4, Up5, Up6, Up7, Up8, Up9, Up10 =
					time(), "Myriad", newproxy(), {}, game, newproxy(), Enum, warn, print, workspace

				coroutine.isyieldable(Up1, Up2, Up6) -- optimize 2 can make those locals cease to exist

				local opt1Function = loadstring(
					[[
		--!optimize 1
		local Up1, Up2, Up3, Up4, Up5, Up6, Up7, Up8, Up9, Up10 = ...
		local function originalFunction()
			local _8, _7, _6, _5, _4, _3, _2, _1 = Up8, Up7, Up6, Up5, Up4, Up3, Up2, Up1
			local function protoFunction()
				local _10 = Up10
			end

			return function() end
		end

		return originalFunction
	]],
					"=MYRIAD-getupvalues-opt1"
				)(Up1, Up2, Up3, Up4, Up5, Up6, Up7, Up8, Up9, Up10, _G)

				if type(opt1Function) ~= "function" then
					return {
						status = 500,
						message = "[!optimize 1] - Failed to compile test function with loadstring",
					}
				end

				self._opt1 = opt1Function
				self._opt1Order = {
					Up1,
					Up2,
					Up3,
					Up4,
					Up5,
					Up6,
					Up7,
					Up8,
					Up10,
				}

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "opt1-table",
			run = function(self)
				if type(self._opt1) ~= "function" then
					return { status = 200, message = "Passed" }
				end

				local opt1upvalues = debug.getupvalues(self._opt1)
				if type(opt1upvalues) ~= "table" then
					return {
						status = 500,
						message = "[!optimize 1] - debug.getupvalues did not return a table",
					}
				end

				self._opt1Upvalues = opt1upvalues
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "opt1-expected",
			run = function(self)
				if type(self._opt1Upvalues) ~= "table" or type(self._opt1Order) ~= "table" then
					return { status = 200, message = "Passed" }
				end

				local opt1upvalues = self._opt1Upvalues
				local opt1upvaluesOrder = self._opt1Order
				local pFlag, pV = false, nil

				for i, v in ipairs(opt1upvaluesOrder) do
					if not table.find(opt1upvalues, v) then
						pFlag = true
						pV = v

						break
					end
				end

				if pFlag then
					return {
						status = 500,
						message = `[!optimize 1] - Expected upvalue was not found: {pV}`,
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "opt1-unexpected",
			run = function(self)
				if type(self._opt1Upvalues) ~= "table" or type(self._opt1Order) ~= "table" then
					return { status = 200, message = "Passed" }
				end

				local opt1upvalues = self._opt1Upvalues
				local opt1upvaluesOrder = self._opt1Order
				local p2Flag, p2I = false, 0

				for i, v in ipairs(opt1upvalues) do
					if not table.find(opt1upvaluesOrder, v) then
						p2Flag = true
						p2I = i

						break
					end
				end

				if p2Flag then
					return {
						status = 500,
						message = `[!optimize 1] - Unexpected upvalue at index {p2I}`,
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "opt1-count",
			run = function(self)
				if type(self._opt1Upvalues) ~= "table" or type(self._opt1Order) ~= "table" then
					return { status = 200, message = "Passed" }
				end

				local opt1upvalues = self._opt1Upvalues
				local opt1upvaluesOrder = self._opt1Order
				if #opt1upvalues ~= #opt1upvaluesOrder then
					return {
						status = 500,
						message = `[!optimize 1] - Upvalue count is not {#opt1upvaluesOrder}, it's {#opt1upvalues}`,
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "empty",
			run = function(self)
				local function noUpvalues()
					return "MYRIAD_NO_UPVALUES"
				end

				local emptyValues = debug.getupvalues(noUpvalues)
				if type(emptyValues) ~= "table" or next(emptyValues) ~= nil then
					return {
						status = 500,
						message = "Function with no upvalues should return an empty table",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "cclosure",
			run = function(self)
				if pcall(debug.getupvalues, print) then
					return {
						status = 500,
						message = "Should error with C closures",
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
