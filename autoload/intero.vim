function! intero#connect()
	let sockpath = intero#util#findsocket(expand('%:p:h'))
	if sockpath == -1
		echom 'Could not find .intero.sock in '.expand('%:p:h').' or any of its parent directories.'
	else
		let b:intero_rpc_channel = rpcstart('nc', ['-U', sockpath])
	endif
endfunction

function! intero#setbufmodule(modname)
	let b:intero_module = a:modname
endfunction

function! intero#ensurebufmodule()
	execute ':silent keeppatterns %s/\s*module\s*\(\S\+\)/\=intero#setbufmodule(submatch(1))/gn'
endfunction

function! intero#ensureconn(ctx)
	if !exists('b:intero_rpc_channel')
		call intero#connect()
	endif
	try
		return a:ctx.callback()
	catch /Invalid.*/
		call intero#connect()
		return a:ctx.callback()
	endtry
endfunction

function! intero#type(str)
	let ctx = { 'str': a:str }
	function ctx.callback() dict
		return rpcrequest(b:intero_rpc_channel, 'type', self.str)
	endfunction
	return ''.intero#ensureconn(ctx)
endfunction

function! intero#ranged(fun)
	call intero#ensurebufmodule()
	let ctx = { 'fun': a:fun }
	let ctx.pos = intero#util#get_visual_selection()
	function ctx.callback() dict
		return rpcrequest(b:intero_rpc_channel, self.fun, b:intero_module, self.pos[0], self.pos[1], self.pos[2], self.pos[3], self.pos[4])
	endfunction
	return intero#ensureconn(ctx)
endfunction

function! intero#uses()
	let dat = intero#ranged('uses-at')
	if has_key(dat, 'error')
		echom dat.error
	elseif has_key(dat, 'uses')
		let result = []
		for use in dat.uses
			if has_key(use, 'loc')
				let fpath = intero#util#findfile(expand('%:p:h'), substitute(use.loc[0], '\.', '/', 'g').'.hs')
				if fpath == -1
					let fpath = use.loc[0]
				endif
				call add(result, { 'filename': fpath, 'lnum': use.loc[1], 'col': use.loc[2], 'type': 'U' })
			elseif has_key(use, 'unhelpful')
				call add(result, { 'text': use.unhelpful })
			endif
		endfor
		call setqflist(result, 'r', 'Uses of '.intero#util#get_visual_selection()[4])
		copen
	endif
endfunction

function! intero#gotodef()
	let dat = intero#ranged('loc-at')
	if has_key(dat, 'error')
		echom dat.error
	elseif has_key(dat, 'loc')
		let fpath = intero#util#findfile(expand('%:p:h'), substitute(dat.loc[0], '\.', '/', 'g').'.hs')
		if fpath == -1
			let fpath = dat.loc[0]
		endif
		execute 'edit +'.dat.loc[1].' '.fpath
		normal 0
		execute 'normal '.(dat.loc[2] - 1).'l'
	elseif has_key(dat, 'unhelpful')
		echom dat.unhelpful
	endif
endfunction

function! intero#omnifunc(findstart, base) abort
	if a:findstart
		let line = getline('.')
		let start = col('.') - 2
		while start > 0 && !(line[start - 1] =~ '\s')
			let start -= 1
		endwhile
		return start
	else
		let ctx = { 'base': a:base }
		function ctx.callback() dict
			return rpcrequest(b:intero_rpc_channel, 'complete', self.base)
		endfunction
		return intero#ensureconn(ctx)
	endif
endfunction
