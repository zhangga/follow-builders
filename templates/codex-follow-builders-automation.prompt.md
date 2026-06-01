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
3. 运行 `node prepare-digest.js` 获取 JSON。若命令整体失败但本地 bundled feed 文件存在，可用 `../feed-x.json`、`../feed-podcasts.json`、`../feed-blogs.json`、`../prompts/*.md` 和 `~/.follow-builders/config.json` 组装同结构 JSON 作为降级预览，并在飞书消息开头简短标注“实时 feed 拉取失败，以下使用本地缓存 feed”。
4. 只根据 JSON 中的 `x`、`blogs`、`podcasts`、`prompts` 和 `config` 生成摘要。遵守 prompt：中文输出，保留每条内容的原始 URL，不编造职位、观点、引用或来源；没有 URL 的内容不要包含。
5. 如果 `stats.podcastEpisodes`、`stats.xBuilders` 和 `stats.blogPosts` 都为 0，通过飞书发送一句中文提示“今天 Follow Builders 没有新的更新。”后结束。
6. 摘要格式：标题 `AI Builders Digest — <当天日期>`；按 X / Twitter、Official Blogs、Podcasts 分区；移动端易读；末尾加 `Generated through the Follow Builders skill: https://github.com/zarazhangrui/follow-builders`。
7. 通过飞书发送给用户 open_id `ou_1a698174d06fdc75f9f5567d41da0ac2`，身份使用 bot：`lark-cli im +messages-send --as bot --user-id ou_1a698174d06fdc75f9f5567d41da0ac2 --text <digest>`。不要因为 `lark-cli auth check --scope "im:message:send_as_bot"` 显示 missing 就提前放弃；实际发送已验证可用。若发送 API 返回失败，再记录真实错误。
8. 如果内容过长，按自然段切成每段不超过 3500 字符的多条消息发送，第一条保留标题，后续加 `(续)`。
9. 若飞书发送失败，在自动化运行结果中记录错误详情和已生成摘要，不要静默吞掉失败。
```

After creating the automation, show the resulting automation id and confirm the next run time is daily at 08:00 Asia/Shanghai.
