# cmux workflows

cmux is the top-level workspace switcher for terminal, browser, and agent work.
It complements `~/binbox`, `~/.config/nvim`, and tmux instead of replacing them.

## Global actions

- `Codex`: starts `codex` in a new tab with the agent's normal approval flow.
- `Claude`: starts `claude` in a new tab with the agent's normal approval flow.
- `Binbox Doctor`: runs `bb doctor` in a new tab.

The config does not include permission-skipping flags. Add them only as a local,
untracked override if a specific machine needs that behavior.

## Workspace commands

- `Open binbox`
  - CWD: `~/binbox`
  - Use for editing personal CLI tools, checking `bb list`, and running `bb check`.
- `Open Neovim Config`
  - CWD: `~/.config/nvim`
  - Use for LazyVim config work and local help docs such as `:help nvim-devops-workflow`.
- `Go Dev`
  - CWD: current directory
  - Opens editor plus shell/test panes with Go command hints.
- `Python Dev`
  - CWD: current directory
  - Opens editor plus venv/pytest command hints.
- `Terraform Ops`
  - CWD: current directory
  - Uses the binbox Terraform flow: `bb tfplan`, `bb tfsum`, `bb tfapply session 15`, `bb tfapply`.
- `Kubernetes Ops`
  - CWD: current directory
  - Shows binbox Kubernetes helpers: `bb kctx`, `bb kns`, `bb klog`, `bb kexec`, `bb kpf`.

Interactive fzf-based commands are shown as hints when a workspace opens. They are
not auto-run during workspace creation, so a new cmux workspace does not block on
an unexpected picker.

## Operating rules

- Prefer `bb <tool>` in cmux commands; do not rely on aliases from `aliases.zsh`.
- Keep project-specific layouts in each project's `.cmux/cmux.json` when they are
  not useful globally.
- Keep secrets, session approvals, browser history, and machine-specific paths out
  of this repo.
- After editing `cmux.json`, run `cmux reload-config` or restart cmux.
