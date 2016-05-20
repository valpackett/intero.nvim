function! intero#util#get_visual_selection()
	" Based on http://stackoverflow.com/a/6271254
	let [lnum1, col1] = getpos("'<")[1:2]
	let [lnum2, col2] = getpos("'>")[1:2]
	let lines = getline(lnum1, lnum2)
	let lines[-1] = lines[-1][:col2 - 2]
	let lines[0] = lines[0][col1 - 1:]
	return [lnum1, col1, lnum2, col2, join(lines, "\n")]
endfunction

function! intero#util#findsocket(dir)
	if getftype(a:dir.'/.intero.sock') ==# "socket" || getftype(a:dir.'/.intero.sock') ==# "fifo"
		return a:dir.'/.intero.sock'
	elseif a:dir ==# '/'
		return -1
	else
		return intero#util#findsocket(fnamemodify(a:dir, ':h'))
	endif
endfunction

function! intero#util#findfile(dir, file)
	if getftype(a:dir.'/'.a:file) ==# "file"
		return a:dir.'/'.a:file
	elseif a:dir ==# '/'
		return -1
	else
		return intero#util#findfile(fnamemodify(a:dir, ':h'), a:file)
	endif
endfunction
