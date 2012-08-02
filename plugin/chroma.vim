""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim global plugin for colour printing messages in Vim
" Maintainer:	Barry Arthur <barry.arthur@gmail.com>
" Version:	0.1
" Description:	Simple extensible markup based colour message (:echo) printer
" Last Change:	2012-08-02
" License:	Vim License (see :help license)
" Location:	plugin/chroma.vim
" Website:	https://github.com/dahu/chroma
"
" See chroma.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help chroma
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:chroma_version = '0.1'

" Vimscript Setup: {{{1
" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

" load guard
" uncomment after plugin development
"if exists("g:loaded_chroma")
"      \ || v:version < 700
"      \ || v:version == 703 && !has('patch338')
"      \ || &compatible
"  let &cpo = s:save_cpo
"  finish
"endif
"let g:loaded_chroma = 1

" Chroma Class {{{1
function! Chroma()
  let chroma = {}
  let chroma.tagPattern = '%\([^%]\+\)%'
  let chroma.echoPattern = '"|echohl % |echon "\1"|echohl None|echon "'
  let chroma.tags = {
        \ '!'   : 'Error',
        \ '\\*' : 'WarningMsg',
        \ '+'   : 'Type',
        \ '/'   : 'Keyword',
        \ '_'   : 'Label'
        \}
  let chroma.matchers = []

  func chroma.generate_matchers() dict
    let self.matchers = []
    for [tag, highlight] in items(self.tags)
      call add(self.matchers, {
            \ 'match'   : substitute(self.tagPattern, '%', tag, 'g'),
            \ 'replace' : substitute(self.echoPattern, '%', highlight, '')
            \})
    endfor
  endfunc

  " Public Interface
  func chroma.del(tag) dict
    call remove(self.tags, a:tag)
    call self.generate_matchers()
    return self
  endfunc

  func chroma.add(tag, highlight) dict
    let self.tags[a:tag] = a:highlight
    call self.generate_matchers()
    return self
  endfunc

  func chroma.set(tag, highlight) dict
    call self.add(a:tag, a:highlight)
    return self
  endfunc

  func chroma.print(msg) dict
    let msg = a:msg
    for matcher in self.matchers
      let msg = substitute(msg, matcher['match'], matcher['replace'], 'g')
    endfor
    exe 'echon "' . msg . '"|echon "\n"'
    return self
  endfunc

  return chroma
endfunction
let chroma = Chroma()
call chroma.generate_matchers()

" Commands: {{{1
command! -nargs=* Chroma call chroma.print(<q-args>)

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo

" vim: set sw=2 sts=2 et fdm=marker:
