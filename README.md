# cmux-config

cmux 설정을 GitHub로 관리하고 여러 Mac에서 같은 설정을 쓰기 위한 repo입니다.

이 설정은 `~/.config/nvim`과 `~/binbox`를 전제로 한 보완형 작업판입니다. tmux,
Neovim, binbox 흐름을 cmux로 대체하지 않고, cmux의 command palette, workspace,
agent notification, in-app browser를 상위 진입점으로 사용합니다.

## 사용법

새 장비에서 repo를 실제 cmux 설정 디렉토리로 clone한 뒤:

```sh
git clone https://github.com/jisung9870/cmux-config.git ~/.config/cmux
cd ~/.config/cmux
```

cmux의 보조 설정 파일을 연결합니다:

```sh
./scripts/bootstrap.sh
```

기본값은 symlink 방식입니다. `cmux.json`은 이미 실제 설정 위치에 있고, `Application Support` 아래의 보조 설정 파일만 이 repo의 파일을 직접 가리키게 됩니다. 설정 변경 후 Git diff로 바로 확인할 수 있습니다.

일회성 복사만 원하면:

```sh
./scripts/bootstrap.sh --copy
```

적용 후 cmux가 이미 실행 중이면 설정을 다시 읽습니다:

```sh
cmux reload-config
```

`cmux` CLI가 아직 PATH에 없으면 앱을 재시작해도 됩니다.

## config 관리 방식

사람이 수정하는 source는 `config.d/` 아래 역할별 JSON fragment입니다. `cmux.json`은
cmux가 실제로 읽는 generated output으로 유지하고 Git에도 commit합니다. 새 Mac에서
clone 직후에도 cmux가 바로 설정을 읽을 수 있게 하기 위해서입니다.

수정 루틴은 다음 순서로 고정합니다:

```sh
# config.d/**/*.json 수정
python3 scripts/build-config.py
./scripts/check-config.sh
git diff
```

`cmux.json`을 직접 수정하지 않습니다. 직접 수정한 내용은 다음 build 때 사라집니다.
generated output이 source와 맞는지만 확인하려면 다음 명령을 씁니다:

```sh
python3 scripts/build-config.py --check
```

fragment 규칙과 새 action/command 추가 방법은 [docs/config-split.md](docs/config-split.md)에 정리했습니다.

## 권장 기본 설정

`cmux.json`에는 기본 동작을 크게 바꾸지 않는 보수적 편의 설정만 활성화했습니다.

- App: telemetry 비활성화, 종료 확인은 변경/작업 중 상태일 때만, Markdown은 cmux viewer로 열기, Command Palette는 모든 surface 검색
- Terminal: agent session 자동 resume 유지, renderer memory 회수 유지, agent hibernation은 안정성을 위해 비활성화
- Notifications: agent 권한 요청/idle/turn complete 알림을 명시하되 turn complete는 `whenIdle`로 제한
- Browser: 터미널 링크는 cmux browser에서 열고, 다운로드는 저장 위치를 묻게 설정
- Workspace groups: `~/home/projects`, `~/home/lab`, `~/home/poc`, `~/home/work-history`, `~/binbox`, `~/.config/nvim`, `~/.config/cmux`를 색상/아이콘으로 구분
- Shortcuts: sidebar focus 중에는 workspace/surface 번호 선택 단축키가 동작하지 않게 해 입력 충돌을 줄임

## 작업 흐름

Command Palette에서 바로 열 수 있는 전역 작업판을 관리합니다:

- `Open binbox`: `~/binbox`에서 `nvim`, shell, `bb list`를 엽니다.
- `Open Neovim Config`: `~/.config/nvim`에서 설정과 help 문서 작업을 엽니다.
- `Go Dev`: 현재 디렉토리 기준 Go 편집/테스트 작업판을 엽니다.
- `Python Dev`: 현재 디렉토리 기준 Python venv/pytest 작업판을 엽니다.
- `Terraform Ops`: 현재 디렉토리 기준 `bb tfx plan`, `bb tfx sum`, `bb tfx apply` 흐름을 엽니다.
- `Kubernetes Ops`: 현재 디렉토리 기준 `bb kx ctx`, `bb kx ns`, `bb kx log`, `bb kx exec`, `bb kx pf` 힌트 작업판을 엽니다.

Surface tab bar에는 기본 터미널/브라우저/split 버튼에 더해 `Codex`, `Claude`,
`Binbox Doctor`를 둡니다. agent 실행은 권한 우회 플래그 없이 기본 명령만 사용합니다.

세부 설명은 [docs/workflows.md](docs/workflows.md)에 정리했습니다.

cmux를 실제로 어떻게 쓰면 되는지 빠르게 보려면 [docs/cheatsheet.md](docs/cheatsheet.md)를 먼저 봅니다.
작업별 운영 흐름은 [docs/usage-guide.md](docs/usage-guide.md)에 정리했습니다.

## 현재 장비 변경분 가져오기

cmux 설정을 앱에서 바꾼 뒤 repo로 반영하려면 generated output을 먼저 가져온 뒤,
필요한 변경만 `config.d/` source fragment로 옮깁니다:

```sh
./scripts/pull-local.sh
git diff cmux.json
```

fragment를 수정한 뒤 다시 build하고 확인합니다:

```sh
python3 scripts/build-config.py
git diff
./scripts/check-config.sh
git status --short
```

cmux 적용 확인은 앱에서 설정 reload를 실행하거나 cmux를 재시작한 뒤 확인합니다.

앱에서 생성되는 session restore 승인, 브라우저 기록, socket, password/token류는 repo에
넣지 않습니다. `scripts/check-sensitive.sh`는 커밋 전 항상 실행합니다.

## GitHub 동기화 흐름

```sh
git add README.md docs scripts config.d cmux.json app-support .gitignore .gitattributes
git commit -m "Improve cmux defaults"
git push
```

다른 장비에서는 `~/.config/cmux`에 clone 후 `./scripts/bootstrap.sh`를 실행하면 됩니다. 기존 로컬 파일이 있으면 같은 경로에 `*.backup.YYYYMMDDHHMMSS`로 백업하고 관리 파일을 적용합니다.

## 추적 범위

추적 대상과 제외한 런타임 파일의 기준은 [docs/managed-files.md](docs/managed-files.md)에 정리했습니다.
