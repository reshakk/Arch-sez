#!/usr/bin/env bash

plugins=(
	https://github.com/preservim/nerdtree 
	https://github.com/tpope/vim-commentary
	https://github.com/Yggdroot/indentLine 
	https://github.com/dense-analysis/ale 
	https://github.com/mattn/emmet-vim 
	https://github.com/ap/vim-css-color.git
	https://github.com/hail2u/vim-css3-syntax
	https://github.com/othree/html5.vim
	https://github.com/Valloric/MatchTagAlways
)

npm_plug=(
	htmlhint
	browser-sync
)

printf "\n%.0s" {1..2}  
echo -e "\e[35m
        ####################
         VIM-PLUGINS SCRIPT
        ####################
\e[0m"
printf "\n%.0s" {1..1} 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_func.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_vim.log"

mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.local/share/nvim/site/pack/vendor/start"

for RPG in "${plugins[@]}"; do
	git_name="$( echo $RPG | rev | cut -d '/' -f 1 | rev )"
	git clone --depth=1 "$RPG" "$HOME/.local/share/nvim/site/pack/vendor/start/$git_name" 2>&1 || tee -a "$LOG"	
done


if pacman -Q npm &> /dev/null; then
	for NPMP in "${npm_plug[@]}"; do
		sudo npm install -g "$NPMP" 2>&1 || tee -a "$LOG"
	done
else
	echo "${ERROR} npm isn't installed. Try it manually." 2>&1 | tee -a "$LOG"
fi

cat << EOF > "$HOME/.config/nvim/init.vim"


" Enable HTML linters: htmlhint and tidy
let g:ale_linters = {
\   'html': ['htmlhint', 'tidy'],
\}

" Optional: Enable fixing with tidy (tidy can fix some HTML issues)
let g:ale_fixers = {
\   'html': ['tidy'],
\}

" Optional: Customize signs and error messages appearance
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

" Css syntax
augroup VimCSS3Syntax
  autocmd!

  autocmd FileType css setlocal iskeyword+=-
augroup END


EOF


