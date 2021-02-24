" Last Change: 2020 mar 30
" Author: Thomas Vigouroux

if exists('g:loaded_templar')
	finish
else
	let g:loaded_templar = 1
endif

augroup Templar
    autocmd BufNewFile * lua require'templar'.source()
augroup END


command! -nargs=+ TemplarRegister lua require'templar'.register(<f-args>)
