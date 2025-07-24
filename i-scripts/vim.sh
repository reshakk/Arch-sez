#!/usr/bin/env bash

plugins=(
	https://github.com/preservim/nerdtree # Get directory with :NERDtree
	https://github.com/tpope/vim-commentary # Multi-comment with g+c
	https://github.com/Yggdroot/indentLine # Displaying thin vertical lines at each indentation level for code indented with spaces
	https://github.com/dense-analysis/ale # Check syntax
	https://github.com/mattn/emmet-vim # Abbreviations
	https://vimawesome.com/plugin/vim-css-color-the-story-of-us
	https://github.com/hail2u/vim-css3-syntax
	https://github.com/othree/html5.vim
	https://github.com/preservim/vim-indent-guides
	https://github.com/Valloric/MatchTagAlways.git
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

MAIN_DIR="$HOME/.vim"

mkdir -p "$MAIN_DIR"
mkdir -p "$MAIN_DIR/autoload"
mkdir -p "$MAIN_DIR/bundle"

curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim 2>&1 || tee -a "$LOG"

for RPG in "${plugins[@]}"; do
	git_name="$( echo $RPG | rev | cut -d '/' -f 1 | rev )"
	git clone --depth=1 "$RPG" "$MAIN_DIR/bundle/$git_name" 2>&1 || tee -a "$LOG"	
done


if pacman -Q npm &> /dev/null; then
	for NPMP in "${npm_plug[@]}"; do
		sudo npm install -g "$NPMP" 2>&1 || tee -a "$LOG"
	done
else
	echo "${ERROR} npm isn't installed. Try it manually." 2>&1 | tee -a "$LOG"
fi

cat << EOF > "$HOME/.vimrc"

execute pathogen#infect()
syntax on
filetype plugin indent on

" Autocomplete for html
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags

let g:indent_guides_start_level = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_auto_colors = 0
hi IndentGuidesOdd  ctermbg=236
hi IndentGuidesEven ctermbg=NONE

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

let g:mta_use_matchparen_group = 1


EOF


