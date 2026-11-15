--!nocheck
--!nolint

return {
	global = "run_on_actor",
	cases = {
		{
			id = "actor",
			run = function(self)
				local gameRefs = require("@gameRefs")
				local actor = gameRefs.PMOVON

				if not actor then
					return {
						status = 500,
						message = "Failed find to actor",
					}
				end

				self._actor = actor
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "tables",
			run = function(self)
				if self._actor == nil then
					return { status = 200, message = "Passed" }
				end

				local tempFolder = Instance.new("Folder", game)
				tempFolder.Name = os.date("%H")

				local detectXref = {}
				local sendData = {
					["GAME"] = game,
					["TABLE"] = detectXref,
					["TABLE_STR"] = tostring(detectXref),
				}

				local success, errorMessage = pcall(
					run_on_actor,
					self._actor,
					[[local Table = ...
    workspace:SetAttribute("MYRIAD_ROA_TABLETEST", type(Table) == "table")]],
					{}
				)

				task.wait(0.1)

				local receivedTable = workspace:GetAttribute("MYRIAD_ROA_TABLETEST")
				workspace:SetAttribute("MYRIAD_ROA_TABLETEST", nil)

				if not success or not receivedTable then
					return {
						status = 500,
						message = "Does not support tables as argument",
					}
				end

				self._tempFolder = tempFolder
				self._sendData = sendData
				self._errorMessage = errorMessage
				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "truss",
			run = function(self)
				if self._actor == nil or self._tempFolder == nil or self._sendData == nil then
					return { status = 200, message = "Passed" }
				end

				run_on_actor(
					self._actor,
					[[
        local externaldData = ({...})[1]
        
        local originalPart = Instance.new("TrussPart")
        
        if not externaldData or type(externaldData) ~= "table" then
            originalPart.Name = "ONE_ARG"
        elseif tostring(externaldData["TABLE"]) == externaldData["TABLE_STR"] then
            originalPart.Name = "SAME_XREF"
        elseif externaldData["GAME"] ~= game then
            originalPart.Name = "GAME_XREF"
        elseif select("#", ...) ~= 5 then
            originalPart.Name = "MULTI_ARGS"
        else
            originalPart.Name = "SUCCESS"
        end
        
        task.delay(0.25, function()
            originalPart:Destroy()
        end)

        originalPart.Parent = game[os.date("%H")]
    ]],
					self._sendData,
					1,
					2,
					3,
					4
				)

				task.wait(0.1)

				local TrussPart = self._tempFolder:FindFirstChildWhichIsA("TrussPart")

				self._tempFolder:Destroy()

				if not TrussPart then
					return {
						status = 500,
						message = "Failed to find a TrussPart created by the actor",
					}
				end

				local statusResult = TrussPart.Name
				TrussPart:Destroy()
				self._statusResult = statusResult

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "xref",
			run = function(self)
				if self._statusResult == nil then
					return { status = 200, message = "Passed" }
				end

				if self._statusResult == "SAME_XREF" then
					return {
						status = 500,
						message = "The tables have the same xrefs as in the main VM",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "game",
			run = function(self)
				if self._statusResult == nil then
					return { status = 200, message = "Passed" }
				end

				if self._statusResult == "GAME_XREF" then
					return {
						status = 500,
						message = "Xrefs are not converted automatically, which could cause problems in functions and table Keys",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "one-arg",
			run = function(self)
				if self._statusResult == nil then
					return { status = 200, message = "Passed" }
				end

				if self._statusResult == "ONE_ARG" then
					return {
						status = 500,
						message = "Its fatal error, does not support a single argument",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "multi-args",
			run = function(self)
				if self._statusResult == nil then
					return { status = 200, message = "Passed" }
				end

				if self._statusResult == "MULTI_ARGS" then
					return {
						status = 500,
						message = "Does not support multiple arguments",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "unknown",
			run = function(self)
				if self._statusResult == nil then
					return { status = 200, message = "Passed" }
				end

				local statusResult = self._statusResult
				if
					statusResult == "SAME_XREF"
					or statusResult == "GAME_XREF"
					or statusResult == "ONE_ARG"
					or statusResult == "MULTI_ARGS"
					or statusResult == "SUCCESS"
				then
					return {
						status = 200,
						message = `Passed`,
					}
				end

				return {
					status = 500,
					message = "Unknown error, check console",
				}
			end,
		},
	},
}
