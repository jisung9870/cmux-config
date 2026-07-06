# cmux workflows

cmux는 terminal, browser, agent 작업을 묶는 상위 workspace switcher입니다.
`~/binbox`, `~/.config/nvim`, tmux를 대체하지 않고 보완합니다.

## Global actions

- `Codex`: agent의 기본 승인 흐름으로 `codex`를 새 tab에서 시작합니다.
- `Claude`: agent의 기본 승인 흐름으로 `claude`를 새 tab에서 시작합니다.
- `Binbox Doctor`: 새 tab에서 `bb doctor`를 실행합니다.

config에는 permission bypass flag를 넣지 않습니다. 특정 장비에서만 필요하면 추적하지
않는 local override로 둡니다.

## Workspace commands

- `Open binbox`
  - CWD: `~/binbox`
  - 개인 CLI 도구를 수정하고 `bb list`, `bb check`를 실행할 때 씁니다.
- `Open Neovim Config`
  - CWD: `~/.config/nvim`
  - LazyVim config와 `:help nvim-devops-workflow` 같은 local help 문서를 다룰 때 씁니다.
- `Go Dev`
  - CWD: 현재 디렉토리
  - Go command hint가 있는 editor, shell, test pane을 엽니다.
- `Python Dev`
  - CWD: 현재 디렉토리
  - venv와 pytest hint가 있는 editor, shell, test pane을 엽니다.
- `Terraform Ops`
  - CWD: 현재 디렉토리
  - `bb tfplan`, `bb tfsum`, `bb tfapply session 15`, `bb tfapply` 흐름을 보여줍니다.
- `Kubernetes Ops`
  - CWD: 현재 디렉토리
  - `bb kctx`, `bb kns`, `bb klog`, `bb kexec`, `bb kpf` helper를 보여줍니다.

fzf 기반 interactive command는 workspace가 열릴 때 자동 실행하지 않습니다. pane에는
hint만 띄우고, 필요한 시점에 직접 실행합니다.

## 운영 규칙

- cmux command에서는 alias에 의존하지 않고 `bb <tool>`을 씁니다.
- 전역으로 유용하지 않은 project-specific layout은 각 프로젝트의 `.cmux/cmux.json`에 둡니다.
- secret, session approval, browser history, machine-specific path는 이 repo에 넣지 않습니다.
- config source는 `config.d/` fragment입니다. `cmux.json`은 generated output입니다.
- fragment 수정 후 `python3 scripts/build-config.py`, `./scripts/check-config.sh`,
  `cmux reload-config` 순서로 적용합니다.
