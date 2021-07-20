function! JumpToDef()
	let l:word = expand('<cword>')
	let l:word_parts = split(l:word, '::\|->')

	let l:path = GetDefinitionPath(l:word_parts)

	if !empty(l:path)
		echo 'Found! ' . l:path
		call OpenSub(l:path, l:word_parts[-1])
	else
		echo "NOT found. :'("
	endif
endfunction

function! ShowPod()
	let l:word = expand('<cword>')
	let l:word_parts = split(l:word, '::')

	let l:path = GetDefinitionPath(l:word_parts)

	if !empty(l:path)
		let l:name = l:word_parts[-1]
		let l:pod = system("awk '/=\w+ " . name . "/,/=cut/' " . l:path)
		if !empty(l:pod)
			execute 'split pod'
			normal! gg
			normal! v
			normal! G
			normal! d
			call append(line('$'), split(l:pod, "\n"))
			normal! dd
			normal! dd
			normal! dd
			normal! G
			normal! dd
			normal! dd
			normal! gg
			execute 'set syntax=pod'
		else
			echo "Pod not found. :'("
		endif
	else
		echo "Subroutine not found. :'("
	endif
endfunction

function! GetDefinitionPath(word_parts)
	let l:path = ''
	if (len(a:word_parts) > 1)
		let l:path = FindSubWithModuleName(a:word_parts)
	else
		let l:path = FindSubInCurrentFile(a:word_parts[0])
		if empty(l:path)
			let l:path = FindExportedSub(a:word_parts[0])
		endif
	endif

	return l:path
endfunction

function! ModuleToPaths(module_parts)
	let l:module = join(a:module_parts, '/')
	let l:paths = map(copy(g:perljump_inc), { key, val ->  val . '/' . l:module . '.pm' })
	return l:paths
endfunction

function! FindSubWithModuleName(word_parts)
	let l:paths = ModuleToPaths(a:word_parts[0:-2])
	for l:path in l:paths
		let l:sub = a:word_parts[-1]
		if SearchForSubInFile(l:path, l:sub)
			return l:path
		endif
	endfor
	return
endfunction

function! FindSubInCurrentFile(name)
	let l:pattern = GetSubPattern(a:name, 1)
	let l:line_number = search(l:pattern, 'wn')
	if l:line_number != 0
		return expand('%')
	else
		return ''
	endif
endfunction

function! SearchForSubInFile(path, sub)
	call system("grep -P '" . GetSubPattern(a:sub, 0) .  "' " . shellescape(a:path))
	return ! v:shell_error
endfunction

function! FindExportedSub(name)
	let l:uses = ParseUses()
	" array of arrays (Module1 -> (location1/Module1, location2/Module1, ...), ...)
	let l:paths = map(l:uses, { key, value -> ModuleToPaths(split(value, '::')) })

	for l:module_paths in l:paths
		for l:location_path in l:module_paths
			if SearchForSubInFile(l:location_path, a:name)
				return l:location_path
			endif
		endfor
	endfor

    return
endfunction

function! ParseUses()
	let l:output = system('grep -P "use [A-Z][\w:]*( .+)?;" ' . shellescape(expand('%')))
	let l:rows = split(l:output, "\n")
	let l:uses = map(l:rows, { key, val -> matchstr(val, '\v^use \zs(\w|:)+\ze.*;$') })
	return l:uses
endfunction

function! OpenSub(path, sub)
	execute 'edit' a:path
	call FindSub(a:sub)
endfunction

function! FindSub(name)
	let l:pattern = GetSubPattern(a:name, 1)
	call search(pattern, 'w')
endfunction

function! GetSubPattern(name, vim)
	let l:buffer = ''
	if a:vim
		let l:buffer .= '\v'
	endif
	let l:buffer .= '^sub ' . a:name . '(\(\@\))?' . '\s*(\{|$)'
	return buffer
endfunction
