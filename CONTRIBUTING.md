# Contributing

## How to Contribute

1. Fork the repo
2. Create a branch: `git checkout -b feat/your-feature`
3. Make your changes
4. Test: `make health`
5. Commit using conventional commits (see below)
6. Open a pull request

## Commit Convention

```
feat:     new feature
fix:      bug fix
ci:       CI/CD changes
chore:    maintenance (deps, config)
docs:     documentation only
refactor: code restructure, no behaviour change
```

## Running Locally

```bash
make up        # start all VMs
make provision # provision all services
make health    # verify everything works
make open      # print app URL
```

## Reporting Bugs

Open a GitHub issue with:
- What you did
- What you expected
- What actually happened
- OS, Vagrant version, VirtualBox version
