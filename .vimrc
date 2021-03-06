"{{{ Miscellaneous
    set mouse=""
    filetype plugin indent on
    set confirm
    set loadplugins
    set nocompatible
    set incsearch
    set ignorecase
    set smartcase
    set fileencodings=ucs-bom,utf-8,default,latin1
    set helplang=en
    set history=50
    set modelines=0
    set nomodeline
    set nofoldenable
    set suffixes=.bak,~,.o,.info,.swp,.obj,.info,.aux,.log,.dvi,.bbl,.out,.o,.lo
    set viminfo='20,\"500
"}}}

"{{{ Display settings
    set guifont=AnonymousPro\ for\ Powerline\ 11
    set shortmess+=I
    set title
    set guioptions=aegitc
    set guicursor+=a:blinkon0
    set background=dark
    syntax enable
    set laststatus=2
    set hlsearch
    set wildmenu
    set wildmode=list:longest,full
    set ttyfast
    set ruler
    set number
    set relativenumber
    set showmode
    set showcmd
    set fdm=indent
    set listchars=eol:⏎,tab:¶\ ,trail:·,extends:+,precedes:-,conceal:↑,nbsp:_
    set showbreak=↪\ 
"}}}

"{{{ Input Settings and Key Bindings
    set timeoutlen=0
    set backspace=2
    let s:noremaps = ["H ^","J <C-D>z.","K <C-U>z.","L g_","<C-H> H","<C-L> L","Y y$","<C-J> J","gK K","/ /\\v"]
    let s:nnoremaps = ["<Enter> o<Esc>k","<silent> <C-U> :nohlsearch<Enter><C-L>","<silent> <Space> :call SetWindowMode()<Enter>","<silent> <leader> :call PerfectFormat()<Enter>"]
    "Only works in gvim:
    let s:gui_nnoremaps = ["<silent> <special> <Esc> :call UnsetWindowMode()<Enter>", "<S-Enter> O<Esc>j","<silent> <C-Enter> :call Execute_RHS_of_Cursor()<Enter>","<silent> <C-S-Enter> :call Execute_Current_Line()<Enter>"]
    "Only works with appropriate keys (Shift+Enter/Ctrl+Enter/Ctrl+Shift+Enter) when in a customized terminal.
    let s:term_nnoremaps = ["[26$ O<Esc>j","<silent> [26^ :call Execute_RHS_of_Cursor()<Enter>","<silent> [26@ :call Execute_Current_Line()<Enter>"]
    function Execute_RHS_of_Cursor()
        normal! "zy$
        normal! @z
    endfunction
    function Execute_Current_Line()
        normal! ^"zy$
        normal! @z
    endfunction
    function Set_Default_Map()
        for binding in s:noremaps
            execute "noremap " . binding
        endfor
        for binding in s:nnoremaps
            execute "nnoremap " . binding
        endfor
        if has("gui_running")
            for binding in s:gui_nnoremaps
                execute "nnoremap " . binding
            endfor
        else
            for binding in s:term_nnoremaps
                execute "nnoremap " . binding
            endfor
            autocmd TermResponse * nnoremap <silent> <special> <Esc> :call UnsetWindowMode()<Enter>
        endif
    endfunction
    function Set_Cmd_Win_Map()
            if has("gui_running")
                nunmap <S-Enter>
            else
                nunmap [26$
            endif
            nunmap <Enter>
    endfunction
    autocmd VimEnter * call Set_Default_Map()
    autocmd CmdwinEnter * call Set_Cmd_Win_Map()
    autocmd CmdwinLeave * call Set_Default_Map()

    "{{{ Indenting and Formatting
        set autoindent
        set smartindent
        set cindent
        set expandtab
        set shiftwidth=4

        function PerfectFormat()
            if ((&filetype == "cpp") || (&filetype == "c"))
                set formatprg=indent\ -npsl\ -npcs
                normal gggqG
                set formatprg=uncrustify\ -c\ ~/.config/uncrustify/cpp.cfg\ -l\ CPP\ --no-backup\ 2>/dev/null
                normal gggqG
                set formatprg=astyle\ --mode=c\ --style=horstmann\ --add-one-line-brackets\ --pad-header\ --align-pointer=type\ --align-reference=type
                normal gggqG
                normal gg
            endif
        endfunction
    "}}}

"}}}

"{{{ Window Management
    let s:WinModeSet = 0
    "autocmd VimResized * call WindowModeStatus()

    function WinMove(key)
        let t:curwin = winnr()
        exec "wincmd ".a:key
        if (t:curwin == winnr()) "we havent moved
            if (match(a:key,'[jk]')) "were we going up/down
                wincmd v
            else
                wincmd s
            endif
        exec "wincmd ".a:key
        endif
    endfunction

    function WindowModeStatus()
        if (s:WinModeSet)
            echo "-- WINDOW --"
        else
            echo ""
        endif
    endfunction

    function SetWindowMode()
        if (!s:WinModeSet)
            let s:WinModeSet = 1
            nnoremap <silent> h :call WinMove('h')<Enter>
            nnoremap <silent> j :call WinMove('j')<Enter>
            nnoremap <silent> k :call WinMove('k')<Enter>
            nnoremap <silent> l :call WinMove('l')<Enter>
            nnoremap <silent> d :wincmd q<Enter>
            nnoremap <silent> r <C-W>r
            nnoremap <silent> H :3wincmd <<Enter>
            nnoremap <silent> J :3wincmd -<Enter>
            nnoremap <silent> K :3wincmd +<Enter>
            nnoremap <silent> L :3wincmd ><Enter>
        endif
            call WindowModeStatus()
    endfunction

    function UnsetWindowMode()
        if (s:WinModeSet)
            unmap h
            unmap j
            unmap k
            unmap l
            unmap d
            unmap r
            unmap H
            unmap J
            unmap K
            unmap L
        endif
        let s:WinModeSet = 0
        call Set_Default_Map()
        call WindowModeStatus()
    endfunction
"}}}

"{{{ Settings for Specific Filetypes
    function Insert_Include_Guards()
        let filename = expand("%:t")
        if (empty(filename))
            throw "No filename available to generate include guards."
        endif
        let capitalized_filename = substitute(toupper(expand("%:t")), "\\.", "_", "g")
        let uuid_command = "uuidgen --time"
        let uuid = system(uuid_command)
        if (v:shell_error)
            throw "Calling “" . uuid_command . "” in order to generate include guards failed with output: “" . uuid. "”"
        endif
        let snake_case_uuid = substitute(matchstr(uuid, "[^\n\r]*"), "-", "_", "g")
        execute "normal! ggO#ifndef " . capitalized_filename . "_" . snake_case_uuid
        execute "normal! o#define " . capitalized_filename . "_" . snake_case_uuid
        normal! o
        execute "normal! Go#endif /* " . capitalized_filename . "_" . snake_case_uuid . " */"
        normal! O
        normal! ggjj
    endfunction

    function Initialize_New_File()
        if (&filetype == "c_header")
            if (! &readonly)
                call Insert_Include_Guards()
            endif
            set filetype=c
        elseif (&filetype == "cpp_header")
            if (! &readonly)
                call Insert_Include_Guards()
            endif
            set filetype=cpp
        endif
    endfunction
    autocmd BufNewFile *.h set filetype=c_header
    autocmd BufNewFile *.hpp set filetype=cpp_header
    autocmd BufNewFile * call Initialize_New_File()
"}}}

"{{{ Plugins
    "{{{ Powerline
        python3 from powerline.vim import setup as powerline_setup
        python3 powerline_setup()
        python3 del powerline_setup
        set laststatus=2
        set noshowmode
    "}}}
    let g:ConqueTerm_TERM = 'vt100'
    let g:snippets_dir = $HOME . "/.vim/snippets"
    "let g:solarized_termtrans = 1
    "let g:solarized_termcolors=256
    colorscheme solarized
    au! BufRead,BufWrite,BufWritePost,BufNewFile *.org
    au BufEnter *.org            call org#SetOrgFileType()
"}}}
