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
		time(), "Myriad", newproxy(), {}, game, nil, Enum, warn, print, workspace

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
		[1] = Up1,
		[2] = Up2,
		[3] = Up3,
		[4] = Up4,
		[5] = Up5,
		[6] = Up6,
		[7] = Up7,
		[8] = Up8,
		[9] = Up9,
	}

	for i = 1, 11 do
		local Success, Value = pcall(debug.getupvalue, opt0Function, i)
		if not Success and i < 10 then
			p2Flag = true
			p2I = i

			break
		elseif Success and i >= 10 then
			p3Flag = true
			p3I = i

			break
		elseif Success and Value ~= opt0upvaluesOrder[i] then
			pFlag = true
			pI, pV = i, Value

			break
		end
	end

	if pFlag then
		return {
			status = 500,
			message = `[!optimize 0] - Upvalue at {pI} should be: {opt0upvaluesOrder[pI]}. Got: {pV}`,
		}
	elseif p2Flag then
		return {
			status = 500,
			message = `[!optimize 0] - Index {p2I} should not return an error because it exists.`,
		}
	elseif p3Flag then
		return {
			status = 500,
			message = `[!optimize 0] - Index {p3I} should return an error, it doesn't exist.`,
		}
	end

	pFlag, pI, pV = false, 0, nil
	p2Flag, p2I = false, 0
	p3Flag, p3I = false, 0

	local function opt1Function()
		local _8, _7, _6, _5, _4, _3, _2, _1 = Up8, Up7, Up6, Up5, Up4, Up3, Up2, Up1
		local function protoFunction()
			local _10 = Up10
		end

		return function() end
	end

	local opt1upvaluesOrder = {
		[1] = Up8,
		[2] = Up7,
		[3] = Up5,
		[4] = Up4,
		[5] = Up3,
		[6] = Up1,
		[7] = Up10,
		[8] = Up6,
		[9] = Up2,
	}

	for i = 1, 11 do
		local Success, Value = pcall(debug.getupvalue, opt1Function, i)
		if not Success and i < 10 then
			p2Flag = true
			p2I = i

			break
		elseif Success and i >= 10 then
			p3Flag = true
			p3I = i

			break
		elseif Success and Value ~= opt1upvaluesOrder[i] then
			pFlag = true
			pI, pV = i, Value

			break
		end
	end

	if pFlag then
		return {
			status = 500,
			message = `[!optimize 1] - Upvalue at {pI} should be: {opt1upvaluesOrder[pI]}. Got: {pV}`,
		}
	elseif p2Flag then
		return {
			status = 500,
			message = `[!optimize 1] - Index {p2I} should not return an error because it exists.`,
		}
	elseif p3Flag then
		return {
			status = 500,
			message = `[!optimize 1] - Index {p3I} should return an error, it doesn't exist.`,
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
