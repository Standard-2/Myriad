--!strict
--[[
	kacParser/serialiser.luau

	Converts a parsed `Changelog` value into a JSON string.

	This is a hand-rolled serialiser (no external deps) that:
	  • Preserves field insertion order deterministically.
	  • Supports configurable indentation.
	  • Supports optional null emission for absent fields.
	  • Correctly escapes all JSON special characters.
]]

local Types = require("./types")

export type Changelog = Types.Changelog
export type SerialiseOptions = Types.SerialiseOptions

-- ── JSON primitives ────────────────────────────────────────────────────────

--- Escape a Lua string for use as a JSON string value.
local function jsonStr(s: string): string
	s = s:gsub("\\", "\\\\")
	s = s:gsub('"', '\\"')
	s = s:gsub("/", "\\/")
	s = s:gsub("\b", "\\b")
	s = s:gsub("\f", "\\f")
	s = s:gsub("\n", "\\n")
	s = s:gsub("\r", "\\r")
	s = s:gsub("\t", "\\t")
	-- Control characters U+0000–U+001F (excluding the ones already handled)
	s = s:gsub("[\0-\31]", function(c)
		return string.format("\\u%04x", string.byte(c))
	end)
	return '"' .. s .. '"'
end

--- Serialise an array of strings to a JSON array, with nice indentation.
local function jsonStrArray(arr: { string }, baseIndent: string, unit: string): string
	if #arr == 0 then
		return "[]"
	end
	local inner = baseIndent .. unit
	local items: { string } = {}
	for _, v in arr do
		table.insert(items, inner .. jsonStr(v))
	end
	return "[\n" .. table.concat(items, ",\n") .. "\n" .. baseIndent .. "]"
end

-- ── section / release serialisers ─────────────────────────────────────────

local SECTION_ORDER = { "added", "changed", "deprecated", "removed", "fixed", "security" }

local function jsonChangeSection(
	changes: Types.ChangeSection,
	baseIndent: string,
	unit: string,
	emitNulls: boolean
): string
	local inner = baseIndent .. unit
	local fields: { string } = {}

	for _, key in SECTION_ORDER do
		local entries: { Types.ChangeEntry }? = (changes :: any)[key]
		if entries ~= nil and #entries > 0 then
			-- Flatten ChangeEntry[] → string[] for output
			local texts: { string } = {}
			for _, e in entries do
				table.insert(texts, e.text)
			end
			table.insert(fields, inner .. jsonStr(key) .. ": " .. jsonStrArray(texts, inner, unit))
		elseif emitNulls then
			table.insert(fields, inner .. jsonStr(key) .. ": null")
		end
	end

	if #fields == 0 then
		return "{}"
	end
	return "{\n" .. table.concat(fields, ",\n") .. "\n" .. baseIndent .. "}"
end

local function jsonRelease(
	r: Types.Release,
	baseIndent: string,
	unit: string,
	emitNulls: boolean,
	includeLinks: boolean
): string
	local inner = baseIndent .. unit
	local parts: { string } = {}

	table.insert(parts, inner .. '"version": ' .. jsonStr(r.version))

	if r.date ~= nil then
		table.insert(parts, inner .. '"date": ' .. jsonStr(r.date))
	elseif emitNulls then
		table.insert(parts, inner .. '"date": null')
	end

	table.insert(parts, inner .. '"tags": ' .. jsonStrArray(r.tags, inner, unit))

	if includeLinks then
		if r.link ~= nil then
			table.insert(parts, inner .. '"link": ' .. jsonStr(r.link))
		elseif emitNulls then
			table.insert(parts, inner .. '"link": null')
		end
	end

	table.insert(
		parts,
		inner .. '"changes": ' .. jsonChangeSection(r.changes, inner, unit, emitNulls)
	)

	return "{\n" .. table.concat(parts, ",\n") .. "\n" .. baseIndent .. "}"
end

local function jsonUnreleased(
	unreleased: { notes: { string }?, changes: Types.ChangeSection },
	baseIndent: string,
	unit: string,
	emitNulls: boolean
): string
	local inner = baseIndent .. unit
	local parts: { string } = {}

	local notes = unreleased.notes
	if notes ~= nil and #notes > 0 then
		table.insert(parts, inner .. '"notes": ' .. jsonStrArray(notes, inner, unit))
	elseif emitNulls then
		table.insert(parts, inner .. '"notes": null')
	end

	table.insert(
		parts,
		inner .. '"changes": ' .. jsonChangeSection(unreleased.changes, inner, unit, emitNulls)
	)

	return "{\n" .. table.concat(parts, ",\n") .. "\n" .. baseIndent .. "}"
end

-- ── public ─────────────────────────────────────────────────────────────────

local Serialiser = {}

function Serialiser.toJSON(changelog: Changelog, options: SerialiseOptions?): string
	local opts = options or {}
	local unit: string = (opts.indent ~= nil and opts.indent ~= "") and opts.indent or "  "
	local emitNulls: boolean = opts.emitNulls == true
	local includeLinks: boolean = opts.includeLinks ~= false -- default true

	local base = unit -- top-level indent
	local parts: { string } = {}

	-- title
	table.insert(parts, base .. '"title": ' .. jsonStr(changelog.title))

	-- description
	if changelog.description ~= nil then
		table.insert(parts, base .. '"description": ' .. jsonStr(changelog.description))
	elseif emitNulls then
		table.insert(parts, base .. '"description": null')
	end

	-- unreleased
	if changelog.unreleased ~= nil then
		table.insert(
			parts,
			base .. '"unreleased": ' .. jsonUnreleased(changelog.unreleased, base, unit, emitNulls)
		)
	elseif emitNulls then
		table.insert(parts, base .. '"unreleased": null')
	end

	-- releases
	local relParts: { string } = {}
	for _, r in changelog.releases do
		table.insert(relParts, base .. unit .. jsonRelease(r, base .. unit, unit, emitNulls, includeLinks))
	end

	local relArr: string
	if #relParts == 0 then
		relArr = "[]"
	else
		relArr = "[\n" .. table.concat(relParts, ",\n") .. "\n" .. base .. "]"
	end
	table.insert(parts, base .. '"releases": ' .. relArr)

	-- links map
	if includeLinks and next(changelog.links) ~= nil then
		local linkParts: { string } = {}
		-- Sort keys for deterministic output
		local keys: { string } = {}
		for k in changelog.links do
			table.insert(keys, k)
		end
		table.sort(keys)
		for _, k in keys do
			table.insert(
				linkParts,
				base .. unit .. jsonStr(k) .. ": " .. jsonStr(changelog.links[k])
			)
		end
		table.insert(
			parts,
			base .. '"links": {\n' .. table.concat(linkParts, ",\n") .. "\n" .. base .. "}"
		)
	elseif emitNulls then
		table.insert(parts, base .. '"links": {}')
	end

	return "{\n" .. table.concat(parts, ",\n") .. "\n}"
end

return Serialiser
