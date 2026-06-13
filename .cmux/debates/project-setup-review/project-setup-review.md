# project-setup.md 검토 + 초기화 스킬 설계 (3자 토론 결론 · 정본)

> **토론**: Claude(진행자·참여) × Codex(내적 정합성·실행 가능성 렌즈) × Gemini(외부 접지·UX·명명 관행 렌즈) · R1~R4 · Light 모드
> **검토 대상**: `docs/project-setup.md`(→ `project-init.md` 개명) + **궁극 목표: 프로젝트 초기화 스킬 제작**
> **일시**: 2026-06-13 · **원본 전사**: `.cmux/debates/project-setup-review/board.md`
> **구성**: R1~R2 = 문서 목적·파일명 (반영 완료) / R3~R4 = 초기화 스킬 설계

---

## 핵심 결론 (3/3 만장일치, confidence 0.80~0.90)

| 질문 | claude | codex | gemini | 최종 |
|------|:------:|:-----:|:------:|:----:|
| **Q1. 목적 적합성** | 수정필요 | 수정필요 | 부적합→수정필요 | **수정필요 (강)** |
| **Q2. 파일명** | 유지(조건부) | init-checklist→**init** | SETUP→**init** | **`project-init.md`로 변경** |

**Q1**: 문서의 골격(8단계 셋업 흐름)은 건전하고 git-commit 스킬·workflow.md로 **명시적 위임**하는 구조라 "부적합"은 아니다. 그러나 따라 해도 셋업이 완결되지 않는 실행 구멍(§2·§7)과 자기모순(§10, `.cmux` 정책)이 있어 **수정이 필요**하다.

**Q2**: `project-setup.md`는 ① "project" 중복, ② `SETUP`이 통상 "빌드·실행(deps/run)"을 함의하는데 이 저장소는 **실행할 앱이 없는 템플릿 메타 저장소**라 오해 유발. → **`project-init.md`** (1회성 초기화 성격 + workflow.md와 "시작 vs 운영" 대칭).

---

## 합의된 수정 패키지 (7건)

| # | 수정 | 근거 | 합의 |
|---|------|------|:----:|
| F1 | **`.cmux/` 추적 정책 충돌 해소 (최우선)** | project-setup §4 예시는 `.cmux/` 전체 ignore(125행), workflow §11은 `.cmux/debates/…md·html` 추적(448행) — **직접 모순**. 현재 토론 결과 파일이 실제 추적 중이라 예시 복붙 시 무시됨. `.cmux/` 뒤에 `!.cmux/debates/**/*.md`·`*.html` 예외 추가(또는 정책 통일) | 3/3 |
| F2 | **파일명 `project-setup.md` → `project-init.md`** + workflow §11·도입부 참조 갱신 | "project 중복" + SETUP 오해 회피 | 3/3 |
| F3 | **§2에 저장소 생성/클론 명령 추가** | `gh repo create`/`git clone`/초기 커밋 전제 없이 §3.1 `git branch develop` 실행 시 HEAD 없어 막힘 | 3/3 |
| F4 | **§7에 워크플로우 문서 복사 원본 + workflow §0 placeholder 작성 + md/drawio/html 동기화 확인** 추가 | "생성"만 있고 원본 위치·§0(`{프로젝트명}`~`{AI예산}`) 작성 연결 부재 → 파일 생성에 그쳐 운영 준비 미완 | 3/3 |
| F5 | **§5에 `mkdir -p` 명령 + 빈 디렉터리 보존 정책** 추가 | 폴더 트리만 있고 생성 명령 없어 "폴더 구조 생성" 체크 불가 | codex·gemini |
| F6 | **본문을 체크리스트 8개에 1:1 정렬** — §8(skill)·§9(agent)를 체크 8번 아래 하나로 묶고, **§10은 §7 하위 "workflow §0 + 핵심 원칙 확인"으로 축약** | 체크 8 vs 본문 10 불일치, §10은 체크리스트에 없는 "유령 섹션"이자 workflow.md 원칙 1·3·8과 중복 | 3/3 |
| F7 | **진입점 확보** — 루트 `README.md`·`CLAUDE.md` 최상단에 "신규 프로젝트는 `docs/project-init.md`부터" 인바운드 링크 | 현재 루트에 README·CLAUDE.md 실재하지 않아 문서 발견성 0 | gemini (codex·claude 무이견) |

> §8·§9 처리 주의: **삭제가 아니라 "구성 게이트"로 유지**(만들 대상 있으면 만들고 없으면 N/A로 닫음). §10도 통째 삭제하면 §7이 빈 껍데기가 되므로 **축약**(정본은 workflow.md).

---

## 검증 원장

| 주장 | 판정 | 근거 |
|------|:----:|------|
| `.cmux/` 전체 ignore vs workflow §11 결과 파일 추적 = 직접 충돌 | ✅ 확정 | grep: project-setup.md:125 `.cmux/` · workflow.md:448 `.cmux/debates/…추적`. 현 추적 파일 존재 |
| §2에 repo 생성/clone 명령 없음 | ✅ 확정 | §2 (29-31행) 산문만 |
| §7 복사 원본·§0 작성 연결 부재 | ✅ 확정 | §7(188-196) vs workflow.md:10-29 |
| 체크리스트 8 vs 본문 10 불일치 (§10 유령 섹션) | ✅ 확정 | 체크 7-16행 vs 본문 §1~§10 |
| README/CLAUDE.md 진입점 부재 | ✅ 확정 | 루트에 두 파일 실재하지 않음 |
| gemini: "예시 하드코딩 오염 위험 크다" | ⚠️ 교정 | 5·37·60·63행 전부 "예시" 명시 라벨 + 명령은 `<owner>/<repo>`. "오염 위험 크다"는 과장 — gemini 수용 |
| gemini R1: Q1 "부적합" | ⚠️ 교정 | 골격 건전 + 명시적 위임(도입부 4행) → "수정필요"로 하향, gemini 수용 |
| 파일명 `SETUP.md` (gemini R1) | ❌ 기각 | 템플릿 메타 저장소엔 SETUP=빌드·실행 오해. gemini 수용 → `project-init.md` |

---

## 잔여 이견·한계 (보존)

1. **F7 진입점의 형태** — README/CLAUDE.md "강제 인바운드 링크"(gemini)에 codex·claude 명시적 반대는 없으나 적극 논의도 없었음(약한 합의). 실제 README 작성 시 문구 확정 필요.
2. **외부 명명 관행 인용**(`GETTING_STARTED.md`·`CONTRIBUTING.md` 표준 운운)은 [미검증] — 출처 없는 일반론. `project-init.md` 결정은 이 일반론이 아니라 "이 저장소 = 실행 앱 없는 템플릿"이라는 내부 사실에 근거함.
3. 세 참여자 모두 LLM — 파일 grep으로 정박 가능한 항목(F1·F3·F4·F6·진입점)은 오라클 확정. 파일명·UX 판단(F2·F7)은 오라클 없는 소프트 결론.

---

## R3~R4 결론 — 프로젝트 초기화 스킬 설계 (3/3 수렴)

**궁극 목표**: `project-init.md`는 최종물이 아니라 **프로젝트 초기화 스킬의 원료**다.

| 질문 | 결론 | 합의 |
|------|------|:----:|
| **A. 스킬↔문서 분담** | **분리** — `docs/project-init.md`는 참조 문서(왜·전체 그림), 스킬은 `.claude/skills/project-init/SKILL.md`(린 플레이북) + `references/`(→문서) + **선별 scripts 1개** | 3/3 |
| **B. 자동화 경계** | **Dry-run 일괄 승인** — 값 선수집 → "실행 계획 요약"(로컬 + ⚠️비가역 원격 분리) → 1회 승인 → 실행. per-step 결재 아님 | 3/3 (분리 강도만 이견) |
| **C. 스킬 이름** | **`project-init`** (문서·workflow 참조와 동명) | 3/3 |
| **D. 스킬화 적기** | **지금 제작** — 의도 안정 충족, 스킬 제작을 self-bootstrapping 첫 실습으로. 단 비가역 자동화는 첫 실행서 walk-forward 검증 | 3/3 |

### 스킬 설계 명세 (합의)

```
.claude/skills/project-init/
├── SKILL.md           # 린 플레이북 8단계, 행동 규칙 MAY/ASK/STOP
├── references/        # → docs/project-init.md (왜·상세)
└── scripts/
    └── protect-branches.sh <owner> <repo>   # 보호 설정만 (고-환각위험 결정적 블록)
```

- **8단계 자동화 3등급** (SKILL.md 행동 규칙으로 표현 — 스킬은 결정적 실행기가 아니라 LLM 지시문):
  - `MAY 로컬 실행`: §4 .gitignore, §5 mkdir, §7 workflow 문서 복사 (가역)
  - `ASK 값 수집`: §1 페르소나 확인, repo명, owner/repo, workflow §0 placeholder({위험도메인} 등)
  - `STOP 명시 승인`: §2 gh repo create, §3.3 보호 PUT, §3.4 main 삭제, 원격 push (**비가역 원격**)
- **발동**: description "새 프로젝트 저장소를 초기화할 때" → 사용자가 "새 프로젝트 시작" 시 auto-trigger 제안.
- **근거 정합**: workflow.md 원칙 5(검수 후 커밋)·§8.4(자동 루프 커밋·publish 금지)와 일치 — 비가역 원격 작업은 사람 승인 게이트.

### R3~R4 검증 원장 (추가)

| 주장 | 판정 | 근거 |
|------|:----:|------|
| 스킬은 결정적 실행기가 아니라 LLM이 읽는 지시문 → 자동화는 MAY/ASK/STOP 행동 규칙으로 | ✅ 확정 | 스킬 표준(SKILL.md = 자연어 플레이북). codex 제기, 3/3 |
| 보호 설정 `gh api PUT` JSON은 환각 위험 → scripts로 캡슐화 | ✅ 채택 | project-init.md §3.3 복잡 JSON. gemini 제기 |
| "create-next-app/yeoman은 비가역 작업 자동 실행 안 함" 유추 | ⚠️ 부분 부적합 | 그 도구들은 **로컬 스캐폴딩**(폴더 삭제로 가역), 원격 repo 미생성. 우리 §2·§3.4는 비가역 원격 — 범주 다름 [도구 동작 자체는 미검증] |
| per-step 승인 = "예/아니오 지옥" | ✅ 채택 | gemini UX 지적, claude 철회 |

### 잔여 이견 (R3~R4, 보존)

1. **scripts 범위** — 1개(보호만, claude·codex) vs 전면 필수(gemini). 첫 실제 프로젝트 적용에서 어느 블록이 반복 환각을 내는지로 판가름 (walk-forward).
2. **일괄 승인의 비가역 분리 강도** — 완전 일괄(gemini) vs 비가역 항목 명시 플래그(claude·codex). 실제 SKILL.md 작성 시 요약 포맷으로 확정.

---

## 다음 단계

- **R1~R2 (반영 완료)**: project-init.md 개명·8절·F1~F7 — 코드 반영됨.
- **R3~R4 (미착수)**: `.claude/skills/project-init/` 스킬 골격 제작 — SKILL.md(8단계 MAY/ASK/STOP) + references(→project-init.md) + scripts/protect-branches.sh. 메타 변경 = 자동 Tier 3, 본 토론이 교차 리뷰. 비가역 자동화는 첫 실프로젝트 walk-forward 검증.
