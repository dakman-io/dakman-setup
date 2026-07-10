---
title: "스펙 — multi-ai-discussion에 grok 토론자 추가 + 3번째 토론자 로테이션"
date: 2026-07-10
handoff_from: dakman-setup (도메인 요구 — 스펙)
handoff_to: claude-config (~/.claude 소유 — 구현·실측검증·설치·git)
type: skill-spec
reply_to: "dakman-setup — cmux workspace list→tree로 재조회(ref 휘발성)"
---

# 스펙 — multi-ai-discussion 토론자에 grok 추가 (3번째 로테이션)

> **거버넌스**: `~/.claude/skills/multi-ai-discussion/`은 claude-config 소유 → dakman-setup은 **도메인 요구(스펙)**만 쓰고 위임. 구현·**grok TUI 실측검증**(agy 전환 선례와 동일)·설치·git은 claude-config. 도메인("무엇이 좋은가")은 요청 측 권한, **충돌 시 이 스펙 우선**. 완료/수정 피드백 루프(수용 게이트).

## 1. 요구 (사용자 지시 — 2026-07-10)

토론 참가자 풀에 **grok**을 추가한다. 참가 정책:

| 토론자 | 참가 |
|--------|------|
| **codex** | **항상** |
| **claude** (claude-debater) | **항상** |
| **grok** ↔ **agy** | **둘 중 하나** — 매 토론 **번갈아 로테이션**(grok→다음엔 agy→다음엔 grok…) |

- **표준 = 3인** (codex + claude + 로테이션된 3번째).
- **4인**(codex+claude+grok+agy)은 **사용자가 명시적으로 "넷이서 토론"이라 요청할 때만.**
- 로테이션 근거 = 오류원 다양성의 **시간축 극대화**: 3번째 슬롯이 **Grok 계열 ↔ Gemini 계열**을 교대 → 장기적으로 두 비-Claude·비-GPT 오류원을 모두 커버(§3 "다양성은 한 세트" 원칙을 시간축으로 확장).

## 2. grok 정찰값 (dakman-setup가 read-only로 확인 — 그대로 써라)

- **실행(자동승인)**: `grok --yolo` — 사용자 alias `grok-dg`의 실체. ⚠️ **alias는 인터랙티브 셸 전용**(스킬 스크립트=비인터랙티브 → alias 안 먹음). 스크립트엔 **`grok --yolo` 직접** 박을 것(chrome-alias 교훈과 동형). codex `--sandbox workspace-write --ask-for-approval never` · agy `--dangerously-skip-permissions`에 대응.
- **바이너리**: `/Users/kiyounglee/.local/bin/grok`, `grok 0.2.93 (stable)`. `command -v grok`로 §0 전제 체크에 추가.
- **모델 계열**: Grok (xAI) — Claude·GPT(codex)·Gemini(agy)와 다른 4번째 오류원.

## 3. claude-config가 실측검증할 것 (agy 전환 때 실측한 항목과 1:1)

grok을 codex·agy와 **대칭인 토론자**로 만들려면 아래를 실제 띄워 확인하고 SKILL.md/discussion-guide에 반영:

1. **작업중(busy) 패턴** — idle-streak 워처가 grep할 grok의 "생각중/작업중" 표식(codex `Working (` · agy `Working...`/`esc to cancel` · claude `esc to interrupt`의 grok 대응). **워처·`.done` 판정의 핵심.**
2. **send + enter 미제출** — codex·agy 공통 함정(§4). grok도 send 후 enter 재전송 필요한지 실측.
3. **`@<path>` 첨부** — 큰 프롬프트를 파일 첨부로 넘길 수 있는지(agy 지원 확인됨). 안 되면 대체 경로 명시.
4. **컨텍스트 리셋** — codex `/new` · agy `/clear` 대응(grok의 리셋 커맨드).
5. **`.done` 프로토콜** — `--yolo`로 터미널 명령 자동 실행돼 `touch ...done` + `cmux send`가 되는지(agy `--dangerously-skip-permissions`처럼).
6. **최초 trust/수락 프롬프트** — `--yolo` 기동 시 첫 수락 프롬프트 유무(agy는 없음, claude-debater는 1회 가능).
7. **launch 방식** — codex/agy는 인라인 명령, claude는 `launch-claude-debater.sh`(페르소나 주입). grok은 페르소나 주입이 필요하면 `launch-grok-debater.sh`, 아니면 인라인 `grok --yolo`. claude-config 판단.

## 4. 반영 대상(참고 — 최종 파일 판단은 claude-config)

- **SKILL.md**: §0 전제(`command -v grok` + 버전), §1 플레이북(step 2 pane 구성·step 3 자동권한 기동에 grok 추가 + **로테이션/4인 라우팅 규칙**), §2/§3(다양성 서술을 grok 포함으로), §4 함정 표(grok send+enter·busy 패턴).
- **references/discussion-guide.md**: §3 launch 상세, §7 이슈, 워처 busy 패턴 표.
- **로테이션 상태 지속** — "지난 토론의 3번째가 누구였나"를 어디에 기록해 교대할지(예: 작은 상태 파일 `~/.claude/skills/multi-ai-discussion/.rotation` 또는 `debates/` 메타). **구현 방식은 claude-config 재량** — 요구는 "매 토론 grok↔agy 교대" 결과만.
- **하위호환**: 기존 agy 참조·진행 중 토론 깨지지 않게(grok은 **가산**). 4-pane→가변 pane(3 표준/4 확장).

## 5. 수용 게이트 (dakman-setup가 실측 검증할 것 — 완료 회신 후)

- [ ] `grok --yolo`로 grok 토론자 pane 기동 + 프롬프트 착지·응답·`.done` 회수 실제 동작(실측 로그/스샷).
- [ ] 표준 호출 시 **3인**(codex+claude+로테이션 3번째), 연속 2회 호출 시 3번째가 **grok↔agy 교대**.
- [ ] "넷이서" 명시 시에만 4인.
- [ ] 워처가 grok busy 패턴을 grep해 조기오발신 없이 완료 판정.
- [ ] alias(`grok-dg`) 아닌 **`grok --yolo` 직접** 사용(비인터랙티브 안전).
- [ ] 기존 agy-only/codex 흐름 회귀 없음.

## 6. 공유 인터페이스 통지 (claude-config 판단)

이건 여러 프로젝트가 쓰는 공용 스킬의 **참가자 모델 변경**이라, 설치 후 영향받는 프로젝트(§6.8 3인 교차 리뷰를 쓰는 dakman-setup 등)에 통지 필요할 수 있음(글로벌 CLAUDE.md "공유 인터페이스 바뀌면 통지"). dakman-setup workflow.md §11의 "진행자 + claude·codex·agy" 서술은 dakman-setup가 완료 회신 후 자체 갱신.
