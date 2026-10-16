local ui = require("@self/ui")
local cascade = require("@packages/cascade")
local binder = cascade.Binder
local statusCodes = require("@modules/statusCodes")

local FILTERS = {
	standards = {
		{ label = "All", match = function()
			return true
		end },
		{ label = "Failed", match = function(entry)
			return entry.status ~= 200
		end },
		{ label = "Pass", match = function(entry)
			return entry.status == 200
		end },
		{ label = "Ambiguous", match = function(entry)
			return entry.status == 0
		end },
		{ label = "Missing", match = function(entry)
			return entry.status == 400
		end },
		{ label = "Dependency", match = function(entry)
			return entry.status == 401
		end },
		{ label = "Functionality", match = function(entry)
			return entry.status == 500
		end },
		{ label = "Alias", match = function(entry)
			return entry.status == 501
		end },
	},
	vulnerabilities = {
		{ label = "All", match = function()
			return true
		end },
		{ label = "Problems", match = function(entry)
			return entry.status ~= 200
		end },
		{ label = "Secured", match = function(entry)
			return entry.status == 200
		end },
		{ label = "Vulnerable", match = function(entry)
			return entry.status == 400
		end },
		{ label = "Ambiguous", match = function(entry)
			return entry.status == 404
		end },
	},
}

local function host(object)
	if typeof(object) == "Instance" then
		return object
	end
	return object.__instance
end

local function entryTone(status: number): string
	if status == 200 then
		return "pass"
	elseif status == 0 or status == 404 then
		return "warn"
	end
	return "fail"
end

local function formatElapsed(elapsed: number): string
	local rounded = math.floor((elapsed or 0) * 100 + 0.5) / 100
	local text = string.format("%.2f", rounded)
	text = string.gsub(text, "0+$", "")
	text = string.gsub(text, "%.$", "")
	return `{text}s`
end

local function optionLabels(filters)
	local labels = {}
	for _, filter in filters do
		table.insert(labels, filter.label)
	end
	return labels
end

return function(self, properties: any)
	properties = properties or {}

	local kind = properties.Kind == "vulnerabilities" and "vulnerabilities" or "standards"
	local filters = FILTERS[kind]
	local icons = kind == "vulnerabilities" and statusCodes.Vulnerabilities or statusCodes.Standards

	local state = {
		report = nil,
		query = "",
		statusIndex = 1,
		showTimes = true,
		expanded = {},
		view = nil,
	}

	local actions = {}
	local structures

	local function refresh()
		if structures then
			structures.render(state.view or {
				countText = "",
				groups = {},
				empty = false,
			})
		end
	end

	local function buildView()
		local report = state.report
		if not report then
			state.view = {
				countText = "",
				groups = {},
				empty = false,
			}
			refresh()
			return
		end

		local query = string.lower(state.query)
		local statusFilter = filters[state.statusIndex] or filters[1]
		local groups = {}

		for _, group in report.groups do
			local entries = {}
			local passed = 0

			for _, entry in group.entries do
				if not statusFilter.match(entry) then
					continue
				end

				local message = tostring(entry.message or "")
				if query ~= "" then
					local haystack = string.lower(`{group.name} {entry.name} {message} {entry.status}`)
					if not string.find(haystack, query, 1, true) then
						continue
					end
				end

				if entry.status == 200 then
					passed += 1
				end

				table.insert(entries, {
					name = tostring(entry.name),
					status = entry.status,
					message = message,
					tone = entryTone(entry.status),
					icon = icons[entry.status] or "•",
					showMessage = entry.status ~= 200 and message ~= "",
					elapsedText = formatElapsed(entry.elapsed or entry.elapsedTestTime or 0),
					showTimes = state.showTimes,
				})
			end

			if #entries == 0 then
				continue
			end

			local tone = "pass"
			for _, entry in entries do
				if entry.tone == "fail" then
					tone = "fail"
					break
				elseif entry.tone == "warn" then
					tone = "warn"
				end
			end

			table.insert(groups, {
				name = group.name,
				passed = passed,
				total = #entries,
				tone = tone,
				expanded = state.expanded[group.name] ~= false,
				entries = entries,
			})
		end

		local summary = report.summary
		local extras = {}
		if (summary.ambiguous or 0) > 0 then
			table.insert(extras, `{summary.ambiguous} {summary.ambiguousLabel}`)
		end
		if (summary.excluded or 0) > 0 then
			table.insert(extras, `{summary.excluded} excluded`)
		end

		local groupLabel = if #groups == 1 then "1 group" else `{#groups} groups`
		state.view = {
			countText = groupLabel,
			executor = tostring(summary.executor or ""),
			passed = summary.passed or 0,
			tested = summary.tested or 0,
			rate = summary.rate or 0,
			timeText = formatElapsed(summary.took or 0),
			extra = table.concat(extras, " • "),
			groups = groups,
			empty = #groups == 0,
		}
		refresh()
	end

	local function buildText(): string
		local report = state.report
		local view = state.view
		if not report or not view then
			return ""
		end

		local summary = report.summary
		local function label(text: string): string
			return string.upper(string.sub(text, 1, 1)) .. string.sub(text, 2)
		end

		local lines = {
			"Summary",
			`  Took: {formatElapsed(summary.took)}`,
			`  Executor: {summary.executor}`,
			`  Version: {summary.version}`,
			`  Tested: {summary.tested}`,
			`  {label(summary.passedLabel)}: {summary.passed}`,
			`  {label(summary.failedLabel)}: {summary.failed}`,
		}
		if summary.ambiguous ~= nil then
			table.insert(lines, `  {label(summary.ambiguousLabel)}: {summary.ambiguous}`)
		end
		table.insert(lines, `  Rate: {summary.rate}%`)
		if (summary.excluded or 0) > 0 then
			table.insert(lines, `  Excluded: {summary.excluded}`)
		end

		local activeFilter = filters[state.statusIndex]
		if state.query ~= "" or (activeFilter and activeFilter.label ~= "All") then
			table.insert(lines, `  Filter: {activeFilter and activeFilter.label or "All"}`)
			if state.query ~= "" then
				table.insert(lines, `  Query: {state.query}`)
			end
		end

		table.insert(lines, "")

		for _, group in view.groups do
			table.insert(lines, group.name)
			for _, entry in group.entries do
				local elapsedSuffix = if state.showTimes and entry.elapsedText then ` ({entry.elapsedText})` else ""
				table.insert(lines, `  {entry.icon} {entry.name}{elapsedSuffix}: {entry.message}`)
			end
			table.insert(lines, "")
		end

		return table.concat(lines, "\n")
	end

	function actions.onQuery(text)
		state.query = text or ""
		buildView()
	end

	function actions.onStatus(index)
		state.statusIndex = index
		buildView()
	end

	function actions.onTimes(value)
		state.showTimes = value
		if state.view then
			for _, group in state.view.groups do
				for _, entry in group.entries do
					entry.showTimes = value
				end
			end
		end
		if structures.setTimes then
			structures.setTimes(value)
		end
	end

	function actions.onToggle(name)
		local open = state.expanded[name] == false
		state.expanded[name] = open
		if state.view then
			for _, group in state.view.groups do
				if group.name == name then
					group.expanded = open
				end
			end
		end
		if structures.toggleGroup then
			structures.toggleGroup(name, open)
		end
	end

	function actions.onCopy()
		if properties.Copied then
			properties.Copied(buildText())
		end
	end

	actions.statusOptions = optionLabels(filters)
	structures = ui(self, properties, actions)

	local function setVisible(val: boolean)
		local body = host(structures.Body)
		body.Visible = val
		if val then
			body.AutomaticSize = Enum.AutomaticSize.Y
			body.Size = UDim2.new(1, 0, 0, 0)
		else
			body.AutomaticSize = Enum.AutomaticSize.None
			body.Size = UDim2.new(1, 0, 0, 0)
		end
	end

	local object = binder.Wrap(properties, {
		Visible = setVisible,
		Report = function(report)
			state.report = report
			state.expanded = {}
			if report then
				for _, group in report.groups do
					state.expanded[group.name] = true
				end
			end
			buildView()
		end,
	}, host(structures.Body))

	object.Type = "TestResults"
	object.Theme = self.Theme
	object.Structures = structures
	object.__container = host(structures.Body)
	object.GetText = buildText

	setVisible(properties.Visible == true)
	binder.Apply({
		Visible = properties.Visible,
		Report = properties.Report,
	}, object)

	return object
end
