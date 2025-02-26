#!/usr/bin/env bash
# set -euo pipefail
# -e : Exit immediately if a command exits with a non-zero status;
# -u : Treat unset variables as an error and exit;
# -o pipeline : Set the exit status to the last command in the pipeline that failed.

# Color Codes
# Run the following command to get list of available colors
# bash -c 'for c in {0..255}; do tput setaf $c; tput setaf $c | cat -v; echo =$c; done'

B=$(tput bold)
BLA=$(tput setaf 0)
RED=$(tput setaf 1)
GRN=$(tput setaf 2)
YEL=$(tput setaf 3)
BLU=$(tput setaf 4)
MAG=$(tput setaf 5)
CYA=$(tput setaf 6)
WHI=$(tput setaf 7)
GRE=$(tput setaf 8)
PRP=$(tput setaf 99)
BRED=$(tput setaf 9)
BGRN=$(tput setaf 10)
BYEL=$(tput setaf 11)
BBLU=$(tput setaf 12)
BMAG=$(tput setaf 13)
BCYA=$(tput setaf 14)
BWHI=$(tput setaf 15)
D=$(tput sgr0)
BEL=$(tput bel)

# Store the current directory path
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Execute scripts with echo statements
echo "${B}${CYA}Starting zap.sh execution...${D}"
"${SCRIPT_DIR}/zap.sh" || { echo "${B}${RED}Error: zap.sh failed${D}"; exit 1; }

echo "${B}${GRN}Starting tmux.sh execution...${D}"
"${SCRIPT_DIR}/tmux.sh" || { echo "${B}${RED}Error: tmux.sh failed${D}"; exit 1; }

echo "${B}${YEL}Starting sym.sh execution...${D}"
"${SCRIPT_DIR}/sym.sh" || { echo "${B}${RED}Error: sym.sh failed${D}"; exit 1; }

echo "${B}${MAG}Starting yay.sh execution...${D}"
"${SCRIPT_DIR}/yay.sh" || { echo "${B}${RED}Error: yay.sh failed${D}"; exit 1; }

echo "${B}${BGRN}All scripts executed successfully!${D}"
