# [위임] dakman-wiki ingest 요청 — git diff 도구 체인 (lazygit + delta + difftastic)

- **요청 세션**: dakman-setup (`~/dakman/workspace/dakman-setup`)
- **작성일**: 2026-08-20 (`date` 실측)
- **회신처**: workspace `dakman-setup` / surface — `notify.sh --whoami` 참조
- **성격**: 비소유 세션의 **풀 문서 전달**(요약 아님). vault는 건드리지 않았다.
- **출처 등급**: 아래 수치·거동은 **전부 이 세션 1차 실측**(2026-08-20, macOS aarch64). 웹 인용 없음.
- **⚠️ `verified` 는 붙이지 말 것** — 사람 게이트(`wiki-verify`) 소관.

---

## 제안 페이지 초안 (`wiki/git-diff-toolchain.md`)

```markdown
---
created: 2026-08-20
updated: 2026-08-20
tags: [git, tooling, terminal, tui, diff, dev-env, ai-native]
source:
  - dakman-setup 세션 1차 실측 (2026-08-20)
  - https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_DiffRenderers.md
  - https://github.com/jesseduffield/lazygit/blob/v0.60.0/docs/Custom_Pagers.md
  - https://github.com/dandavison/delta
  - https://github.com/Wilfred/difftastic
sns_candidate: true
---

# git diff 도구 체인 (lazygit + delta + difftastic)

> **터미널 git의 diff 가독성은 클라이언트가 아니라 *렌더러*가 정한다.** lazygit·gitui·tig는 diff를 **git 원시 출력 그대로** 보여주고, 색·나란히보기·구조비교는 **pager 계층**(delta·difftastic)이 담당한다. 그래서 "lazygit 대안을 찾는" 문제가 대개 **"pager를 안 붙였다"** 로 끝난다.
> **출처**: 2026-08-20 dakman-setup 세션 1차 실측(설치·설정·대조 측정).

## 핵심 — 도구를 바꾸기 전에 pager를 본다

터미널 git TUI를 쓰는데 diff가 밋밋하면 **먼저 pager 설정이 비었는지 확인한다.**

| 층 | 담당 | 예 |
|---|---|---|
| 클라이언트(TUI) | 스테이징·브랜치·커밋 조작 | lazygit · gitui · tig · gitu |
| **렌더러(pager)** | **색·나란히보기·줄번호·구조비교** | **delta · difftastic · diff-so-fancy** |

⚠️ **gitui는 diff 가독성 축에서 lazygit 대안이 아니다** — side-by-side diff 이슈가 **2022-08(#1294)부터 미해결**이고 2026-07에 #2998로 재제기됐다(2026-08-20 확인). 별 수(22.4k)만 보고 고르면 이 축에서 다운그레이드다.

## 🔴 lazygit: 버전에 따라 config 키가 다르다 (조용히 안 먹는다)

| lazygit 버전 | pager 설정 키 |
|---|---|
| **0.60.0** | `git.pagers` |
| **0.64.1** | `git.diffRenderers` |

**공식 문서 기본 브랜치(master)는 최신 키만 설명한다.** 구버전에 그 문안을 붙이면 **에러 없이 무시**된다 — 실패가 조용하다.

🔑 **판별식**: 문서가 아니라 **설치본에 물어본다.**
```bash
lazygit --config | grep -E 'diffRenderers|pagers'
```
실측(2026-08-20): 0.60.0 → `pagers` 1건·`diffRenderers` 0건 / 0.64.1 → 정반대.

### 0.64.1 설정 (`diffRenderers` — `|` 키로 순환)
```yaml
git:
  diffRenderers:
    - command: delta --dark --paging=never --side-by-side --line-numbers
      name: delta
    - command: delta --dark --paging=never --line-numbers
      name: delta-1col            # 패널이 좁을 때(mainPanelSplitMode: horizontal 등)
    - type: extDiff
      command: difft --color=always --context={{diffContext}}
      name: difftastic
    - type: rawGit
      name: default               # git 원본 = 탈출구
```
`type`: `stdinFilter`(기본·GIT_PAGER 경유) / `extDiff`(git `--ext-diff`) / `rawGit`(git 인자만 추가).

### 0.60.0 이하 설정 (`pagers`)
```yaml
git:
  pagers:
    - pager: delta --dark --paging=never --side-by-side --line-numbers
    - externalDiffCommand: difft --color=always
```

## git 전역 pager (CLI `git diff`에도 적용)

delta 공식 README 권장 블록:
```gitconfig
[core]
    pager = delta
[interactive]
    diffFilter = delta --color-only     # git add -p
[delta]
    navigate = true                     # n / N 으로 파일 간 점프
    dark = true
    line-numbers = true
[merge]
    conflictStyle = zdiff3              # ⚠️ pager 아님 — 충돌 마커 포맷 변경 (git ≥ 2.35)
```

## difftastic — "더 예쁜"이 아니라 "더 의미적"

AST 기준으로 비교해 **포맷 변경을 변경이 아니라고 판정**한다. 실측(2026-08-20):

| 변경 | 결과 |
|---|---|
| `f(a,b)` → `f(a, b)` + 들여쓰기 2→4칸 | **`No syntactic changes.`** |
| `return a+b` → `return a-b` | 해당 줄만 구조 diff 표시 |

⇒ 포매터를 돌린 뒤 리뷰, 대규모 리팩터링 diff에서 실질 변경만 보고 싶을 때 효과가 크다.

## 🔴 검증 함정 — pager는 TTY에서만 뜬다

**이 절이 이 페이지에서 가장 재사용성이 높다.** pager 설정을 검증할 때 세 가지가 연속으로 틀렸다(2026-08-20 실측).

| 계기 | 왜 무효인가 | 증상 |
|---|---|---|
| `git diff \| <분석>` | **`core.pager`는 stdout이 TTY일 때만 발동**한다. 파이프면 git이 pager를 아예 안 부른다 | 대조군(`core.pager=cat`)과 실제 설정이 **똑같이 903 bytes** — "설정이 안 먹는다"로 오독 |
| `pgrep -f delta` | 검사 명령의 **명령줄 자체에 그 단어가 들어 있어 자기 자신에 매치** | 프로세스가 없는데 "✅ 관측"이 나옴 |
| `lazygit --print-config-dir` 로 config 검증 | 이 플래그는 **config를 파싱·검증하지 않는다** | 일부러 깨뜨린 config에도 **exit 0** |

**성립하는 검증**:
```bash
# pty 안에서 pager만 바꿔 대조 (DELTA_PAGER=cat 로 less 대기 방지)
#   대조군: core.pager=cat  → truecolor 0 · 배경 0 · 1100 bytes
#   실제:   core.pager=delta → truecolor 15 · 배경 39 · 3579 bytes
```
그리고 **프로세스 계보(PPID 체인)** 로 확인한다 — `git diff` → `/opt/homebrew/bin/delta` 자식 프로세스가 실제로 뜨는지.

## 🔴 프로세스 소유 판정은 이름이 아니라 PPID 계보로

`pgrep lazygit`에 23개가 떠서 "테스트가 leak했다"고 단정했으나, 계보를 끝까지 따라가니 **전부 사용자의 실제 터미널 페인**이었다:
```
lazygit → zsh → login → cmux.app
```
죽였으면 살아 있는 작업 세션을 날렸다. **같은 이름 = 내 프로세스가 아니다.** 판정은 조상 체인이 내 셸에 닿는지로 한다.

⚠️ 그리고 **이미 떠 있는 프로세스는 업그레이드를 못 받는다** — brew는 디스크 바이너리만 교체하고, 실행 중 인스턴스는 메모리의 옛 이미지를 유지한다. 재시작해야 반영된다.

## 실측 환경·수치 (2026-08-20)

| 항목 | 값 |
|---|---|
| 플랫폼 | macOS aarch64 (Apple Silicon), Homebrew |
| lazygit | 0.60.0 → **0.64.1** |
| delta | **0.19.2** |
| difftastic | **0.70.0** |
| git | 2.48.1 |
| delta 렌더 전/후 | 903 → 5,668 bytes (side-by-side, 같은 diff) |
| ANSI 밀도 (TTY) | git 원본 truecolor 0 → delta 15, 배경색 0 → 39 |

## 미검증 (한계)

- **`interactive.diffFilter`(`git add -p`)** — 대화형이라 런타임 확인 못 함. 설정은 delta 공식 권장값 그대로 넣었으나 **돌려본 것은 아니다.**
- **좁은 터미널 줄바꿈 거동** — 200칸에서만 측정.
- **difftastic의 언어 커버리지** — JavaScript 1건만 확인.
- **lazygit 외 TUI(gitui·tig·gitu)** — 설치·실행하지 않았다. 위 gitui 판정은 **이슈 트래커 근거**이지 실행 실측이 아니다.

## 관련

- [[gitleaks-precommit]] — 같은 층(git 훅·도구 체인)의 pre-commit 시크릿 게이트
- [[cmux]] — 이 실측이 이뤄진 터미널 환경
```

---

## ingest 시 참고 (요청측 메모)

1. **peer 링크**: `[[gitleaks-precommit]]`·`[[cmux]]` 둘 다 dakman-wiki에 실재 확인(126개 페이지 전수, 2026-08-20).
2. **중복 없음**: 파일명·본문 전수 검색에서 lazygit·delta·difftastic 전용 페이지 0건. `obsidian-llm-git-quartz-stack.md`는 주제가 다르다(위키 퍼블리싱).
3. **`sns_candidate: true` 제안 근거**: "TUI 대안 찾기가 사실은 pager 미설정 문제였다" + "pager는 TTY에서만 뜬다" 두 토막이 공유 가치가 있다고 봤다 — **판단은 위키 세션·rtong 몫**이니 부적절하면 내려도 된다.
4. **`raw/` 보관**: 이 문서 자체가 원본이다(대화 맥락 소스). 필요하면 `raw/2026-08-20-git-diff-toolchain-handoff.md`로 스냅샷.
5. **⚠️ 태그 3개가 신규 어휘다** — 126개 페이지 전수 대조(2026-08-20):

   | 태그 | 기존 사용 |
   |---|---|
   | `git` · `tooling` · `terminal` · `ai-native` | 2 · 2 · 1 · 9건 (기존 어휘 ✅) |
   | **`tui` · `diff` · `dev-env`** | **0건 — 신규** |

   신규 어휘 도입 여부는 **위키 세션 판단**이다. 어휘를 늘리기 싫으면 `tui`→`terminal`, `dev-env`→`tooling`으로 접고 `diff`는 빼도 내용은 성립한다.
6. **정정 요청 환영** — frontmatter 필드·태그 어휘가 dakman-wiki 스키마와 어긋나면 그쪽 규약이 우선이다. 수정 피드백 주면 반영한다.
