#!/bin/bash
# revdeps.sh — Find ALL packages that depend on a given package (installed or not)

set -uo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Usage ─────────────────────────────────────────────────────────────────────
usage() {
    cat <<EOF

$(echo -e "${BOLD}Usage:${RESET}") $(basename "$0") <package-name> [options]

  Searches all enabled repositories for packages that declare a
  dependency on <package-name>, whether installed or not.
  Useful for tracing why a package keeps getting pulled in.

$(echo -e "${BOLD}Options:${RESET}")
  -p    Also search by what the target package provides
        (catches deps on soname/alias, e.g. libssl.so.3)
  -f    Refresh repo metadata before searching
  -v    Show which repository each result comes from
  -h    Show this help

$(echo -e "${BOLD}Examples:${RESET}")
  $(basename "$0") openssl
  $(basename "$0") libz1 -p
  $(basename "$0") curl -v -f

EOF
    exit 0
}

# ── Argument parsing ──────────────────────────────────────────────────────────
[[ $# -eq 0 ]] && usage

PACKAGE=""
DO_PROVIDES=false
DO_REFRESH=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p) DO_PROVIDES=true ;;
        -f) DO_REFRESH=true ;;
        -v) VERBOSE=true ;;
        -h|--help) usage ;;
        -*)
            echo -e "${RED}Error: Unknown option '$1'${RESET}" >&2
            exit 1
            ;;
        *)
            [[ -n "$PACKAGE" ]] && { echo -e "${RED}Error: Unexpected argument '$1'${RESET}" >&2; exit 1; }
            PACKAGE="$1"
            ;;
    esac
    shift
done

[[ -z "$PACKAGE" ]] && { echo -e "${RED}Error: No package name supplied.${RESET}" >&2; usage; }

# ── Sanity check ──────────────────────────────────────────────────────────────
command -v zypper &>/dev/null || {
    echo -e "${RED}Error: zypper not found. Is this an openSUSE/SUSE system?${RESET}" >&2
    exit 1
}

# ── Helpers ───────────────────────────────────────────────────────────────────
divider() { echo -e "${DIM}$(printf '%.0s─' {1..65})${RESET}"; }

is_installed() { rpm -q "$1" &>/dev/null; }

# ── Optional repo refresh ─────────────────────────────────────────────────────
if $DO_REFRESH; then
    echo -e "${DIM}Refreshing repository metadata...${RESET}"
    zypper refresh
    echo ""
fi

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
divider
echo -e "  ${BOLD}${CYAN}Reverse dependency search${RESET}  →  ${BOLD}${PACKAGE}${RESET}"
divider
echo ""

# ── Build list of terms to search ────────────────────────────────────────────
# We always search by package name. With -p we also search by each
# entry in the package's Provides list (e.g. sonames, aliases).
declare -a SEARCH_TERMS=("$PACKAGE")

if $DO_PROVIDES; then
    echo -e "${DIM}Resolving provides for '${PACKAGE}'...${RESET}"
    mapfile -t PROVIDES < <(
        zypper --no-refresh info "$PACKAGE" 2>/dev/null \
            | awk '/^Provides[[:space:]]*:/{
                    found=1
                    sub(/^Provides[[:space:]]*:[[:space:]]*/,"")
                    print
                    next
                  }
                  found && /^[[:space:]]/{print; next}
                  found{exit}' \
            | tr ',' '\n' \
            | sed 's/[[:space:]]//g; s/[=>].*//' \
            | grep -v "^$\|^${PACKAGE}$" \
            | sort -u
    )

    if [[ ${#PROVIDES[@]} -gt 0 ]]; then
        echo -e "${DIM}Also searching by provides:${RESET}"
        for p in "${PROVIDES[@]}"; do
            echo -e "  ${DIM}· ${p}${RESET}"
            SEARCH_TERMS+=("$p")
        done
    else
        echo -e "${DIM}No additional provides found.${RESET}"
    fi
    echo ""
fi

# ── Core search function ──────────────────────────────────────────────────────
# Parses zypper search --requires output and prints formatted results.
# Writes "NAME|STATUS" lines so the caller can count them.
#
# zypper output format (pipe-delimited):
#   S | Name | Summary | Type
#   S = ' '  → available, not installed
#   S = 'i'  → installed
#   S = 'v'  → installed (different version)

declare -A SEEN=()   # explicitly initialised — fixes set -u on empty arrays

do_search() {
    local term="$1"

    while IFS='|' read -r s_raw name_raw summary_raw type_raw; do
        # Trim all fields
        local status name type
        status="${s_raw//[[:space:]]/}"
        name="${name_raw#"${name_raw%%[![:space:]]*}"}"   # ltrim
        name="${name%"${name##*[![:space:]]}"}"            # rtrim
        type="${type_raw#"${type_raw%%[![:space:]]*}"}"
        type="${type%"${type##*[![:space:]]}"}"

        # Skip header / separator / non-package lines
        [[ -z "$name" || "$name" == "Name" ]] && continue
        [[ "$name" =~ ^-+$ ]]                 && continue
        [[ "$type" != "package" ]]             && continue

        # Deduplicate across multiple search terms
        [[ -n "${SEEN[$name]+_}" ]] && continue
        SEEN[$name]=1

        # Installed flag
        local installed=false
        [[ "$status" == "i" || "$status" == "v" || "$status" == "i+" ]] && installed=true

        # Optional: fetch repo source
        local repo_tag=""
        if $VERBOSE; then
            local repo
            repo=$(zypper --no-refresh info "$name" 2>/dev/null \
                       | awk -F: '/^Repository[[:space:]]*:/{gsub(/^[[:space:]]+/,"",$2); print $2; exit}')
            [[ -n "$repo" ]] && repo_tag="  ${DIM}[${repo}]${RESET}"
        fi

        if $installed; then
            echo -e "  ${GREEN}✔${RESET}  ${BOLD}${name}${RESET}  ${GREEN}(installed)${RESET}${repo_tag}"
        else
            echo -e "  ${CYAN}○${RESET}  ${name}  ${DIM}(available)${RESET}${repo_tag}"
        fi

    done < <(zypper --no-refresh search --requires --match-exact "$term" 2>/dev/null)
}

# ── Run the search ────────────────────────────────────────────────────────────
for term in "${SEARCH_TERMS[@]}"; do
    if [[ ${#SEARCH_TERMS[@]} -gt 1 ]]; then
        echo -e "${YELLOW}▶ requires: '${term}'${RESET}"
    fi
    do_search "$term"
done

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
divider

TOTAL=${#SEEN[@]}

if [[ $TOTAL -eq 0 ]]; then
    echo -e "  ${RED}No packages found that depend on '${PACKAGE}'.${RESET}"
    echo -e "  ${DIM}Tip: try -p to also search by what the package provides.${RESET}"
else
    # Count installed vs available from the SEEN keys
    installed_count=0
    for name in "${!SEEN[@]}"; do
        is_installed "$name" && (( installed_count++ )) || true
    done
    available_count=$(( TOTAL - installed_count ))

    echo -e "  ${BOLD}Found ${TOTAL} package(s) that depend on '${PACKAGE}'${RESET}"
    echo -e "  ${GREEN}✔${RESET}  Installed : ${installed_count}"
    echo -e "  ${CYAN}○${RESET}  Available : ${available_count}"
    echo ""
    echo -e "  ${DIM}Legend: ${GREEN}✔ installed${RESET}${DIM} on this system · ${CYAN}○ available${RESET}${DIM} in repos but not installed${RESET}"
fi

divider
echo ""
