#!/usr/bin/env bash
# project-init: 브랜치 보호 일괄 적용 (develop·staging·production)
# 고-환각위험 결정적 블록을 스크립트로 캡슐화 (gh api PUT JSON 재타이핑 방지)
#
# 적용 규칙: enforce_admins=true(관리자 포함 직접 push 금지, PR로만 머지)
#            · 필수 승인 0명 · force push 금지 · 브랜치 삭제 금지
#
# ⚠️ 비가역 원격 변경 — SKILL.md §9 승인 게이트 통과 후에만 실행할 것.
# 사용법: scripts/protect-branches.sh <owner>/<repo>
#    예:  scripts/protect-branches.sh dakman-io/dakman-setup

set -euo pipefail

REPO="${1:-}"
if [[ -z "$REPO" || "$REPO" != */* ]]; then
  echo "사용법: $0 <owner>/<repo>   (예: dakman-io/dakman-setup)" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI가 필요합니다 (https://cli.github.com)." >&2
  exit 1
fi

BRANCHES=(develop staging production)

for br in "${BRANCHES[@]}"; do
  echo "→ 보호 적용: $REPO @ $br"
  gh api -X PUT "repos/$REPO/branches/$br/protection" --input - <<'JSON'
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
JSON
done

echo ""
echo "✅ 완료. 확인:"
echo "  gh api repos/$REPO/branches --jq '.[] | \"\\(.name)\\tprotected=\\(.protected)\"'"
