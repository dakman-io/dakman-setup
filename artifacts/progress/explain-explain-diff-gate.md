## 🧭 Explainer — 이해 Explainer(/explain-diff) 게이트 추가 (커밋 1183cec)  <!-- Tier: T3 (메타 워크플로우) -->
> 📋 이건 **검토 보조 자료**(이해용)이며 **승인이 아니다** — 판정은 held-out 리뷰어·rtong.
> ⚠️ held-out 리뷰어는 이 Explainer가 아니라 **source/diff를 1차 검토**한다(리뷰 입력을 Explainer로 대체 금지).

### 배경 — 왜 이 변경인가
우리 워크플로우는 처음부터 **"비용 1차 기준 = 사용자 활성 검토 시간"**을 공언해 왔다(문서 상단·§6). 그런데 그 시간을 *직접 줄이는 도구*는 없었다 — Tier·게이트·3인 리뷰는 모두 "결함을 조기에 잡는" 장치지, "사람이 diff를 더 빨리·깊이 이해하게" 하는 장치가 아니다. Geoffrey Litt의 관찰(*Understanding is the new bottleneck*, 2026-07-02)이 이 공백을 정확히 짚는다: AI가 코드를 잘 쓰고 self-verify까지 하면서, 병목이 **"작성"에서 "인간의 이해"로 이동**했다. 이해 없이 넘어가면 **인지 부채**가 쌓인다. dakman-brain이 이 진단을 근거로 `/explain-diff`(Litt가 매일 쓰는 커스텀 스킬) 채택을 확정(rtong GO), 도메인 소유자인 우리(workflow.md)에게 발동지점 반영을 위임했다.

### 직관 — 큰 그림 한눈에
**"diff를 산문 설명으로 바꿔 PR 본문에 넣는다"** — 그게 전부다. 사람이 raw diff를 줄 단위로 읽는 대신, *배경→직관→논리 산문+핵심 스니펫* 순서의 Explainer를 읽는다. 단, 이걸 도입하면서 **거버넌스 척추 하나를 절대 건드리지 않는다**: Explainer는 **이해를 돕는 자료지 판정이 아니다.** maker가 자기 변경을 설명해도 self-approval이 아니고(판정은 여전히 held-out), 무엇보다 **held-out 리뷰어는 이 설명이 아니라 source/diff를 1차로 본다**(maker의 유리한 서사에 정박되면 §1·§4가 막던 상관 오류가 되살아나므로). 즉 "검토 시간↓ + 이해↑"를 얻되 "검증 독립성"은 지킨다.

### 무엇이 어떻게 바뀌나
변경은 **4곳에 발동지점을 박는 것**이다(새 로직이 아니라 *지점 바인딩*, 원칙 11):
1. **§5 품질 게이트 표** — "이해 Explainer" 행을 Tier 차등으로 추가(T1 생략·T2 요약·T3 필수). Lean Default + Escalation과 동형(커버리지·E2E와 같은 escalation 패턴).
2. **§5 근거 note** — 이해 병목의 *왜*와 5개 경계(생성 시점·판정 아님·잠정 발효·옵션 아티팩트·퀴즈 미채택)를 못박음.
3. **§9 DoD PR 본문 필수 필드** — Explainer를 필드로 추가(why 1줄은 그 배경의 TL;DR이라 중복 아님).
4. **§10.2 측정** — 새 게이트엔 새 지표(원칙 13). 첨부율 ↔ **인지부채 마스킹 counter-metric**(붙었지만 안 읽혀 활성 검토시간이 안 줄면 폐기 신호).

핵심 스니펫 — §5 게이트 행 한 줄이 이 변경의 정수다(전체 diff는 PR에 있음):
```markdown
| **이해 Explainer** (`/explain-diff`) | 생략 | 요약형(핵심 변경 1~2문단) | **✓ 필수** | diff→**산문 Explainer**(배경 먼저→직관 먼저→diff 아닌 산문 + 핵심 스니펫), PR 본문 포함 |
```
그리고 경계의 핵심(§5 note):
```markdown
> ★ **held-out 모델 리뷰어는 Explainer가 아니라 source/diff를 1차 검토**(§9 read-only) — 리뷰 입력을 Explainer로 대체하지 않는다(maker 서사 앵커링 방지).
```

### 영향·리스크
- **영향 범위**: 이 표준을 쓰는 모든 프로젝트의 PR 흐름(§5·§6·§9). 실사용 도구(`/explain-diff` 스킬)는 claude-config 소유 — **잠정 발효**(스킬 구현 전 T3는 수기 Explainer 허용)라 하드 블록은 없다.
- **주 리스크 = 앵커링**(가장 큰 위험): held-out 리뷰어가 Explainer에 정박해 raw diff 검토를 건너뛰면 검증 독립성이 형해화된다 → note·DoD·스킬 상단 3중으로 "리뷰어는 source/diff 1차검토" 강제.
- **부 리스크 = Goodhart**: Explainer가 형식적으로 붙기만 하고 안 읽히면 인지부채는 그대로 → §10.2 counter-metric으로 감시(개선 없으면 §10.3 폐기).
- **되돌리기**: 문서 게이트라 되돌리기 쉬움(가역). 메타 변경이라 held-out(codex·agy·claude) R1 전원 FAIL→R2 전원 PASS 거쳐 반영됨.
- **엣지**: large diff는 스킬이 파일/모듈 단위로 graceful degrade(전량 산문화 아님). 퀴즈 게이트는 이번 미채택.
