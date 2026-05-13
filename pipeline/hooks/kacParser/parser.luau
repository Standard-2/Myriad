--!strict
--[[
	kacParser/parser.luau

	Walks the token stream produced by `lexer.luau` and builds a fully
	typed `Changelog` value.  All structural decisions live here; the
	lexer is kept separate so it can be reused or swapped independently.

	State machine
	─────────────
	PREAMBLE   → scanning for the first meaningful structural token
	UNRELEASED → inside the ## [Unreleased] block
	RELEASE    → inside a versioned ## [x.y.z] block
	LINKS      → after all release blocks (reference-link section)
]]

local Types = require("./types")
local Lexer = require("./lexer")

-- Re-export for convenience
export type Changelog = Types.Changelog
export type ParseOptions = Types.ParseOptions
export type Release = Types.Release
export type ChangeSection = Types.ChangeSection
export type ChangeEntry = Types.ChangeEntry

-- ── constants ──────────────────────────────────────────────────────────────

local VALID_SECTIONS: { [string]: boolean } = {
	added = true,
	changed = true,
	deprecated = true,
	removed = true,
	fixed = true,
	security = true,
}

local DEFAULT_OPTIONS: ParseOptions = {
	keepUnreleased = true,
	preserveLinks = true,
	preserveNotes = true,
	includePreReleases = true,
	keepEmptyReleases = true,
}

-- ── helpers ────────────────────────────────────────────────────────────────

local function resolveOption(opts: ParseOptions, key: string): boolean
	local v = (opts :: any)[key]
	if v == nil then
		return (DEFAULT_OPTIONS :: any)[key] :: boolean
	end
	return v :: boolean
end

--- Return true when the version string contains a pre-release identifier.
local function isPreRelease(version: string): boolean
	-- semver pre-release: anything after a hyphen, e.g. "1.0.0-beta.2"
	return version:find("%-") ~= nil
end

--- Merge a list of ChangeEntry into the named key of a ChangeSection.
local function appendEntries(section: ChangeSection, kind: string, entries: { ChangeEntry })
	if #entries == 0 then
		return
	end
	local existing: { ChangeEntry }? = (section :: any)[kind]
	if existing == nil then
		existing = {}
		;(section :: any)[kind] = existing
	end
	for _, e in entries do
		table.insert(existing :: { ChangeEntry }, e)
	end
end

--- Return true when a ChangeSection has at least one entry.
local function hasEntries(section: ChangeSection): boolean
	for _, key in { "added", "changed", "deprecated", "removed", "fixed", "security" } do
		local v: { ChangeEntry }? = (section :: any)[key]
		if v ~= nil and #v > 0 then
			return true
		end
	end
	return false
end

-- ── parser ─────────────────────────────────────────────────────────────────

local Parser = {}

function Parser.parse(source: string, options: ParseOptions?): Changelog
	local opts: ParseOptions = options or {}

	local keepUnreleased = resolveOption(opts, "keepUnreleased")
	local preserveLinks = resolveOption(opts, "preserveLinks")
	local preserveNotes = resolveOption(opts, "preserveNotes")
	local includePreReleases = resolveOption(opts, "includePreReleases")
	local keepEmptyReleases = resolveOption(opts, "keepEmptyReleases")

	local tokens = Lexer.tokenise(source)

	-- ── output accumulators ────────────────────────────────────────────
	local changelog: Changelog = {
		title = "Changelog",
		description = nil,
		unreleased = nil,
		releases = {},
		links = {},
	}

	-- ── parser state ───────────────────────────────────────────────────
	type State = "PREAMBLE" | "UNRELEASED" | "RELEASE"
	local state: State = "PREAMBLE"

	-- Working buffers for the block we are currently accumulating.
	local currentRelease: Release? = nil
	local currentChanges: ChangeSection = {}
	local currentSection: string? = nil        -- active ### kind
	local currentEntries: { ChangeEntry } = {} -- items for currentSection
	local unreleasedNotes: { string } = {}
	local preambleLines: { string } = {}

	-- ── helpers for flushing accumulated data ──────────────────────────

	--- Flush the active list-item buffer into currentChanges.
	local function flushSection()
		if currentSection and #currentEntries > 0 then
			appendEntries(currentChanges, currentSection, currentEntries)
		end
		currentEntries = {}
		currentSection = nil
	end

	--- Commit the current block (unreleased or release) to the changelog.
	local function flushBlock()
		flushSection()

		if state == "UNRELEASED" then
			if keepUnreleased then
				changelog.unreleased = {
					notes = (preserveNotes and #unreleasedNotes > 0) and unreleasedNotes or nil,
					changes = currentChanges,
				}
			end

		elseif state == "RELEASE" and currentRelease ~= nil then
			local rel = currentRelease :: Release
			rel.changes = currentChanges

			local keep = true
			if not includePreReleases and isPreRelease(rel.version) then
				keep = false
			end
			if not keepEmptyReleases and not hasEntries(rel.changes) then
				keep = false
			end

			if keep then
				table.insert(changelog.releases, rel)
			end
		end

		-- Reset accumulators
		currentRelease = nil
		currentChanges = {}
		currentSection = nil
		currentEntries = {}
		unreleasedNotes = {}
	end

	-- ── token walk ─────────────────────────────────────────────────────
	for _, tok in tokens do
		local kind = tok.kind
		local p = tok.payload

		if kind == "H1" then
			changelog.title = p.title :: string
			state = "PREAMBLE"

		elseif kind == "H2_UNRELEASED" then
			if state ~= "PREAMBLE" then
				flushBlock()
			end
			state = "UNRELEASED"

		elseif kind == "H2_RELEASE" then
			-- Always flush before starting a new block
			if state ~= "PREAMBLE" then
				flushBlock()
			end
			state = "RELEASE"
			currentRelease = {
				version = p.version :: string,
				date = ((p.date :: string) ~= "") and (p.date :: string) or nil,
				tags = p.tags :: { string },
				link = nil,
				changes = {},
			}

		elseif kind == "H3" then
			-- Only switch section if we are inside a block
			if state == "RELEASE" or state == "UNRELEASED" then
				flushSection()
				local sec = p.section :: string
				if VALID_SECTIONS[sec] then
					currentSection = sec
				else
					currentSection = nil
				end
			end

		elseif kind == "LIST_ITEM" then
			if (state == "RELEASE" or state == "UNRELEASED") and currentSection then
				table.insert(currentEntries, { text = p.text :: string })
			end

		elseif kind == "BLOCKQUOTE" then
			if state == "UNRELEASED" and preserveNotes then
				local note = p.note :: string
				if note ~= "" then
					table.insert(unreleasedNotes, note)
				end
			end

		elseif kind == "REF_LINK" then
			if preserveLinks then
				local label = p.label :: string
				local url = p.url :: string
				changelog.links[label] = url
			end

		elseif kind == "BLANK" then
			-- Blank lines are structural separators; no action needed.
			-- (Keeping them would just clutter the model.)

		elseif kind == "OTHER" then
			if state == "PREAMBLE" then
				table.insert(preambleLines, tok.raw)
			end
		end
	end

	-- Flush the last open block
	if state ~= "PREAMBLE" then
		flushBlock()
	end

	-- Attach preamble description if any non-blank lines exist
	if #preambleLines > 0 then
		local nonBlank: { string } = {}
		for _, l in preambleLines do
			if l:match("%S") then
				table.insert(nonBlank, l)
			end
		end
		if #nonBlank > 0 then
			changelog.description = table.concat(nonBlank, "\n")
		end
	end

	-- Attach reference-link URLs to matching releases
	if preserveLinks then
		for _, rel in changelog.releases do
			local url = changelog.links[rel.version]
			if url then
				rel.link = url
			end
		end
	end

	return changelog
end

return Parser
