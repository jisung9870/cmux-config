# cmux-config

cmux 설정을 GitHub로 관리하고 여러 Mac에서 같은 설정을 쓰기 위한 repo입니다.

## 사용법

새 장비에서 repo를 clone한 뒤:

```sh
./scripts/bootstrap.sh
```

기본값은 symlink 방식입니다. cmux가 읽는 실제 위치가 이 repo의 파일을 직접 가리키므로, 설정 변경 후 Git diff로 바로 확인할 수 있습니다.

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
git add README.md docs scripts config app-support .gitignore .gitattributes
git commit -m "Manage cmux configuration"
git remote add origin git@github.com:<owner>/<repo>.git
git push -u origin main
```

다른 장비에서는 clone 후 `./scripts/bootstrap.sh`를 실행하면 됩니다. 기존 로컬 파일이 있으면 같은 경로에 `*.backup.YYYYMMDDHHMMSS`로 백업하고 관리 파일을 적용합니다.

## 추적 범위

추적 대상과 제외한 런타임 파일의 기준은 [docs/managed-files.md](docs/managed-files.md)에 정리했습니다.

