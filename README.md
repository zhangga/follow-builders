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
