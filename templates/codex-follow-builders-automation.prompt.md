# Create Follow Builders Feishu Automation

Please create an ACTIVE Codex cron automation for this workspace.

Use these automation fields exactly:

- `id` suggestion: `follow-builders`
- `name`: `Follow Builders 每日飞书摘要`
- `kind`: `cron`
- `status`: `ACTIVE`
- `executionEnvironment`: `local`
- `cwds`: `["/Users/jossyzhang/work/GitHub/follow-builders"]`
- `rrule`: `RRULE:FREQ=WEEKLY;BYHOUR=8;BYMINUTE=0;BYDAY=SU,MO,TU,WE,TH,FR,SA`
- `model`: `gpt-5.5`
- `reasoningEffort`: `medium`

Use this task prompt:

```text
每天生成 Follow Builders 中文摘要并通过飞书发给张泽强本人。

执行步骤：
1. 使用工作区 `/Users/jossyzhang/work/GitHub/follow-builders`，进入 `/Users/jossyzhang/work/GitHub/follow-builders/submodules/zarazhangrui-follow-builders/scripts`。
2. 读取 `/Users/jossyzhang/work/GitHub/follow-builders/submodules/zarazhangrui-follow-builders/SKILL.md` 的 Content Delivery 工作流，只运行 digest，不做 onboarding，不改 cron，不额外访问网页或 X，不调用外部搜索。
3. 运行 `node prepare-digest.js` 获取 JSON。若命令整体失败但本地 bundled feed 文件存在，可用 `../feed-x.json`、`../feed-podcasts.json`、`../feed-blogs.json`、`~/.follow-builders/prompts/*.md`、`../prompts/*.md` 和 `~/.follow-builders/config.json` 组装同结构 JSON 作为降级预览，并在飞书消息开头简短标注“实时 feed 拉取失败，以下使用本地缓存 feed”。
4. 只根据 JSON 中的 `x`、`blogs`、`podcasts`、`prompts` 和 `config` 生成摘要。遵守 prompt：中文输出，保留每条内容的原始 URL，不编造职位、观点、引用或来源；没有 URL 的内容不要包含。
5. 如果 `stats.podcastEpisodes`、`stats.xBuilders` 和 `stats.blogPosts` 都为 0，通过飞书发送一句中文提示“今天 Follow Builders 没有新的更新。”后结束。
6. 摘要使用适合飞书移动端阅读的 Markdown 日报式排版，并优先遵守 JSON 中 `prompts.digest_intro` 的自定义格式：
   - 标题块使用 `# AI Builders Digest`，下一行写 `<当天日期> · Follow Builders`，再加一条 `---` 分隔线。
   - 标题下方加 `## 📌 今日速览`，用 2-4 个 bullet 概括今天最值得看的主线、内容数量和优先阅读项，随后再加 `---`。
   - 按 `## 🧵 X / Twitter`、`## 🏢 Official Blogs`、`## 🎙 Podcasts` 分区，每个大分区之间用 `---` 分割。
   - 每个分区内部用编号列表，不用 `###` 堆叠小标题；每条用 `**作者/来源，角色或标题**` 开头。
   - 每条固定包含 `**关键信号：**`、`**为什么重要：**`、`🔗 **来源：**`；Podcast 额外包含 `**本期：** <JSON 里的原始标题>`。
   - 来源链接必须以明文 URL 出现，不要只做成隐藏在文字里的 Markdown link；多条 URL 用独立行列出。
   - emoji 只用于 section 标题和来源标签；不使用表格，不写长段墙；每条控制在 2-4 句，优先保留可操作洞察。
   - 末尾加 `Generated through the Follow Builders skill: https://github.com/zarazhangrui/follow-builders`。
7. 通过飞书发送给用户 open_id `ou_1a698174d06fdc75f9f5567d41da0ac2`，身份使用 bot：`lark-cli im +messages-send --as bot --user-id ou_1a698174d06fdc75f9f5567d41da0ac2 --markdown <digest>`。不要因为 `lark-cli auth check --scope "im:message:send_as_bot"` 显示 missing 就提前放弃；实际发送已验证可用。若发送 API 返回失败，再记录真实错误。
8. 如果内容过长，优先按 `---` 分隔的大 section 或完整编号条目切成每段不超过 3500 字符的多条 Markdown 消息发送。第一条保留完整标题和 `## 📌 今日速览`，后续标题用 `# AI Builders Digest（续）` 和 `<当天日期> · Follow Builders`。
9. 若飞书发送失败，在自动化运行结果中记录错误详情和已生成摘要，不要静默吞掉失败。
```

After creating the automation, show the resulting automation id and confirm the next run time is daily at 08:00 Asia/Shanghai.
