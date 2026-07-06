# cmux config split

이 repo의 cmux config는 사람이 수정하는 source와 cmux가 읽는 generated output을
분리합니다.

- Source: `config.d/**/*.json`
- Generated output: `cmux.json`
- Generator: `scripts/build-config.py`
- Full validation: `scripts/check-config.sh`

`cmux.json`은 직접 수정하지 않습니다. 수정이 필요하면 fragment를 바꾸고 build합니다.

## fragment 규칙

`config.d/base/*.json`은 top-level object입니다. 각 파일의 key는 최종 `cmux.json`의
top-level key로 merge됩니다.

- `base/app.json`: `$schema`, `schemaVersion`, `app`
- `base/terminal.json`: `terminal`
- `base/notifications.json`: `notifications`
- `base/sidebar.json`: `sidebar`
- `base/automation.json`: `automation`
- `base/browser.json`: `browser`
- `base/workspace-groups.json`: `workspaceGroups`
- `base/shortcuts.json`: `shortcuts`
- `base/viewers.json`: `fileExplorer`, `diffViewer`, `markdown`

`config.d/actions/*.json`은 action id를 key로 갖는 object입니다. generator가 이
object들을 최종 `actions` object 안으로 merge합니다.

`config.d/ui/main.json`은 최종 `ui` object의 내용입니다.

`config.d/commands/*.json`은 command array입니다. generator가 파일 순서대로 array를
concatenate해 최종 `commands`에 넣습니다. 현재 순서는 `tools.json`, `dev.json`,
`ops.json`입니다.

모든 fragment는 strict JSON입니다. comment, trailing comma, JSONC syntax를 쓰지 않습니다.

## validation 규칙

`scripts/build-config.py`는 다음 문제를 build 실패로 처리합니다:

- `base` fragment 사이의 top-level key 중복
- `actions` fragment 사이의 action key 중복
- `commands` fragment 사이의 command `name` 중복
- object가 필요한 fragment에 array가 들어간 경우
- command object에 비어 있지 않은 string `name`이 없는 경우

generated output은 deterministic pretty JSON으로 `cmux.json`에 기록됩니다.

## build workflow

fragment를 수정한 뒤:

```sh
python3 scripts/build-config.py
./scripts/check-config.sh
git diff
```

`cmux.json`이 source와 같은지 확인만 하려면:

```sh
python3 scripts/build-config.py --check
```

`scripts/check-config.sh`는 다음을 순서대로 실행합니다:

```sh
python3 scripts/build-config.py --check
python3 -m json.tool cmux.json
cmux config check
scripts/check-sensitive.sh
```

## 새 action 추가

1. agent나 tool 실행 action이면 `config.d/actions/agents.json`에 추가합니다.
2. workspace command를 menu에서 호출하는 action이면 `config.d/actions/workspaces.json`에 추가합니다.
3. UI에 노출해야 하면 `config.d/ui/main.json`의 button 또는 context menu에 action id를 추가합니다.
4. `python3 scripts/build-config.py`와 `./scripts/check-config.sh`를 실행합니다.

action id는 안정적인 namespace를 씁니다. 예: `agent.codex`, `workspace.go`,
`binbox.doctor`.

## 새 command 추가

1. 도구 repo 고정 layout은 `config.d/commands/tools.json`에 추가합니다.
2. language 개발 layout은 `config.d/commands/dev.json`에 추가합니다.
3. infrastructure 또는 운영 layout은 `config.d/commands/ops.json`에 추가합니다.
4. Command Palette나 menu에서 바로 실행해야 하면 matching action을
   `config.d/actions/workspaces.json`에 추가합니다.
5. `config.d/ui/main.json`의 `newWorkspace.contextMenu`에 action id를 추가합니다.
6. `python3 scripts/build-config.py`와 `./scripts/check-config.sh`를 실행합니다.

전역 command에는 프로젝트 전용 build/test command를 넣지 않습니다. 특정 repo에만 맞는
workflow는 해당 repo의 `.cmux/cmux.json`에 둡니다.

## commit workflow

커밋 전 확인:

```sh
./scripts/check-config.sh
git diff --check
git status --short
```

`config.d/`, `cmux.json`, 관련 문서를 함께 commit합니다. `cmux.json`만 바뀐 diff나
fragment만 바뀐 diff는 build workflow가 빠진 신호로 봅니다.
