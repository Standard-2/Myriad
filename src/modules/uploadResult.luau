--!nocheck

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local UPLOAD_URL = "https://myriad.tools/api/upload"

return function(payload)
	local player = Players.LocalPlayer
	if not player then
		return { ok = false, error = "No local player to attach this result to." }
	end

	local requester = request
		or http_request
		or (http and http.request)
	if not requester then
		return { ok = false, error = "This executor has no request function." }
	end

	local encodedOk, encoded = pcall(function()
		return HttpService:JSONEncode({
			type = payload.type,
			playerId = player.UserId,
			metadata = payload.metadata,
			results = payload.results,
		})
	end)
	if not encodedOk then
		return { ok = false, error = "Could not encode the result." }
	end

	local called, response = pcall(requester, {
		Url = UPLOAD_URL,
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json",
		},
		Body = encoded,
	})

	if not called or type(response) ~= "table" then
		return { ok = false, error = "The upload request failed." }
	end

	local status = response.StatusCode or response.status or response.Status
	local rawBody = response.Body or response.body or ""
	local decoded = nil
	if type(rawBody) == "string" and rawBody ~= "" then
		pcall(function()
			decoded = HttpService:JSONDecode(rawBody)
		end)
	end

	if status == 200 and type(decoded) == "table" and decoded.success and type(decoded.url) == "string" then
		return {
			ok = true,
			url = decoded.url,
			remaining = decoded.remaining,
			limit = decoded.limit,
		}
	end

	local message = if type(decoded) == "table" and type(decoded.error) == "string"
		then decoded.error
		else `Upload failed ({tostring(status or "no status")}).`

	if type(decoded) == "table" and type(decoded.retryAfter) == "number" then
		message ..= ` Try again in {decoded.retryAfter}s.`
	end

	return { ok = false, error = message, status = status }
end
