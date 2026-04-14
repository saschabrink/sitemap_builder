# Changelog

## [0.1.0] - 2026-04-14

### Added
- `SitemapBuilder` struct with `:url` and `:lastmod` fields
- `new/1` — creates a builder for a given host URL
- `add/2` — adds a pre-built entry
- `add/3` — maps a single item or a list to entries via a function
- `generate/1` — renders to XML string
- `lastmod` accepts `Date`, `DateTime`, and Ecto datetime tuples
