--!nocheck
--!nolint

return function()
	if not debug or not debug.getconstant then
		return {
			status = 400,
			message = "Global not found",
		}
	end

	--// Functionality test
	local pFlag, pI, pV = false

	local function originalFunction()
		local _1 = 2
		local _2 = "A"

		print(_1)
		tostring(_2)

		Date.now()
	end

	local constOrder = { -- Optimization levels make the order essentially useless. So we instead check if the expected constants exist.
		"print",
		"A",
		"tostring",
		"Date",
		"now",
	}

	local constants = {}
	local index = 1

	while true do
		local success, const = pcall(debug.getconstant, originalFunction, index)
		if not success then
			break
		end

		constants[index] = const
		index += 1
	end

	for i, v in ipairs(constOrder) do
		if not table.find(constants, v) then
			pFlag = true
			pV = v
			pI = i

			break
		end
	end

	local invalidIndexSuccess, _ = pcall(debug.getconstant, originalFunction, index)

	if invalidIndexSuccess then
		return {
			status = 500,
			message = "Should error when retrieving Out-of-bounds indexes.",
		}
	elseif pcall(debug.getconstant, print, 1) then
		return {
			status = 500,
			message = "Should error with C closures",
		}
	end

	--// Alias test
	local envIndex, failedIndex = require("@dependencies/aliasTest.luau")({
		"getconstant",
	})

	if not envIndex then
		return {
			status = 501,
			message = `Alias not found: {failedIndex}`,
		}
	end

	if pFlag then
		return {
			status = 200,
			message = `Passed with inconsistency: Expected constant wasn't found: {pV} (Check your optimization level)`,
		}
	end

	return {
		status = 200,
		message = `Passed`,
	}
end
