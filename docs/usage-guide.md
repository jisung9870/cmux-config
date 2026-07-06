# cmux usage guide

cmux는 작업을 시작하고 전환하고 관찰하는 상위 작업판입니다. 실제 편집은 Neovim,
세부 CLI는 binbox, 장기 terminal session은 필요하면 tmux가 맡습니다.

## 운영 모델

- cmux workspace: 하나의 일감, repo, 환경, 또는 점검 흐름.
- pane: 동시에 봐야 하는 영역. 예: editor, shell, log/browser.
- surface/tab: 같은 pane 안에서 바꿔 볼 terminal/browser/file preview.
- sidebar: 여러 작업의 상태판. branch, cwd, port, PR, notification을 보고 이동합니다.

일반 원칙은 단순합니다. 새 일감은 cmux workspace로 열고, 반복 명령은 pane에 남기고,
세부 대화형 선택은 `bb <tool>`에 맡깁니다.

## 하루 시작 루틴

1. 자주 쓰는 설정 작업판을 엽니다.

```sh
cmux ~/binbox
cmux ~/.config/nvim
```

2. 진행할 repo에서 목적에 맞는 workspace command를 실행합니다.

- Go repo: `Go Dev`
- Python repo: `Python Dev`
- Terraform repo: `Terraform Ops`
- Kubernetes 점검: `Kubernetes Ops`

3. agent가 필요하면 현재 작업판에서 `Codex` 또는 `Claude` action을 실행합니다.

## 작업별 흐름

### Go 개발

- `Go Dev`를 현재 repo에서 실행합니다.
- 왼쪽 editor pane에서 `nvim`으로 수정합니다.
- shell pane에서 `go env GOMOD`, `go test ./...`, 필요한 `go test ./... -run <TestName>`을 실행합니다.
- 로그나 실행 결과를 오래 봐야 하면 test pane을 그대로 둡니다.

### Python 개발

- `Python Dev`를 현재 repo에서 실행합니다.
- `.venv`가 없으면 shell pane에서 `python -m venv .venv`를 실행합니다.
- Neovim에서는 `:help nvim-python-go` 또는 venv selector 흐름을 따릅니다.
- test pane에서 `python -m pytest`와 lint 명령을 반복합니다.

### Terraform 작업

- `Terraform Ops`를 module 또는 root repo에서 실행합니다.
- 먼저 `bb tfplan`으로 plan을 만들고, `bb tfsum tree`로 변경을 훑습니다.
- markdown 요약이 필요하면 `bb tfsum md plan-summary.md`를 사용합니다.
- apply는 바로 실행하지 말고 `bb tfapply session 15`로 계정 확인 세션을 연 뒤 `bb tfapply`를 실행합니다.

### Kubernetes 점검

- `Kubernetes Ops`를 실행합니다.
- context pane에서 `bb kctx`, `bb kns`로 대상 환경을 정합니다.
- logs pane에서 `bb klog` 또는 `bb klog -n <namespace>`로 로그를 봅니다.
- shell pane에서 `bb kexec`, `bb kpf`, `kubectl get pods -A`를 실행합니다.

### binbox 도구 개발

- `Open binbox`를 실행합니다.
- `bb list`로 도구 목록을 확인합니다.
- 새 도구는 `bb new <name>`로 만들고, 검증은 `bb check`와 repo test를 사용합니다.
- cmux 문서나 설정에서 binbox 명령을 부를 때는 alias가 아니라 `bb <tool>` 형태만 사용합니다.

### Neovim 설정 작업

- `Open Neovim Config`를 실행합니다.
- docs pane의 힌트에 따라 `:help nvim-devops-workflow`, `:help nvim-python-go`,
  `:help nvim-terminal-tmux`를 확인합니다.
- 설정 변경 후 `./scripts/test-setup.sh` 또는 필요한 headless check를 실행합니다.

## browser 사용

cmux browser는 dev server, 문서, PR, preview를 terminal 옆에서 보는 용도입니다.

```sh
cmux browser open http://localhost:3000
cmux browser open http://127.0.0.1:8000
```

터미널 링크와 `open http://...`는 cmux browser로 들어오도록 설정되어 있습니다.
localhost 계열 HTTP는 warning 없이 열리도록 허용합니다.

## 알림 사용

- agent permission prompt, idle reminder, turn complete 알림은 켜져 있습니다.
- turn complete는 `whenIdle`이라 agent가 아직 background work를 처리 중이면 알림을 늦춥니다.
- 읽지 않은 알림으로 이동하려면 `cmux jump-to-unread`를 씁니다.
- sidebar에서 notification message와 unread ring을 보고 어느 workspace가 막혔는지 확인합니다.

## 설정 변경 루틴

1. `config.d/` 아래 역할별 JSON fragment를 수정합니다.
2. generated output인 `cmux.json`을 재생성합니다.

```sh
python3 scripts/build-config.py
```

3. generated output drift, JSON 문법, cmux validation, sensitive key scan을 확인합니다.

```sh
./scripts/check-config.sh
```

4. 실행 중인 앱에 반영합니다.

```sh
cmux reload-config
```

`Broken pipe`나 socket 오류가 나면 cmux 앱을 재시작합니다. 설정 파일 자체가 유효한지는
`./scripts/check-config.sh` 결과를 기준으로 판단합니다.

`cmux.json`은 cmux가 읽는 generated output입니다. 직접 수정하지 않고, 변경 내용은
`config.d/` source fragment에 남깁니다.

## 프로젝트별 설정

전역 `cmux.json`에는 반복해서 쓰는 공통 workflow만 둡니다. 특정 repo에만 맞는 명령은
해당 repo의 `.cmux/cmux.json`에 둡니다.

예시:

- 특정 backend의 `make dev`
- 특정 frontend의 `pnpm dev`
- 특정 docker compose stack
- 특정 service의 dashboard URL

전역 설정에 프로젝트 전용 명령을 넣으면 다른 repo에서 Command Palette가 지저분해지고,
경로가 없는 장비에서 실패하기 쉽습니다.

## 안전 규칙

- agent action에는 권한 우회 플래그를 넣지 않습니다.
- secret, token, password, session restore approval은 Git에 넣지 않습니다.
- `terminal.resumeCommands`는 local approval signature를 포함할 수 있으므로 추적하지 않습니다.
- `bb` 명령은 PATH에 있어야 합니다. 새 장비에서는 `~/binbox/bb setup`을 먼저 실행합니다.
