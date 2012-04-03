" Vim filetype plugin file
" Language:     Gyp
" Maintainer:   Channing Dai (http://www.listary.com)
" URL:          https://github.com/ChanningDai/gyp.vim
" Original Maintainer:   Kelan Champagne  (http://yeahrightkeller.com)

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

set ts=2
set sw=2
set tw=0
set wm=0
set expandtab

" Set 'formatoptions' to break comment lines but not other lines,
" and insert the comment leader when hitting <CR> or using "o".
setlocal formatoptions-=t formatoptions+=croql

" Set 'comments' to format dashed lists in comments.
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://

setlocal commentstring=#%s

let b:undo_ftplugin = "setl fo< ofu< com< cms<" 


map <leader>c :call CreateFileFromGyp()<CR>
map <leader>a :call AddFilesBasedOnCurrentLine()<CR>
map <leader>s :call SortList()<CR>
map <leader>r :call RenameFiles()<CR>

function! CreateFileFromGyp()
python << EOF
import vim, re, os
lines = vim.current.range
for line in lines:
    m = re.search("['\"](\S*)['\"],",line)
    if m:
	path = vim.eval('fnamemodify("' + m.group(1) + '", ":p")')
	if not os.path.exists(path):
	    f = open(path, 'w')
	    f.close()
	    print "Create file: " + path

EOF
endfunction

function! AddFilesBasedOnCurrentLine()
python << EOF
import vim
b = vim.current.buffer
line_num = int(vim.eval('line(".")'))
file_name = vim.current.line.strip()
b[line_num - 1: line_num] = ["'" + file_name + ".cpp',", "'" + file_name + ".h',"]
vim.command('normal 2==')
EOF
endfunction

function! SortList()
python << EOF
import vim
start_line = int(vim.eval('search("[", "nb")')) + 1
end_line = int(vim.eval('search("]", "n")')) - 1
vim.command("%d,%dsort" % (start_line, end_line))
EOF
endfunction

function! RenameFiles()
python << EOF
import vim, re, os
def python_input(message = 'input'):
  vim.command('call inputsave()')
  vim.command("let user_input = input('" + message + ": ')")
  vim.command('call inputrestore()')
  return vim.eval('user_input')

def GetPathFromLine(line):
    m = re.search("['\"](\S*)['\"],",line)
    if m:
	return vim.eval('fnamemodify("' + m.group(1) + '", ":p")')

def RenameLine(line_num, pattern, replace_with):
#print "replace %s with %s" % (pattern, replace_with)
    b = vim.current.buffer
    if pattern not in b[line_num-1]:
	return
    old_path = GetPathFromLine(b[line_num-1])
    b[line_num-1] = b[line_num-1].replace(pattern, replace_with)
    new_path = GetPathFromLine(b[line_num-1])
    os.rename(old_path, new_path)
    print "Rename %s to %s" % (old_path, new_path)

line_num = int(vim.eval('line(".")'))
m = re.search("['\"](\S*)['\"],", vim.current.line)
pattern = m.group(1).rpartition(".")[0]
replace_with = python_input("New file name")
RenameLine(line_num, pattern, replace_with)
RenameLine(line_num + 1, pattern, replace_with)
EOF
endfunction
