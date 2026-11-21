--!nocheck
--!nolint

return {
	global = "saveinstance",
	dependencies = {
		globals = {
			"listfiles",
			"delfile",
		},
	},
	cases = {
		{
			id = "save",
			run = function()
				local guid = game:GetService("HttpService"):GenerateGUID(false):gsub("-", "")
				local part = Instance.new("Part")

				saveinstance(part, {
					FileName = guid,
				})

				task.wait(0.5)

				local found = false

				for _, file in pairs(listfiles("")) do
					if file:find(guid) then
						found = true
						delfile(file)
					end
				end

				if not found then
					return {
						status = 500,
						message = "Couldn't find saved part. Args passed: (Instance, { FileName = string })",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
	},
}
