# cmux-config

cmux 설정을 GitHub로 관리하고 여러 Mac에서 같은 설정을 쓰기 위한 repo입니다.

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

## 현재 장비 변경분 가져오기

cmux 설정을 앱에서 바꾼 뒤 repo로 반영하려면:

```sh
./scripts/pull-local.sh
```

그 다음 확인:

```sh
git diff
./scripts/check-sensitive.sh
git status --short
```

## GitHub 동기화 흐름

```sh
git add README.md docs scripts cmux.json app-support .gitignore .gitattributes
git commit -m "Manage cmux configuration"
git remote add origin git@github.com:<owner>/<repo>.git
git push -u origin main
```

다른 장비에서는 `~/.config/cmux`에 clone 후 `./scripts/bootstrap.sh`를 실행하면 됩니다. 기존 로컬 파일이 있으면 같은 경로에 `*.backup.YYYYMMDDHHMMSS`로 백업하고 관리 파일을 적용합니다.

## 추적 범위

추적 대상과 제외한 런타임 파일의 기준은 [docs/managed-files.md](docs/managed-files.md)에 정리했습니다.
