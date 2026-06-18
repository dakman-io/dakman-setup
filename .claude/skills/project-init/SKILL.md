---
name: project-init
description: 새 앱/웹 프로젝트를 dakman 표준으로 초기화한다(로컬 경로 확인·페르소나·.gitignore·폴더·워크플로우 문서·첫 커밋·브랜치 전략·보호 규칙). 사용자가 "새 프로젝트 시작", "저장소 초기화", "project-init", "프로젝트 셋업"을 말하거나 빈/새 저장소에서 dakman 규칙을 적용하려 할 때 사용. local-first: 로컬 준비·첫 커밋까지 마친 뒤, 원격 저장소 생성·push·브랜치 보호·main 삭제 같은 비가역 작업은 실행 계획을 보여주고 1회 승인을 받은 뒤 실행한다.
---

# project-init — 프로젝트 초기화

새 프로젝트를 dakman 표준으로 부트스트랩하는 **local-first 8단계 플레이북**.
**전체 그림·근거·명령 상세는 참조 문서가 정본**: [`references/project-init.md`](references/project-init.md) (= 저장소의 `docs/project-init.md`). 셋업 이후 운영은 `.claude/workflows/workflow.md`.

## 행동 규칙 (가장 중요 — 먼저 읽어라)

이 스킬은 LLM이 따르는 지시문이지 자동 실행기가 아니다. 각 단계는 아래 3등급 중 하나다:

- 🟢 **MAY (로컬·가역)** — 바로 실행해도 됨. 로컬 파일/폴더/커밋. 실패해도 되돌리기 쉬움.
- 🟡 **ASK (값 수집)** — 사용자에게 값을 먼저 물어 채운다. 추측 금지.
- 🔴 **STOP (비가역·원격)** — **절대 임의 실행 금지.** 원격 저장소·push·브랜치 보호·삭제. §9 Dry-run 요약에 모아 **1회 승인**을 받은 뒤에만 실행.

> **local-first 원칙**: §1~§7(로컬 준비 + 첫 커밋 + 로컬 브랜치)은 전부 🟢/🟡 가역. 원격을 건드리는 🔴는 전부 §9 승인 게이트로 모인다. 첫 커밋으로 HEAD가 먼저 생기므로 "초기 커밋 없음 → 브랜치 생성 실패" 문제가 발생하지 않는다.
> 정합: workflow.md 원칙 5(검수 후 커밋)·§8.4(자동 루프는 커밋·머지·publish 금지).

## 진행 순서

먼저 🟡 값을 수집하고, §1~§7의 🟢 로컬 작업을 끝낸 뒤, §9에서 🔴 원격 작업을 일괄 승인받는다.

### 🟡 0. 값 수집 (먼저)
사용자에게 묻는다 (추측 금지):
- **로컬 경로** — 어디에 만들지. 규약 `<도메인>/workspace/<repo>` (예: `~/dakman/workspace/<repo>`)
- **신규 vs 기존 remote** — remote가 없는 신규(a)인지, 이미 빈 repo가 있고 클론된 상태(b)인지 → §2·§9 분기
- `<owner>/<repo>` — GitHub 저장소 경로
- 프로젝트 성격(웹/앱) + workflow.md §0 placeholder (`{프로젝트명}`·`{플랫폼}`·`{타입체크}`·`{단위테스트}`·`{린트}`·`{E2E도구}`·`{디자인도구}`·`{커버리지}`·`{위험도메인}`·`{AI예산}`)
- `{위험도메인}` 특히 명시적으로 — 실패 시 데이터·돈·신뢰에 직접 영향 주는 핵심 로직 (자동 T3 입력값)

### 1. 페르소나 지정 + 로컬 경로 확인 — 🟡 경로 / 🟢 기록
- 🟡 로컬 경로·신규/기존 확정 (위 §0)
- 🟢 `CLAUDE.md`에 페르소나 기록:
  - **역할**: "너는 이 역할 최적의 전문가이고, 이 프로젝트를 함께 수행하는 파트너이자 친구로서 나와 함께 해주면 돼." (workflow.md §9의 6역할 + 제안·반론 자세)
  - **말투**: 대화는 반말로 한다.
  - **업무 응답**: 작업·결과 보고는 서술형(줄글) 금지 — 헤더·불릿·표 중심의 보고서 형태로 한다.

### 2. 로컬 초기화 — 🟢 로컬
확정 경로에서 로컬 git 준비 (원격 생성은 §9로 미룸):
```bash
# (a) 신규: mkdir -p <도메인>/workspace/<repo> && cd $_ && git init
# (b) 기존 클론(빈 repo): cd <도메인>/workspace/<repo>   (origin 이미 연결됨)
```

### 3. .gitignore 추가 — 🟢 로컬
`references/project-init.md` §3 블록 그대로 작성 (.DS_Store·.trash·.cmux·.playwright-mcp·drawio bkp·.env). `.cmux/`는 전체 무시 + 결론 산출물만 `git add -f`.

### 4. 폴더 구조 생성 — 🟢 로컬
```bash
mkdir -p .claude/{agents,skills,hooks,workflows,guides} \
  artifacts/planning/user-stories artifacts/design \
  artifacts/progress artifacts/review artifacts/tests docs/prompt app
```
빈 디렉터리 유지가 필요하면 `.gitkeep`.

### 5. 워크플로우 문서 준비 + 정합 — 🟢 복사 / 🟡 §0 채우기
- 🟢 `.claude/workflows/workflow.{md,drawio,html}` 확보(이 템플릿에서 복사 또는 생성)
- 🟡 workflow.md §0 placeholder를 §0에서 수집한 값으로 채움
- 핵심 원칙 정합 확인: SDD(원칙1)·ATDD+TDD(원칙3)·디자인시스템(원칙8)·Tier(§2)

### 6. 첫 커밋 (HEAD 생성) — 🟢 로컬
§1~§5의 로컬 파일을 한 번에 커밋 → HEAD 생성(이후 브랜치 가능). .gitignore가 이미 있어 첫 커밋부터 깨끗.
```bash
git add -A
git commit -m "[<사용자명>] init: 프로젝트 초기 셋업 (페르소나·gitignore·구조·workflow)"
```
커밋 컨벤션은 `git-commit` 스킬 (`[사용자명] <type>(<scope>): <설명>`, 한글 명령형, Co-Authored-By 제외).

### 7. 브랜치 전략 — 🟢 로컬 생성 / 🔴 원격(§9)
- 🟢 로컬 브랜치 생성: `git branch develop && git branch staging && git branch production`
- 🔴 이하 원격 작업은 §9 승인 게이트로: push · 디폴트 설정 · 보호 · main 삭제

### 8. skill / agent 구성 — 🟡 (초기엔 비어도 됨)
필요 시 maker-checker 쌍으로만 (planner↔us-reviewer, designer↔design-reviewer, developer↔code-reviewer). 발동 지점 없는 agent 금지 (workflow.md 원칙 11·12).

### 🔴 9. 실행 계획 요약 → 1회 승인 (비가역 게이트)
§1~§8은 전부 로컬(가역)이라 이미 끝나 있다. 이제 **원격 작업을 모아 한 번에 승인**받는다. 승인 전 절대 실행 금지:

```
[실행 계획 — 승인 필요]
🟢 로컬 (이미 완료, 되돌리기 쉬움): CLAUDE.md · .gitignore · 폴더 구조 · workflow 문서 · 첫 커밋 · 로컬 브랜치
⚠️ 비가역 원격 작업:
  (a 신규) gh repo create <owner>/<repo> --private --source=. --remote=origin --push   (원격 생성 + push)
  (b 기존) git push -u origin develop staging production                                (브랜치 push)
  · gh repo edit <owner>/<repo> --default-branch develop
  · scripts/protect-branches.sh <owner>/<repo>            (3개 브랜치 보호 — JSON 환각 방지 결정적 스크립트)
  · git push origin --delete main                         (★ 원격 main 영구 삭제, 있을 때만)
승인하시겠습니까? (개별 제외도 가능)
```

승인 후 순서대로 실행하고, 마지막에 `references/project-init.md` §7.6 확인 명령으로 결과 검증.

## 주의
- 🔴 작업은 환경·권한·승인에 따라 달라지므로 절대 자동 일괄 실행하지 말 것.
- 값을 모르면 추측하지 말고 묻는다.
- 상세 명령·근거가 필요하면 `references/project-init.md`를 정본으로 참조.
