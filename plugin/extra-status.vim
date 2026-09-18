" extra-status.vim - extra information on the Vim statusline
" Format language: a plain string, components prefixed by %
"
"   %L %C        line / column from the start (1-based)
"   %-L %-C      line / column from the end (line('.')-line('$'), col('.')-col('$'))
"   %_ %0-9 %a-z unnamed, numbered, and named registers
"   %H:%M:%S     last-write time of the current file (%M = minutes, strftime)
"   %W           modified flag (* / ✓)
"   %%           literal %
"   %=           native: everything after it is right-aligned
"   %<           native: truncation point (left of it is kept on overflow)
"   %*           native: reset highlight after a %#Group# region
"   Search for -1 and switch comment if you want %-L or %-C to have the last line/column as 1 instead of 0

let s:default_format = '(%-L,%C){%_}[%H:%M:%S]<%W>'

if !exists('g:format')
    let g:format = s:default_format
endif
if !exists('g:register_width')
    let g:register_width = 36
endif
if !exists('g:register_nl')
    let g:register_nl = '↵'
endif
if !exists('g:register_tab')
    let g:register_tab = '➜'
endif
if !exists('g:register_trunc')
    let g:register_trunc = [0, '...']
endif
if !exists('g:register_reserve')
    let g:register_reserve = 24
endif
if !exists('g:register_replace')
    let g:register_replace = []
endif
if !exists('g:modified_msg')
    let g:modified_msg = '*'
endif
if !exists('g:unmodified_msg')
    let g:unmodified_msg = '✓'
endif

function! s:ReplacePairs()
    let l:r = get(g:, 'register_replace', [])
    if empty(l:r)
        return []
    endif
    if type(l:r) == v:t_list && len(l:r) == 2 && type(l:r[0]) == v:t_string && type(l:r[1]) == v:t_string
        return [l:r]
    endif
    return l:r
endfunction

function! s:Trunc()
    let l:t = get(g:, 'register_trunc', [0, '...'])
    if type(l:t) == v:t_string
        return [1, l:t]
    endif
    if type(l:t) == v:t_list && len(l:t) >= 2
        return [l:t[0], l:t[1]]
    endif
    return [0, '...']
endfunction

function! GetModifiedFlag()
    return &modified ? g:modified_msg : g:unmodified_msg
endfunction

function! FileSaveTime(token)
    let l:file = expand('%')
    if empty(l:file) || !filereadable(l:file)
        let l:out = a:token
        let l:out = substitute(l:out, '%T', '--:--:--', 'g')
        let l:out = substitute(l:out, '%Y', '----', 'g')
        let l:out = substitute(l:out, '%B', '---', 'g')
        let l:out = substitute(l:out, '%[HMSydD]', '--', 'g')
        return l:out
    endif
    let l:spec = a:token
    let l:spec = substitute(l:spec, '%D', '%d', 'g')
    let l:spec = substitute(l:spec, '%T', '%H:%M:%S', 'g')
    return strftime(l:spec, getftime(l:file))
endfunction

function! s:Truncate(text, max, mode, symbol)
    let l:trunc_w = strchars(a:symbol)
    if a:max < l:trunc_w
        return v:null
    endif
    let l:len = strchars(a:text)
    if l:len <= a:max
        return a:text
    endif
    let l:keep = a:max - l:trunc_w
    if l:keep <= 0
        return v:null
    endif
    if a:mode == 1
        return strcharpart(a:text, 0, l:keep) . a:symbol
    elseif a:mode == -1
        return a:symbol . strcharpart(a:text, l:len - l:keep, l:keep)
    endif
    let l:left = l:keep / 2
    let l:right = l:keep - l:left
    return strcharpart(a:text, 0, l:left) . a:symbol . strcharpart(a:text, l:len - l:right, l:right)
endfunction

function! StatusRegister(reg)
    let l:raw = getreg(a:reg ==# '_' ? '"' : a:reg)
    if empty(l:raw)
        return ''
    endif

    let l:clean = l:raw
    for l:pair in s:ReplacePairs()
        if type(l:pair) == v:t_list && len(l:pair) == 2
            let l:clean = substitute(l:clean, l:pair[0], l:pair[1], 'g')
        endif
    endfor

    if !empty(g:register_nl)
        let l:clean = substitute(l:clean, '[\r\n]\+', g:register_nl, 'g')
    endif
    if !empty(g:register_tab)
        let l:clean = substitute(l:clean, '\t', g:register_tab, 'g')
    endif
    let l:clean = trim(l:clean)

    let l:trunc = s:Trunc()
    " Clamp to the real window width so the register content never grows
    " past the statusline and overlaps the other components on splits/resizes
    let l:max = min([g:register_width, winwidth(0) - g:register_reserve])
    let l:cut = s:Truncate(l:clean, l:max, l:trunc[0], l:trunc[1])
    if l:cut is v:null
        return ''
    endif
    return l:cut
endfunction

function! BuildStatusline(fmt)
    let l:out = ''
    let l:i = 0
    let l:n = strlen(a:fmt)
    while l:i < l:n
        let l:rest = strpart(a:fmt, l:i)
        if l:rest[0] !=# '%'
            let l:out .= l:rest[0]
            let l:i += 1
            continue
        endif

        if strpart(l:rest, 0, 2) ==# '%%'
            let l:out .= '%%'
            let l:i += 2
            continue
        endif

        if l:rest =~# '^%-L' || l:rest =~# '^%-l'
            "let l:out .= '%{line(''.'')-line(''$'')}'
            let l:out .= '%{line(''.'')-line(''$'')-1}'
            let l:i += 3
            continue
        endif
        if l:rest =~# '^%-C' || l:rest =~# '^%-c'
            "let l:out .= '%{col(''.'')-col(''$'')}'
            let l:out .= '%{col(''.'')-col(''$'')-1}'
            let l:i += 3
            continue
        endif
        if l:rest =~# '^%L'
            let l:out .= '%{line(''.'')}'
            let l:i += 2
            continue
        endif
        if l:rest =~# '^%C'
            let l:out .= '%{col(''.'')}'
            let l:i += 2
            continue
        endif

        let l:comp = matchstr(l:rest, '^%[HMSYDBT]\([:./ \-]%[HMSYDBT]\)\+')
        if !empty(l:comp)
            let l:out .= '%{FileSaveTime(''' . escape(l:comp, "'\\") . ''')}'
            let l:i += strlen(l:comp)
            continue
        endif

        let l:one = matchstr(l:rest, '^%[HMSYDBT]')
        if !empty(l:one)
            let l:out .= '%{FileSaveTime(''' . escape(l:one, "'\\") . ''')}'
            let l:i += strlen(l:one)
            continue
        endif

        if l:rest =~# '^%W'
            let l:out .= '%{GetModifiedFlag()}'
            let l:i += 2
            continue
        endif

        let l:rm = matchstr(l:rest, '^%[_0-9a-z]')
        if !empty(l:rm)
            let l:out .= '%{StatusRegister(''' . escape(strpart(l:rm, 1), "'\\") . ''')}'
            let l:i += 2
            continue
        endif

        if l:rest =~# '^%[=<*]'
            let l:out .= strpart(l:rest, 0, 2)
            let l:i += 2
            continue
        endif

        let l:hl = matchstr(l:rest, '^%#[A-Za-z0-9_]\+#')
        if !empty(l:hl)
            let l:out .= l:hl
            let l:i += strlen(l:hl)
            continue
        endif

        let l:out .= '%'
        let l:i += 1
    endwhile
    return l:out
endfunction

command! ExtraStatusReload let &statusline = BuildStatusline(g:format) | redrawstatus
command! ExtraStatusCompile echo BuildStatusline(g:format)

set laststatus=2
let &statusline = BuildStatusline(g:format)

augroup ExtraStatus
    autocmd!
    autocmd CursorMoved,CursorMovedI,CmdlineLeave,TextYankPost,BufEnter,BufWritePost,VimResized,WinEnter,TextChanged,TextChangedI * redrawstatus
augroup END