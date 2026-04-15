defmodule SitemapBuilderTest do
  use ExUnit.Case, async: true

  describe "new/1" do
    test "returns a builder tuple with the given host" do
      assert {"https://example.com", []} = SitemapBuilder.new("https://example.com")
    end
  end

  describe "add/2" do
    test "adds a pre-built entry" do
      entry = %SitemapBuilder{url: "/about", lastmod: ~D[2026-01-01]}

      {_host, entries} =
        SitemapBuilder.new("https://example.com")
        |> SitemapBuilder.add(entry)

      assert entries == [entry]
    end
  end

  describe "add/3" do
    test "maps a single item to an entry" do
      {_host, entries} =
        SitemapBuilder.new("https://example.com")
        |> SitemapBuilder.add(%{slug: "hello", updated_at: ~D[2026-01-01]}, fn item ->
          %SitemapBuilder{url: "/posts/#{item.slug}", lastmod: item.updated_at}
        end)

      assert [%SitemapBuilder{url: "/posts/hello"}] = entries
    end

    test "maps a list of items to entries" do
      items = [
        %{slug: "one", updated_at: ~D[2026-01-01]},
        %{slug: "two", updated_at: ~D[2026-01-02]}
      ]

      {_host, entries} =
        SitemapBuilder.new("https://example.com")
        |> SitemapBuilder.add(items, fn item ->
          %SitemapBuilder{url: "/posts/#{item.slug}", lastmod: item.updated_at}
        end)

      assert length(entries) == 2
      assert [%SitemapBuilder{url: "/posts/one"}, %SitemapBuilder{url: "/posts/two"}] = entries
    end
  end

  describe "comment/2" do
    test "adds a comment entry to the builder" do
      {_host, entries} =
        SitemapBuilder.new("https://example.com")
        |> SitemapBuilder.comment("Homepage")

      assert entries == [{:comment, "Homepage"}]
    end

    test "comment appears in generated XML" do
      xml =
        SitemapBuilder.new("https://example.com")
        |> SitemapBuilder.comment("Homepage")
        |> SitemapBuilder.add(%SitemapBuilder{url: "/en", lastmod: ~D[2026-01-01]})
        |> SitemapBuilder.generate()

      assert xml =~ "<!-- Homepage -->"
    end

    test "comment appears before its section entries" do
      xml =
        SitemapBuilder.new("https://example.com")
        |> SitemapBuilder.comment("Homepage")
        |> SitemapBuilder.add(%SitemapBuilder{url: "/en", lastmod: ~D[2026-01-01]})
        |> SitemapBuilder.generate()

      comment_pos = :binary.match(xml, "<!-- Homepage -->") |> elem(0)
      loc_pos = :binary.match(xml, "<loc>") |> elem(0)
      assert comment_pos < loc_pos
    end
  end

  describe "generate/1" do
    test "renders valid XML with loc and lastmod" do
      xml =
        SitemapBuilder.new("https://example.com")
        |> SitemapBuilder.add(%SitemapBuilder{url: "/about", lastmod: ~D[2026-04-14]})
        |> SitemapBuilder.generate()

      assert xml =~ ~s(<?xml version="1.0" encoding="UTF-8"?>)
      assert xml =~ ~s(xmlns="http://www.sitemaps.org/schemas/sitemap/0.9")
      assert xml =~ "<loc>https://example.com/about</loc>"
      assert xml =~ "<lastmod>2026-04-14</lastmod>"
    end

    test "handles DateTime lastmod" do
      dt = ~U[2026-04-14 12:00:00Z]

      xml =
        SitemapBuilder.new("https://example.com")
        |> SitemapBuilder.add(%SitemapBuilder{url: "/", lastmod: dt})
        |> SitemapBuilder.generate()

      assert xml =~ "<lastmod>2026-04-14</lastmod>"
    end

    test "handles Ecto datetime tuple lastmod" do
      tuple = {{2026, 4, 14}, {12, 0, 0}}

      xml =
        SitemapBuilder.new("https://example.com")
        |> SitemapBuilder.add(%SitemapBuilder{url: "/", lastmod: tuple})
        |> SitemapBuilder.generate()

      assert xml =~ "<lastmod>2026-04-14</lastmod>"
    end

    test "renders empty lastmod for unknown format" do
      xml =
        SitemapBuilder.new("https://example.com")
        |> SitemapBuilder.add(%SitemapBuilder{url: "/", lastmod: nil})
        |> SitemapBuilder.generate()

      assert xml =~ "<lastmod></lastmod>"
    end

    test "renders multiple entries" do
      xml =
        SitemapBuilder.new("https://example.com")
        |> SitemapBuilder.add(%SitemapBuilder{url: "/en", lastmod: ~D[2026-01-01]})
        |> SitemapBuilder.add(%SitemapBuilder{url: "/es", lastmod: ~D[2026-01-01]})
        |> SitemapBuilder.generate()

      assert xml =~ "<loc>https://example.com/en</loc>"
      assert xml =~ "<loc>https://example.com/es</loc>"
    end
  end
end
