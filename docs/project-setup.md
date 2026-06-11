## 깃에 레파지토리 생성 후 클론
### 브랜치 생성 및 설정
|브랜치명|디폴트|보호 브랜치|설명|
|:-:|:-:|:-:|:-:|
|feature|no|no|기능 개발|
|develop|yes|yes|개발 브랜치|
|staging|no|yes|스테이징 브랜치|
|production|no|yes|프로덕션 브랜치|


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