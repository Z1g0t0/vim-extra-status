# vim-extra-status
Useful extra information on the status line.

## Components
- **Symmetric Cursor Coordinates**: Display line and column number relative to the beginning/end of the file/line.
```vim
%L %C: Displays the current line number relative to the beginning of the file, current column number relative to the beginning of the line.
%-L %-C: Displays the current line number relative to the end of the file, current column number relative to the end of the line.
```

- **Register Preview**: Display given register index/content. 
```vim
%<0-9a-z_>: Displays the index and/or content of a register(%_ = unnamed), truncated if over g:register_width characters(36 by default).
Examples: 
{Unnamed: %_} -> Output: "{Unnamed: <unnamed register's content>}"
[1]: %1 -> Output: "{[1]: <1 register's content>}"
A=%a -> Output: "A=<a register's content>"
```

- **Write Information**: Display the last modified time of the file and its current status(modified/unchanged).
```vim
%H:%M:%S Displays the last modified time of the file as HH:MM:SS.
%W Displays current state.
Example: [%H:%M:%S](%W) -> Output: "[11:22:33](*)"
```

- **Custom Format and Symbols**: Customizable format and symbols order.
```vim
Defaults: 
let g:register_width = 36       " Maximum characters register's content displays(truncates if over)
let g:register_reserve = 24     " Reserved width of the window which the register's content doesn't go over)
let g:register_nl = '↵'         " Register's content newline alias(\r\n = ↵)
let g:register_tab = '➜'       " Register's content tab alias(\t = ➜)
let g:register_replace = ['\s\+', ' ']  " Custom register's content regex replace
let g:modified_msg = '*'                " Modified/Unsaved changes symbol(*)
let g:unmodified_msg = '✓'              " Unmodified/Saved symbol(✓)
" Truncate register's content display at the beginning with "..."
let g:register_trunc = [0, '...']   " [<-1, 0, 1>, <symbol>]
"                                     -1 = ...Truncate at the beginning.
"                                     0 = Truncate in ... the middle.
"                                     1 = Truncate at the end...
"                                     <symbol> = String placeholder
let g:format = "(%-L,%C){%_}[%H:%M:%S]<%W>" 
"(-24, 0){Defaults:↵let g:re...{%_}[%H:%M:%S]<%W>"[11:22:33]<*>
```

- **Native Features**: Vim's native layout items can be used to further customize the format.
```vim
%= Right-align: everything after it is pushed to the window edge.
%< Truncation point: By default when the statusline is too long for the window, it's content is left truncated/right focused. With this everything before it is kept.
%#<hi_group>#: Vim color/highlight groups, e.g. WarningMsg, ErrorMsg, ModeMsg...
%* Resets the highlight back to the default.

Example: 
"Always show line-column, truncated unnamed buffer(left) modified buffer component highlighted in WarningMsg color and clock is right-aligned.
let g:format = '(%L,%C)%<{%_}%#WarningMsg#(%W)%*%=[%H:%M:%S]'
Output:(-9,1){...hilighted in WarningMsg color and clock is right-aligned.↵}(✓)                   [19:45:26]

## Installation
Using [vim-plug](https://github.com/junegunn/vim-plug):
```vim
Plug 'username/statusline.vim'
```