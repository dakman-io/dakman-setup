---
title: "/explain-diff 글로벌 스킬 스펙 (→ dakman-claude-config 구현 위임)"
date: 2026-07-03
owner: dakman-setup (도메인=workflow.md) · 구현=dakman-claude-config (글로벌 ~/.claude)
status: 스펙 확정 — 구현 위임 (2026-06-28 스킬·에이전트 생성·수정 절차)
domain_source: dakman-brain 확정 판단 (충돌 시 이 스펙 우선) + Geoffrey Litt
---

# /explain-diff — 이해 Explainer 스킬 스펙

> **핸드오프**: 이 스펙은 도메인 요구다. 글로벌 스킬(`~/.claude/skills/explain-diff/`) 구현·검증·git은 **dakman-claude-config 소유**. dakman-setup은 workflow.md §5·§9 발동지점(정본)을 이미 반영·머지했다.

## 배경 (왜)
병목이 "코드 작성"→**"인간의 이해"**로 이동(Geoffrey Litt, *Understanding is the new bottleneck*, 2026-07-02). AI가 코드를 잘 쓰고 self-verify까지 하니, 인간의 몫 = **참여·판단**이고 이해 없이 넘어가면 **인지 부채**가 쌓인다. 우리 워크플로우의 1차 비용함수(**사용자 활성 검토 시간**)를 직접 낮추면서 이해는 높이는 도구가 없었음 — 이 스킬이 그 갭을 메운다.
- 근거: dakman-wiki `wiki/understanding-is-the-bottleneck.md` (**미검증** — 2차 요약 경유) · 원문 `geoffreylitt.com/2026/07/02/understanding-is-the-new-bottleneck.html`. Litt = 신뢰 높은 1차 저자, `/explain-diff`는 그의 실사용 커스텀 스킬.

## 기능 (①)
`git diff`(스테이지/브랜치/PR)를 입력받아 **구조화된 Explainer**를 생성하고, **PR 본문에 포함**한다(사람 게이트 검토 대상). 순수 설명/문서 스킬 — 발행·비가역 산출 아님 → **메인/Orchestrator가 직접 실행하는 순수 스킬**(에이전트 중심 3노드 대상 아님, workflow.md §9 경계).

## 출력 3원칙 (② — 정본, 브레인 확정)
1. **배경 먼저** — 이 변경이 왜 필요한지·어떤 맥락인지 먼저.
2. **직관 먼저·세부 나중** — 큰 그림/핵심 아이디어 먼저, 세부 코드는 뒤.
3. **diff가 아니라 산문** — 논리 순서의 산문 + **핵심 코드 스니펫만 인용**(전체 diff 재나열 금지).

## Tier 연동 (③ — Lean Default + Escalation 정합)
- **T3**: 필수 — 풀 Explainer(배경·직관·산문·스니펫·영향/리스크).
- **T2**: 요약형 — 핵심 변경 1~2문단.
- **T1**: 생략.

## 인터랙티브 아티팩트 (④ — 옵션 관행, 신규 스킬 아님)
T3·위험 도메인에서 이해를 돕는 아티팩트를 Explainer에 첨부할 수 있다 — **기존 스킬 활용**(`erd-viewer`로 스키마 변경 시각화 · `md2html`로 Explainer HTML화 등). 스킬 신설 아님, `/explain-diff`가 이들을 강제 호출하지도 않음(관행 권장).

## 경계 (⑤ — self-approval 금지 정합)
Explainer는 **판정 *자료*지 판정이 아니다**. maker가 자기 diff를 설명해도 **self-approval이 아니다**(workflow.md §4 held-out). 판정은 **held-out 리뷰어·rtong(사용자)**. 스킬 출력에 "이건 검토 보조 자료이며 승인이 아님"을 명확히.

## 제외 (⑥)
**퀴즈 게이트 이번 스펙 제외**(보류). Litt의 "퀴즈 통과 못하면 코드 안 보냄" speed bump는 정착 후 **T3·위험 도메인 on-demand**로 재검토 — 이번 구현에 넣지 않는다.

## 인터페이스 (구현 참고 — 세부는 claude-config 재량)
- 발동: 사용자 `/explain-diff [범위]` 또는 형상관리(§6) PR 생성 시 Orchestrator가 Tier에 따라 호출.
- 입력: diff(기본=현재 브랜치 vs develop, 또는 스테이지/지정 범위).
- 출력: PR 본문에 붙일 **마크다운 Explainer**(위 3원칙·Tier 크기). T3는 옵션으로 아티팩트 경로 첨부.
- git-ops와 정합: PR 본문 조립 시 Explainer 필드를 넣는다(workflow.md §9 DoD).

## 폴백·한계 (held-out 리뷰 반영)
- **large diff 폴백**: diff가 컨텍스트/프롬프트 한계를 넘으면 전체 대신 **파일 단위 요약 또는 핵심 모듈별 분할**로 처리(실패 아닌 graceful degrade). 임계 초과 시 그 사실을 Explainer 상단에 명기.
- **산출 주체**: **Orchestrator/Ops**가 호출(형상관리 §6). maker가 자기 diff를 *설명 대상*으로 삼을 뿐 실행자는 무관 — 어느 쪽이든 §4 self-approval 위반 아님.
- **산출 위치**: 로컬 `artifacts/progress/explain-<scope>.md`(인터랙티브 아티팩트도 여기; `artifacts/review/`는 §4 리뷰 이슈 파일 전용이라 회피) → 형상관리에서 PR 본문에 포함. workflow.md §5 note와 정합.
- **앵커링 가드(중요)**: 스킬 출력에 "**held-out 리뷰어는 이 Explainer가 아니라 source/diff를 1차 검토**한다(리뷰 입력을 Explainer로 대체 금지)"를 명기 — Explainer는 *사용자* 이해용.

## 검증 기준 (구현 완료 판정)
- 실제 diff 1건에 대해 3원칙(배경→직관→산문+스니펫) 형태의 Explainer 산출.
- Tier별 크기 차등(T3 풀 / T2 요약 / T1 생략) 동작.
- 출력에 "판정 자료지 승인 아님" 경계 문구 포함.
- workflow.md §5·§9 발동지점과 정합(PR 본문 포함 가능).

## 소유·정합
- **도메인·발동지점(정본)** = dakman-setup workflow.md §5·§9 (머지 완료).
- **스킬 구현·git** = dakman-claude-config (`~/.claude/skills/explain-diff/`).
- 충돌 시 **이 스펙(도메인) 우선** — 단 구현 품질(형식·컨벤션·도구권한)은 claude-config 검증.
