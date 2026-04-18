# sitemap_builder usage rules

Rules apply to `sitemap_builder ~> 0.1`.

Pipeline-friendly XML sitemap generator. Start with `new/1`, pipe through
`add/2`, `add/3`, `comment/2`, finish with `generate/1`. That's the whole
API.

## Minimal pattern

```elixir
xml =
  SitemapBuilder.new("https://example.com")
  |> SitemapBuilder.comment("Homepage")
  |> SitemapBuilder.add(%SitemapBuilder{url: "/", lastmod: ~D[2026-01-01]})
  |> SitemapBuilder.comment("Posts")
  |> SitemapBuilder.add(posts, fn post ->
    %SitemapBuilder{url: "/posts/#{post.slug}", lastmod: post.updated_at}
  end)
  |> SitemapBuilder.generate()
```

## The struct

```elixir
%SitemapBuilder{url: "/en/about", lastmod: ~D[2026-04-17]}
```

Both fields are `@enforce_keys` — missing either raises at compile time.

- **`url`** — path relative to the host you passed to `new/1`. Start with
  `/`. Don't repeat the host here.
- **`lastmod`** — `Date`, `DateTime`, or an Ecto datetime tuple
  (`{{y,m,d}, {h,m,s}}`). Anything else silently renders as empty.

## Functions

| Function | Signature |
|---|---|
| `new/1` | `new(host) -> builder` |
| `add/2` | `add(builder, %SitemapBuilder{})` |
| `add/3` | `add(builder, items \| item, fun)` — `fun` maps to `%SitemapBuilder{}` |
| `comment/2` | `comment(builder, text)` — inserts an `<!-- ... -->` |
| `generate/1` | `generate(builder) -> iodata/String.t` (the XML) |

## Phoenix controller example

```elixir
def sitemap(conn, _params) do
  xml =
    SitemapBuilder.new(url(~p"/"))
    |> SitemapBuilder.add(MyApp.Blog.list_posts(), fn post ->
      %SitemapBuilder{url: ~p"/posts/#{post.slug}", lastmod: post.updated_at}
    end)
    |> SitemapBuilder.generate()

  conn
  |> put_resp_content_type("application/xml")
  |> send_resp(200, xml)
end
```

## Do

- **Leading slash on `url`.** `"/en/about"`, not `"en/about"` — you'll
  get `https://example.comen/about` otherwise. There's no validation.
- **Group sections with `comment/2`.** Free debugging aid when the
  sitemap grows — see at a glance which section a URL came from.
- **Pass a fully-qualified host to `new/1`** including scheme:
  `"https://example.com"`, no trailing slash.

## Don't

- **Don't pass naive strings as `lastmod`.** Strings hit the catch-all
  clause and render empty — Google treats that as "unknown" and the
  whole entry loses freshness signal.
- **Don't include the host in `url`.** It's concatenated by `generate/1`.
- **Don't paginate huge sitemaps in one builder.** For >50 000 URLs,
  build a sitemap index yourself and emit multiple files — this library
  only generates a single `<urlset>`.

## Testing

```elixir
test "generates valid XML with posts" do
  xml =
    SitemapBuilder.new("https://example.com")
    |> SitemapBuilder.add(%SitemapBuilder{url: "/", lastmod: ~D[2026-01-01]})
    |> SitemapBuilder.generate()

  assert xml =~ ~s(<loc>https://example.com/</loc>)
  assert xml =~ ~s(<lastmod>2026-01-01</lastmod>)
end
```

## Configuration

None.
