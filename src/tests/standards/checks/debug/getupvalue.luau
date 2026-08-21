--!nocheck
--!nolint

return function()
	if not debug or not debug.getupvalue then
		return {
			status = 400,
			message = "Global not found",
		}
	elseif not loadstring then
		return {
			status = 401,
			message = "Dependency 'loadstring' not found",
		}
	end

	--// Functionality test
	local pFlag, pI, pV = false, 0, nil
	local p2Flag, p2I = false, 0
	local p3Flag, p3I = false, 0

	local Up1, Up2, Up3, Up4, Up5, Up6, Up7, Up8, Up9, Up10 =
		time(), "Myriad", newproxy(), {}, game, newproxy(), Enum, warn, print, workspace

	coroutine.isyieldable(Up1, Up2, Up6) -- optimize 2 can make those locals cease to exist

	local opt0Function = loadstring([[
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
	]], "=MYRIAD-getupvalue")(Up1, Up2, Up3, Up4, Up5, Up6, Up7, Up8, Up9, Up10, _G)

	if type(opt0Function) ~= "function" then
		return {
			status = 500,
			message = "[!optimize 0] - Failed to compile test function with loadstring",
		}
	end

	local opt0upvaluesOrder = {
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

	local opt0upvalues = {}
	local index = 1

	while true do
		local Success, Value = pcall(debug.getupvalue, opt0Function, index)
		if not Success then
			break
		end

		opt0upvalues[index] = Value
		index += 1
	end

	for i, v in ipairs(opt0upvaluesOrder) do
		if not table.find(opt0upvalues, v) then
			pFlag = true
			pI, pV = i, v

			break
		end
	end

	for i, v in ipairs(opt0upvalues) do
		if not table.find(opt0upvaluesOrder, v) then
			p2Flag = true
			p2I = i

			break
		end
	end

	if pFlag then
		return {
			status = 500,
			message = `[!optimize 0] - Expected upvalue was not found: {pV}`,
		}
	elseif p2Flag then
		return {
			status = 500,
			message = `[!optimize 0] - Unexpected upvalue at index {p2I}`,
		}
	elseif #opt0upvalues ~= #opt0upvaluesOrder then
		return {
			status = 500,
			message = `[!optimize 0] - Upvalue count is not {#opt0upvaluesOrder}, it's {#opt0upvalues}`,
		}
	elseif pcall(debug.getupvalue, opt0Function, index) then
		return {
			status = 500,
			message = `[!optimize 0] - Index {index} should return an error, it doesn't exist.`,
		}
	end

	pFlag, pI, pV = false, 0, nil
	p2Flag, p2I = false, 0
	p3Flag, p3I = false, 0

	local opt1Function = loadstring([[
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
	]], "=MYRIAD-getupvalue-opt1")(Up1, Up2, Up3, Up4, Up5, Up6, Up7, Up8, Up9, Up10, _G)

	if type(opt1Function) ~= "function" then
		return {
			status = 500,
			message = "[!optimize 1] - Failed to compile test function with loadstring",
		}
	end

	local opt1upvaluesOrder = {
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

	local opt1upvalues = {}
	index = 1

	while true do
		local Success, Value = pcall(debug.getupvalue, opt1Function, index)
		if not Success then
			break
		end

		opt1upvalues[index] = Value
		index += 1
	end

	for i, v in ipairs(opt1upvaluesOrder) do
		if not table.find(opt1upvalues, v) then
			pFlag = true
			pI, pV = i, v

			break
		end
	end

	for i, v in ipairs(opt1upvalues) do
		if not table.find(opt1upvaluesOrder, v) then
			p2Flag = true
			p2I = i

			break
		end
	end

	if pFlag then
		return {
			status = 500,
			message = `[!optimize 1] - Expected upvalue was not found: {pV}`,
		}
	elseif p2Flag then
		return {
			status = 500,
			message = `[!optimize 1] - Unexpected upvalue at index {p2I}`,
		}
	elseif #opt1upvalues ~= #opt1upvaluesOrder then
		return {
			status = 500,
			message = `[!optimize 1] - Upvalue count is not {#opt1upvaluesOrder}, it's {#opt1upvalues}`,
		}
	elseif pcall(debug.getupvalue, opt1Function, index) then
		return {
			status = 500,
			message = `[!optimize 1] - Index {index} should return an error, it doesn't exist.`,
		}
	elseif pcall(debug.getupvalue, opt1Function, 0) then
		return {
			status = 500,
			message = "Should error when retrieving invalid upvalue indexes",
		}
	elseif pcall(debug.getupvalue, print, 1) then
		return {
			status = 500,
			message = "Should error with C closures",
		}
	end

	--// Alias test
	local envIndex, failedIndex = require("@dependencies/aliasTest.luau")({
		"getupvalue",
	})

	if not envIndex then
		return {
			status = 501,
			message = `Alias not found: {failedIndex}`,
		}
	end

	return {
		status = 200,
		message = `Passed`,
	}
end
