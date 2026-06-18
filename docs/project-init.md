# 프로젝트 초기화 가이드 (범용 템플릿)

> 새 앱/웹 프로젝트를 시작할 때 위에서부터 순서대로 따라 하는 **초기화 체크리스트**.
> 셋업 완료 후의 운영 규칙은 `.claude/workflows/workflow.md`(7단계 워크플로우)가 정본이다.
> 명령어의 `<owner>/<repo>`는 새 저장소로 치환한다 (예: `dakman-io/dakman-setup`).
>
> 🤖 이 절차는 **`project-init` 스킬**(글로벌 단일 정본 `~/.claude/skills/project-init/` — 어느 디렉터리에서나 발동; 버전관리 원본은 이 리포 `.claude/skills/project-init/`)로 실행할 수 있다 — "새 프로젝트 시작"이라고 하면 발동. 본 문서는 그 스킬의 정본 설계 참조이며, 비가역 원격 작업(저장소 생성·브랜치 보호·main 삭제)은 스킬이 실행 계획을 보여주고 승인받은 뒤 처리한다.
>
> **순서 원칙 = local-first.** 로컬에서 위치·파일·첫 커밋까지 준비한 뒤(가역), 원격 작업(생성·push·보호·삭제 = 비가역)은 마지막에 한 번에 처리한다. 첫 커밋으로 HEAD가 생긴 뒤 브랜치를 만들기 때문에 "초기 커밋 없음" 문제가 원천 발생하지 않는다.

## 셋업 체크리스트

- [ ] 1. 페르소나 지정 + 로컬 경로 확인
- [ ] 2. 로컬 초기화 (폴더 + git init / 기존 클론)
- [ ] 3. .gitignore 추가
- [ ] 4. 폴더 구조 생성
- [ ] 5. 워크플로우 문서 준비 + 운영 정합 확인
- [ ] 6. 첫 커밋 (HEAD 생성)
- [ ] 7. 브랜치 전략 (로컬 생성 → 원격 push·보호·main 삭제)
- [ ] 8. skill / agent 구성 (워크플로우 지점 바인딩)
- [ ] 9. LLM 위키 연동 (지식 축적 — 무설정 자동 + 마커 규약)

---

## 1. 페르소나 지정 + 로컬 경로 확인

프로젝트를 시작하면 먼저 **두 가지를 확정**한다.

**(1) 로컬 경로** — 어디에 만들지 먼저 확인한다. 이후 모든 작업의 기준점이다.
- 규약: `<도메인>/workspace/<repo>` (예: `~/dakman/workspace/<repo>`, `~/chagok/workspace/<repo>`)
- **신규(remote 없음)** 인지 **기존 remote 존재(빈 repo가 이미 있고 클론됨)** 인지 판별 → §2·§7의 분기 결정

**(2) 페르소나** — `CLAUDE.md`에 기록 (매 세션 유지):

> **너는 이 역할 최적의 전문가이고, 이 프로젝트를 함께 수행하는 파트너이자 친구로서 나와 함께 해주면 돼.**

- 단계별 전문성은 workflow.md §9의 6역할(Orchestrator·Planner·Designer·Developer·QA Reviewer·Ops)을 따른다.
- 파트너이자 친구로서: 지시 수행만 하지 않고 더 나은 방향을 제안하고, 틀렸다고 판단되면 근거를 들어 반대 의견을 낸다.
- **말투**: 대화는 반말로 한다.
- **업무 응답 형식**: 작업·결과 보고는 서술형(줄글) 금지 — 헤더·불릿·표 중심의 **보고서 형태**로 응답한다.

## 2. 로컬 초기화

확정한 경로에서 로컬 git 저장소를 준비한다. (원격 저장소 생성은 §7로 미룬다 — local-first)

```bash
# (a) 신규: 폴더 생성 + git init
mkdir -p <도메인>/workspace/<repo> && cd $_
git init

# (b) 기존 remote가 이미 있고 클론된 상태(빈 repo): 그 디렉터리에서 진행
cd <도메인>/workspace/<repo>   # origin 이미 연결돼 있음
```

> 아직 커밋이 없어도 된다 — §1~§5의 로컬 파일을 모은 뒤 §6에서 첫 커밋으로 HEAD를 만든다.

## 3. .gitignore 추가

OS 잡파일·환경 변수·AI 도구 임시 산출물이 (첫 커밋부터) 섞이지 않도록 프로젝트 루트에 추가한다:

```gitignore
# OS
.DS_Store

# 임시 보관 (삭제 예정 파일)
.trash/

# cmux 토론 산출물 (전사·시그널 전부 무시)
.cmux/

# playwright MCP 임시 산출물 (스냅샷·콘솔 로그·스크린샷)
.playwright-mcp/

# LLM 위키 자동 ingest 큐 (로컬 상태 — 머신 전역 훅이 사용)
.wiki-ingest/

# drawio 백업/잠금 파일
.$*.bkp
**/.$*.bkp

# Claude Code 로컬 설정 (개인 권한 — 공유 금지)
.claude/settings.local.json

# 환경 변수
.env
.env.*
!.env.example
```

> **`.cmux/` 추적 예외**: 토론 *결론* 산출물(`.cmux/debates/<주제>/<주제>.md`·`.html`)만 `git add -f`로 추적한다 (workflow.md §11). `.cmux/`를 통째로 무시하되 결과물만 강제 추가 — `!` 재포함 패턴은 디렉터리 전체 무시 하에선 동작하지 않으므로 쓰지 않는다.

## 4. 폴더 구조

| 폴더 | 역할 |
|:-:|:-|
| .claude | Claude Code 설정 (agents·skills·hooks·workflows) |
| artifacts | AI Input / Output 산출물 |
| docs | 작업 문서 (초기화 가이드·메모) |
| app | 애플리케이션 소스 |

```bash
mkdir -p .claude/{agents,skills,hooks,workflows,guides} \
  artifacts/planning/user-stories artifacts/design \
  artifacts/progress artifacts/review artifacts/tests \
  docs/prompt app
# 빈 디렉터리는 git에 남지 않으므로, 유지가 필요하면 각 폴더에 .gitkeep 추가
```

```shell
project/
├── .claude/
│   ├── agents/              # 6개 역할별 전문 프롬프트 (workflow.md §9)
│   ├── skills/              # 프로젝트 스킬
│   ├── hooks/
│   ├── workflows/
│   │   ├── workflow.md      # 7단계 워크플로우 (정본)
│   │   ├── workflow.drawio  # 워크플로우 다이어그램 (7 스윔레인)
│   │   └── workflow.html    # 워크플로우 시각화 뷰
│   └── guides/
├── artifacts/
│   ├── planning/            # prd.md · architecture.md · ci-cd.md
│   │   └── user-stories/    # US + AC (Given-When-Then)
│   ├── design/              # design-system.md · us-to-frame-map.md · 프레임
│   ├── progress/            # todo.md (spine) · loop-triage.md
│   ├── review/              # 리뷰 이슈 파일 (us/design/code/e2e)
│   └── tests/               # E2E flow · pass-fail 로그 · 커버리지 리포트
├── docs/
│   ├── project-init.md      # 본 문서
│   ├── prompt/
│   └── memo.md
├── app/
│   ├── .env
│   └── .env.example
├── README.md                # 진입점 — 신규 프로젝트는 docs/project-init.md부터
├── CLAUDE.md                # 페르소나(§1) + 정본 문서 링크
└── .gitignore
```

> 경로 규약은 `workflow.md` §11과 단일 정합 — 없는 문서는 해당 단계 첫 진입 시 작성한다.

## 5. 워크플로우 문서 준비 + 운영 정합 확인

운영 정본은 `.claude/workflows/`에 둔다. 셋업 단계에서는 이 3개 파일을 **갖추고 프로젝트에 맞게 채운다** (방법론 상세는 workflow.md가 정본 — 여기서는 준비·정합만).

1. **문서 확보** — 템플릿 저장소(dakman-setup)의 `.claude/workflows/workflow.{md,drawio,html}`를 새 프로젝트로 복사하거나, 없으면 생성한다.
   - `workflow.md` — 7단계: 브리핑 → 기획 → 디자인 → 구현 → 검증 → 형상관리 → 완료(평가·개선·다음 작업 제안)
   - `workflow.drawio` — 7 스윔레인(A~G), 노드 A-1 형식 넘버링, 역할 색상
   - `workflow.html` — md와 동일 내용의 시각화 뷰 (md 갱신 시 함께 갱신)
2. **§0 placeholder 채우기** — workflow.md §0 표의 프로젝트별 값을 채운다: `{프로젝트명}`·`{플랫폼}`·`{타입체크}`·`{단위테스트}`·`{린트}`·`{E2E도구}`·`{디자인도구}`·`{커버리지}`·`{위험도메인}`·`{AI예산}`. **`{위험도메인}`은 특히 명시적으로** — 실패 시 데이터·돈·신뢰에 직접 영향 주는 핵심 로직 (자동 T3 입력값).
3. **핵심 원칙 정합 확인** — 본 프로젝트의 방법론이 workflow.md 원칙과 일치하는지 점검: **SDD**(원칙 1, 문서→디자인→소스) · **ATDD+TDD 이중 루프**(원칙 3) · **디자인 시스템 4 레이어**(원칙 8) · **Tier 분류**(§2). 상세 정의는 workflow.md를 정본으로 참조.
4. **검증 인프라 결정** (셋업 시 1회) — 어떤 도구를 연결할지 정한다:
   - E2E: 웹 = playwright(+mcp) / 모바일 = maestro
   - 보안 검사 대상: XSS · SQL Injection · CSRF · 인증/인가 · 권한 · 입출력값 검증 · 세션 관리
   - 성능 테스트: 로딩 · 응답 · 동시 접속
5. 기획 입력 문서 체인: 제안요청서 → 제안서 → PRD → TASK

## 6. 첫 커밋 (HEAD 생성)

§1~§5에서 만든 로컬 파일(CLAUDE.md·.gitignore·폴더 구조·workflow 문서)을 **한 번에 커밋**한다. 이 커밋이 HEAD가 되어 §7 브랜치 생성이 가능해진다.

```bash
git add -A
git commit -m "[<사용자명>] init: 프로젝트 초기 셋업 (페르소나·gitignore·구조·workflow)"
```

- **커밋 컨벤션**: `git-commit` 스킬을 따른다 — `[사용자명] <type>(<scope>): <설명>` 형식, 한글 명령형, 원자적 커밋, Co-Authored-By 서명 제외.
- .gitignore가 이미 있으므로 `.DS_Store`·`.env` 등은 첫 커밋부터 제외된다.

## 7. 브랜치 전략

| 브랜치명 | 디폴트 | 보호 브랜치 | 설명 |
|:-:|:-:|:-:|:-:|
| feature/* | no | no | 기능 개발 (예: feature/login) |
| develop | yes | yes | 개발 브랜치 |
| staging | no | yes | 스테이징 브랜치 |
| production | no | yes | 프로덕션 브랜치 |

보호 브랜치 규칙 (develop, staging, production 공통):
- 직접 푸시 금지, PR을 통해서만 머지 (관리자 포함 `enforce_admins: true`)
- 필수 승인 인원 0명 (혼자서도 머지 가능)
- force push 금지, 브랜치 삭제 금지

### 7.1 로컬 브랜치 생성 (가역)

```bash
git branch develop
git branch staging
git branch production
```

작업 브랜치는 develop에서 `feature/*` 이름으로 생성:

```bash
git switch develop
git switch -c feature/login   # 예시
```

> `feature`라는 브랜치가 존재하면 ref 이름 충돌로 `feature/login`을 만들 수 없으므로,
> 고정 `feature` 브랜치는 두지 않고 `feature/*` 컨벤션만 사용한다.

### 7.2 원격 연결 + push (⚠️ 비가역 — 승인 후)

```bash
# (a) 신규: 로컬을 원격으로 생성하며 push
gh repo create <owner>/<repo> --private --source=. --remote=origin --push

# (b) 기존 remote: 브랜치만 push
git push -u origin develop staging production
```

### 7.3 디폴트 브랜치 설정 (gh)

```bash
gh repo edit <owner>/<repo> --default-branch develop
```

### 7.4 보호 브랜치 설정 (gh)

```bash
# develop, staging, production에 각각 적용
# enforce_admins: true = 관리자 포함 직접 푸시 금지 (PR로만 머지)
for br in develop staging production; do
  gh api -X PUT "repos/<owner>/<repo>/branches/$br/protection" \
    --input - <<'EOF'
{
  "required_status_checks": null,
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 0
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
done
```

> 이미 보호가 적용된 저장소에서 관리자 강제만 나중에 켜려면:
> `gh api -X POST "repos/<owner>/<repo>/branches/<br>/protection/enforce_admins"`

### 7.5 main 브랜치 삭제 (⚠️ 비가역)

```bash
git switch develop              # main에서 벗어나기
git branch -d main              # 로컬 삭제
git push origin --delete main   # 원격 삭제 (원격 main이 있을 때만)
```

### 7.6 설정 확인

```bash
gh repo view <owner>/<repo> --json defaultBranchRef          # 디폴트 브랜치 확인
gh api repos/<owner>/<repo>/branches \
  --jq '.[] | "\(.name)\tprotected=\(.protected)"'           # 보호 상태 확인
```

## 8. skill / agent 구성

워크플로우의 지점에 바인딩되는 skill·agent를 구성한다. **초기엔 비어 있어도 무방** — 필요가 생기는 시점에 아래 기준으로 추가한다 (구성 게이트).

### skill 생성
- **생성 트리거**: 같은 맥락 설명을 **2회 이상 반복 + 의도가 안정**되면 스킬화한다.
  - 근거(intent debt): 에이전트는 매 세션 cold start라 의도의 빈틈을 추측으로 채운다 — 스킬이 없으면 매 사이클 프로젝트를 처음부터 재유도.
- CLAUDE.md가 비대해져 에이전트 오류가 늘면 스킬로 분할한다.
- **지점 바인딩**: 스킬은 workflow.md §9 배치 원칙을 따른다 — 어느 단계/게이트에서 발동하는지 명시하고 `.claude/skills/`에 기록.

### agent 생성 원칙
- **maker-checker 쌍 필수** — 만드는 에이전트가 있으면 반드시 그 산출물을 검사하는 에이전트가 있어야 한다 (workflow.md 원칙 12):
  - planner ↔ us-reviewer
  - designer ↔ design-reviewer
  - developer ↔ code-reviewer
- 발동 지점이 workflow.md에 없는 agent는 만들지 않는다 (원칙 11 — 지점 바인딩).

## 9. LLM 위키 연동 (지식 축적)

이 프로젝트에서 나오는 지식(리서치·의사결정·방법론)은 부문별 **중앙 LLM 위키**(dakman/chagok/emotion vault)로 모은다. Karpathy "LLM wiki" 패턴 — 매 질의마다 재발견하는 RAG와 달리 **한 번 컴파일해 최신 유지**, 소스를 더할수록 복리로 풍부해진다.

**무설정 자동 연결.** 위키 자동 ingest는 **머신 전역 Claude 유저 훅**(`~/.claude/settings.json` PostToolUse → `~/.claude/hooks/`)으로 동작한다 — **per-repo 훅·설정이 필요 없다.** 새 프로젝트는 만들자마자 자동 커버된다. 운영 스킬(`wiki-ingest`·`wiki-organize`)과 온보딩(`wiki-onboarding`)도 글로벌 단일 정본(`~/.claude/skills/`)이므로 **리포에 사본을 두지 않는다**(드리프트 방지).

**셋업에서 할 일은 두 가지뿐:**

1. **`.gitignore`에 `.wiki-ingest/` 추가** (§3에 포함) — repo별 ingest 큐(로컬 상태).
2. **위키로 보낼 문서에 마커 달기** — *vault 밖* 소스 문서의 frontmatter에 `wiki-ingest` 객체(Option B 라이프사이클):
   ```yaml
   ---
   wiki-ingest:
     status: pending      # pending | done | skip | sync
     note: notes/x.md     # done 후 스킬이 기록
     at: 2026-06-16
     by: auto             # auto | manual
     hash: a1b2c3d4e5f6   # 본문 sha256[:12] — sync 변경 감지
   title: ...
   ---
   ```

   | status | 동작 |
   |--------|------|
   | `pending` | develop 머지 시 훅이 큐에 적재 |
   | `done` | 완료 — 재큐 안 함 (수동 처리도 `done` + `by: manual`) |
   | `skip` | 대상 아님 |
   | `sync` | 본문이 바뀌면 재ingest (living doc) |

   > **vault 내부 노트·README·CLAUDE.md엔 달지 않는다.** 마커는 vault 밖 소스 문서에만. 옛 스칼라 `wiki-ingest: true`는 `pending`으로 해석(하위호환).

**흐름**: 마커(`pending`) 단 문서를 develop에 머지 → 훅이 `.wiki-ingest/queue.txt`에 적재 + 알림 → "위키에 정리해줘"로 `wiki-ingest` 실행(현재 경로로 부문 vault 자동 라우팅) → 노트 생성·검증 요청, 스킬이 소스 마커를 `done`으로 갱신.

**온보딩**: 위키 운영법은 프로젝트마다 문서를 두지 말고 **`/wiki-onboarding` 스킬**을 호출한다 — vault 라우팅·거버넌스·검증 2축·마커 규약이 전부 내장돼 있다.

> 상세 정본: `wiki-onboarding` 스킬 §8(자동 ingest 마커) · 판정/해시 정본은 `~/.claude/hooks/wiki-ingest-marker.py`.
