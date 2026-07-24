--!nocheck
--!nolint

return function()
	if not debug or not debug.setstack then
		return {
			status = 400,
			message = "Global not found",
		}
	end

	--// Alias test
	local envIndex, failedIndex = require("@dependencies/aliasTest.luau")({
		"setstack",
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
