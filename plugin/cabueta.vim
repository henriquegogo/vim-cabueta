sign define CabuetaDefaultSign text=>

command! CabuetaSignQuickfix exe 'sign unplace * buffer='.bufnr('') | for item in getqflist() | if item.bufnr != 0 | exe 'sign place '.item.lnum.' line='.item.lnum.' name=CabuetaDefaultSign buffer='.item.bufnr | endif | endfor

" Async
command! -nargs=? CabuetaAsync let b:cabueta_qf_list = [] | call setqflist([], 'r') | exe 'CabuetaSignQuickfix' | call job_start(['sh', '-c', <f-args>], {'callback': 'CabuetaRefreshQuickfix'})
func CabuetaRefreshQuickfix(...)
  if exists('b:cabueta_qf_list')
    if exists('a:2') | let b:cabueta_qf_list += [a:2] | endif
    call setqflist([], 'r', {'efm':&errorformat, 'lines':b:cabueta_qf_list})
    exe 'CabuetaSignQuickfix'
  endif
endfunc

" Linter
if executable('xmllint')
  au FileType xml let b:cabueta_qf_list = [] | setl mp=xmllint\ % | setl efm=%f:%l:%m,%-G%.%#
endif
if executable('tidy')
  au FileType html let b:cabueta_qf_list = [] | setl mp=tidy\ -e\ \--gnu-emacs\ yes\ % | setl efm=%f:%l:%c:%m,%-G%.%#
endif
if executable('eslint')
  au FileType javascript let b:cabueta_qf_list = [] | setl mp=eslint\ -f=unix\ % | setl efm=%f:%l:%c:%m,%-G%.%#
endif
if executable('tsc')
  au FileType typescript let b:cabueta_qf_list = [] | setl mp=tsc\ --noEmit\ % | setl efm=%+A\ %#%f\ %#(%l\\,%c):\ %m,%C%m
endif
if executable('pylint')
  let g:polyglot_disabled = ['python-compiler']
  au FileType python let b:cabueta_qf_list = [] | setl mp=pylint\ % | setl efm=%f:%l:%c:%m,%-G%.%#
endif
au BufReadPost,BufWritePost *.xml,*.html,*.js,*.ts,*.py if exists('b:cabueta_qf_list') | exe 'CabuetaLinter' | endif
au BufWinEnter *.xml,*.html,*.js,*.ts,*.py if exists('b:cabueta_qf_list') | call CabuetaRefreshQuickfix() | endif
au CursorMoved *.xml,*.html,*.js,*.ts,*.py if exists('b:cabueta_qf_list') | echo join(map(filter(getqflist(), "v:val.lnum == line('.')"),trim("v:val.text")),"\n") | endif
command! CabuetaLinter exe 'CabuetaAsync '.substitute(&makeprg, '%', expand('%'), '')
