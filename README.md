# follow-builders
Follow Builders, Not Influencers

## Shortcuts

Run these from the repository root:

macOS/Linux:

```bash
make update-submodule
make npm-install
make setup
```

You can also run the shell script directly with `bash ./follow-builders setup`.

Windows PowerShell:

```powershell
.\follow-builders.ps1 update-submodule
.\follow-builders.ps1 npm-install
.\follow-builders.ps1 setup
```

- `update-submodule` initializes/updates `submodules/zarazhangrui-follow-builders`.
- `npm-install` runs `npm install` in `submodules/zarazhangrui-follow-builders/scripts`.
- `setup` does both steps in order.

## Feishu Restore

To restore the daily Feishu digest on a new computer, use:

```bash
bash scripts/bootstrap-feishu-follow-builders.sh
```

This installs the Follow Builders dependencies, writes
`~/.follow-builders/config.json`, and installs the repository-backed digest
layout prompt from `templates/follow-builders-prompts/digest-intro.md` to
`~/.follow-builders/prompts/digest-intro.md`. The prompt controls the Feishu
daily-report layout, including emoji section markers, dividers, numbered items,
and visible source links.

Full restore notes live in `docs/follow-builders-feishu-restore.md`.
