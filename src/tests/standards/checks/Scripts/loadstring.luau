--!nocheck
--!nolint

return function()
	if not loadstring then
		return {
			status = 400,
			message = "Global not found",
		}
	end

	local nilCauseIncomplete, errorMessageIncomplete = loadstring("MYRIAD", "=MYRIAD")

	globalVar = nil
	local func = loadstring([[
		globalVar = {"Hello", "World"}
	]], "=MYRIAD")
	
	if globalVar then
		return {
			status = 500,
			message = "globalVar was modified before function execution",
		}
	end
	
	local funcConst = loadstring("const Myriad = 49_100 return Myriad", "=MYRIAD")
	local nilCauseErrorConst, errorMessageConst = loadstring("const Myriad = 110_116 Myriad = 0 return Myriad", "=MYRIAD")
	
	func()

	local funcSource = debug.info(func, "s")
	if funcSource ~= "MYRIAD" then
		return {
			status = 500,
			message = `The source is "{funcSource}" instead of "MYRIAD"`,
		}
	end

	if nilCauseIncomplete ~= nil then
		return {
			status = 500,
			message = "Didn't error on incomplete expression",
		}
	elseif not (globalVar and globalVar[1] == "Hello" and globalVar[2] == "World") then
		return {
			status = 500,
			message = "Failed to modify global variable",
		}
	elseif errorMessageIncomplete ~= "MYRIAD:1: Incomplete statement: expected assignment or a function call" then
		return {
			status = 500,
			message = `Unexpected error message for incomplete expression: {errorMessageIncomplete}`,
		}
	elseif not funcConst or funcConst() ~= 49100 then
		return {
			status = 500,
			message = "Outdated Luau version. 'const' syntax not supported",
		}
	elseif nilCauseErrorConst ~= nil then
		return {
			status = 500,
			message = "Didn't error on reassigning a constant",
		}
	elseif errorMessageConst ~= "MYRIAD:1: Assigned expression must be a variable or a field" then
		return {
			status = 500,
			message = `Unexpected error message for constant reassignment: {errorMessageConst}`,
		}
	end
	
	globalVar = nil

	for OptimizeLevel = 0, 2 do
		local optmFunc, errorMessage = loadstring(`--!optimize {OptimizeLevel}\n` .. [[
			local function dupclosure()
				return function() end
			end

			if dupclosure() ~= dupclosure() then return 0 end

			local function inlinefunction()
				return debug.info(1, "f")
			end

			local f = debug.info(1, "f")
			if f == inlinefunction() then
				return 2
			end

			return 1
		]], "=MYRIAD")

		if not optmFunc then
			return {
				status = 500,
				message = `Failed to compile at optimization level {OptimizeLevel}: {errorMessage}`,
			}
		end

		local realOptmLevel = optmFunc()
		if realOptmLevel ~= OptimizeLevel then
			return {
				status = 500,
				message = `Optimization level mismatch: expected {OptimizeLevel}, got {realOptmLevel}`,
			}
		end
	end

	--// Alias test
	local envIndex, failedIndex = require("@dependencies/aliasTest.luau")({})

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
