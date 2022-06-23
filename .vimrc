"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Basic Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Compatibility
if &compatible
    set nocompatible
endif

filetype off

" Tabs
set tabstop=4
set shiftwidth=4
set expandtab
set cursorline
set autoindent

" Hide Buffers
set hidden

" Backup
set nobackup
set nowritebackup

" Search
set hlsearch

set cmdheight=1

set ruler

set updatetime=300

set shortmess+=c

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
end

call plug#begin('~/.vim/plugged')
    "" Themes
    Plug 'itchyny/lightline.vim'
    Plug 'Jorengarenar/vim-darkness'
    " Plug 'tomasiser/vim-code-dark'
    Plug 'fxn/vim-monochrome'
    " Plug 'pgdouyon/vim-yin-yang'
    " Plug 'widatama/vim-phoenix'
    " Plug 'danishprakash/vim-yami'

    "" Git
    Plug 'tpope/vim-fugitive'
    Plug 'junegunn/gv.vim'

    "" Editing
    Plug 'neoclide/coc.nvim'
    Plug 'junegunn/vim-easy-align'
    Plug 'editorconfig/editorconfig-vim'
    Plug 'dense-analysis/ale'
    Plug 'posva/vim-vue'
    Plug 'digitaltoad/vim-pug'
    Plug 'prettier/vim-prettier',
        \ { 'do': 'yarn install --frozen-lockfile --production' }
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Advanced Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set t_Co=256
set t_ut=
colorscheme monochrome
let g:lightline = { 'colorscheme': 'nord' }
set laststatus=2
set noshowmode

au FileType markdown
    \ set wrap |
    \ vmap <Leader><Bslash> :EasyAlign*<Bar><Enter> |

au FileType python
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |

" COC
" Tab to trigger completion
inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
    inoremap <silent><expr> <c-space> coc#refresh()
else
    inoremap <silent><expr> <c-@> coc#refresh()
endif

" Documentation
let g:coc_global_extensions = [
    \ 'coc-json',
    \ 'coc-git',
    \ 'coc-tsserver',
    \ 'coc-html',
    \ 'coc-css',
    \ 'coc-python',
    \ 'coc-vetur' ,
    \ 'coc-svelte' ]

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

nnoremap <silent> K :call <SID>show_documentation()<CR>

" Ale
let g:ale_linters = {
    \ 'python': ['flake8', 'pydocstyle']
    \ }

" Tmux
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif
