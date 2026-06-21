# AI-Driven Workflow (범용 템플릿)

> **1인 개발 환경 운영 매뉴얼 — 앱/웹 프로젝트 공용 템플릿.** 모든 작업은 먼저 Tier 1/2/3으로 분류한다.
> **기본은 단순하고 위험하면 상향한다.** Lean Default + Escalation.
>
> **비용 1차 기준 = 사용자 활성 검토 시간.** AI 토큰·시간·대기는 병렬화 가능 (낮은 가중치).
>
> 이 문서 자체는 메타 워크플로우 = 변경 시 **Tier 3 + 3인 교차 리뷰 적용**.
>
> **템플릿 사용법**: 새 프로젝트 시작 시 §0 표의 `{placeholder}`만 채우면 된다. 본문은 `{이름}` 형태로 §0을 참조한다.

---

## 0. 프로젝트 설정 — 프로젝트별로 채우는 곳

| 항목 | placeholder | 웹 예시 | 앱 예시 |
|------|:----------:|--------|--------|
| 프로젝트명 | `{프로젝트명}` | shop-web | SetBox |
| 플랫폼 | `{플랫폼}` | 웹 (Next.js) | 모바일 (Expo/RN) |
| 타입 체크 | `{타입체크}` | `npx tsc --noEmit` | `npx tsc --noEmit` |
| 단위 테스트 | `{단위테스트}` | `npx vitest run` | `npx jest` |
| 린트 | `{린트}` | `npx eslint .` | `npx expo lint` |
| E2E 도구 | `{E2E도구}` | Playwright (+ MCP) | Maestro |
| E2E 실행 | `{E2E실행}` | `npx playwright test` | `./scripts/e2e-test.sh` |
| 디자인 도구 | `{디자인도구}` | Pencil / Figma | Pencil |
| 실행 확인 환경 | `{실행환경}` | 브라우저 (dev server) | 시뮬레이터/에뮬레이터 |
| 커버리지 목표 | `{커버리지}` | 핵심 도메인 80% / 서비스·스토어 70% / 유틸 90% | 좌동 |
| 위험 도메인 | `{위험도메인}` | 결제, 인증, 주문 데이터 | Timer core, 백그라운드 복구, 세션 기록 |
| AI 월 예산 (선택) | `{AI예산}` | 월 $50 — §8.4 루프 cap의 상한 | 좌동 |

> `{위험도메인}` = 실패 시 사용자 데이터·돈·신뢰에 직접 영향을 주는 프로젝트 핵심 로직.
> 프로젝트 시작 시 반드시 명시적으로 정의한다 (§2 자동 Tier 3의 입력값).

---

## 1. 목적과 핵심 원칙

**핵심 원칙** (보존):
1. **문서 → 디자인 → 소스** — 변경 반영 순서 필수, 코드부터 시작 금지.
2. **AC 기반 개발** — User Story의 Acceptance Criteria가 구현/테스트/리뷰의 단일 기준.
3. **ATDD + TDD 이중 루프 필수** — 외곽: AC를 *실패하는 인수 테스트*로 먼저 변환(ATDD), 내부: 단위 RED → GREEN → REFACTOR(TDD). 테스트 없는 기능 코드 금지. 인수 테스트는 가능한 가장 빠른 레벨(서비스/API/컴포넌트)에서 작성 — E2E는 §5의 별도 게이트.
4. **Critical+Major 0건 원칙** — 자동 리뷰 루프는 Critical+Major 이슈가 0건이 될 때까지 반복. Minor는 Orchestrator 재량.
5. **검수 후 커밋** — 사용자 확인 없이 형상관리 금지.
6. **feature/* 브랜치만 직접 push** — develop 이후 PR 필수, `gh pr merge --merge` (PR/US 단위 추적성). 브랜치 전략 상세는 `docs/project-init.md` 참조.
7. **리뷰-수정 분리** — 리뷰어는 별도 파일로 이슈 기록, 원본 직접 수정 금지. 작성자가 반영.
8. **디자인 시스템 준수** — Foundation → Component → Pattern → Screen 4 레이어, 토큰 단일 소스.
9. **자기참조성** — 본 문서 / docs/project-init.md / CLAUDE.md 변경은 자동 Tier 3.
10. **쉬프트-레프트** — US/AC 단계 결함 검출이 가장 비용 효율적. 작성 시점에 강한 리뷰 적용.
11. **agent·skill 지점 바인딩** — 워크플로우가 뼈대, agent와 skill은 그 위의 **명시된 지점**(§3 단계·§5 게이트·§6 시점)에 배치한다. 발동 지점이 문서에 없는 agent/skill은 만들지 않는다 (§9 배치 원칙).
12. **maker-checker 쌍** — 만드는 에이전트가 있으면 그 산출물을 검사하는 에이전트가 반드시 있어야 한다 (예: developer ↔ code-reviewer). 검사 없는 생성 에이전트 도입 금지.
13. **정량 평가 기반 진화** — 워크플로우 완료 시마다 정량 지표를 남기고, 평가 결과로 **개선/유지/폐기**를 결정한다 (§10). 측정할 수 없는 규칙은 만들지 않는다.

---

## 2. Tier 분류 — 모든 작업의 진입점

**3축 위험 평가 — 각 축 yes=1 / no=0** (30초 안에 판단). 의심되면 위험 방향(yes)으로.

| 축 | 질문 (yes = 위험) |
|---|------|
| **사용자 영향** | 사용자가 직접 보거나 체감하는가? |
| **되돌림 비용** | 실패 시 되돌리기 어렵거나 데이터 영향이 있는가? |
| **검증 불명확** | 자동 테스트·명확한 수동 확인으로 증명하기 **어려운가?** |

**판정 함수**: 위험 합계 **0 = T1 / 1 = T2 / 2+ = T3**. 위험 도메인 해당 시 합계 무관 자동 T3.

| Tier | 정의 | 예시 |
|------|------|------|
| **T1 Trivial** | 위험 0 — **동작·의도·사용자 가시 문구를 바꾸지 않는 변경만** | 내부 오탈자, lint, 포맷팅, unused import |
| **T2 Standard** | 위험 1 | 기존 US 1개 구현, UI 텍스트 변경, 컴포넌트 추가, **기존 expectation 보정**(테스트가 승인하는 대상을 바꾸므로 최소 T2) |
| **T3 Major** | 위험 2+ 또는 자동 T3 | 신규 US, 데이터 모델/마이그레이션, `{위험도메인}`, 메타 워크플로우 |

### 재분류 — 스코프 드리프트 대응

작업 중 상향 사유(위험 도메인 접촉, 새 위험 축 발견)가 나오면 **즉시 중단 + 새 Tier로 초단축 재브리핑** 후 둘 중 선택:
1. 기존 산출물이 새 Tier 게이트를 통과할 수 있으면 → **현 작업에서 증거 보강**
2. 설계 변경 또는 위험 도메인 접촉이면 → **현 브랜치 동결 + 신규 작업으로 분리**

선택은 Orchestrator가 제안하고 **사용자가 결정**, 사유는 PR 본문에 기록(§10.1). 상향 후에는 생략했던 단계·증거를 새 Tier 기준으로 재구성한다.

### 자동 Tier 3 = 위험 도메인 (단일 정의)

다음 영역은 **분류 평가 생략 → 자동 Tier 3** + **3인 리뷰 항상 발동** (§6에서 "위험 도메인"으로 참조):

- 데이터 모델 / 마이그레이션 / 저장소 스키마
- `{위험도메인}` — §0에서 정의한 프로젝트 핵심 로직
- 보안 / 개인정보 / 인증
- 메타 워크플로우 (workflow.md / project-init.md / CLAUDE.md)
- 신규 화면 + 신규 상태 + 신규 데이터 동시

---

## 3. 7단계 기본 흐름

```mermaid
flowchart LR
    S1[1. 브리핑<br/>+ Tier 분류] --> S2[2. 기획<br/>US + AC]
    S2 --> S3[3. 디자인]
    S3 --> S4[4. 구현<br/>브랜치 + ATDD/TDD]
    S4 --> S5[5. 검증<br/>리뷰 + E2E]
    S5 --> S6[6. 형상관리<br/>검수 + PR]
    S6 --> S7[7. 완료<br/>평가·개선·다음 제안]
    S7 --> DONE((사이클 종료))
    style S1 fill:#4a9eff,color:#fff
    style S4 fill:#ff6b6b,color:#fff
    style S5 fill:#ffd93d,color:#333
    style S6 fill:#6bcb77,color:#fff
    style S7 fill:#9575cd,color:#fff
    style DONE fill:#45b7aa,color:#fff
```

| # | 단계 | 담당 | 산출물 | T1 | T2 | T3 |
|---|------|------|------|:--:|:--:|:--:|
| 1 | **브리핑** + Tier 분류 + 일정 산정 | Orchestrator | 작업 범위·접근·예상 변경·Tier·AI/사용자 시간 | 짧게 | ✓ | ✓ |
| 2 | **기획** (US + AC) | Planner | `artifacts/planning/user-stories/*.md` (Given-When-Then) | skip | 최소 | ✓ 정식 |
| 3 | **디자인** (`{디자인도구}`) | Designer | `artifacts/design/*` 프레임 + 매핑 갱신 | skip | UI 시 | ✓ |
| 4 | **구현** (브랜치 + ATDD/TDD) | Developer | `feature/*` + 인수·단위 테스트 + 코드 + 디자인 대조 | 테스트 면제 가능 | ✓ | ✓ |
| 5 | **검증** (리뷰 + E2E) | QA Reviewer | 리뷰 파일, E2E flow, pass-fail 로그 | 자체 점검 | 1회 | 풀 루프 |
| 6 | **형상관리** | Ops | 검수 + todo 갱신 + PR + merge | ✓ | ✓ | ✓ |
| 7 | **완료** (평가·개선·다음 작업 제안) | Orchestrator | §10.1 지표 확정 · §10.3 기준 개선 제안 · todo spine 기반 다음 작업 제안 | 기록 1줄 | ✓ | ✓ |

> 시각화: `.claude/workflows/workflow.drawio` (7 스윔레인 A~G, 역할 색상) · `.claude/workflows/workflow.html`

---

## 4. 공통 리뷰 루프

```
작성자 산출물 → Reviewer 이슈 파일 → Orchestrator 판정
  ├─ Critical+Major 0건 → 다음 단계 또는 사람 판단
  ├─ Round 상한 도달 → 사용자 에스컬레이션
  └─ 그 외 → 작성자 반영 → R+1
```

**Round 상한**: T1 없음 / T2 R1~R2 / T3 R1~R3 / 예외(사용자 승인) R5.

R2 초과 시 **Context Hygiene** — 세션을 새로 열고 핵심 스펙만 Read하여 컨텍스트 정화.

**리뷰 파일**: `artifacts/review/{type}-{scope}-review[-{reviewer}]-round{N}.md` (type: us/design/code/e2e/content, reviewer: claude/codex/gemini).

**판정 주체**: 라운드 중 통합·중재는 **Orchestrator (Claude 메인 세션)**. 별도 "기획 판단 에이전트" 없음.

**종결 판정 (held-out)**: 루프 종결("Critical+Major 0건") 선언은 Tier 차등 —
- **T3·위험 도메인**: 작성에 참여하지 않은 노드(3인 리뷰의 codex/gemini 또는 fresh 세션)가 **필수**로 판정. 코드를 쓴 에이전트가 자기 완료를 선언하지 않는다 (원칙 12).
- **T2**: 선택 (비용 고려, Orchestrator 재량).
- **T1**: self.

---

## 5. 품질 게이트 매트릭스 — Tier별 적용

| 게이트 | T1 | T2 | T3 | 기준 |
|--------|:--:|:--:|:--:|------|
| 타입 체크 | ✓ | ✓ | ✓ | `{타입체크}` 0 errors |
| 단위 테스트 | 관련만 | 관련 + 회귀 | 풀 + 신규 | `{단위테스트}` pass |
| 커버리지 | skip | 변경 영역 | `{커버리지}` 목표 달성 | 커버리지 리포트 |
| 린트 | ✓ | ✓ | ✓ | `{린트}` 0 errors |
| AC 충족 (인수 테스트) | n/a | ✓ | ✓ | AC를 변환한 인수 테스트 pass로 증명 (ATDD 외곽 루프) |
| 디자인 대조 | skip | UI 시 | UI 시 ✓ | `{디자인도구}` vs `{실행환경}` |
| 코드 리뷰 | self | R1 | R1~R3 | Critical+Major 0 |
| E2E (`{E2E도구}`) | skip | 핵심 영향 시 | 기본 전체 — 명시적 Impact 분석 근거 시 관련 flow로 축소 가능 | `{E2E실행}` pass. SYS 면제 가능 |
| 3인 교차 리뷰 | §6 매트릭스 참조 |

**Tier별 최소 증거**: T1 변경 파일+테스트 / T2 AC+리뷰 1개 / T3 US+리뷰들+테스트·E2E.

---

## 6. cmux 3인 교차 리뷰 — 작성/수정 × Tier 매트릭스

> **검토 ≠ 3인 리뷰.** 3인 리뷰는 **사용자 활성 시간을 줄이는 도구** (사용자가 R1~R3 반복 검토 → 1회 검토로 압축).
>
> **비용 함수**: 사용자 활성 검토 시간 = 진짜 비용. AI 토큰/시간/대기는 낮은 가중치.

### 6.1 발동 결정 트리 (작성/수정 직후 5개 yes/no 순차 평가)

```
1. 위험 도메인인가? (§2 자동 Tier 3 = 메타/데이터/{위험도메인}/보안/신규 화면+상태+데이터)
   → yes: 3인 필수 (작성/수정·Tier 무관)
   → no: 다음

2. R2 초과 의견 갈림 또는 사용자 명시 요청인가?
   → yes: 3인 필수
   → no: 다음

3. T1인가?
   → yes: skip (자체 점검만)
   → no: 다음

4. 작성(신규)인가, 수정인가?
   → 작성: §6.2 매트릭스 적용
   → 수정: §6.3 매트릭스 + 의미 변경 승격 규칙 적용

5. 사용자가 "skip" 명시했나?
   → yes: skip + PR 본문 "Review skipped: <근거>" 1줄
   → no: 매트릭스 결과 적용
```

> **skip 우선순위**: 사용자 명시 skip은 §6.2/6.3의 "필수"보다 우선한다. 단 **위험 도메인(트리 1번)은 사용자도 skip 불가** — 검증 방식 대체(§8.1)만 가능.

### 6.2 작성 시 매트릭스 (신규 산출물)

| 시점 | T1 | T2 | T3 |
|------|:--:|:--:|:--:|
| US/AC 작성 | skip | **필수** | **필수** |
| 디자인 작성 (신규 화면) | skip | 권장 | **필수** |
| 테스트 작성 (인수+단위) | self | **필수** | **필수** |
| 소스 코드 작성 | self | **필수** | **필수** |
| E2E 작성 | skip | **필수** | **필수** |

### 6.3 수정 시 매트릭스 (기존 산출물 변경, 시점별)

| 시점 | T1 | T2 | T3 |
|------|:--:|:--:|:--:|
| US/AC 수정 | skip | 선택 (의미 변경 시 작성급 승격) | 의미 변경=3인 필수 / 단순 보정=QA |
| 디자인 수정 | skip | skip (눈검수) | 구조 변경 시 권장 / 미세 조정=skip |
| 테스트 수정 (인수+단위) | self | 선택 | 의도 변경 시 필수 / 단순 보정=QA |
| 소스 코드 수정 | self | 선택 | 설계 변경 시 필수 / 단순 보정=QA |
| E2E 수정 | skip | skip (selector 안정화 = QA 단독) | 여정/순서 변경 시 필수 |

**의미 변경 승격 규칙** — 다음 중 1+ 해당 시 "수정"이 작성급으로 승격 (§6.2 적용):
- AC 의미 변경 / 설계 변경 / 데이터·`{위험도메인}`·보안 영향 / E2E 여정 변경

> **위험 도메인은 작성/수정·Tier 무관 항상 필수** — §6.1 결정 트리 1번에서 이미 처리.

### 6.4 추가 발동 트리거 (매트릭스 외)

다음 1+ 해당 시 위 매트릭스 결과와 무관하게 3인 리뷰 발동 (§6.1 결정 트리 2번):
1. **R2 초과 의견 갈림** (Major 판단 합의 안 됨)
2. **사용자 명시 요청** ("교차 리뷰" / "토론" / "3인 의견")

### 6.5 한 작업 안에서 시점 sequence

T2/T3 작업 1건 = 4~5개 시점 (US/AC → 디자인 → 테스트 → 소스 → E2E)에서 각각 §6.1 결정 트리 검사.

**기본 원칙 (병렬 + 시점별 즉시 검토)**:
- 각 시점 작성 직후 즉시 발동 (다음 시점 진입 전 완료)
- 3인 리뷰는 codex/gemini 동시 송신 (병렬, 가장 느린 모델 기준 wall-clock)
- Orchestrator summary는 **시점별 1쪽** (시점마다 1회)
- 사용자 검토 = 시점별 1회, 작업당 4~5회 × 5~20분 = 총 활성 시간 20~100분

**묶음 옵션 (사용자 명시 요청 시)**:
- 모든 시점 마치고 한꺼번에 검토 = 작업당 1회
- **장점**: 사용자 활성 시간 ↓ (~30분 단일 검토)
- **단점**: 회귀 비용 ↑ (US/AC 결함이 E2E까지 전파된 후 발견)
- **추천 시점**: T2 단순 작업, 위험 도메인 X. T3는 묶음 비추 (조기 발견 가치 큼).

### 6.6 사용자 활성 시간 압축 흐름 (시점 1개 기준)

```
[1] AI 산출물 작성
[2] 3인 리뷰 (Claude+Codex+Gemini, 병렬)        ← 사용자 시간 0 (다른 작업 가능)
[3] Orchestrator summary 작성 (1쪽, ≤5개 결정)  ← 사용자 시간 0
[4] AI 합의 이슈 반영                           ← 사용자 시간 0
[5] 사용자 검토 1회 (summary만)                 ← 활성 시간 5~20분
[6] 사용자 OK → 다음 시점 진입
```

> **위험 도메인 한정 옵션 — Echo-back 검수**: 에이전트가 변경의 why를 설명하고 사용자가 1문장으로 요약 응답 — 이해 격차(Comprehension Debt) 강제 동기화.

### 6.7 Orchestrator Summary 형식 (필수)

사용자가 raw 리뷰 3개를 읽지 않고 **Summary 1쪽만** 검토:

```markdown
## 3인 리뷰 통합 (Round N, 시점: <US/AC|디자인|테스트|소스|E2E>)
- Critical/Major 합의 이슈: <list>
- raw C/M 집계 병기: claude C{n}/M{n} · codex C{n}/M{n} · gemini C{n}/M{n}  ← summary와 불일치 시 즉시 노출 (요약 편향 가드)
- 모델 간 의견 충돌: <있으면 명시>
- 사용자 결정 필요 질문: <≤5개, 핵심 의도 결정>
- raw 파일: artifacts/review/*-{claude|codex|gemini}-round{N}.md
```

**최대 5개 결정 항목** cap. Critical+Major 0이면 사용자는 summary 보고 즉시 OK.

### 6.8 절차
- 상세 cmux 명령·토론 프로토콜: 글로벌 스킬 `multi-ai-discussion` 참조 (3-pane 셋업, 응답 완료 프로토콜, 공유 칠판 모드).
- 종결 판정: 3인 모두 Critical+Major 0건. 갈리면 가장 엄격한 기준 수용 후 R+1.

---

## 7. AI 역량 기준 일정 산정

> 작업 추정은 사람 기준이 아니라 **AI 기준**. 진짜 병목은 사용자 결정·검토 시간.

### Tier별 매트릭스

| Tier | AI 작업 | 사용자 검토 | 대기·버퍼 | Wall-clock |
|------|:------:|:--------:|:------:|:--------:|
| T1 | 5~20분 | 0~10분 | 0~10분 | 10~40분 |
| T2 | 30~120분 | 15~30분 | 20~60분 | 1~3.5시간 |
| T3 | 2~6시간 | 30~90분 | 1~4시간 | 반나절~2일 |
| T3 + 3인 리뷰 | 3~8시간 | 45~120분 | 2~6시간 | **1~3일** |
| 메타 (workflow.md 등) | 2~6시간 | 1~3시간 | 1~3시간 | 1~2일 |

> 메타 행은 "T3 + 3인 리뷰"의 특수형 — 코드 게이트 대신 문서 정합 검증이라 wall-clock은 짧지만 사용자 검토 비중이 더 크다.

### 표기 규칙 (브리핑 단계 필수)

```
AI 작업 / 사용자 검토 / 버퍼 / 3인 리뷰 포함 여부
예: "T2 작성, AI 60분 / 사용자 검토 15분 / 버퍼 30분 / 3인 리뷰 4회"
```

### 변동 요인
- 외부 AI 응답 대기 (병렬 시 가장 느린 모델 기준)
- **외부 AI rate limit 도달** — 작업 중단·재개 비용
- approval 모달 처리
- cmux pane 문제 / 컨텍스트 비대화 / AI 헤매는 경우

---

## 8. 예외와 면제

### 8.1 SYS 면제 (수동 검수 + E2E 면제)
**조건** (모두): UI 변경 없음 / 사용자 직접 확인 화면 없음 / 단위·통합 테스트 동등 검증 / 코드 리뷰 C+M 0건 / Legacy 회귀 별도 검증.

**대체 검증**: 단위·통합 테스트, 타입 체크, 마이그레이션 검증 로그.
**기록**: PR/US 설명에 면제 근거 1줄. **"면제 = 검증 방식 대체"** (검증 없음 X).

### 8.2 Fast-track (출시 직전 release blocker)
**대상**: release blocker만. 사용자 명시 승인 필수.

**3대 안전장치**:
1. **Scope Lockdown** — 데이터·`{위험도메인}`·마이그레이션·보안 변경 절대 금지 (T3 fast-track 불가)
2. **Explicit Evidence** — 타입 체크 + 관련 단위 테스트 100% 통과 결과 PR/커밋 포함
3. **Post-mortem Marker** — `[FT]` 마킹 + 매 릴리스 직후 5분 회귀 체크

**남용 모니터링**: 매월 `git log --grep "FT\|fast-track"` 카운트. 월 5회 초과 시 재검토.

### 8.3 T1 자동 흐름 단축
T1 = 브리핑 → 구현 → 형상관리 → 완료(§10.1 기록 1줄)의 단축 흐름. 기획·디자인·검증 게이트 skip. 단 타입 체크+관련 테스트 생략 금지.

### 8.4 자동 루프 등록 규칙 (Loop Budget & Permission Guard)

/loop·cron·hooks 등 **자동 루프**를 등록할 때 다음 7개 항목을 함께 기록한다 (위치: `artifacts/progress/loop-triage.md` 상단):

```
목적 / 주기 / 예산 cap (토큰 또는 시간) / 허용 도구 / 쓰기 권한 / 종료 조건 / 산출물 위치
```

- **자동 루프는 커밋·머지·PR publish 금지** — 발견·기록까지만. 결정은 사람이 (원칙 5 유지).
- **예산 cap 필수** — 미지정 시 보수적 기본값(최대 3회 실행) 강제. 루프 종료 시 사용 토큰/비용 1줄 기록.
- **자동화 대상은 점검류만** — 광역 버그 헌팅·탐사 금지 (§10.2 점검 항목이 1차 후보).
- **커넥터(MCP/CLI) 이원화** — 읽기·증거 수집은 자유. 쓰기 행위(PR 생성 등)는 **Draft까지**, publish는 사용자 게이트.
- 빈 결과로 끝난 루프는 자동 종료 (기록 0줄 — 트리아지 노이즈 방지).

---

## 9. 역할과 완료 조건

### 6개 핵심 역할

| 역할 | 책임 | 단계 |
|------|------|------|
| **Orchestrator** (Claude 메인) | Tier 분류, 흐름 선택, 리뷰 통합 판정, **3인 summary 작성**, 사용자 대화, **완료 단계 평가·다음 작업 제안** | 1, 4, 5(판정), 6, 7 |
| **Planner** | US+AC 작성 (Given-When-Then), Spec 검토 체크리스트 | 2 |
| **Designer** | 디자인 (`{디자인도구}`), 디자인 스펙 정리, 디자인 시스템 준수 | 3 |
| **Developer** | ATDD/TDD 이중 루프 구현, `{위험도메인}` 전문 작업, 커버리지 보강 | 4 |
| **QA Reviewer** | 코드 리뷰, 디자인 대조, E2E flow, 회귀 검증 (모드: code/design/E2E) | 5 |
| **Ops** | 브랜치, todo, 커밋, PR, 릴리스 | 1(브랜치), 6 |

> 모드 전환 시 명시적 `Read(체크리스트)` 필수 — Mode Confusion 방지.
> 전문 프롬프트는 `.claude/agents/*.md` 참조.

### agent·skill 배치 원칙 (원칙 11·12의 운영 규칙)

- **지점 바인딩**: 새 agent/skill 도입 시 §3 단계·§5 게이트·§6 시점 중 **어디서 발동하는지 먼저 명시**하고 `.claude/agents/`·`.claude/skills/`에 기록한다. 발동 지점 없는 범용 agent 금지.
- **maker-checker 쌍 필수**: 생성형 agent(planner, designer, developer 등)는 대응하는 검사 agent(us-reviewer, design-reviewer, code-reviewer 등)와 **쌍으로만** 도입한다. 검사자는 작성에 참여하지 않은 노드여야 한다 (원칙 7 리뷰-수정 분리와 연결).
- **배치 맵 = §3 단계 표의 "담당" 열**: agent를 추가·변경하면 §3 표를 같이 갱신한다 — 표에 없는 agent는 워크플로우에 없는 것이다.

### 에이전트 중심 실행 패턴 (스킬 실행 주체 = maker 에이전트 — 원칙 12의 구조적 강제)

**문제 신호.** 스킬(playbook)을 **메인(Orchestrator)이 직접 실행**하면 *만든 주체 = 검수 주체*가 되어 self-approval이 생긴다(원칙 12·§4 held-out 위반). 저위험에선 무해하지만, **공개·비가역·고위험 산출물**(외부 발행 콘텐츠·코드·마이그레이션)에선 독립 검수가 빠진 채 발행되는 구멍이 된다.

**3노드 + 오케스트레이터.** 해당 산출물을 만드는 스킬은 메인이 직접 실행하지 않고 다음으로 실행한다:

| 노드 | 역할 | 컨텍스트 | 도구 | self-approve |
|------|------|---------|------|:---:|
| `<x>-writer` (maker 에이전트) | 스킬을 *실행*해 초안 생성 | 서브에이전트(격리) | Skill + 작성 도구 | ❌ 자기 완료 선언 금지 |
| `<x>-write` (action 스킬) | 산출 행위 자체 (기계적) | maker 안에서 실행 | Write·Read·Edit·Bash | n/a |
| `<x>-reviewer` (checker 에이전트) | 독립 검수·게이트 | 서브에이전트(컨텍스트 격리) | source **read-only** + 리뷰 파일만 write | ❌ 게이트만·소스 수정 금지 |
| Orchestrator (메인) | Tier 분류·라우팅·디스패치·통합·판정 *요청·기록* | 메인 | 전체 | ❌ 스스로 종결 선언 금지(§4) |

> ⚠️ **"격리 ≠ 탈상관"(거버넌스 환상 주의).** 서브에이전트는 *컨텍스트*만 격리될 뿐 **모델 계열은 메인과 동일**하다(correlated errors). 따라서 same-model `<x>-reviewer`는 **§4 held-out이 아니다** — 앵커링은 줄여도 모델 편향은 그대로다. 진짜 탈상관(held-out) 종결은 **§6 교차모델 3인 또는 fresh 세션**에서만 나온다. Orchestrator도 메인이라 **자기 종결 선언을 하지 않는다**(§4): 라우팅·통합·판정 *요청·기록*까지만, 최종 "Critical+Major 0건" 선언은 비작성 노드가 한다.

**제어 흐름.**
1. Orchestrator가 Tier 분류·라우팅.
2. `<x>-writer`가 `<x>-write` 스킬을 호출해 `status: draft` 산출 — **자기 완료를 선언하지 않는다**.
3. Orchestrator가 **별개** `<x>-reviewer` 디스패치 — source read-only, 이슈는 **§4 캐노니컬 리뷰 파일**(`artifacts/review/{type}-{scope}-review-{reviewer}-round{N}.md`)에만 기록(원칙 7, 새 경로 발명 금지).
4. **기계적 판정(하드 제약).** reviewer 보고 Critical+Major가 **1건이라도 있으면 자동 FAIL** — Orchestrator 재량 통과 금지. FAIL → writer 재작업 → reviewer 재디스패치 = **§4 Round 루프**(상한 T2 R1~2 / T3 R1~3, 초과 시 사용자 에스컬레이션).
5. **종결·발행 게이트 — T3 held-out 예외 없음(§4).** 패턴 진입 산출물은 경계상 **모두 T3**((공개 AND 비가역)=§2 2축=T3, 또는 자동 T3)이므로 §4 "작성 비참여 노드 종결"이 **예외 없이 적용**된다. same-model `<x>-reviewer`는 *first-pass 게이트*(하드 제약)일 뿐 **종결 노드가 아니다**. "**고위험**" ≡ 자동 T3·위험도메인(§2). 두 분기는 held-out **강도만** 다르다(상호배타):
   - **고위험(자동 T3·위험도메인)**: `<x>-reviewer` first-pass 후 **§6 교차모델 3인 게이트 필수**. 3인 C+M 0 = held-out 종결 → 사용자 발행 승인.
   - **(공개 AND 비가역) but ¬고위험**: `<x>-reviewer` first-pass 후 **held-out 종결 필수 — fresh 세션 또는 §6 중 택1**(§4 충족, §6 3인까지는 비강제). same-model 단독 종결 불가. 의심 시 §6 승격.

**전환 경계 (과공학 방지 — 원칙 13).** 3노드화는 **(공개 AND 비가역) 또는 자동 T3**(데이터·위험도메인·보안·메타·신규 화면+상태+데이터)인 산출물에만. 판단은 §2 **3축 전체**(사용자 영향·되돌림 비용·검증 불명확)와 판정 함수(2+ = T3)를 그대로 쓴다 — 새 기준을 만들지 않는다. 저위험 유틸리티(로컬 read/transform: 문서 변환·검색 등)는 메인 직접 실행 **순수 스킬로 유지**. ⚠️ 단 형상관리처럼 **원격·발행·merge 등 비가역 쓰기**를 포함하는 스킬은 저Tier여도 §9 DoD·§8.4의 사용자/Ops 발행 게이트를 유지한다(저위험 예외 ≠ 발행 자동화 허용).

**네이밍 규약.** action 스킬 = 동사(`<x>-write`/`-render`/`-build`), maker = `<x>-writer`, checker = **캐노니컬 역할 reviewer명 재사용**(developer↔code-reviewer, designer↔design-reviewer, planner↔us-reviewer), 없을 때만 `<x>-reviewer` 신설. `<x>` = 스킬 기준 명사(예: `sns`).
- **agent 역할명 ≠ reviewer 식별자**: §4/§6 리뷰 파일의 `{reviewer}`는 *모델 id*(claude/codex/agy), `code-reviewer`는 *agent 역할명* — 혼동 금지.
- ⚠️ **마이그레이션·충돌**: 기존 스킬 `sns-writer`(이미 `-writer` 점유)는 규약상 **스킬 `sns-write` + 에이전트 `sns-writer`**로 분리(P1 파일럿 처리). `-write`/`-writer` 1글자 차이는 grep·오타 취약 — 파일럿에서 혼동 비용을 측정해 필요 시 동사 분리(`sns-compose` 등) 재검토.

**메커니즘은 파일럿(RFC) — 검증 전 표준화 금지.** 위 *거버넌스*(3노드 역할·held-out 종결·검수 분리·하드 제약·경계)는 원칙 11·12의 정본 강제다. 그러나 **"에이전트가 스킬을 호출"하는 구현 메커니즘은 미검증 = 파일럿**:
- **Option A**(우선): maker 에이전트 frontmatter `tools: Skill,…` + "초안은 `<x>-write`로만".
- **Option C**(경량 폴백): 하네스가 서브에이전트 `Skill` 미지원이면 메인이 스킬을 실행하되 **독립 `<x>-reviewer` 서브에이전트로 검수만 분리**(검수 분리 = 가치의 핵심).
- **Option B**(무거움·최후): cmux pane(multi-ai-discussion식) — 화면 점유·흐름 단절 크니 다른 경로 불가 시만.
- **파일럿 게이트**: 첫 전환(dakman-sns)에서 동작·기록 경로·성공 기준을 확인하기 전까지 **메커니즘(A/B/C) 표준 확정과 타 프로젝트 agent/skill 생성을 금지**한다. 거버넌스 표준의 *문서화 자체*(본 §9·project-init §8 포인터)는 정본이므로 이 금지와 무관 — 다운스트림은 *문서화된 스펙*에 맞춰 파일럿 후 구현한다. 결과는 §10.2 지표로.

**측정(원칙 13).** §10.2에 추가: **공개 산출물 탈출 결함 수(패턴 전/후)** · **단일 모델 self-approval 발행 건수**(同 계열 노드만 거쳐 발행된 공개물). 개선 없으면 §10.3으로 폐기 검토.

**산출물 상태기계.** maker 산출 frontmatter `status`: `draft`(writer) → `reviewed`(same-model `<x>-reviewer` first-pass PASS) → `held-out-passed`(§4 held-out 종결: 고위험=§6 교차모델 / ¬고위험=fresh 세션 또는 §6) → `published`(사용자 승인 후 Orchestrator 기록). 검수 노드(`same-model`·`held-out:fresh|xmodel`)를 frontmatter에 함께 기록 — 이게 §10.2 "단일 모델 self-approval 발행 건수" **집계 키**다(`held-out-passed` 없이 `published` = self-approval 신호). **T3(=모든 패턴 진입 산출물)는 `reviewed`에서 바로 `published`로 갈 수 없다** — `held-out-passed` 필수.

### 완료 조건 (Definition of Done)
- 모든 적용 게이트 Critical+Major 0건 (종결 판정은 §4 held-out 규칙)
- `artifacts/progress/todo.md` 갱신 — 항목별 1줄 spine: `status(open/tried/passed/blocked) · 다음 행동 · 검증 증거 링크 · 되돌릴 커밋`. 상세 증거는 artifacts/review·tests 링크로 (todo 오염 방지). **세션 재개 시 첫 Read 대상.**
- 사용자 검수 통과 (T1/SYS 면제 가능)
- pre-merge 검증: `{단위테스트}` + `{타입체크}` pass
- PR 본문 필수 필드:
  - **why / risk / rollback** 각 1줄 (Comprehension Debt 가드 — 사용자가 확인)
  - **Tier 기록**: initial/final Tier · 3축 판정 값 · 자동 T3 여부 · 재분류 사유(해당 시)
  - §10.1 정량 기록 (라운드 수 · first-pass · 활성 시간) + Fast-track/SYS 면제 근거(해당 시) + 3인 리뷰 summary 링크
- `gh pr merge --merge` (rebase 금지, PR/US 단위 추적성 유지)

---

## 10. 정량 평가와 자기 점검 — 개선/유지/폐기 결정 (원칙 13)

### 10.1 작업 완료 시 기록 (수집 지점 = PR 본문 + 7단계 완료, §9 DoD와 연결)

워크플로우 1회 완료(PR 머지)마다 다음을 PR 본문에 남기고, **7단계(완료)에서 Orchestrator가 지표를 확정**한다 — 월간 평가의 데이터 원천:

```
Tier / 리뷰 라운드 수 / 게이트 first-pass 여부 / 사용자 활성 검토 시간(분) / FT·면제 여부
```

7단계는 기록에 그치지 않는다 — §10.3 기준으로 즉시 개선점을 제안하고(작업 단위 마이크로 평가), todo spine을 기반으로 **다음 작업을 제안**한다.

### 10.2 매월 1회 집계·평가

- `git log --grep "FT"` Fast-track 빈도
- 최근 PR 10개에서 실제 사용 단계 vs 문서 명시 단계
- `artifacts/review/` R3+ 파일 카운트 (자동 루프 깊이)
- 3인 리뷰 summary 품질 (5개 결정 항목 cap 준수 여부)
- **탈출 결함 수** — 머지 후 발견된 버그를 당시 부여 Tier별 집계 (오분류 신호)
- **사용자 활성 검토 시간 추이** — 본 워크플로우의 1차 비용 함수 (증가 추세 = 워크플로우 실패 신호)
- **summary ↔ raw 대조** — 3인 리뷰 summary의 C/M 카운트와 raw 리뷰 파일 집계 일치 여부 (요약 편향 감지, §6.7 병기 의무와 쌍)
- **자동 루프 §8.4 준수** — 등록된 루프의 7개 항목 기록·예산 cap·사용량 기록이 실제로 채워졌는지
- **에이전트 중심 패턴 효과(§9)** — 공개 산출물 탈출 결함 수(패턴 전/후) · 단일 모델 self-approval 발행 건수(同 계열 노드만 거쳐 발행된 공개물). 개선 없으면 §10.3으로 폐기 검토

### 10.3 평가 기반 결정 (개선 / 유지 / 폐기)

| 신호 | 결정 |
|------|------|
| 지표 개선 또는 안정 | 유지 |
| 3회 이상 우회된 규칙 | 삭제·축약·예외화 (개선) |
| 3회 이상 즉흥 처리된 노하우 | 문서화 (흡수) |
| 측정 자체가 불가능한 규칙 | 측정 가능하게 수정하거나 폐기 |
| 비용(활성 시간) 증가 + 품질(탈출 결함) 미개선 | 해당 단계/게이트 폐기 검토 — 워크플로우는 성역이 아니다 |

새 규칙 도입 시 "운영 가능성 체크" 통과 필수: 30초 판단 가능 / 산출물 위치 명확 / 생략 조건 명확 / 중복 X / **측정 지표 존재**.

### 10.4 점검 자동화 (한정)

§10.2 월간 집계는 cron / `/loop`로 자동화할 수 있다 — 단 **§8.4 등록 규칙(예산 cap·쓰기 금지) 준수**:
- 대상은 **점검류만** (지표 집계, 기한 알림, FT 카운트). 광역 버그 헌팅 금지.
- 산출물: `artifacts/progress/loop-triage.md` — 발견이 있을 때만 기록, 없으면 자동 종료.
- 참고 잔여 아이디어(미채택): Complexity Delta(수정 대비 코드량 비대 = 슬롭 신호) — 측정 방법 확립 전까지 §10.2 수동 점검 시 정성 참고만.

---

## 11. 참고 문서

경로는 `docs/project-init.md`의 기본 폴더 구조(`artifacts/planning·design·progress·review·tests`, `docs/`)를 따른다.

| 문서 | 내용 |
|------|------|
| `docs/project-init.md` | 프로젝트 초기화 가이드 — 저장소 생성, 브랜치 전략(feature/* → develop → staging → production), 폴더 구조 |
| `.claude/workflows/workflow.md` · `workflow.drawio` · `workflow.html` | 본 문서(정본) + 다이어그램 + 시각화 뷰 |
| `artifacts/planning/prd.md` | 제품 요구사항 |
| `artifacts/planning/user-stories/*.md` | US + AC (Given-When-Then) |
| `artifacts/planning/architecture.md` | 기술 스택, 폴더 구조, 상태 관리 |
| `artifacts/planning/ci-cd.md` | CI/CD 배포 파이프라인 (웹: Vercel/Cloudflare 등, 앱: EAS 등) |
| `artifacts/design/design-system.md` | 디자인 시스템 4 레이어, 토큰 |
| `artifacts/design/us-to-frame-map.md` | US ↔ 디자인 프레임 매핑 |
| `artifacts/review/` | 리뷰 이슈 파일 (§4 네이밍 규칙) |
| `artifacts/tests/` | E2E flow, pass-fail 로그, 커버리지 리포트 |
| `artifacts/progress/todo.md` | 진행 상황 + Fast-track `[FT]` 마킹 |
| `.claude/agents/*.md` | 6개 역할별 전문 프롬프트 |
| `.claude/skills/` | 프로젝트 스킬 (커버리지 측정 SSoT 등) |
| 글로벌 스킬 `project-init` | 프로젝트 초기화 — `docs/project-init.md`를 MAY/ASK/STOP 플레이북으로 실행 (글로벌 단일 정본 `~/.claude/skills/project-init/`, 리포 사본 없음; 비가역 원격 작업은 승인 게이트) |
| 글로벌 스킬 `multi-ai-discussion` | cmux 3-pane 셋업, codex/gemini 3인 교차 리뷰 프로토콜 (§6.8) |
| [Addy Osmani "Loop Engineering"](https://x.com/addyosmani/status/2064127981161959567) | §8.4·§10.4·held-out 판정의 외부 근거 (원문 발췌·댓글 클러스터: `.cmux/debates/loop-engineering-workflow/sources.md`) |
| `.cmux/debates/<토론명>/<토론명>.md`·`.html` | 3자 토론 결론 산출물 — 본 문서 개정 근거 (`workflow-tier-utility`, `loop-engineering-workflow`). 결과 파일만 git 추적, 전사·시그널은 무시 |

> 새 프로젝트에서는 위 경로를 생성하면서 시작한다. 없는 문서는 해당 단계 첫 진입 시 작성.

---

## 12. 변경 이력

- **2026-06-21 에이전트 중심 실행 패턴 명문화 (3인 교차 리뷰 R1 반영)**: 스킬 중심(메인 직접 실행 → self-approval 구멍) → 에이전트 중심 전환 표준을 §9에 신설 — `<x>-writer`(maker)·`<x>-write`(스킬)·`<x>-reviewer`(checker) 3노드 + Orchestrator 패턴. 원칙 11·12의 *구조적 강제*(새 원칙 아님). codex·agy·claude 3인 리뷰(R1 전원 FAIL) 반영: **격리≠탈상관** 명시(same-model 검수는 §4 held-out 아님 → 공개·비가역·고위험은 §6 교차모델 종결) · Orchestrator 자기 종결 선언 금지 + **하드 제약**(reviewer C+M≥1=자동 FAIL) · 리뷰 파일은 §4 캐노니컬 경로 재사용 · FAIL 루프를 §4 Round 상한에 배선 · 전환 경계 = (공개 AND 비가역) 또는 자동 T3 + §2 3축 전체 · 메커니즘은 파일럿(RFC)로 격리(검증 전 다운스트림 롤아웃 금지) · §10.2 측정 지표 추가 · 산출물 status 상태기계. project-init §8은 정본 §9를 가리키는 포인터로(SSoT). 다운스트림(글로벌 스킬·각 프로젝트)이 이 스펙에 맞춰 구현.
- **2026-06-13 project-init 개명 + 검토 반영**: 3자 토론(`.cmux/debates/project-setup-review/`) 결론 반영 — `docs/project-setup.md` → **`docs/project-init.md`** 개명(SETUP=빌드·실행 오해 회피, 1회성 init 성격), 초기화 가이드 본문 8절 정렬·§2 저장소 생성·§5 mkdir·§7 workflow §0 채우기 보강, `.cmux/` 추적 정책 명시. 본 문서 원칙 6·9·§2·§11 참조 경로 동반 수정.
- **2026-06-11 워크플로우 문서 이동**: `docs/workflow.{md,drawio,html}` → **`.claude/workflows/`** — 워크플로우 정의 문서를 Claude 설정 폴더 구조(project-setup.md §4)의 의도된 위치로 이동. 참조 경로 동반 수정.
- **2026-06-11 design 폴더 분리**: 디자인 산출물을 `artifacts/planning/design/` → **`artifacts/design/`**(최상위)로 분리 — 기획(2)·디자인(3) 단계 분리 및 Planner·Designer 역할 분리와 정합. §3·§11·project-setup.md 트리·drawio 동반 수정.
- **2026-06-11 역할 분리 (5→6)**: Architect를 **Planner(기획)·Designer(디자인)**로 분리 — 단계·산출물 책임이 명확해지고 maker-checker 쌍(planner↔us-reviewer, designer↔design-reviewer)이 1:1로 대응. §3 담당·§9 역할 표·배치 원칙·§11 동반 수정. workflow.drawio 레인 표기와 정합.
- **2026-06-11 7단계 확장 + 다이어그램 재작성**: 6단계 → **7단계** — "7. 완료(평가·개선·다음 작업 제안)" 신설 (원칙 13·§10.1과 연결, 작업 단위 마이크로 평가). §8.3 T1 단축 흐름·§9 Orchestrator 단계 동반 수정. `workflow.drawio`를 현행 7단계 기준 7 스윔레인(A~G, 노드 A-1 형식 넘버링, 역할 색상)으로 전면 재작성 — 구버전(SetBox 15단계)은 폐기.
- **2026-06-11 토론 합의 일괄 반영 (Tier 10건 + Loop 8건)**: 3자 교차 리뷰 결론(`workflow-tier-utility.md`, `loop-engineering-workflow.md`) 반영 — §2 판정 함수 정규화(위험 합계 0/1/2+) + T1 범위 제한(expectation 보정 → T2) + 재분류 규칙 신설 / §4 held-out 종결 판정(Tier 차등) / §5 T3 E2E 완화(Impact 근거 시 축소) / §6.1 skip 우선순위 + §6.6 Echo-back 옵션 + §6.7 raw C/M 병기 / §7 메타 행 각주 + rate limit 변동 요인 / **§8.4 자동 루프 등록 규칙 신설**(예산 cap·쓰기 금지·커넥터 이원화) / §9 DoD에 why·risk·rollback + Tier 기록 + todo spine 스키마 / §10.2 보강 + **§10.4 점검 자동화** / §0 AI 월 예산 행 / §11 근거 문서 링크.
- **2026-06-11 4대 운영 철학 명문화**: 원칙 11~13 추가 (agent·skill 지점 바인딩 / maker-checker 쌍 / 정량 평가 기반 진화). §9에 "agent·skill 배치 원칙" 신설, §10을 "정량 평가와 자기 점검"으로 확장 — 작업 완료 시 기록(10.1) → 월간 집계(10.2) → 개선/유지/폐기 결정(10.3) 구조화.
- **2026-06-11 ATDD 이중 루프**: 원칙 3을 TDD 단독 → **ATDD(외곽: AC→인수 테스트) + TDD(내부: 단위 RED-GREEN-REFACTOR) 이중 루프**로 변경. §5 "AC 충족" 게이트를 인수 테스트 pass로 객관화. 인수 테스트는 가장 빠른 레벨에서 작성(E2E와 분리). §3·§6 매트릭스·§9 역할 동반 수정.
- **2026-06-11 §11 경로 정합화**: 참고 문서 경로를 `project-setup.md` 폴더 구조(`artifacts/planning·progress·review·tests`)에 맞춤. SetBox 시절 경로(`artifacts/architecture·design·reviews`, `docs/todo.md`) 제거, cmux-guide.md → 글로벌 스킬 `multi-ai-discussion` 참조로 교체. 본문 참조(§1, §2, §3, §4, §6.7, §6.8, §9, §10) 동반 수정.
- **2026-06-11 템플릿화**: SetBox 전용 워크플로우 → 앱/웹 공용 범용 템플릿. §0 프로젝트 설정 신설, 도구·명령어·위험 도메인을 `{placeholder}`로 분리 (타입체크/테스트/린트/E2E/디자인 도구/커버리지/위험 도메인).
- **2026-05-08 R1~R5 (SetBox 원본)**: 3인 교차 리뷰(Claude+Codex+Gemini) 메타 토론으로 수렴. 15단계 풀 흐름 → 6단계 + Tier 라우팅, 발동 결정 트리(§6.1), 작성/수정 분리 매트릭스, 사용자 활성 시간 비용 함수, Fast-track 안전장치 도입.

> 본 문서 변경 = 자동 Tier 3 + 위험 도메인 (3인 리뷰 항상 필수). 다음 변경 시 동일 적용.
