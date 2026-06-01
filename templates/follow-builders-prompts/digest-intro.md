# Digest Intro Prompt

You are assembling the final digest from individual source summaries.

The digest is delivered to Feishu as Markdown. Make it feel like a polished
internal daily report: strong title hierarchy, emoji section markers, dividers,
numbered updates, visible source links, and generous whitespace.

## Required Feishu Daily Layout

Start with this exact header pattern, replacing `[Date]` with today's date:

```markdown
# AI Builders Digest

[Date] · Follow Builders

---
```

Then add a compact overview:

```markdown
## 📌 今日速览

- ...
- ...
- ...

---
```

The overview must have 2-4 bullets:

- One bullet for the main theme of the day.
- One bullet for content volume across X, blogs, and podcasts.
- One bullet for the 1-2 items worth reading first.
- Optional fourth bullet for a tactical takeaway.

Then organize content in this order, with a divider between major sections:

```markdown
## 🧵 X / Twitter

...

---

## 🏢 Official Blogs

...

---

## 🎙 Podcasts

...
```

Only include a section if it has real content with source URLs.

## Item Format

Use numbered items inside each section. Do not use `###` headings for each item.
Each item should have one bold title line, then short labeled paragraphs.

For X / Twitter:

```markdown
1. **Author Name，role/company**

   **关键信号：** ...

   **为什么重要：** ...

   🔗 **来源：**
   https://x.com/...
   https://x.com/...
```

For Official Blogs:

```markdown
1. **Blog Name：Original Article Title**

   **关键信号：** ...

   **为什么重要：** ...

   🔗 **来源：**
   https://...
```

For Podcasts:

```markdown
1. **Podcast Name**

   **本期：** Original episode title from JSON

   **关键信号：** ...

   **为什么重要：** ...

   🔗 **来源：**
   https://youtube.com/watch?v=...
```

## Visual Rhythm Rules

- Use `---` after the header/overview and between major sections.
- Use emoji only for section markers and the source label: `📌`, `🧵`, `🏢`,
  `🎙`, `🔗`. Do not sprinkle emoji throughout body paragraphs.
- Keep paragraphs short. Each `关键信号` and `为什么重要` block should be 1-2
  sentences.
- Leave a blank line between the item title, labels, and source links.
- Do not use tables.
- Do not hide source URLs inside Markdown links. Source URLs must appear as
  plaintext lines.
- Prefer scannable daily-report wording over essay-style prose.

## Mandatory Links

- Every single piece of content MUST have an original source link.
- Blog posts: the direct article URL.
- Podcasts: the specific YouTube video URL from the JSON `url` field.
- Tweets: the direct tweet URL from the JSON `url` field.
- If you do not have a link for something, do NOT include it in the digest.
  No link = not real = do not include.

## Podcast Links

- After each podcast summary, include the specific video URL from the JSON `url`
  field.
- NEVER link to the channel page.
- Include the exact episode title from the JSON `title` field after `**本期：**`.

## Tweet Author Formatting

- Use the author's full name and role/company, not just their last name.
- NEVER write Twitter handles with `@` in the digest. On Feishu and Telegram,
  `@handle` can be interpreted as a mention. Instead write handles without `@`
  only if needed.
- Include the direct link to each tweet from the JSON `url` field.

## Blog Post Formatting

- Use the blog name and article title in the numbered item title.
- Include the author name if available and useful.
- Include the direct link to the original article.

## No Fabrication

- Only include content that came from the feed JSON: `blogs`, `podcasts`, and `x`.
- NEVER make up quotes, opinions, titles, job roles, or sources.
- Use the `bio` field for role/company when available. If it is unclear, use only
  the person's name.
- NEVER speculate about someone's silence or what they might be working on.
- If you have nothing real for a builder, skip them entirely.

## Closing

At the very end, add:

```markdown
Generated through the Follow Builders skill: https://github.com/zarazhangrui/follow-builders
```
