# cmux cheatsheet

이 문서는 이 repo의 `cmux.json` 기준으로 자주 쓰는 조작만 모은 빠른 참고용입니다.
cmux는 tmux, Neovim, binbox를 대체하지 않고 여러 작업판을 묶는 상위 진입점으로 씁니다.

## 1분 시작

```sh
cmux ~/binbox
cmux ~/.config/nvim
cmux .
```

- `cmux <path>`: 해당 디렉토리를 새 workspace로 엽니다.
- `cmux reload-config`: `~/.config/cmux/cmux.json`과 Ghostty 설정을 다시 읽습니다.
- `cmux config check`: 현재 primary/project 설정 파일이 유효한지 봅니다.
- `cmux settings path`: cmux가 읽는 설정 파일 경로를 확인합니다.

## 앱에서 제일 먼저 쓸 것

- Command Palette: workspace command와 action을 검색해서 실행합니다.
- Surface tab bar: `New Terminal`, `New Browser`, split, `Codex`, `Claude`, `Binbox Doctor`를 빠르게 실행합니다.
- New Workspace menu: `Open binbox`, `Open Neovim Config`, 언어/DevOps 작업판을 고릅니다.
- Sidebar: git branch, directory, port, PR, notification 상태를 보고 작업판을 전환합니다.

기본 단축키는 cmux 버전과 설정에 따라 바뀔 수 있습니다. 앱 안의 Settings 또는 `cmux shortcuts`를 기준으로 확인합니다.
이 repo에서는 sidebar focus 중 workspace/surface 번호 선택 단축키가 동작하지 않도록만 scope를 좁혀 둡니다.

## 등록된 action

| 이름 | 동작 | 용도 |
| --- | --- | --- |
| `Codex` | `codex`를 새 tab에서 실행 | 현재 작업판에서 Codex 시작 |
| `Claude` | `claude`를 새 tab에서 실행 | 현재 작업판에서 Claude Code 시작 |
| `Binbox Doctor` | `bb doctor`를 새 tab에서 실행 | binbox 의존성 점검 |

agent action은 권한 우회 플래그를 넣지 않습니다. 각 agent의 기본 승인 흐름을 그대로 사용합니다.

## 등록된 workspace command

| 이름 | CWD | 언제 쓰나 |
| --- | --- | --- |
| `Open binbox` | `~/binbox` | 개인 CLI 도구 수정, `bb check`, `bb new <name>` |
| `Open Neovim Config` | `~/.config/nvim` | LazyVim 설정, help 문서, editor workflow 정리 |
| `Go Dev` | 현재 디렉토리 | Go 편집, 테스트, 로그 확인 |
| `Python Dev` | 현재 디렉토리 | venv 선택, pytest, lint 확인 |
| `Terraform Ops` | 현재 디렉토리 | `bb tfplan`, `bb tfsum`, `bb tfapply` 흐름 |
| `Kubernetes Ops` | 현재 디렉토리 | `bb kctx`, `bb kns`, `bb klog`, `bb kexec`, `bb kpf` 흐름 |

fzf 기반 명령은 workspace가 열릴 때 자동 실행하지 않습니다. pane 안에 힌트만 띄우고, 필요한 시점에 직접 실행합니다.

## 자주 쓰는 CLI

```sh
cmux config check
cmux reload-config
cmux list-workspaces
cmux tree
cmux jump-to-unread
cmux browser open http://localhost:3000
cmux open README.md
```

- `cmux list-workspaces`: 현재 workspace 목록 확인.
- `cmux tree`: window/workspace/pane/surface 구조 확인.
- `cmux jump-to-unread`: 읽지 않은 알림으로 이동.
- `cmux browser open <url>`: 현재 workspace에 browser surface 열기.
- `cmux open <path-or-url>`: 파일 또는 URL 열기.

## DevOps 빠른 흐름

- Go: `Go Dev` 열기 → `nvim`에서 수정 → shell pane에서 `go test ./...`.
- Python: `Python Dev` 열기 → `.venv` 확인 → `python -m pytest`.
- Terraform: `Terraform Ops` 열기 → `bb tfplan` → `bb tfsum tree` → 필요 시 `bb tfapply session 15`.
- Kubernetes: `Kubernetes Ops` 열기 → `bb kctx`/`bb kns` → `bb klog` 또는 `bb kexec`.
- 도구 개발: `Open binbox` 열기 → `bb check` → 테스트/문서 수정.
- 에디터 설정: `Open Neovim Config` 열기 → `:help nvim-devops-workflow`.

## 문제 해결

```sh
cmux config check
cmux settings path
cmux reload-config
./scripts/check-sensitive.sh
```

- `cmux reload-config`가 `Broken pipe`로 실패하면 cmux 앱을 재시작합니다.
- `socket not found`가 나오면 cmux 앱이 실행 중인지 확인합니다.
- Command Palette에 새 항목이 안 보이면 `cmux config check` 후 앱 재시작 또는 reload를 합니다.
- `bb`가 없다고 나오면 `~/binbox/bb setup` 후 새 shell에서 다시 시도합니다.
- agent 버튼이 실패하면 `codex` 또는 `claude`가 PATH에 있는지 확인합니다.

## 하지 않을 것

- session restore approval, socket password, browser history를 Git에 넣지 않습니다.
- cmux command에서 zsh alias에 의존하지 않습니다. 항상 `bb <tool>` 형태를 씁니다.
- 전역 설정에 프로젝트 전용 build/test command를 넣지 않습니다. 프로젝트별 `.cmux/cmux.json`에 둡니다.
