## 깃에 레파지토리 생성 후 클론
### 브랜치 생성 및 설정
|브랜치명|디폴트|보호 브랜치|설명|
|:-:|:-:|:-:|:-:|
|feature/*|no|no|기능 개발 (예: feature/login)|
|develop|yes|yes|개발 브랜치|
|staging|no|yes|스테이징 브랜치|
|production|no|yes|프로덕션 브랜치|

보호 브랜치 규칙 (develop, staging, production 공통):
- 직접 푸시 금지, PR을 통해서만 머지 (관리자 포함 `enforce_admins: true`)
- 필수 승인 인원 0명 (혼자서도 머지 가능)
- force push 금지, 브랜치 삭제 금지

#### git-commit 스킬 확인
- 커밋 컨벤션 적용

#### 브랜치 생성 및 푸시 (git)

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

#### 디폴트 브랜치 설정 (gh)

```bash
gh repo edit dakman-io/dakman-setup --default-branch develop
```

#### 보호 브랜치 설정 (gh)

```bash
# develop, staging, production에 각각 적용
# enforce_admins: true = 관리자 포함 직접 푸시 금지 (PR로만 머지)
for br in develop staging production; do
  gh api -X PUT "repos/dakman-io/dakman-setup/branches/$br/protection" \
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

#### main 브랜치 삭제

```bash
git switch develop              # main에서 벗어나기
git branch -d main              # 로컬 삭제
git push origin --delete main   # 원격 삭제
```

#### 설정 확인

```bash
gh repo view dakman-io/dakman-setup --json defaultBranchRef   # 디폴트 브랜치 확인
gh api repos/dakman-io/dakman-setup/branches \
  --jq '.[] | "\(.name)\tprotected=\(.protected)"'            # 보호 상태 확인
```

#### .gitignore 추가

OS 잡파일·환경 변수·AI 도구 임시 산출물이 커밋되지 않도록 프로젝트 루트에 `.gitignore`를 추가한다:

```gitignore
# OS
.DS_Store

# cmux 토론 산출물
.cmux/

# playwright MCP 임시 산출물 (스냅샷·콘솔 로그·스크린샷)
.playwright-mcp/

# Claude Code 로컬 설정 (개인 권한 — 공유 금지)
.claude/settings.local.json

# 환경 변수
.env
.env.*
!.env.example
```


## 기본 폴더
|폴더명|설명|
|:-:|:-:|
|.claude|클로드 설정|
|artifacts|AI Input / Output 파일|
|docs|작업 임시 파일|


## 폴더 구조

```shell
project/
├── .claude/
│   ├── agents/
│   ├── skills/
│   ├── hooks/
│   ├── workflows/
│   └── guides/
├── artifacts/
│   ├── planning/
│   ├── progress/
│   ├── review/
│   └── tests/
├── docs/
|   ├── prompt/
|   └── memo.md
├── app/
│   ├── xxx/
│   ├── xxx/
│   ├── xxx/
│   ├── .env
│   └── .env.example
├── README.md
├── CLAUDE.md
└── .gitignore
```

## workflow 생성
- workflow.md 생성
- workflow.drawio 생성
- workflow에 필요한 skill, agent, hooks 제안 받기
- 제안요청서 - 제안서 - PRD - TASK 
- 브리핑 - 기획 - 디자인 - 개발 - 테스트 - 배포 - 개선 - 다음 작업 제안

## skill 생성
- **생성 트리거**: 같은 맥락 설명을 **2회 이상 반복 + 의도가 안정**되면 스킬화한다.
  - 근거(intent debt): 에이전트는 매 세션 cold start라 의도의 빈틈을 추측으로 채운다 — 스킬이 없으면 매 사이클 프로젝트를 처음부터 재유도.
- CLAUDE.md가 비대해져 에이전트 오류가 늘면 스킬로 분할한다.
- **지점 바인딩**: 스킬은 workflow.md §9 배치 원칙을 따른다 — 어느 단계/게이트에서 발동하는지 명시하고 `.claude/skills/`에 기록.

## agent 생성 원칙
- **만드는 에이전트가 있으면 반드시 리뷰 하는 에이전트가 있어야 한다. 예를 들면 developer 에이전트가 있으면 code-review 에이전트가 있어야 한다.**

## 개발 방법론
- SDD (Specification Driven Development)

### 기획
- User Story
- Acceptance Criteria

### 디자인
- 

### 개발
- TDD(Test Driven Development)
- ATDD(Acceptance Test Driven Development)

### 테스트
- E2E 테스트(End to End Test)
    - 웹: playwright, playwright mcp
    - 모바일: maestro
- 보안 검사
    - XSS
    - SQL Injection
    - CSRF
    - 인증/인가
    - 권한 검사
    - 데이터 검증
    - 입력값 검증
    - 출력값 검증
    - 세션 관리
- 성능 테스트
    - 로딩 테스트
    - 응답 테스트
    - 동시 접속 테스트