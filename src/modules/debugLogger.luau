--!nocheck

local config = require("@config")

local debugLogger = {}
debugLogger.__index = debugLogger

local function sanitizeFileSegment(value)
	return tostring(value):gsub("[^%w%-_]", "-")
end

local function formatLine(message)
	return `[{DateTime.now():ToIsoDate()}] {message}`
end

local function ensureFolder(path)
	if isfolder and isfolder(path) then
		return true
	end

	if makefolder then
		local success = pcall(makefolder, path)
		if success then
			return true
		end
	end

	return false
end

function debugLogger.canWrite()
	return type(writefile) == "function"
end

function debugLogger.new(enabled)
	local self = setmetatable({
		enabled = enabled,
		active = false,
		lines = {},
		path = nil,
		writeFailure = nil,
	}, debugLogger)

	return self
end

function debugLogger:start()
	if not self.enabled or not debugLogger.canWrite() then
		return false
	end

	ensureFolder(config.logging.rootDirectory)
	ensureFolder(config.logging.logDirectory)

	local stamp = sanitizeFileSegment(DateTime.now():ToIsoDate())
	self.path = `{config.logging.logDirectory}/{stamp}.{config.logging.logExtension}`
	self.active = true

	self:write("Debug log initialized")

	return self.active
end

function debugLogger:write(message)
	if not self.active then
		return false
	end

	table.insert(self.lines, formatLine(message))

	local success, failure = pcall(writefile, self.path, table.concat(self.lines, "\n") .. "\n")
	if not success then
		self.writeFailure = failure
		self.active = false
		return false
	end

	return true
end

function debugLogger:getWorkspacePath()
	if not self.path then
		return nil
	end

	return `<workspace>/{self.path}`
end

function debugLogger:finish(message)
	if message then
		self:write(message)
	end

	self.active = false
end

return debugLogger
