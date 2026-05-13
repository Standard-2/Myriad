--!strict
--[[
	kacParser/types.luau
	Shared type definitions for the Keep a Changelog parser.
	https://keepachangelog.com/en/1.1.0/
]]

export type ChangeKind = "added" | "changed" | "deprecated" | "removed" | "fixed" | "security"

--- A single change entry. May carry inline code spans or plain text.
export type ChangeEntry = {
	text: string,
}

--- A set of categorised change entries for one release (or Unreleased).
export type ChangeSection = {
	added: { ChangeEntry }?,
	changed: { ChangeEntry }?,
	deprecated: { ChangeEntry }?,
	removed: { ChangeEntry }?,
	fixed: { ChangeEntry }?,
	security: { ChangeEntry }?,
}

--- A parsed release block.
export type Release = {
	--- Semver string extracted from `## [x.y.z]`, e.g. `"1.6.2"` or `"1.0.0-beta.2"`.
	version: string,
	--- ISO-8601 date string if present after ` - `, otherwise nil.
	date: string?,
	--- Metadata tags extracted from backtick spans, e.g. `{"STABLE", "HOTFIX"}`.
	tags: { string },
	--- Markdown link target extracted from `[version]: url`, otherwise nil.
	link: string?,
	--- All categorised change entries for this release.
	changes: ChangeSection,
}

--- The top-level parsed changelog.
export type Changelog = {
	--- Title from the `# H1` heading, defaults to `"Changelog"`.
	title: string,
	--- Description lines that appear between the H1 and the first H2 block.
	description: string?,
	--- The `## [Unreleased]` block, if present and not suppressed by options.
	unreleased: {
		--- Raw note lines from the unreleased block (e.g. `> Current target: …`).
		notes: { string }?,
		changes: ChangeSection,
	}?,
	--- All versioned releases in document order (newest first).
	releases: { Release },
	--- Reference-link map: version string → URL, e.g. `{ ["1.6.2"] = "https://…" }`.
	links: { [string]: string },
}

--- Options controlling parser and serialiser behaviour.
export type ParseOptions = {
	--- When true, the `## [Unreleased]` block is parsed and included.
	--- Default: true
	keepUnreleased: boolean?,
	--- When true, `[version]: url` reference links are parsed and attached to releases.
	--- Default: true
	preserveLinks: boolean?,
	--- When true, blockquote lines (starting with `>`) inside the Unreleased block
	--- are captured as `unreleased.notes`.
	--- Default: true
	preserveNotes: boolean?,
	--- When true, pre-release versions (containing `-`) are included in `releases`.
	--- Default: true
	includePreReleases: boolean?,
	--- When true, releases with zero change entries are still kept in the output.
	--- Default: true
	keepEmptyReleases: boolean?,
}

export type SerialiseOptions = {
	--- Indentation string for JSON output.  Default: `"  "` (two spaces).
	indent: string?,
	--- When true, emits `null` for absent optional fields.
	--- When false, absent fields are omitted entirely.
	--- Default: false
	emitNulls: boolean?,
	--- When true, includes the `links` map in JSON output.
	--- Default: true
	includeLinks: boolean?,
}

return nil
