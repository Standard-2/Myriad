--!nocheck
--!nolint

return {
	cases = {
		{
			id = "global",
			run = function(self)
				if not saveinstance then
					return {
						status = 400,
						message = "Global not found",
					}
				end

				self._saveinstance = true
				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "listfiles",
			run = function(self)
				if not self._saveinstance then
					return { status = 200, message = `Passed` }
				end

				if not listfiles then
					return {
						status = 501,
						message = "Dependant global 'listfiles' not found",
					}
				end

				self._listfiles = true
				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "delfile",
			run = function(self)
				if not self._saveinstance or not self._listfiles then
					return { status = 200, message = `Passed` }
				end

				if not delfile then
					return {
						status = 501,
						message = "Dependant global 'delfile' not found",
					}
				end

				self._delfile = true
				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "save",
			run = function(self)
				if not self._saveinstance or not self._listfiles or not self._delfile then
					return { status = 200, message = `Passed` }
				end

				--// Functionality test
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
