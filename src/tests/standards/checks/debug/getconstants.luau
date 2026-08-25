--!nocheck
--!nolint

return function()
	if not debug or not debug.getconstants then
		return {
			status = 400,
			message = "Global not found",
		}
	end

	--// Functionality test
	local function originalFunction()
		local _1 = 2
		local _2 = "A"

		print(_1)
		tostring(_2)

		Date.now()
	end

	local constOrder = {
		"print",
		"A",
		"tostring",
		"Date",
		"now",
	}

	local constants = debug.getconstants(originalFunction)
	if type(constants) ~= "table" then
		return {
			status = 500,
			message = "debug.getconstants did not return a table",
		}
	end

	for i, v in ipairs(constOrder) do
		local found = false

		for _, const in pairs(constants) do
			if const == v then
				found = true

				break
			end
		end

		if not found then
			return {
				status = 500,
				message = `Expected constant was not found: {v}`,
			}
		end
	end

	if pcall(debug.getconstants, print) then
		return {
			status = 500,
			message = "Should error with C closures",
		}
	end

	--// Alias test
	local envIndex, failedIndex = require("@dependencies/aliasTest.luau")({
		"getconstants",
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
