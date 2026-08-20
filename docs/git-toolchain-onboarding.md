# git 도구 체인 온보딩 — lazygit + delta + difftastic

터미널 git의 **조작은 TUI가, diff 가독성은 pager가** 담당한다. lazygit·gitui·tig는 diff를 **git 원시 출력 그대로** 보여주므로, 렌더러를 안 붙이면 어떤 클라이언트를 써도 diff는 밋밋하다.

| 층 | 담당 | 이 문서가 쓰는 것 |
|---|---|---|
| TUI | 스테이징·브랜치·커밋 조작 | **lazygit** |
| **pager** | **색·나란히보기·줄번호·구조비교** | **delta** · **difftastic** |

> 검증 기준 환경: macOS aarch64 · Homebrew · lazygit 0.64.1 · delta 0.19.2 · difftastic 0.70.0 · git 2.48.1 (2026-08-20 실측)

---

## 0. 5분 요약

```bash
brew install lazygit git-delta difftastic
lazygit --config | grep -E 'diffRenderers|pagers'   # ← 아래 §2 분기 판별
```
그다음 **§2**(lazygit)와 **§3**(git 전역) 블록을 복붙하면 끝.

---

## 1. 설치

```bash
brew install lazygit git-delta difftastic
```

⚠️ **formula 이름이 명령 이름과 다르다.**

| formula | 실행 명령 |
|---|---|
| `git-delta` | `delta` |
| `difftastic` | `difft` |

```bash
lazygit --version && delta --version && difft --version   # 확인
```

---

## 2. lazygit 설정

### 🔴 먼저 — 버전에 따라 키 이름이 다르다

**공식 문서 기본 브랜치는 최신 키만 설명한다. 구버전에 그 문안을 붙이면 에러 없이 무시된다.**

```bash
lazygit --config | grep -E 'diffRenderers|pagers'
```

| 출력 | 쓸 블록 |
|---|---|
| `diffRenderers: []` | **A** (0.61 이상) |
| `pagers: []` | **B** (0.60 이하) |

설정 파일 경로:
```bash
lazygit --print-config-dir      # macOS: ~/Library/Application Support/lazygit
```

### 블록 A — `diffRenderers` (0.61+)

`config.yml`의 `git:` 섹션에 넣는다. `|` 키로 순환하고 상태바에 이름이 뜬다.

```yaml
git:
  diffRenderers:
    - command: delta --dark --paging=never --side-by-side --line-numbers
      name: delta
    - command: delta --dark --paging=never --line-numbers
      name: delta-1col
    - type: extDiff
      command: difft --color=always --context={{diffContext}}
      name: difftastic
    - type: rawGit
      name: default
```

| 항목 | 언제 |
|---|---|
| `delta` | 기본 — 화면이 넓을 때 |
| `delta-1col` | 패널이 좁을 때(`mainPanelSplitMode: horizontal` 등) |
| `difftastic` | 포맷 변경을 걸러내고 실질 변경만 보고 싶을 때 |
| `default` | git 원본 — 탈출구 |

`type` 값: `stdinFilter`(기본·생략 가능·GIT_PAGER 경유) · `extDiff`(git `--ext-diff`) · `rawGit`(git 인자만 추가).

### 블록 B — `pagers` (0.60 이하)

```yaml
git:
  pagers:
    - pager: delta --dark --paging=never --side-by-side --line-numbers
    - externalDiffCommand: difft --color=always
```

---

## 3. git 전역 pager

터미널에서 `git diff`·`git show`·`git log -p`를 직접 칠 때도 delta를 쓴다. `~/.gitconfig`:

```gitconfig
[core]
	pager = delta
[interactive]
	diffFilter = delta --color-only
[delta]
	navigate = true
	dark = true
	line-numbers = true
```

명령으로 넣으려면:

```bash
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.dark true
git config --global delta.line-numbers true
```

| 키 | 효과 |
|---|---|
| `core.pager` | `git diff`·`show`·`log -p` |
| `interactive.diffFilter` | `git add -p` 등 대화형 |
| `delta.navigate` | `n` / `N` 으로 파일 간 점프 |
| `delta.dark` | 다크 배경 팔레트 (밝은 테마면 `delta.light true`) |

### 선택 — 머지 충돌까지

```gitconfig
[merge]
	conflictStyle = zdiff3
```
충돌 마커에 **원본(base)까지** 표시해 3-way 머지가 훨씬 읽힌다. ⚠️ pager가 아니라 **충돌 마커 포맷을 바꾸는 설정**이고 git 2.35 이상이 필요하다.

### 선택 — 줄번호 클릭으로 에디터 열기

블록 A의 `command` 를 이걸로 바꾼다:
```
delta --dark --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"
```
⚠️ 터미널이 OSC 8 하이퍼링크를 지원해야 한다. delta의 `--navigate` 는 lazygit 안에서 동작하지 않는다.

---

## 4. 적용 시점

- **lazygit·git 설정**: 다음에 새로 여는 프로세스부터.
- ⚠️ **이미 떠 있는 lazygit은 반영되지 않는다** — brew는 디스크 바이너리만 교체하고 실행 중 인스턴스는 메모리의 옛 이미지를 유지한다. **재시작해야 한다.**

---

## 부록 — 이 문서가 다루지 않는 것

- **검증 절차**(설정이 실제로 먹었는지 확인하는 법)와 **되돌리기**, **실패 사례·계기 함정**은 이 문서 범위 밖이다.
- 그 내용은 `docs/handoff/2026-08-20-git-diff-toolchain-lazygit-delta.md` 에 실측과 함께 정리돼 있고, dakman-wiki `wiki/git-diff-toolchain` 으로 ingest 위임 중이다.
