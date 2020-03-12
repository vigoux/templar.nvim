" Last Change: 2020 mar 12
" Author: Thomas Vigouroux
if exists('g:loaded_templar')
	finish
else
	let g:loaded_templar = 1
endif

augroup Templar
augroup END


command! -nargs=* TemplarRegister lua require'templar'.register(<f-args>)
