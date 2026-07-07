# cmux 사용 가이드 (lazyvim + tmux 사용자용)

이미 **LazyVim + tmux**로 일하고 있고, 여기에 **cmux**를 얹어 제대로 쓰고 싶은 사람을 위한 실전 가이드입니다.
cmux는 tmux/nvim/binbox를 대체하지 않습니다. 그 위에 얹는 **최상위 GUI 오케스트레이터**입니다.

> 이 문서를 cmux 안에서 열기: `cmux open docs/guide.md` (내장 마크다운 뷰어로 렌더링됩니다)
> 빠른 참조는 [cheatsheet.md](cheatsheet.md), 워크플로우별 상세는 [usage-guide.md](usage-guide.md) 참고.

---

## 1. 역할 분담 — 무엇을 무엇으로 하나

| 도구 | 역할 | 예 |
|---|---|---|
| **cmux** | 최상위 GUI. 프로젝트별 작업공간 전환, pane/탭 배치, 브라우저, **AI 에이전트 상태·알림 관리** | 워크스페이스 전환, 내장 브라우저, Claude/Codex 실행·감시 |
| **tmux** | 서버측 **영속 세션**. 접속이 끊겨도 살아있어야 하는 것 | 원격 SSH 세션, 장시간 빌드/서버, detach 후 재접속 |
| **LazyVim** | 편집기 | 코드 편집, LSP, git |
| **binbox(`bb`)** | CLI 도구 모음 | `bb kx`, `bb tfx`, `bb tm`, `bb doctor` |

핵심 감각: **"이 창을 닫아도 살아있어야 하나?" → tmux. "지금 화면을 어떻게 배치하고 무슨 에이전트를 돌리나?" → cmux.**

---

## 2. 구조: Window > Workspace > Surface > Pane

cmux의 계층을 알면 단축키가 전부 이해됩니다.

```
Window (앱 창, ⌘⇧N)
└─ Workspace (왼쪽 사이드바의 항목, ⌘N / ⌘1..9)   ← 보통 "프로젝트 하나 = 워크스페이스 하나"
   └─ Pane (화면 분할, ⌘D / ⌘⇧D)
      └─ Surface = 탭 (⌘T / ⌃1..9)                ← 터미널 · 브라우저 · 파일뷰어
```

- **Workspace**: 사이드바에 쌓이는 작업공간. cwd(폴더)에 묶여 있고, 경로별로 색/아이콘이 자동 지정됩니다(§ 7).
- **Pane**: 한 워크스페이스 안의 분할 화면.
- **Surface**: pane 안의 탭. 터미널일 수도, 브라우저일 수도, 마크다운 뷰어일 수도 있습니다.

---

## 3. 5분 시작하기

```sh
cmux ~/home/projects/foo    # 폴더를 새 워크스페이스로 열기 (앱이 꺼져 있으면 실행됨)
```

그다음 앱 안에서:

1. **⌘⇧P** — Command Palette. **여기서 등록된 모든 액션/워크스페이스 명령을 검색**합니다. "그 기능 어디 있지?" 싶으면 무조건 여기.
2. **⌘N** — 새 워크스페이스. 또는 사이드바의 **New Workspace 메뉴**에서 미리 만든 레이아웃(Open binbox / Go Dev / Kubernetes Ops 등, § 6) 선택.
3. **⌘D / ⌘⇧D** — 오른쪽/아래로 분할.
4. **⌘T** — pane 안에 새 탭(surface).
5. **⌘1~9** — 워크스페이스 전환. **⌃1~9** — 같은 pane의 탭 전환.

---

## 4. 매일 쓰는 단축키

cmux 기본값 기준입니다. (전체: **⌘,** → Settings > Keyboard Shortcuts, 또는 터미널에서 `cmux docs shortcuts`)

### 이동 · 창
| 키 | 동작 |
|---|---|
| **⌘⇧P** | Command Palette (모든 명령 검색) |
| **⌘1…9** | 워크스페이스 1~9 선택 |
| **⌃⌘] / ⌃⌘[** | 다음 / 이전 워크스페이스 |
| **⌘B** | 왼쪽 사이드바 토글 |
| **⌘⌥B** | 오른쪽 사이드바(파일 탐색기) 토글 |
| **⌘N** | 새 워크스페이스 · **⌘O** 폴더 열기 |
| **⌘⇧,** | **설정 리로드** (config.d 편집 후 반영 — CLI 불필요, § 10) |

### 분할(pane) · 탭(surface)
| 키 | 동작 |
|---|---|
| **⌘D / ⌘⇧D** | 오른쪽 / 아래 분할 |
| **⌥⌘ ←↑↓→** | 방향으로 pane 포커스 이동 |
| **⌘⇧↩** | 현재 pane 확대/축소(zoom) 토글 |
| **⌃⌘=** | 분할 크기 균등화 |
| **⌘T** | 새 탭 · **⌃1…9** 탭 선택 · **⌘W** 탭 닫기 |
| **⌘⇧T** | 방금 닫은 것 다시 열기 |
| **⌘⇧K** | 화면 클리어(스크롤백 유지) · **⌘⇧M** 복사 모드 |

### 브라우저 · 검색 · 알림
| 키 | 동작 |
|---|---|
| **⌘⇧L** | 브라우저 열기 · **⌘L** 주소창 |
| **⌘F** 찾기 · **⌘⇧F** | 디렉토리 내 검색 |
| **⌘I** 알림 패널 · **⌘⇧U** | 최신 미읽음으로 점프 (에이전트 감시 핵심, § 6) |

> **Canvas 모드**(⌃⌘C): pane들을 자유 배치 캔버스로 보는 모드. 여러 에이전트를 한눈에 볼 때 유용. ⌃⌘T로 그리드 정렬.

---

## 5. tmux와 함께 쓰기

둘은 층이 다르므로 **경쟁이 아니라 중첩**입니다.

- cmux **pane 안에서 그냥 tmux를 씁니다**: `tmux attach -t <세션>` (또는 `bb tm`).
- tmux 서버는 launchd 밑에서 도는 **독립 데몬**이라, **cmux를 재시작/종료해도 tmux 세션은 유지**됩니다. cmux pane이 닫히면 tmux 클라이언트만 detach될 뿐입니다.

권장 분담 패턴:

| 상황 | 권장 |
|---|---|
| 원격 SSH, 장시간 서버/빌드, "끊겨도 살아야 함" | **tmux** 세션 (cmux pane에서 attach) |
| 프로젝트별 화면 배치, 로컬 개발, 브라우저 붙이기 | **cmux** 워크스페이스/pane |
| AI 에이전트(Claude/Codex) 실행·감시 | **cmux** (§ 6 — 상태 추적·알림·세션 복원이 여기서만 됨) |

즉, "화면 배치와 에이전트는 cmux, 영속 세션은 tmux"로 나누면 충돌이 없습니다.

---

## 6. Claude Code / Codex를 cmux로 잘 쓰기 ⭐

cmux가 에이전트에 좋다는 이유는 **에이전트를 그냥 실행**하는 게 아니라 **상태를 추적하고 관리**해주기 때문입니다.

### 무엇을 해주나
- **상태 추적**: 각 에이전트 탭의 상태(`running` / `idle` / `needsInput`)를 인식해 사이드바에 표시.
- **알림**: 턴 완료·권한 요청 시 macOS 알림 + Dock 배지 + 메뉴바 + **pane 링/플래시**. → **⌘⇧U**로 "손이 필요한 에이전트"로 바로 점프. (당신 설정: `agentTurnComplete: whenIdle`, `agentPermissionPrompt: true`)
- **Feed (사이드바 인라인 승인)**: 권한/플랜/질문 승인을 탭 안 들어가지 않고 사이드바에서 바로 처리. `cmux hooks setup`이 이 브릿지를 깔아줍니다.
- **세션 자동 복원**: 앱을 정상 재시작해도 각 에이전트를 native resume(`claude --resume <id>`, `codex resume <id>`)으로 되살립니다. (당신 설정: `autoResumeAgentSessions: true`)
- **Agent Hibernation**(옵션, 기본 off): 유휴 백그라운드 에이전트를 죽여 RAM 회수 후, 탭 복귀 시 세션째 재개. 12개 넘게 동시에 돌릴 때만 발동.

### 켜는 법
- **Claude Code**: 설정의 `claudeCodeIntegration`이 켜져 있으면(당신은 `true`) cmux 래퍼가 자동 처리. 별도 작업 불필요.
- **Codex 및 기타**(grok, opencode, gemini, cursor 등): 한 번만
  ```sh
  cmux hooks setup            # PATH에 있는 지원 에이전트 전부 설치
  cmux hooks setup codex      # 특정 에이전트만
  ```
  이걸 하면 Codex도 상태 추적·알림·세션 복원·Feed가 붙습니다.

### 실전 패턴
1. 프로젝트 워크스페이스를 열고(§ 3), 탭바의 **Claude** 또는 **Codex** 버튼(또는 팔레트에서 검색)으로 에이전트 탭을 띄웁니다.
2. 여러 프로젝트/작업에 각각 에이전트를 병렬로 돌립니다.
3. 다른 일을 하다가 **⌘⇧U**를 누르면 방금 끝났거나 승인이 필요한 에이전트로 이동합니다.
4. 승인은 Feed(사이드바)에서 바로, 재시작해도 세션은 복원됩니다.

> 이미 등록돼 있는 것: 탭바 버튼 `Codex`/`Claude`/`Binbox Doctor`, Command Palette 액션 `agent.codex`/`agent.claude`.

---

## 7. 워크스페이스 그룹 (경로별 자동 색/아이콘)

특정 폴더에서 워크스페이스를 열면 색과 아이콘이 자동 지정됩니다 — 사이드바에서 프로젝트를 한눈에 구분하려는 장치입니다.

| 경로 | 색 | 아이콘 |
|---|---|---|
| `~/home/projects` | 파랑 | folder |
| `~/home/lab` | 청록 | testtube |
| `~/home/poc` | 노랑 | lightbulb |
| `~/home/work-history` | 보라 | doc |
| `~/binbox` | 초록 | terminal |
| `~/.config/nvim` | 올리브 | pencil |
| `~/.config/cmux` | 주황 | switch |

새 그룹은 ⌃⌘G, 선택한 워크스페이스 묶기는 ⌘⇧G.

---

## 8. 브라우저 활용

- **⌘⇧L**로 브라우저 surface를 엽니다. 로컬 개발서버 미리보기에 좋습니다.
- 터미널에 뜬 링크(`http://localhost:3000` 등)를 클릭하면 **cmux 내장 브라우저로 자동 오픈**됩니다 (localhost 계열은 보안 예외 허용).
- ⌥⌘D로 pane을 브라우저로 분할해 "코드 | 미리보기" 배치를 만들 수 있습니다.

---

## 9. 등록된 워크스페이스 명령 (미리 만든 레이아웃)

New Workspace 메뉴 또는 팔레트에서:

| 명령 | cwd | 여는 것 |
|---|---|---|
| **Open binbox** | `~/binbox` | nvim + 셸 + `bb list` |
| **Open Neovim Config** | `~/.config/nvim` | nvim + docs 힌트 + checkhealth |
| **Go Dev** / **Python Dev** | 현재 폴더 | nvim + 언어별 테스트 힌트 |
| **Terraform Ops** | 현재 폴더 | nvim + `bb tfx plan/sum/session/apply` 힌트 |
| **Kubernetes Ops** | 현재 폴더 | `bb kx ctx/ns/log/exec/pf` 힌트 |

> 힌트 pane은 명령을 **인쇄만** 하고 자동 실행하지 않습니다(fzf 인터랙티브라서). 필요할 때 직접 실행하세요.

---

## 10. 설정 바꾸고 반영하기

이 저장소가 곧 cmux 설정입니다. **`cmux.json`은 직접 수정하지 않습니다** — `config.d/` 조각을 고치고 재생성합니다.

```sh
# 1. config.d/**/*.json 편집 (base / actions / commands / ui)
# 2. 재생성
python3 scripts/build-config.py
# 3. 검증 (drift / JSON / 시크릿 스캔)
./scripts/check-config.sh
# 4. 앱에 반영:  cmux에서 ⌘⇧,  (Reload configuration)
```

- **반영은 ⌘⇧, 단축키가 가장 확실합니다** (Ghostty + cmux.json 둘 다 리로드, 앱 재시작 불필요).
- 새 항목 추가 방법은 [config-split.md](config-split.md) 참고 (액션/워크스페이스 명령/탭바 버튼 등).

---

## 11. 자주 쓰는 CLI

```sh
cmux <path>                 # 폴더를 새 워크스페이스로 열기
cmux open <파일|URL>        # 파일/URL 열기 (md는 뷰어로)
cmux hooks setup            # 에이전트 통합 설치 (§ 6)
cmux docs [shortcuts|settings|agents|browser|dock]   # 공식 문서 바로가기(소켓 불필요)
cmux settings open          # 설정 창 열기
```

> `list-workspaces`, `tree`, `reload-config`, `ping` 등 **소켓 제어 명령**은 § 12 참고.

---

## 12. 트러블슈팅 — CLI 소켓 에러

`cmux reload-config` / `open` / `ping` / `list-workspaces` 등 **소켓을 쓰는 CLI**가 실패할 때. (GUI·단축키는 영향 없음)

### 증상 A — `Socket not found at .../Library/Application Support/cmux/cmux.sock`
- **원인**: cmux 앱을 **업데이트하면** 소켓 기본 경로가 바뀝니다(현재 기본값: `~/.local/state/cmux/cmux.sock`). 그런데 업데이트 전 버전이 띄운 **오래된 셸에 낡은 `CMUX_SOCKET_PATH`**(옛 경로)가 남아 있으면 CLI가 없어진 옛 소켓을 찾습니다.
- **해결**: **cmux에서 새 터미널 탭(⌘T)을 열어** 거기서 실행하세요. 새 pane은 올바른 환경변수를 받습니다. (옛 셸에서 임시로 넘기려면 `unset CMUX_SOCKET_PATH`)
- 확인: `env | grep CMUX_SOCKET_PATH` 값이 실제 앱 소켓(`cat /tmp/cmux-last-socket-path`)과 다르면 이 케이스입니다.

### 증상 B — `Failed to write to socket (Broken pipe, errno 32)`
- **원인**: `automation.socketControlMode`가 **`cmuxOnly`**(cmux 기본값)라 소켓 제어를 **현재 실행 중인 cmux 인스턴스가 관리하는 터미널**로 제한합니다. cmux 밖 셸이나, **업데이트로 교체되기 전(옛 인스턴스)에 뜬 pane**에서 실행하면 연결은 되지만 앱이 거부합니다. 고장이 아닙니다.
- **해결**: 마찬가지로 **업데이트/재시작 후 새로 연 cmux pane**에서 실행하세요.

### 어느 경우든 크리티컬하지 않음
- 설정 반영은 **⌘⇧,**(Reload configuration) 단축키로 됩니다 — 소켓 불필요.
- 앱을 재시작해도 설정은 반영되고 **tmux 세션은 유지**됩니다(§ 5).
- 파일만 열려면 `nvim docs/guide.md`처럼 에디터로 봐도 됩니다.

### CLI를 아무 터미널에서나 쓰고 싶다면
(스크립트/자동화 등) `config.d/base/automation.json`의 `socketControlMode`를 `"automation"` 또는 `"password"`(+ `socketPassword`)로 바꿉니다. 소켓을 더 여는 트레이드오프를 감안하세요.

---

## 참고 링크
- 빠른 참조: [cheatsheet.md](cheatsheet.md) · 워크플로우: [usage-guide.md](usage-guide.md) · 명령 목록: [workflows.md](workflows.md)
- 설정 구조: [config-split.md](config-split.md) · 관리 파일: [managed-files.md](managed-files.md)
- 공식 문서: https://cmux.com/docs · 에이전트 훅: `cmux docs agents`
