--!nocheck
--!nolint

return {
	global = "loadstring",
	cases = {
		{
			id = "before execution",
			run = function(self)
				local nilCauseIncomplete, errorMessageIncomplete = loadstring("MYRIAD", "=MYRIAD")
				self._incompleteOk = true
				self._nilCauseIncomplete = nilCauseIncomplete
				self._errorMessageIncomplete = errorMessageIncomplete

				globalVar = nil
				local func = loadstring(
					[[
		globalVar = {"Hello", "World"}
	]],
					"=MYRIAD"
				)
				self._func = func

				if globalVar then
					return {
						status = 500,
						message = "globalVar was modified before function execution",
					}
				end

				local funcConst = loadstring("const Myriad = 49_100 return Myriad", "=MYRIAD")
				local nilCauseErrorConst, errorMessageConst =
					loadstring("const Myriad = 110_116 Myriad = 0 return Myriad", "=MYRIAD")
				self._funcConst = funcConst
				self._constOk = true
				self._nilCauseErrorConst = nilCauseErrorConst
				self._errorMessageConst = errorMessageConst

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "source",
			run = function(self)
				local func = self._func
				func()
				self._called = true

				local funcSource = debug.info(func, "s")
				if funcSource ~= "MYRIAD" then
					return {
						status = 500,
						message = `The source is "{funcSource}" instead of "MYRIAD"`,
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "incomplete",
			run = function(self)
				if not self._incompleteOk then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local nilCauseIncomplete = self._nilCauseIncomplete
				if nilCauseIncomplete ~= nil then
					return {
						status = 500,
						message = "Didn't error on incomplete expression",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "global variable",
			run = function(self)
				if not self._called then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				if not (globalVar and globalVar[1] == "Hello" and globalVar[2] == "World") then
					return {
						status = 500,
						message = "Failed to modify global variable",
					}
				end

				globalVar = nil
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "incomplete message",
			run = function(self)
				if not self._incompleteOk then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local errorMessageIncomplete = self._errorMessageIncomplete
				if
					errorMessageIncomplete ~= "MYRIAD:1: Incomplete statement: expected assignment or a function call"
				then
					return {
						status = 500,
						message = `Unexpected error message for incomplete expression: {errorMessageIncomplete}`,
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "const",
			run = function(self)
				if not self._constOk then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local funcConst = self._funcConst
				if not funcConst or funcConst() ~= 49100 then
					return {
						status = 500,
						message = "Outdated Luau version. 'const' syntax not supported",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "const reassign",
			run = function(self)
				if not self._constOk then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local nilCauseErrorConst = self._nilCauseErrorConst
				if nilCauseErrorConst ~= nil then
					return {
						status = 500,
						message = "Didn't error on reassigning a constant",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "const message",
			run = function(self)
				if not self._constOk then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local errorMessageConst = self._errorMessageConst
				if errorMessageConst ~= "MYRIAD:1: Assigned expression must be a variable or a field" then
					return {
						status = 500,
						message = `Unexpected error message for constant reassignment: {errorMessageConst}`,
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "optimize 0",
			run = function(self)
				local OptimizeLevel = 0
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

				self._opt0 = optmFunc
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "optimize 0 level",
			run = function(self)
				local OptimizeLevel = 0
				local optmFunc = self._opt0
				if type(optmFunc) ~= "function" then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local realOptmLevel = optmFunc()
				if realOptmLevel ~= OptimizeLevel then
					return {
						status = 500,
						message = `Optimization level mismatch: expected {OptimizeLevel}, got {realOptmLevel}`,
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "optimize 1",
			run = function(self)
				local OptimizeLevel = 1
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

				self._opt1 = optmFunc
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "optimize 1 level",
			run = function(self)
				local OptimizeLevel = 1
				local optmFunc = self._opt1
				if type(optmFunc) ~= "function" then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local realOptmLevel = optmFunc()
				if realOptmLevel ~= OptimizeLevel then
					return {
						status = 500,
						message = `Optimization level mismatch: expected {OptimizeLevel}, got {realOptmLevel}`,
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "optimize 2",
			run = function(self)
				local OptimizeLevel = 2
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

				self._opt2 = optmFunc
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "optimize 2 level",
			run = function(self)
				local OptimizeLevel = 2
				local optmFunc = self._opt2
				if type(optmFunc) ~= "function" then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				local realOptmLevel = optmFunc()
				if realOptmLevel ~= OptimizeLevel then
					return {
						status = 500,
						message = `Optimization level mismatch: expected {OptimizeLevel}, got {realOptmLevel}`,
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
