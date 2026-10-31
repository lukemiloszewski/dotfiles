---
name: memex
description: >
  Search Luke's memex: his own notes plus about 8,000 things he has saved (X bookmarks, Raindrop
  bookmarks with the full saved page, GitHub stars), through the memex MCP server or the `memex`
  command. Use when he asks what he knows, wrote, read, saved or bookmarked about something; asks
  to find a half-remembered post, article, thread or repo; asks what he saved recently or in some
  period; wants his own sources or earlier thinking before research, writing or a decision; or
  asks which tools or libraries he has starred for a task. Check it before web search for anything
  he may already have saved.
---

# Memex

One index over Luke's own writing and everything he has saved:

| source | what it is | whose view |
|---|---|---|
| `note` | Luke's notes and blog posts | **his** |
| `x` | X bookmarks: posts and threads, with quoted posts and the context they reply to | the author's |
| `raindrop` | web bookmarks with the saved page's text (articles, papers, docs) | the author's |
| `github` | starred repositories, with their README | the project's |

Saving something isn't endorsing it. Attribute claims to their author, and keep what Luke wrote
apart from what he saved.

## The four calls

Every result has an `id` (`<source>/<slug>`, e.g. `x/2013737031843668316`). That's the handle
for the other calls.

| MCP tool (server `memex`) | Command line | Does |
|---|---|---|
| `search(query, sources, since, until, mode, limit)` | `memex search "<query>" --source x --since 2026-01-01 --mode fts --json` | best matches; with no query, the newest first |
| `read(id, section, offset)` | `memex read <id> [--section N] [--json]` | the full text (paged over MCP), or one section |
| `similar(id, sources, since, until, limit)` | `memex similar <id> [--json]` | documents closest in meaning |
| `overview()` | — | counts per source, dates covered, when it was last built |

Use the MCP tools when they're available. Each search there takes well under a second. Without
them, run the command line from `~/code/memex` as `uv run memex …`. It takes about 4 s per search,
because it loads the model each time.

## Matching the request to a call

| Luke asks | Call |
|---|---|
| "what do I know / have I saved about X" | `search("X")`, then read the best few |
| "what did I write / think about X" | `search("X", sources=["note"])` |
| "that thread by @karpathy about tokenizers" | `search("karpathy tokenizers", sources=["x"])` (the handle is in the title); add `mode="fts"` if it's an exact phrase |
| "which libraries have I starred for X" | `search("X", sources=["github"])` |
| "what did I save this week / in March" | `search(since=..., until=..., sources=[...])` with no query |
| "things like this one" / "go deeper on this" | `similar(id)` |
| "anything recent about X" | `search("X", since=<a month or two ago>)` |

## Searching well

1. **Pick the mode by the query:**
   - `hybrid` (the default) suits almost everything. Phrase the query the way the content would
     put it: "how to evaluate LLM agents", not "agent eval".
   - `fts` for exact words: names, handles, library or function names, error messages, quoted
     phrases.
   - `vec` for a concept that shares no vocabulary with the text.
2. **Search more than once.** Try 2–3 phrasings, or broad then narrow, before concluding there's
   nothing. Run independent searches in parallel.
3. **Filter to match the intent.** `sources` and `since`/`until` narrow the search exactly. Dates
   are inclusive, `YYYY-MM-DD`. Resolve "last month" or "this year" to dates from today's date.
4. **Read before you claim anything.** A snippet is only the start of the matching section. For a
   long page, `read(id, section=hit.section)` gets the part that matched. Read the whole document
   only when you need it, following `next_offset` for long ones.
5. **Expand from a good hit** with `similar(id)` to find the rest of a cluster: Luke's related notes,
   or other saves on the topic. Filter it too, e.g. `sources=["note"]` for what he wrote around it.

## Reading results

- **Scores** rank results within one search only:
  - hybrid scores are small (about 0.01–0.03);
  - vec scores are cosine similarity: 0.8 or more is close, below 0.7 is loose;
  - a search with no query has no scores.
- **`date`** is when Luke saved it, or for X (which doesn't report that) when it was posted.
  Notes carry their own date.
- **`matches`** is how many sections of the document matched. A high count means the whole
  document is about the topic.
- **Freshness:** the index only covers up to `overview().built_at`. Anything saved later isn't in
  it yet.
- **Errors** say what to fix (an unknown id or source, a bad date, no database yet). Correct the
  call; don't retry it unchanged.

## Answering

- Lead with the answer, then the sources. Cite each with its `url`, or with the `id` and title
  for notes, plus its date.
- When it helps, group the sources: what Luke wrote, then what he saved.
- Quote sparingly, and only from text you've read.
- When nothing relevant turns up after a few phrasings, say so plainly, then offer a web search.
