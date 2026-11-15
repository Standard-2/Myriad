--!nocheck
--!nolint

return {
	global = "compareinstances",
	dependencies = {
		globals = {
			{ name = "cloneref", message = "'cloneref' needed to test this reliably" },
		},
	},
	cases = {
		{
			id = "cloneref part",
			run = function(self)
				local originalPart = Instance.new("Part")
				if cloneref(originalPart) == originalPart then
					return {
						status = 500,
						message = `(CR) Cloned part cannot be equal to original reference`,
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "cloneref service",
			run = function(self)
				local originalService = game:GetService("CoreGui")
				if cloneref(originalService) == originalService then
					return {
						status = 500,
						message = `(CR) Cloned service cannot be equal to original reference`,
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "game",
			run = function(self)
				if not compareinstances(game, game) then
					return {
						status = 500,
						message = `Two equal instances (game, game) assumed unequal`,
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "coregui",
			run = function(self)
				local originalService = game:GetService("CoreGui")
				local originalServiceAgain = game:GetService("CoreGui")
				if not compareinstances(originalService, originalServiceAgain) then
					return {
						status = 500,
						message = `Two equal instances (CoreGui, CoreGui) assumed unequal`,
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "unequal",
			run = function(self)
				if compareinstances(game, workspace) then
					return {
						status = 500,
						message = `Two unequal instances (game, workspace) assumed equal`,
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "cloned part",
			run = function(self)
				local originalPart = Instance.new("Part")
				if not compareinstances(originalPart, cloneref(originalPart)) then
					return {
						status = 500,
						message = `Two equal instances (originalPart, clonedPart) assumed equal`,
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "cloned service",
			run = function(self)
				local originalService = game:GetService("CoreGui")
				if not compareinstances(originalService, cloneref(originalService)) then
					return {
						status = 500,
						message = `Two equal instances (originalService, clonedService) assumed equal`,
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
		{
			id = "tables",
			run = function(self)
				local tempTable = {}
				if pcall(compareinstances, tempTable, tempTable) then
					-- The function is called compareINSTANCES", not "compareOBJETS" or anything similar
					return {
						status = 500,
						message = "No error occurred when comparing tables",
					}
				end

				return { status = 200, message = `Passed` }
			end,
		},
	},
}
