---
title: PRD 심층 조사 — 클래식부터 AI 시대까지 (멀티소스 교차검증)
created: 2026-06-20
status: draft
source_tier: corroborated  # 다출처 교차검증 + 단일출처·오피니언 혼합 (항목별 표기)
tags: [prd, ai-prd, product-management, spec-driven-development, evals, methodology]
wiki-ingest:
  status: done
  note: "dakman-wiki: notes/ai-prd-methodology.md"
  at: 2026-06-21
  by: manual
sources:
  - dakman-wiki/notes/ai-prd-methodology.md (우리 기존 노트 · 요즘IT 기반 secondary)
  - github/spec-kit · Amazon Kiro · ChatPRD (도구 · primary/official)
  - Hamel Husain · Eugene Yan · Aakash Gupta · Pragmatic Engineer (eval 권위자 · 교차검증)
  - Marty Cagan(SVPG) · Lenny Rachitsky · Amazon PR-FAQ · Reforge (PM 정본 · 논쟁)
  - Anthropic Cat Wu · OpenAI Miqdad Jaffer 템플릿 (AI-PRD primary)
  - Reddit r/ProductManagement·r/vibecoding (실무자 여론 · opinion/anecdote)
---

# PRD 심층 조사 — 클래식부터 AI 시대까지

> 우리 LLM 위키 + GitHub·X·Reddit·YouTube·블로그를 멀티소스로 조사·교차검증한 결과.
> 검증 등급: ✅ **다출처 교차검증** · ⚠️ **단일/secondary·한 진영** · 💬 **오피니언/일화** · 🚫 **마케팅 과장(배제)**

---

## TL;DR — 핵심 결론

1. **PRD는 안 죽었다.** 진짜 논쟁은 "죽음 vs 생존"이 아니라 **헤비 vs 경량**이다 — *아무도 10~50쪽 워터폴 PRD를 옹호하지 않는다*. ✅
2. **핵심 통찰**: "문서(산출물)는 **사고의 잔여물**이다. 사고·정렬을 지키고 문서는 줄여라." (Reddit 최고 득표 프레임 + Cagan/Lenny 계보) ✅
3. **AI가 PRD를 둘로 쪼갠다**: ⓐ **인간용 = 더 경량**(정렬 도구) + ⓑ **에이전트용 = 더 엄격**(기계검증 가능한 스펙 + Eval). 두 커뮤니티가 *"사람에겐 가볍게, 에이전트에겐 엄밀하게"*로 수렴. ✅
4. **우리 요즘IT 노트('AI PRD = Eval 중심으로 허용 답변 범위 정의')는 다출처로 교차검증됨** — 단일 한국 출처의 특이 주장이 아니라 업계 패턴. ✅
5. **단, 정직하게**: "AI 때문에 PRD가 *더 중요해졌다*"는 **컨센서스가 아니라 한 진영(~30–35%, 가장 빠르게 성장)**. 다수(~50%)는 "더 *가벼워졌고*, 가치는 *늘* 사고/정렬이었다"고 본다. ⚠️ 날선 반론: *"엄밀함은 원래 필요했고, AI는 그 부재를 더 빨리 드러낼 뿐."* 💬

---

## 1. PRD란 + 왜 중요한가 (클래식)

**PRD(Product Requirements Document)** = "무엇을·왜 만드는가"를 정의해 팀을 정렬시키는 문서. 핵심 가치 3가지(15년+ 권위자 일치 ✅):

- **문제 우선(problem-first)** — Lenny: *"문제 정의(problem statement)가 모든 문제 해결의 가장 중요한 단 한 걸음."* Amazon "Working Backwards"는 고객 가치에서 거꾸로 설계.
- **정렬(alignment)** — 산출물 자체가 아니라 *팀이 같은 그림을 공유*하는 게 목적.
- **사고 강제(thinking-forcing)** — Shreyas Doshi: *"쓰는 행위가 사고를 강제한다"* — PRD의 진짜 값은 작성자 자신의 추론을 명료화하는 데 있다.

---

## 2. 캐노니컬 PRD 구조 (컨센서스)

Product School·Aha!·Reforge·Atlassian·ChatPRD 종합 — 채워 넣는 양식이 아니라 **사고 체크리스트**로 쓰라(Mind the Product). ✅

| 영역 | 섹션 |
|---|---|
| 맥락 | 개요·변경 이력(changelog)·작성자·상태 |
| 왜 | **문제 정의**(고객 페인·대상) |
| 목표 | 비즈니스 목표 + **측정 가능한 성공 지표** |
| 사용자 | 페르소나·유스케이스·시나리오 |
| 요구 | 사용자 스토리(As a…/I want…/so that…) · 기능 요구 |
| 검증 | **수용 기준**(Given-When-Then 증가 추세) |
| 품질 | 비기능 요구(성능·보안·접근성, ISO/IEC 25010) |
| 경계 | **스코프 & 비목표(non-goals)** — 명시적 "안 함" |
| 설계 | UX·고충실도 프로토타입 링크 |
| 운영 | 분석/텔레메트리·의존성·리스크·롤아웃 |
| 미정 | **열린 질문**(TBD 허용) |

> ChatPRD 10섹션(가장 많이 인용되는 클래식 템플릿): 개요/문제 → 목표·지표 → 유저스토리 → 기능요구("system shall…") → 비기능요구 → 디자인 → 기술고려 → 일정 → 열린질문·리스크 → 부록.

---

## 3. 큰 논쟁 — 헤비 vs 경량 (죽음 아님)

명명된 두 진영이 15년간 충돌. ✅ **수렴점 = 문제 우선·경량·리빙·프로토타입 짝**. 차이는 "글로 된 산출물이 얼마나 남는가".

| 진영 | 대표 | 입장 |
|---|---|---|
| **반(反)-헤비 PRD** | **Marty Cagan(SVPG)**·Amazon(PR-FAQ)·Basecamp(Shape Up)·Intercom | *"고충실도 프로토타입이 곧 스펙"* / "발견(discovery) > 문서화" / "남이 정의한 요구를 맹목 실행하지 않는다" |
| **구조화-경량-리빙독** | **Lenny**(1-pager)·**Reforge**("PRD는 명사 아닌 동사")·**Aakash Gupta** | 짧지만 살아있는 문서로 정렬. *"끝내거나 완벽할 걱정 말고, 시작하기에 충분한가만 봐라"* |

**실무자 여론 스펙트럼** (Reddit r/ProductManagement·r/vibecoding 실측, 💬 오피니언):

```
PRD 죽었다 ◄───────────────────────────────────► PRD 더 중요
"프로토타입 우선,     "경량+진화; 가치는        "스펙이 해법;
 그냥 바이브코딩"      문서 아닌 정렬"           에이전트가 그대로 실행
                                              + AI는 Eval 필요"
  ~15–20%                ~50% (중심)               ~30–35% (급성장)
 (인디/바이브코더)    (주류 PM, Cagan 계보)     (AI-PM·에이전트 빌더)
```

- 최고 득표 프레임: **"빠른 무문서 개발은 결국 큰 혼란을 부른다"(250▲)** — "PRD 죽었다" 과장에 대한 백래시. 동시에 *"PRD는 이제 더 중요. 차이는 LLM이 내 문서를 실제로 *읽는다*는 것"(85▲)*.
- **핵심 합의**: "산출물은 사고의 잔여물 — 사고를 지키고 문서를 줄여라." 헤비 PRD 실패는 대개 *발견(discovery) 실패*(엔지니어를 일찍 안 끼움)이지 PRD 무용의 증거가 아니다.

---

## 4. AI 시대의 전환 — PRD가 둘로 갈린다

### 4-A. AI **제품**용 PRD (확률적·비결정론적 출력)

전통 PRD는 *"입력 A → 항상 출력 B"*를 가정하지만, LLM은 *"사실은 맞아도 부적절"*할 수 있다. → **측정 가능한 품질 차원 + 허용 임계값**으로 전환. ✅(Ainna·Anthropic·요즘IT 일치)

- **Eval이 테스트케이스를 대체.** *"허용 답변 범위"* 예: *"사실 정확·구조화된 응답을 최소 92% 비율로 반환"* — 요즘IT의 "허용 답변 범위 + 판단 기준" 프레임과 정확히 일치.
- **이중 성공지표**: AI 지표(Eval 통과율·환각률·가드레일 발동률) + 전통 지표(인게이지먼트·리텐션·NPS).

### 4-B. **에이전트 입력**용 PRD (Spec-Driven Development)

PRD가 *정적 청사진*이 아니라 *코딩 에이전트가 실행하는 입력*이 된다. ✅(spec-kit·Kiro·Anthropic primary)

- **github/spec-kit** (114k★, GitHub 공식): `/constitution`(불가침 원칙·품질 게이트) → `/specify`(무엇·왜, 기술 금지) → `/plan`(어떻게) → `/tasks`(순서화·테스트 가능 단위) → `/implement`. **스펙 = 실행 가능한 아티팩트**.
- **Amazon Kiro**: 3파일 — `requirements.md`(**EARS 표기**: "WHEN [trigger] THE SYSTEM SHALL [response]") → `design.md`(아키텍처·시퀀스·스키마) → `tasks.md`(**모든 태스크가 요구사항에 역링크**, 테스트 포함). **requirement→task 추적성**.
- **Anthropic Cat Wu**(Claude Code 제품 총괄): *"스펙을 쓴 뒤 Claude Code에 보내 빌드되는지 봐라. 거친 프로토타입도 대화를 바꾼다."*
- **에이전트 가독 PRD**(Haberlah/OpenAI Miqdad Jaffer 템플릿): 기계검증 가능한 수용기준(정확도 임계·환각<X%·드리프트 모니터링), **"DO NOT CHANGE" 경계**, 원자적 번호 유저스토리, "Claude가 체크할 체크박스" 수용기준, "어떻게(표준)"는 짝 **CLAUDE.md**로 분리. Peter Yang: *"PRD = CLAUDE.md"*(에이전트의 영속 컨텍스트).

---

## 5. AI PRD 핵심 자산 — 8항목 + Eval 3단계 (교차검증·정련)

우리 노트의 자산이 **다출처로 검증**됐다. ✅ 정련 포인트 포함:

**AI PRD 8항목**: ① 기능 개요 ② 입출력 명세(언어 포함) ③ 시스템 프롬프트 초안(금지사항) ④ 품질 기준(합격선) ⑤ **실패 정의**(불허 시나리오) ⑥ 평가 계획(회귀테스트) ⑦ 모니터링 ⑧ 리스크·제한.

**Eval 평가 피라미드** — Husain·Gupta·Yan·Pragmatic Engineer·evidently.ai 독립 확인 ✅ (이게 가장 큰 검증 수확):

| 단계 | 내용 | 정련(외부 권위자) |
|---|---|---|
| 1. 규칙/코드 기반 | 단어·길이·기밀·구조·실행 자동 채점 | Husain은 아래에 **code-based**(정규식/구조/실행) 단계를 더 분리. **binary Pass/Fail > Likert** |
| 2. LLM-as-Judge | 다른 LLM이 적절성 판단(사람 100배속) | ⚠️ Eugene Yan: *"LLM-judge가 구원하지 않는다"* — **사람 라벨로 보정** 필수, judge 자체가 비결정·게임 가능. 100+ 라벨 데이터 있을 때만 |
| 3. 사람 평가 | 까다로운 케이스·회귀 기준점 | 선별 적용 |

> ⚠️ 우리 노트 사례(에어캐나다·Salesforce/Adobe)는 글 자체가 1차 검증원이 아님 — 일반에 알려진 일화이나 **verified 금지**(원 노트 표기 유지).

**추가 자산(외부에서 보강)**:
- **eval-driven dev** = 만들기 *전에* 성공기준(Eval)을 정의 → 8항목의 ④⑤⑥을 *최종 섹션이 아니라 전제조건*으로.
- **requirement→task 추적성**(Kiro) + **constitution/품질게이트 층**(spec-kit) = 우리 노트에 없던 결합 후보.

---

## 6. 도구 지형

✅ 무게중심은 클래식 "PRD 템플릿 repo"가 아니라 **spec-driven 도구**에 있다 (PRD 템플릿 repo는 대부분 저-star·파편화).

| 도구 | 신뢰 | 무엇 |
|---|---|---|
| **github/spec-kit** | ✅ 114k★·GitHub 공식 | SDD 정본 (constitution→specify→plan→tasks) |
| **Amazon Kiro** | ✅ AWS 공식 | 에이전틱 IDE, EARS·요구역링크 3파일 스펙 |
| **ChatPRD** (Claire Vo) | 상용·업계 존중 | AI가 PRD 초안→사람 정제, 10섹션 템플릿 |
| snarktank/ai-dev-tasks | 7.8k★ 커뮤니티 | create-prd→generate-tasks→process(승인 체크포인트) |
| johnnychauvet/prd-skill | 소·신규 | Claude Code `/prd`(JTBD+수용기준) |
| ~~priankr/prd-templates~~ | 🚫 ~3★·준-방치, "리딩 PM 출처" 미검증 | 약한 출처 — 의존 금지 |

---

## 7. 실무자가 실제로 하는 것 💬

(r/ProductManagement "2026년 PRD 작성법" 100+ 답변을 OP가 AI로 요약, + 실측 스레드)

- **엔지니어와 협업 > 문서** (가장 강한 테마): 스펙을 벽 너머로 던지지 말고 일찍 대화.
- **간결함 승**: 1-pager·짧은 문제정의·Jira/Linear 불릿. *"아무도 10쪽 PRD 안 읽는다."*
- **AI는 주로 리서치+초안**: 인터뷰 요약·경쟁분석·초안. (작성자 대체 아님)
- 실전 경량 포맷: **one-pager**(문제·비목표·성공지표·가드레일)·PR-FAQ·제품 컨셉(1–3쪽)·결정 로그.
- 실전 AI 습관: **음성메모→Claude Code→2~3회 반복**("CC를 주니어 PM처럼") · **적대적 다모델 리뷰**(PRD를 Claude→ChatGPT→Gemini로 코딩 전 검토) · **에이전트-컨텍스트 분리**(사람용 1-pager + 에이전트용 `.md` — "에이전트가 제약을 슬쩍 버리고 '해결'하니까").
- 엔지니어 관찰: *"빌드 중 실제 참조하는 건 수용기준과 엣지케이스 목록뿐. 배경 섹션은 아무도 안 읽는다."*

---

## 8. 모범사례 & 안티패턴

| ✅ 모범 | 🚫 안티패턴 |
|---|---|
| 문제 우선, 해법 나중 | 문제 검증 전 해법으로 점프 |
| PRD=동사/리빙독("시작에 충분한가") | 한 번 쓰고 얼린 워터폴 PRD |
| 고충실도 프로토타입과 짝 | 긴 산문이 발견/검증을 대체(Cagan 경고) |
| 테스트 가능 수용기준(G-W-T); AI는 Eval 임계 | 모호 기준("빠른"·"직관적") |
| 협업·회람·우선순위(RICE)·비목표 명시 | **LLM 생성 bloat**(Aakash: 길수록 좋은 거 아님) |
| (AI) 확률 시스템에 맞는 Eval·이중지표 | 확률 시스템에 결정론적 pass/fail / 한쪽 지표만 |

---

## 9. dakman 적용 (제안)

우리 워크플로우(SDD: 제안요청서→제안서→**PRD**→TASK / project-init / `artifacts/planning/`)와 직접 맞물린다.

- **AI 기능 스펙 템플릿화** ✅: 8항목 + Eval Plan을 `artifacts/planning/`의 *기능·품질 축* 템플릿으로 — 기존 ERD/데이터흐름 스펙(*데이터 축*)의 짝. (우리 노트 시사점 유지)
- **Eval 피라미드 ↔ 우리 검증 규율**: 규칙→LLM-judge→사람 순서가 [[llm-false-consensus-discipline]]의 **"비-LLM 오라클 정박 → judge는 사람 라벨로 보정"**과 동형. *Yan의 "judge가 구원 아니다"를 우리 §3에 명시 반영.*
- **spec-driven 결합 후보**: spec-kit의 **constitution(품질 게이트)** ↔ 우리 `workflow.md` 원칙 / Kiro의 **requirement→task 추적성** ↔ 우리 US→AC→task. project-init §5와 정합.
- **두 갈래 PRD 채택**: *사람용 경량 1-pager*(정렬) + *에이전트용 엄격 스펙*(기계검증 수용기준·"DO NOT CHANGE"·CLAUDE.md 짝) — 실무자·도구 양쪽이 수렴한 패턴.
- **균형 경계** ⚠️: "AI라서 PRD가 더 중요"를 교조화하지 말 것. 다수 여론은 "사람에겐 더 가볍게". 우리 강점인 **Tier(위험 기반 강도 조절)**로 — 고위험 AI 기능엔 8항목+Eval 풀, 저위험엔 경량 — *"엄밀함은 위험에 비례."*

---

## 10. 검증 상태 & 출처

| 등급 | 항목 |
|---|---|
| ✅ **다출처 교차검증** | Eval 3단계 피라미드 · deterministic→probabilistic 전환 · 헤비vs경량 논쟁 · 캐노니컬 구조 · spec-driven dev(spec-kit/Kiro) · "스펙을 에이전트에 보내라"(Anthropic) |
| ⚠️ **단일/secondary·한 진영** | "AI라서 PRD가 *더 중요*"(한 진영 ~30–35%) · 요즘IT 사례(에어캐나다·Salesforce/Adobe = 일화, 1차 검증원 아님) · AI-PRD *섹션별 템플릿*은 아직 통합 중(emerging) |
| 💬 **오피니언/일화** | Reddit/X 여론·스펙트럼 % (정성 추정, 측정 분포 아님) · 실무자 워크플로우 |
| 🚫 **마케팅 과장(배제)** | "PRD 50% 빨리"·"AI 도구 5종 비교 승자" 리스티클·프롬프트팩 |

**주요 출처**: github/spec-kit · Amazon Kiro(kiro.dev) · ChatPRD · Hamel Husain(hamel.dev) · Eugene Yan · Aakash Gupta(news.aakashg.com) · Marty Cagan(svpg.com) · Lenny Rachitsky · Amazon Working Backwards · Reforge · Anthropic Cat Wu(claude.com/blog) · OpenAI Miqdad Jaffer 템플릿(productcompass.pm) · Reddit r/ProductManagement·r/vibecoding.

> **접근 한계**: SVPG·Lenny·Aakash 원문 다수가 403/페이월 → 색인 요약+다중 secondary로 재구성(인용 verbatim 재현 시 원문 대조 필요). Reddit은 playwright 실브라우저로 verbatim·득표수 직접 추출. X/Twitter는 402 차단 — 검색 스니펫+뉴스레터 기반(2차).
