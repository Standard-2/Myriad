--!nocheck
--!nolint

return {
	global = "Drawing.Fonts",
	cases = {
		{
			id = "ui",
			run = function(self)
				if not Drawing.Fonts["UI"] then
					return {
						status = 500,
						message = "UI font not found",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "system",
			run = function(self)
				if not Drawing.Fonts["System"] then
					return {
						status = 500,
						message = "System font not found",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "plex",
			run = function(self)
				if not Drawing.Fonts["Plex"] then
					return {
						status = 500,
						message = "Plex font not found",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "monospace",
			run = function(self)
				if not Drawing.Fonts["Monospace"] then
					return {
						status = 500,
						message = "Monospace font not found",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "ui-id",
			run = function(self)
				if Drawing.Fonts["UI"] ~= 0 then
					return {
						status = 500,
						message = "UI font isn't ID 0",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "system-id",
			run = function(self)
				if Drawing.Fonts["System"] ~= 1 then
					return {
						status = 500,
						message = "System font isn't ID 1",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "plex-id",
			run = function(self)
				if Drawing.Fonts["Plex"] ~= 2 then
					return {
						status = 500,
						message = "Plex font isn't ID 2",
					}
				end

				return {
					status = 200,
					message = `Passed`,
				}
			end,
		},
		{
			id = "monospace-id",
			run = function(self)
				if Drawing.Fonts["Monospace"] ~= 3 then
					return {
						status = 500,
						message = "Monospace font isn't ID 3",
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
