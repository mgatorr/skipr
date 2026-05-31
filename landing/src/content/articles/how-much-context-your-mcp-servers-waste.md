---
title: How much context are your MCP servers wasting?
description: Every MCP server you connect injects its full tool schema into every message. Here's how to measure the cost — and why it's often 30–40% of your context window.
publishDate: 2026-05-31
ogImage: /og/mcp-context-cost.png
draft: false
---

You connected a handful of MCP servers to Claude Code and everything got a little slower,
a little pricier, and you're not totally sure why. Here's the uncomfortable part: **every
MCP server you connect injects its full tool schema — every tool name, description, and
parameter — into the context of every single message**, whether you use those tools or not.

Developers who have measured it report that **30–40% of their context window** can be
consumed by tool schemas that are never called. That's context you pay for on every turn,
that crowds out your actual code, and that quietly raises latency and cost.

## Why this happens

MCP is a "load everything up front" protocol by default. When a server advertises 40 tools,
all 40 schemas are in play. Connect five busy servers and you can be carrying tens of
thousands of tokens of overhead before you've typed a word.

## How to measure it

You don't have to guess. For each server you can:

1. Spawn it over stdio.
2. Call `tools/list`.
3. Measure the byte/token weight of the returned schemas.

Done across every connected server, that gives you a **per-server context cost** and a total
— the number that actually matters.

```text
$ sorrel analyze
server            tools   context cost
github             42     8,310 tok
playwright         31     6,740 tok
supabase           28     5,120 tok
filesystem          9     1,180 tok
────────────────────────────────────
total                     21,350 tok  (~34% of context)
# est. — measured from each server's tools/list schema
```

> The percentages above are **measured estimates** from each server's advertised schema, not
> a guarantee — your real usage depends on your model and configuration.

## What to do about it

Once you can see the cost, the fixes are obvious: disable servers you're not using, prefer
focused servers over kitchen-sink ones, and turn things back on when you actually need them.
The point isn't to run fewer tools — it's to **stop paying for tools you never call**.

This is exactly the problem **Sorrel** is being built to make visible: a friendly control
layer for piloting Claude Code, whose hero feature is a per-server MCP token-cost analyzer.

_Sorrel is an independent tool and is not affiliated with Anthropic._
