--!nocheck

--// Imports
local stopwatch = require("@modules/stopwatch")

local framework = {}

local cache = {}
local stack = {}
local registry = nil

local function splitId(id)
	local dot = string.find(id, ".", 1, true)
	if not dot then
		return nil, id
	end
	return string.sub(id, 1, dot - 1), string.sub(id, dot + 1)
end

local function readGlobal(name)
	if type(name) ~= "string" or name == "" or type(getfenv) ~= "function" then
		return nil
	end

	local ok, env = pcall(getfenv, 0)
	if not ok or type(env) ~= "table" then
		return nil
	end

	local index = env
	for segment in string.gmatch(name, "[^%.]+") do
		if type(index) ~= "table" then
			return nil
		end
		index = index[segment]
	end
	return index
end

local function globalOk(name, expected)
	if type(name) ~= "string" or name == "" then
		return false
	end

	local value = readGlobal(name)
	if type(expected) == "string" and expected ~= "" then
		return type(value) == expected
	end
	return value ~= nil and value ~= false
end

local function globalPresent(name)
	return globalOk(name, nil)
end

local function describeGlobal(entry, fallbackType)
	local name = entry
	local expected = nil
	local message = nil
	if type(entry) == "table" then
		name = entry.name
		if type(entry.type) == "string" and entry.type ~= "" then
			expected = entry.type
		end
		if type(entry.message) == "string" then
			message = entry.message
		end
	end
	if expected == nil and type(fallbackType) == "string" and fallbackType ~= "" then
		expected = fallbackType
	end
	return name, expected, message
end

local function rejectGlobals(globals, fallbackType, status, defaultMessage)
	if type(globals) == "string" then
		globals = { globals }
	elseif type(globals) == "table" and type(globals.name) == "string" and globals[1] == nil then
		globals = { globals }
	elseif type(globals) ~= "table" then
		return nil
	end

	for _, entry in ipairs(globals) do
		local name, expected, message = describeGlobal(entry, fallbackType)
		local label = if type(name) == "string" and name ~= "" then name else "nil"
		if not globalOk(name, expected) then
			return {
				status = status,
				message = message or defaultMessage(label),
			}
		end
	end
	return nil
end

function framework.aliases(aliases)
	for _, alias in ipairs(aliases) do
		local value = readGlobal(alias)
		if value == nil or value == false then
			return false, alias
		end
	end
	return true
end

local function lookup(id)
	local groupName, checkName = splitId(id)
	if not groupName or type(registry) ~= "table" then
		return nil, checkName
	end

	local group = registry[groupName]
	if type(group) ~= "table" then
		return nil, checkName
	end
	return group[checkName], checkName
end

local function headline(row)
	local message = tostring(row.message or "")
	local id = tostring(row.id or "")
	if string.sub(id, 1, 1) == "[" and string.find(message, id, 1, true) == nil then
		if message == "" then
			return id
		end
		return `{id} {message}`
	end
	return message
end

local function finish(rows)
	local status = 200
	local message = "Passed"
	for _, row in rows do
		if row.status ~= 200 then
			status = row.status
			message = headline(row)
			break
		end
	end

	local result = {
		status = status,
		message = message,
	}
	if #rows > 0 then
		result.cases = rows
	end
	return result
end

local function normalizeCall(ok, value)
	if not ok then
		return {
			status = 0,
			message = tostring(value),
		}
	end
	if type(value) ~= "table" or type(value.status) ~= "number" then
		return {
			status = 0,
			message = "Case returned no result",
		}
	end

	local result = {
		status = value.status,
		message = if value.message == nil then "" else tostring(value.message),
	}
	if type(value.cases) == "table" then
		result.cases = value.cases
	end
	return result
end

local function runSpec(spec)
	local missingGlobal = rejectGlobals(spec.global, spec.type, 400, function()
		return "Global not found"
	end)
	if missingGlobal then
		return missingGlobal
	end

	local dependencies = spec.dependencies
	if type(dependencies) == "table" then
		local checks = dependencies.checks
		if type(checks) == "table" then
			for _, dep in ipairs(checks) do
				local depId = dep
				local custom = nil
				if type(dep) == "table" then
					depId = dep.id
					if type(dep.message) == "string" then
						custom = dep.message
					end
				end
				if type(depId) ~= "string" or depId == "" then
					return {
						status = 401,
						message = custom or "Dependency 'nil' didn't pass",
					}
				end

				local depResult = framework.dependency(depId)
				if type(depResult) ~= "table" or depResult.status ~= 200 then
					if type(depResult) == "table" and depResult.message == "Dependency cycle" then
						return {
							status = 401,
							message = "Dependency cycle",
						}
					end
					if custom then
						return {
							status = 401,
							message = custom,
						}
					end
					local _, checkName = splitId(depId)
					return {
						status = 401,
						message = `Dependency '{checkName or depId}' didn't pass`,
					}
				end
			end
		end

		local missingDep = rejectGlobals(dependencies.globals, nil, 401, function(label)
			return `Dependant global '{label}' not found`
		end)
		if missingDep then
			return missingDep
		end
	end

	for key in pairs(spec) do
		if type(key) == "string" and string.sub(key, 1, 1) == "_" then
			spec[key] = nil
		end
	end

	local rows = {}
	local cases = spec.cases
	if type(cases) == "table" then
		for _, case in ipairs(cases) do
			local id = "case"
			if type(case) == "table" and type(case.id) == "string" and case.id ~= "" then
				id = case.id
			end

			local elapsedOf = stopwatch.start()
			local ok, value
			if type(case) == "table" and type(case.run) == "function" then
				ok, value = pcall(case.run, spec)
			else
				ok, value = false, "Case returned no result"
			end
			local elapsed = elapsedOf()

			local row
			if not ok then
				row = {
					id = id,
					status = 0,
					message = tostring(value),
					elapsed = elapsed,
				}
			elseif type(value) ~= "table" or type(value.status) ~= "number" then
				row = {
					id = id,
					status = 0,
					message = "Case returned no result",
					elapsed = elapsed,
				}
			else
				row = {
					id = id,
					status = value.status,
					message = if value.message == nil then "" else tostring(value.message),
					elapsed = elapsed,
				}
			end
			table.insert(rows, row)
		end
	end

	local aliasList = spec.aliases
	if type(aliasList) == "table" then
		for _, alias in ipairs(aliasList) do
			local found, missing = framework.aliases({ alias })
			if not found then
				local name = tostring(missing or alias)
				table.insert(rows, {
					id = name,
					status = 501,
					message = `Alias not found: {name}`,
					elapsed = 0,
				})
			end
		end
	end

	return finish(rows)
end

function framework.begin(nextRegistry)
	cache = {}
	stack = {}
	if type(nextRegistry) == "table" then
		registry = nextRegistry
	end
end

function framework.peek(id)
	return cache[id]
end

function framework.store(id, result)
	if id then
		cache[id] = result
	end
end

function framework.dependency(id)
	if type(id) ~= "string" or id == "" then
		return {
			status = 401,
			message = "Dependency 'nil' didn't pass",
		}
	end

	local hit = cache[id]
	if hit then
		return hit
	end
	if stack[id] then
		return {
			status = 401,
			message = "Dependency cycle",
		}
	end

	local test, checkName = lookup(id)
	if test == nil then
		local missing = {
			status = 401,
			message = `Dependency '{checkName or id}' didn't pass`,
		}
		cache[id] = missing
		return missing
	end

	return framework.run(test, id)
end

function framework.run(test, id)
	if id and stack[id] then
		return {
			status = 401,
			message = "Dependency cycle",
		}
	end
	if id then
		stack[id] = true
	end

	local elapsedOf = stopwatch.start()
	local result
	if type(test) == "function" then
		result = normalizeCall(pcall(test))
	elseif type(test) == "table" then
		result = runSpec(test)
	else
		result = {
			status = 0,
			message = "Case returned no result",
		}
	end
	result.elapsed = elapsedOf()

	if id then
		stack[id] = nil
		cache[id] = result
	end
	return result
end

return framework
