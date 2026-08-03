--!nocheck
--!nolint

-- Please reference our manual tests to properly verify your implementation.
-- https://docs.myriad.tools/spec/File%20Dialog/openfilesdialog/
return function()
	if not openfilesdialog then
		return {
			status = 400,
			message = "Global not found",
		}
	end

	return {
		status = 200,
		message = "Passed",
	}
end
