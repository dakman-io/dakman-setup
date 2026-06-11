# Loop Engineering × 우리 워크플로우 — 3자 토론 결론 (정본)

> **토론**: Claude(진행자·참여) × Codex(내적 정합성·운영 가능성 렌즈) × Gemini(외부 접지·비용 현실성 렌즈) · R1~R2
> **출처**: Addy Osmani "Loop Engineering" 아티클 전문 + 댓글 286개 중 상위 클러스터 + lucas 한국어 포스트 + 댓글 — playwright MCP로 직접 수집 (`.cmux/debates/loop-engineering-workflow/sources.md`)
> **일시**: 2026-06-11 · **원본 전사**: `.cmux/debates/loop-engineering-workflow/board.md`
> **출처 링크**: [Addy 아티클](https://x.com/addyosmani/status/2064127981161959567) · [lucas 포스트](https://x.com/lucas_flatwhite/status/2064210932654649639)

---

## 핵심 결론 (3/3 만장일치, confidence 0.85~0.90)

**Loop Engineering의 6요소를 "도입"할 필요는 없다 — 절반은 우리 워크플로우에 이미 구조적으로 있고, 나머지는 1인 개발·토큰 비용 제약에 맞게 "선별 채택 + 가드레일"이 결론이다.**

| 요소 | 우리 현황 | 최종 판정 |
|------|----------|----------|
| **Sub-agents** (maker≠checker) | 부분 존재 — 원칙 7(리뷰-수정 분리), agent 생성 원칙. **단 종결 판정은 작성 참여자(Orchestrator)에 남아 있음** | **수정채택** — Tier 차등 held-out 판정 (T3·위험 도메인 필수 / T2 선택 / T1 self) |
| **Skills** | 구조 존재, project-setup "skill 생성" 섹션은 비어 있음 | **수정채택** — intent debt 기반 생성 트리거 ("2회 반복 + 의도 안정 시 스킬화") |
| **Memory** | 부분 존재 — artifacts/, todo.md | **수정채택** — todo.md를 "루프의 spine"으로 확장 (1줄 상태 스키마 + 증거 링크) |
| **Automations** | 부재 — §10 점검이 수동 | **수정채택** — 점검류 한정 자동화 + 예산 cap |
| **Connectors** | 부분 존재 — MCP·gh 사용 중, 규정 없음 | **수정채택** — 읽기 자유 / 쓰기는 **Draft PR까지**, publish는 사용자 게이트 |
| **Worktrees** | 부재 | **보류** — 재론 조건: "병렬 구현 sub-agent 도입 시" |

**토론의 재료가 된 핵심 긴장**: 아티클 본문은 비전을 팔고, 댓글은 **토큰 비용 / 품질(슬롭·회귀) / 'done' 정의**라는 3대 현실 제약으로 반박 — Addy 본인이 답글에서 "(1) token costs (2) verification against what 'good' means"를 핵심 미해결로 인정. 이 구도가 그대로 결론의 가드레일이 됐다.

---

## 합의된 반영 패키지 (9건)

| # | 제안 | 반영 위치 | 내용 |
|---|------|----------|------|
| L1 | **점검 자동화 (한정)** | workflow.md §10 | 월간 자기 점검을 cron//loop로 자동화. **점검류만** — 광역 버그 헌팅 금지. 루프마다 주기·예산 cap·산출물 위치(`artifacts/progress/loop-triage.md`)·빈 결과 자동 종료 명시 |
| L2 | **held-out 종결 판정 (Tier 차등)** | workflow.md §4 | 리뷰 루프 종결("C+M 0건") 판정: **T3·위험 도메인 = 작성에 참여하지 않은 노드 필수**, T2 = 선택, T1 = self. "코드를 쓴 에이전트가 자기 완료를 선언하지 않는다" |
| L3 | **Memory spine** | workflow.md §9 DoD + §11 | `artifacts/progress/todo.md` 확장 — 항목별 1줄: `status(open/tried/passed/blocked) · 다음 행동 · 검증 증거 링크 · 되돌릴 커밋`. 상세 증거는 artifacts/review·tests 링크로 (todo 오염 방지). 세션 재개 시 첫 Read 대상 |
| L4 | **Skills 생성 트리거** | project-setup.md "## skill 생성" | "같은 맥락 설명을 **2회 이상 반복 + 의도가 안정**되면 스킬화. CLAUDE.md가 비대해져 오류가 늘면 분할." (근거: intent debt — 스킬 없으면 루프가 매 사이클 프로젝트를 재유도) |
| L5 | **Comprehension Debt 가드** | workflow.md §9 DoD | PR/summary 필수 필드 **`why / risk / rollback`** + 사용자 확인. 위험 도메인 한정 옵션: Echo-back(에이전트 설명 → 사용자 요약 응답) §6.6에 1줄 |
| L6 | **참고 문서** | workflow.md §11 | Addy 아티클 + 본 토론 산출물 링크 추가 |
| L7 | **Loop Budget & Permission Guard** | workflow.md 신규 항목(§8 또는 §10) + §0 | 자동 루프 등록 시 기록: `목적 / 주기 / 예산 cap / 허용 도구 / 쓰기 권한 / 종료 조건 / 산출물 위치`. **자동 루프는 커밋·머지·PR publish 금지** (원칙 5 유지). §0 표에 "AI 월 예산" 행(선택). ★gemini 최종 추가: **cap 미지정 시 보수적 기본값 적용**(fail-safe, 예: 최대 3회 실행) + **루프 종료 시 사용 토큰/비용 1줄 기록** |
| L8 | **Connectors 이원화** | workflow.md §0 + 원칙 | 읽기·증거 수집 MCP/CLI는 자유. 쓰기 행위(PR 생성 등)는 **Draft까지** — publish 버튼이 품질 게이트 |
| L9 | **Worktrees 보류 기록** | (반영 없음) | 1인 환경에서 병렬 격리는 효용보다 인지 파편화 비용이 큼 ("YOU are still the ceiling" — Addy 본인). 병렬 구현 sub-agent 도입 시 재론 |

> ⚠️ 투명성 기재: L7의 ★ 2건은 gemini의 최종 라운드 추가로, 기합의된 L7 범위 내 가드여서 진행자가 수용했고 codex 재확인은 생략함.

---

## 3대 잔여 문제 — 우리 워크플로우 대응 진단

| 문제 | 진단 | 대응 |
|------|------|------|
| **Verification** ("done is a claim, not a proof") | **가장 강함** — 검수 후 커밋(원칙 5), §5 게이트, ATDD 인수 테스트. 단 unattended 루프엔 불충분 | L2(held-out 판정) + L7(자동 루프 커밋 금지) |
| **Comprehension Debt** | **최대 공백** — 문서에 직접 장치 없음. 실전 사용자 증언(댓글 Seunghyeon: "종료 조건이랑 되돌릴 기록에서 브레이크 걸게 된다")과 일치 | L5(why/risk/rollback 필수 필드) + L3(되돌릴 커밋 기록) |
| **Cognitive Surrender** | 부분 대응 — §6.6 "summary만 검토" 흐름이 오히려 취약점 | Tier 패키지 5번(summary-raw C/M 대조)과 L5로 보강 |

---

## 검증 원장

| 주장 | 판정 | 근거 |
|------|:----:|------|
| 아티클 5요소가 Claude Code에 모두 존재 | ⚠️ 부분 확인 | /loop·cron·hooks·worktree isolation·agents·skills·MCP = 이 세션 실환경에서 확인. **/goal은 이 환경 스킬 목록에 없음** [부분 미검증 — 버전/플랜 차이 가능] |
| claude R1 "Sub-agents 이미 있음" | ⚠️ 교정 | 종결 판정·summary 책임이 작성 참여자(Orchestrator)에 남음 (workflow.md:122, 232-244) — codex 적발, claude 수용 |
| 댓글 3대 제약(비용/품질/done 정의) | ✅ 확정 | Addy 본인 답글: "(1) token costs and (2) verification against what 'good' means are important factors" (sources.md) |
| "토큰 비용이 루프의 최대 진입장벽" | ✅ 확정 | 댓글 4건+ (Luciano·greenido·Andrei·Hashim) + Addy 인정 |
| 루프 실사용 사례 존재 | ✅ 확정 | 댓글 Maku Mazakpe — /loop 기반 커밋 감시 리뷰 루프 원문 |
| gemini "CLAUDE.md 10KB 초과 시 분할" | ❌ 미검증 | 수치 출처 없음 (자가 라벨) — 정성 기준만 채택 |
| gemini "Chaos Test" (의도적 결함 주입) | ❌ 기각 | [미검증] + 1인 환경 과잉 — 3/3 동의 |
| gemini "Complexity Delta" (슬롭 지표) | ❌ 미검증·잔여 기록 | 수식·임계값 없음. §10 점검 시 참고 팁 후보로만 보존 |

---

## 잔여 이견·한계 (보존)

1. **L7 ★ 2건의 codex 미확인** — 기합의 범위 내 추가라 진행자가 수용했으나, 반영 시 codex 관점(운영 가능성 체크) 재검 권장.
2. **Complexity Delta** — 슬롭 감지 지표로서의 가치는 3자 모두 인정하나 측정 방법이 없어 잔여 기록. 향후 §10 점검에서 "수정 대비 코드량 비대" 정성 체크로 실험 가능.
3. **/goal 기능** — 아티클의 핵심 사례인데 이 환경에서 미확인. L2(held-out 판정)는 /goal 의존이 아니라 우리 3인 리뷰 구조로 구현하므로 결론에는 영향 없음.
4. **walk-forward 체크**: 반영 후 처음 등록되는 자동 루프 3개에서 L7 기록(예산 cap·산출물·종료 조건)이 실제로 채워지는지 §10 첫 점검에서 확인 (소유자: 사용자).
5. 세 참여자 모두 LLM — 아티클·댓글·우리 문서 원문 인용으로 정박했으나, "패키지가 실제로 비용 폭주를 막는가"는 운영해 봐야 안다.

---

## 토론 경과

- **R1**: claude "3개는 이미 있음, 선별 채택"(0.75) → codex "'이미 있음' 과대평가 — 종결 판정이 작성자에 남음" + P7(Budget & Permission Guard) 신규 제안(0.82) → gemini "중앙집권형 프롬프트 엔지니어링에 머물러 있다" — Worktrees 강기각, 비용 가드레일 전면화, loop-state.json·Echo-back 제안(0.85)
- **R2**: claude 중재안 v2(Tier 차등 held-out, todo 확장, Draft 게이트)(0.85) → codex 전반 찬성 + P3 조건(1줄 spine + 증거 링크)(0.87) → gemini 전면 수용 + fail-safe 예산·사용량 기록 추가(0.90) → **수렴 종료**
- 직전 Tier 토론과의 정합: L2는 Tier 수정 패키지 5·6번(summary-raw 대조)과, L7은 9번(rate limit)과 연결 — 충돌 없음.

## 다음 단계 (제안)

Tier 수정 패키지 10건 + 본 Loop 패키지 9건(실반영 8건)을 묶어 workflow.md/project-setup.md에 일괄 반영 가능. 둘 다 메타 변경(자동 T3)이며 각자의 3자 교차 리뷰를 이미 거침 — 사용자 검수만 남음.
