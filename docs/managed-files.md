# Managed files

이 repo는 여러 Mac에서 재사용할 수 있는 portable cmux 설정만 추적합니다.

## 포함하는 파일

- `config.d/**/*.json`
  - 사람이 수정하는 cmux config source fragment입니다.
  - `base`, `actions`, `ui`, `commands`로 역할을 나눕니다.
  - strict JSON만 사용합니다. JSONC comment나 외부 dependency는 쓰지 않습니다.
- `cmux.json`
  - cmux가 실제로 읽는 generated output입니다.
  - source는 아니지만 clone 직후 cmux가 바로 읽을 수 있게 Git에 commit합니다.
  - `scripts/build-config.py`로만 재생성합니다.
- `app-support/com.cmuxterm.app/config.ghostty`
  - 원본 위치: `~/Library/Application Support/com.cmuxterm.app/config.ghostty`
  - cmux terminal theme 설정입니다.
- `app-support/com.cmuxterm.app/config.synced-preview`
  - 원본 위치: `~/Library/Application Support/com.cmuxterm.app/config.synced-preview`
  - 현재 장비에서는 비어 있지만, 향후 synced preview 설정을 안정적으로 둘 위치로 추적합니다.

`commands` fragment의 command는 shell alias에 의존하지 않고 `bb <tool>`을 호출합니다.
cmux가 command 실행 전에 interactive rc file을 source하지 않을 수 있기 때문입니다.

## 제외하는 파일

아래 파일은 추적하지 않습니다:

- `~/.cmuxterm/*.jsonl`
- `~/.cmuxterm/claude-hook-sessions.json`
- `~/Library/Application Support/cmux/search.db*`
- `~/Library/Application Support/cmux/session-*.json`
- `~/Library/Application Support/cmux/cmux.sock`
- `~/Library/Application Support/com.cmuxterm.app/browser_history.json`
- `~/Library/Application Support/com.cmuxterm.app/phc_*/`
- `~/Library/Preferences/com.cmuxterm.app.plist`

이 파일들은 local session, log, browser history, socket, telemetry/cache data,
window geometry, machine-specific identifier를 포함하거나 장비별로 분리하는 편이 안전한 값입니다.

추가로 아래 값은 Git에 넣지 않습니다:

- live machine에서 복사한 `terminal.resumeCommands`
- `automation.socketPassword` 또는 password/token/key field
- 모든 Mac에서 같은 command를 쓰지 않는 machine-specific editor path

커밋 전에는 `./scripts/check-config.sh`를 실행해 generated output drift, JSON 문법,
cmux validation, sensitive key scan을 함께 확인합니다.
