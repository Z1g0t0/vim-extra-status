# vim-extra-status
Useful extra information on the status line.

## Components

### **Symmetric Cursor Coordinates**

Displays line and column number relative to the beginning/end of the file/line.

- %L: Displays current line number relative to the beginning of the file.
- %-L: Displays current line number relative to the end of the file.
- %C: Displays current column number relative to the beginning of the line.
- %-C: Displays current column number relative to the end of the line.

### **Register Preview**

Displays given register index/content. 

- %<0-9a-z_>: Displays the index and/or content of a register(%_ = unnamed), truncated if over g:register_width characters(36 by default).

#### Examples:

{Unnamed: %_} 
```
{Unnamed: <register(%_ = unnamed), truncated if over g:register_width characters(36 by default).}
``` 

\[1]: %1 
``` 
[1]: < of a register(%_ = unnamed), truncated if over g:register_width characters(36 by default).
```
A=%a
```
A=<ent of a register(%_ = unnamed), truncated if over g:register_width characters(36 by default).
```
### **Write Information**

Display the last modified time of the file and its current status(modified/unchanged).

 - %H %M %S: Displays the last modified time of the file as HH MM SS.
 - %W: Displays current state.

[%H:%M:%S]\(%W)
```
[11:22:33](*)
```

### **Custom Format and Symbols**

Customizable format and symbols order.

Defaults: 
```vim
let g:register_width = 36       " Maximum characters register's content displays(truncates if over)
let g:register_reserve = 24     " Reserved width which the register's content doesn't go over)
let g:register_nl = '↵'         " Register's content newline alias(\r\n = ↵)
let g:register_tab = '➜'       " Register's content tab alias(\t = ➜)
let g:register_replace = ['\s\+', ' ']  " Custom register's content regex replace
let g:modified_msg = '*'                " Modified/Unsaved changes message(*)
let g:unmodified_msg = '✓'              " Unmodified/Saved message(✓)

" Truncate register's content display at the beginning with "..."
let g:register_trunc = [0, '...']   " [<-1, 0, 1>, <symbol>]
"                                     -1 = ...Truncate at the beginning.
"                                     0 = Truncate in ... the middle.
"                                     1 = Truncate at the end...
"                                     <symbol> = String placeholder

let g:format = "(%-L,%C){%_}[%H:%M:%S]<%W>" 
```
```
(-24, 0){Defaults:↵let g:re...{%_}[%H:%M:%S]<%W>}[11:22:33]<*>
```

### **Vim's Native Features**

Vim's native layout items can be used to further customize the format.

 - **%=**: Right-align everything after it is pushed to the window edge.
 - **%<**: By default statusline is left truncated/right focused. This sets the truncation point.
 - **%#<hi_group>#**: Vim color/highlight groups, e.g. *WarningMsg*, *ErrorMsg*, *ModeMsg*...
 - **%\***: Resets the highlight back to the default.

Example:

```vim
" Always show line, column, unnamed buffer truncated to the left.
" Modified buffer status highlighted in WarningMsg color and last write right-aligned.
let g:format = '(%L,%C)%<{%_}%#WarningMsg#(%W)%*%=[%H:%M:%S]'
```
```
(-8,1){...hilighted in WarningMsg color and time is right-aligned.↵}(✓)                       [19:45:26]
```

## Installation
Using [vim-plug](https://github.com/junegunn/vim-plug):
```vim
Plug 'username/statusline.vim'
```