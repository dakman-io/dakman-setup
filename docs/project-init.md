# 프로젝트 초기화 가이드 (범용 템플릿)

> 새 앱/웹 프로젝트를 시작할 때 위에서부터 순서대로 따라 하는 **초기화 체크리스트**.
> 셋업 완료 후의 운영 규칙은 `.claude/workflows/workflow.md`(7단계 워크플로우)가 정본이다.
> 명령어의 `<owner>/<repo>`는 새 저장소로 치환한다 (예: `dakman-io/dakman-setup`).

## 셋업 체크리스트

- [ ] 1. 페르소나 지정 (CLAUDE.md)
- [ ] 2. 저장소 생성 후 클론
- [ ] 3. 브랜치 전략 적용 (생성 → 디폴트 → 보호 → main 삭제 → 확인)
- [ ] 4. .gitignore 추가
- [ ] 5. 폴더 구조 생성
- [ ] 6. 커밋 컨벤션 확인 (git-commit 스킬)
- [ ] 7. 워크플로우 문서 준비 + 운영 정합 확인
- [ ] 8. skill / agent 구성 (워크플로우 지점 바인딩)

---

## 1. 페르소나 지정

프로젝트를 시작하면 가장 먼저 Claude의 페르소나를 지정하고 `CLAUDE.md`에 기록한다 (매 세션 유지):

> **너는 이 역할 최적의 전문가이고, 이 프로젝트를 함께 수행하는 파트너이자 친구로서 나와 함께 해주면 돼.**

- 단계별 전문성은 workflow.md §9의 6역할(Orchestrator·Planner·Designer·Developer·QA Reviewer·Ops)을 따른다 — 각 단계에서 그 역할 최적의 전문가로 임한다.
- 파트너이자 친구로서: 지시 수행만 하지 않고 더 나은 방향을 제안하고, 틀렸다고 판단되면 근거를 들어 반대 의견을 낸다.

## 2. 저장소 생성 후 클론

GitHub에 저장소를 생성하고(README 포함 = 초기 커밋 생성) 클론한다. 이후 모든 설정은 클론한 디렉토리에서 진행.

```bash
# 옵션 A: gh로 신규 생성 (README 포함 → main에 초기 커밋이 생김)
gh repo create <owner>/<repo> --private --add-readme --clone
cd <repo>

# 옵션 B: GitHub 웹에서 생성(README 체크) 후 클론
git clone https://github.com/<owner>/<repo>.git
cd <repo>
```

> ⚠️ 초기 커밋(HEAD)이 있어야 §3.1의 `git branch develop`이 동작한다. README 없이 빈 저장소를 만들었다면 먼저 아무 파일이나 1개 커밋한다.

## 3. 브랜치 전략

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

### 3.1 브랜치 생성 및 푸시 (git)

```bash
git branch develop
git branch staging
git branch production
git push -u origin develop staging production
```

작업 브랜치는 develop에서 `feature/*` 이름으로 생성:

```bash
git switch develop
git switch -c feature/login   # 예시
```

> `feature`라는 브랜치가 존재하면 ref 이름 충돌로 `feature/login`을 만들 수 없으므로,
> 고정 `feature` 브랜치는 두지 않고 `feature/*` 컨벤션만 사용한다.

### 3.2 디폴트 브랜치 설정 (gh)

```bash
gh repo edit <owner>/<repo> --default-branch develop
```

### 3.3 보호 브랜치 설정 (gh)

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

### 3.4 main 브랜치 삭제

```bash
git switch develop              # main에서 벗어나기
git branch -d main              # 로컬 삭제
git push origin --delete main   # 원격 삭제
```

### 3.5 설정 확인

```bash
gh repo view <owner>/<repo> --json defaultBranchRef          # 디폴트 브랜치 확인
gh api repos/<owner>/<repo>/branches \
  --jq '.[] | "\(.name)\tprotected=\(.protected)"'           # 보호 상태 확인
```

## 4. .gitignore 추가

OS 잡파일·환경 변수·AI 도구 임시 산출물이 커밋되지 않도록 프로젝트 루트에 추가한다:

```gitignore
# OS
.DS_Store

# 임시 보관 (삭제 예정 파일)
.trash/

# cmux 토론 산출물 (전사·시그널 전부 무시)
.cmux/

# playwright MCP 임시 산출물 (스냅샷·콘솔 로그·스크린샷)
.playwright-mcp/

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

## 5. 폴더 구조

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

## 6. 커밋 컨벤션

`git-commit` 스킬을 따른다 — `[사용자명] <type>(<scope>): <설명>` 형식, 한글 명령형, 원자적 커밋, Co-Authored-By 서명 제외.

## 7. 워크플로우 문서 준비 + 운영 정합 확인

운영 정본은 `.claude/workflows/`에 둔다. 셋업 단계에서는 이 3개 파일을 **갖추고 프로젝트에 맞게 채운다** (방법론 상세는 workflow.md가 정본 — 여기서는 준비·정합만).

1. **문서 확보** — 템플릿 저장소(dakman-setup)의 `.claude/workflows/workflow.{md,drawio,html}`를 새 프로젝트로 복사하거나, 없으면 생성한다.
   - `workflow.md` — 7단계: 브리핑 → 기획 → 디자인 → 구현 → 검증 → 형상관리 → 완료(평가·개선·다음 작업 제안)
   - `workflow.drawio` — 7 스윔레인(A~G), 노드 A-1 형식 넘버링, 역할 색상
   - `workflow.html` — md와 동일 내용의 시각화 뷰 (md 갱신 시 함께 갱신)
2. **§0 placeholder 채우기** — workflow.md §0 표의 프로젝트별 값을 채운다: `{프로젝트명}`·`{플랫폼}`·`{타입체크}`·`{단위테스트}`·`{린트}`·`{E2E도구}`·`{디자인도구}`·`{커버리지}`·`{위험도메인}`·`{AI예산}`.
3. **핵심 원칙 정합 확인** — 본 프로젝트의 방법론이 workflow.md 원칙과 일치하는지 점검: **SDD**(원칙 1, 문서→디자인→소스) · **ATDD+TDD 이중 루프**(원칙 3) · **디자인 시스템 4 레이어**(원칙 8) · **Tier 분류**(§2). 상세 정의는 workflow.md를 정본으로 참조.
4. **검증 인프라 결정** (셋업 시 1회) — 어떤 도구를 연결할지 정한다:
   - E2E: 웹 = playwright(+mcp) / 모바일 = maestro
   - 보안 검사 대상: XSS · SQL Injection · CSRF · 인증/인가 · 권한 · 입출력값 검증 · 세션 관리
   - 성능 테스트: 로딩 · 응답 · 동시 접속
5. 기획 입력 문서 체인: 제안요청서 → 제안서 → PRD → TASK

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
