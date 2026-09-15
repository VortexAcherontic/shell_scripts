#!/bin/bash
# revdeps.sh — Find all packages that depend on a given package (openSUSE)

set -uo pipefail

# ── Colours ─────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Usage ────────────────────────────────────────────────────────────────────
usage() {
    echo -e "${BOLD}Usage:${RESET} $(basename "$0") <package-name> [options]"
    echo ""
    echo "Options:"
    echo -e "  ${BOLD}-i${RESET}   Search only installed packages (skips repo search)"
    echo -e "  ${BOLD}-r${RESET}   Search only repository packages (skips installed search)"
    echo -e "  ${BOLD}-h${RESET}   Show this help message"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") openssl"
    echo "  $(basename "$0") libcurl4 -i"
    echo "  $(basename "$0") zlib -r"
    exit 0
}

# ── Argument parsing ─────────────────────────────────────────────────────────
if [[ $# -eq 0 ]]; then
    usage
fi

PACKAGE=""
DO_INSTALLED=true
DO_REPO=true

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i) DO_REPO=false ;;
        -r) DO_INSTALLED=false ;;
        -h|--help) usage ;;
        -*) echo -e "${RED}Error: Unknown option '$1'${RESET}" >&2; exit 1 ;;
        *)
            if [[ -n "$PACKAGE" ]]; then
                echo -e "${RED}Error: Unexpected argument '$1'${RESET}" >&2
                exit 1
            fi
            PACKAGE="$1"
            ;;
    esac
    shift
done

if [[ -z "$PACKAGE" ]]; then
    echo -e "${RED}Error: No package name supplied.${RESET}" >&2
    echo ""
    usage
fi

# ── Helpers ──────────────────────────────────────────────────────────────────
divider() {
    echo -e "${DIM}$(printf '%.0s─' {1..60})${RESET}"
}

is_installed() {
    rpm -q "$1" &>/dev/null
}

# ── Header ───────────────────────────────────────────────────────────────────
echo ""
divider
echo -e "  ${BOLD}${CYAN}Reverse dependency lookup${RESET}  →  ${BOLD}${PACKAGE}${RESET}"
divider
echo ""

# ── 1. Installed packages ────────────────────────────────────────────────────
if $DO_INSTALLED; then
    echo -e "${BOLD}${YELLOW}Installed packages that require '${PACKAGE}':${RESET}"
    echo ""

    mapfile -t INSTALLED < <(rpm -q --whatrequires "$PACKAGE" 2>/dev/null)

    found_installed=false
    for pkg in "${INSTALLED[@]}"; do
        # rpm outputs "no package requires <name>" when nothing is found
        if [[ "$pkg" == no\ package* ]]; then
            break
        fi
        echo -e "  ${GREEN}✔${RESET}  $pkg"
        found_installed=true
    done

    if ! $found_installed; then
        echo -e "  ${DIM}No installed packages depend on '${PACKAGE}'.${RESET}"
    fi

    echo ""
fi

#
