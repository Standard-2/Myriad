local result = {}

function result.secured(message, details)
	return {
		status = 200,
		message = message,
		details = details,
	}
end

function result.vulnerable(message, details)
	return {
		status = 400,
		message = message,
		details = details,
	}
end

function result.ambiguous(message, details)
	return {
		status = 404,
		message = message,
		details = details,
	}
end

return result
