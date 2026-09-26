#!/usr/bin/env bash
#
# check_branch.sh
# Checks if branch A (default: master) is after branch B (default: suporte)
# and finds the last commit where both branches were the same.
#
# Usage:
#   ./check_branch.sh                   # Compares 'master' and 'suporte'
#   ./check_branch.sh [BRANCH_A] [BRANCH_B]

set -euo pipefail

# Color styling for terminal output
if [ -t 1 ]; then
    BOLD=$'\033[1m'
    GREEN=$'\033[32m'
    YELLOW=$'\033[33m'
    BLUE=$'\033[34m'
    CYAN=$'\033[36m'
    RED=$'\033[31m'
    RESET=$'\033[0m'
else
    BOLD=""
    GREEN=""
    YELLOW=""
    BLUE=""
    CYAN=""
    RED=""
    RESET=""
fi

# Ensure the script is run inside a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf "%s\n" "${RED}Error: Not inside a git repository.${RESET}" >&2
    exit 1
fi

BRANCH_A="${1:-master}"
BRANCH_B="${2:-suporte}"

# Validate both branches exist
if ! git rev-parse --verify --quiet "$BRANCH_A" >/dev/null 2>&1; then
    printf "%s\n" "${RED}Error: Branch '$BRANCH_A' not found.${RESET}" >&2
    exit 1
fi

if ! git rev-parse --verify --quiet "$BRANCH_B" >/dev/null 2>&1; then
    printf "%s\n" "${RED}Error: Branch '$BRANCH_B' not found.${RESET}" >&2
    exit 1
fi

printf "%s\n" "${BOLD}${BLUE}=== Comparing Branches ===${RESET}"
printf "Target branch : %s\n" "${CYAN}$BRANCH_A${RESET}"
printf "Base branch   : %s\n\n" "${CYAN}$BRANCH_B${RESET}"

# 1. Find the last commit where both branches were the same (merge-base)
MERGE_BASE=$(git --no-pager merge-base "$BRANCH_A" "$BRANCH_B" 2>/dev/null || true)

if [ -z "$MERGE_BASE" ]; then
    printf "%s\n" "${RED}No common ancestor found between '$BRANCH_A' and '$BRANCH_B' (unrelated histories).${RESET}"
    exit 1
fi

printf "%s\n" "${BOLD}${BLUE}=== Last Common Commit (Where both branches were the same) ===${RESET}"
git --no-pager log -1 --format=format:"Commit  : %C(yellow)%H%C(reset) (%h)%nAuthor  : %an <%ae>%nDate    : %ad (%ar)%nSummary : %C(bold)%s%C(reset)%n" --date=format:"%Y-%m-%d %H:%M:%S" "$MERGE_BASE"
printf "\n"

# 2. Check relationship between branches
AHEAD_COUNT=$(git --no-pager rev-list --count "$BRANCH_B..$BRANCH_A")
BEHIND_COUNT=$(git --no-pager rev-list --count "$BRANCH_A..$BRANCH_B")

printf "%s\n" "${BOLD}${BLUE}=== Branch Status ===${RESET}"
printf "Commits in '%s' ahead of '%s'  : %s\n" "$BRANCH_A" "$BRANCH_B" "${BOLD}$AHEAD_COUNT${RESET}"
printf "Commits in '%s' ahead of '%s'  : %s\n\n" "$BRANCH_B" "$BRANCH_A" "${BOLD}$BEHIND_COUNT${RESET}"

if [ "$BEHIND_COUNT" -eq 0 ] && [ "$AHEAD_COUNT" -eq 0 ]; then
    printf "%s\n" "${GREEN}Result: Branch '$BRANCH_A' and branch '$BRANCH_B' are identical (pointing to the same commit).${RESET}"
elif [ "$BEHIND_COUNT" -eq 0 ] && [ "$AHEAD_COUNT" -gt 0 ]; then
    printf "%s\n" "${GREEN}Result: YES! Branch '$BRANCH_A' is AFTER branch '$BRANCH_B'.${RESET}"
    printf "Branch '%s' contains all commits from '%s' and has %s commit(s) after it.\n\n" "$BRANCH_A" "$BRANCH_B" "${BOLD}$AHEAD_COUNT${RESET}"
    printf "%s\n" "${BOLD}Commit(s) in '$BRANCH_A' after '$BRANCH_B':${RESET}"
    git --no-pager log  --oneline --graph "$BRANCH_B..$BRANCH_A"
elif [ "$BEHIND_COUNT" -gt 0 ] && [ "$AHEAD_COUNT" -eq 0 ]; then
    printf "%s\n" "${YELLOW}Result: NO. Branch '$BRANCH_A' is BEFORE branch '$BRANCH_B'.${RESET}"
    printf "Branch '%s' is %s commit(s) behind '%s'.\n\n" "$BRANCH_A" "${BOLD}$BEHIND_COUNT${RESET}" "$BRANCH_B"
    printf "%s\n" "${BOLD}Commit(s) in '$BRANCH_B' ahead of '$BRANCH_A':${RESET}"
    git --no-pager log --oneline --graph "$BRANCH_A..$BRANCH_B"
else
    printf "%s\n" "${YELLOW}Result: Branch '$BRANCH_A' and branch '$BRANCH_B' have DIVERGED.${RESET}"
    printf "Neither branch is strictly after the other.\n"
    printf "- '%s' has %s commit(s) not in '%s'.\n" "$BRANCH_A" "${BOLD}$AHEAD_COUNT${RESET}" "$BRANCH_B"
    printf "- '%s' has %s commit(s) not in '%s'.\n\n" "$BRANCH_B" "${BOLD}$BEHIND_COUNT${RESET}" "$BRANCH_A"
    printf "%s\n" "${BOLD}Commit(s) only in '$BRANCH_A':${RESET}"
    git --no-pager log --oneline --graph "$BRANCH_B..$BRANCH_A"
    printf "\n%s\n" "${BOLD}Commit(s) only in '$BRANCH_B':${RESET}"
    git --no-pager log --oneline --graph "$BRANCH_A..$BRANCH_B"
fi
