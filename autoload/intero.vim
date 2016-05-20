function! intero#findsocket(dir)
	if getftype(a:dir.'/.intero.sock') ==# "socket" || getftype(a:dir.'/.intero.sock') ==# "fifo"
		return a:dir.'/.intero.sock'
	elseif a:dir ==# '/'
		return -1
	else
		return intero#findsocket(fnamemodify(a:dir, ':h'))
	endif
endfunction

function! intero#connect()
	let sockpath = intero#findsocket(expand('%:p:h'))
	if sockpath == -1
		echom 'Could not find .intero.sock in '.expand('%:p:h').' or any of its parent directories.'
	else
		let b:intero_rpc_channel = rpcstart('nc', ['-U', sockpath])
	endif
endfunction

function! intero#setbufmodule(modname)
	let b:intero_module = a:modname
endfunction

function! intero#ensureconn(ctx)
	if !exists('b:intero_rpc_channel')
		call intero#connect()
	endif
	try
		return a:ctx.callback()
	catch /Invalid channel.*/
		call intero#connect()
		return a:ctx.callback()
	endtry
endfunction

function! intero#type(str)
	let ctx = { 'str': a:str }
	function ctx.callback() dict
		return rpcrequest(b:intero_rpc_channel, 'type', self.str)
	endfunction
	return intero#ensureconn(ctx)
endfunction

function! intero#type_at()
	execute ':silent keeppatterns %s/\s*module\s*\(\S\+\)/\=intero#setbufmodule(submatch(1))/gn'
	let ctx = {}
	let ctx.pos = intero#util#get_visual_selection()
	function ctx.callback() dict
		return rpcrequest(b:intero_rpc_channel, 'type-at', b:intero_module, self.pos[0], self.pos[1], self.pos[2], self.pos[3], self.pos[4])
	endfunction
	return intero#ensureconn(ctx)
endfunction

function! intero#omnifunc(findstart, base) abort
	if a:findstart
		let line = getline('.')
		let start = col('.') - 2
		while start > 0 && !(line[start - 1] =~ '\s')
			let start -= 1
		endwhile
		let g:temp___start = start
		return start
	else
		let ctx = { 'base': a:base }
		function ctx.callback() dict
			return rpcrequest(b:intero_rpc_channel, 'complete', self.base)
		endfunction
		return intero#ensureconn(ctx)
	endif
endfunction
