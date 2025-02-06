scriptencoding utf-8

let s:PATTERN = '^$~.*[]\'
let s:Config = vital#fern#import('Config')
let s:AsyncLambda = vital#fern#import('Async.Lambda')

let s:STATUS_NONE = g:fern#STATUS_NONE
let s:STATUS_COLLAPSED = g:fern#STATUS_COLLAPSED

function! fern#renderer#web_devicons#new() abort
  let default = fern#renderer#default#new()
  return extend(copy(default), {
        \ 'render': funcref('s:render'),
        \ 'syntax': funcref('s:syntax'),
        \ 'highlight': funcref('s:highlight'),
        \})
endfunction

function! s:render(nodes) abort
  let options = {
        \ 'leading': g:fern#renderer#web_devicons#leading,
        \ 'padding': g:fern#renderer#web_devicons#padding,
        \ 'root_symbol': g:fern#renderer#web_devicons#root_symbol,
        \ 'indent_markers': g:fern#renderer#web_devicons#indent_markers,
        \ 'root_leading': g:fern#renderer#web_devicons#root_leading,
        \}
  let base = len(a:nodes[0].__key)

  if options.indent_markers
    let length_nodes = len(a:nodes)
    let levels = {}

    for i in range(length_nodes - 1, 0, -1)
      let node = a:nodes[i]
      let node._renderer_web_devicons_level = len(node.__key) - base
      let node._renderer_web_devicons_last = get(levels, node._renderer_web_devicons_level, 0) isnot# 1 ? 1 : 0

      for key in keys(levels)
        if key > node._renderer_web_devicons_level
          let levels[key] = 0
        endif
      endfor

      let levels[node._renderer_web_devicons_level] = 1
    endfor

    for i in range(length_nodes)
      let node = a:nodes[i]
      let last_marker = i is# 0 ? [0] : a:nodes[i - 1]._renderer_web_devicons_marker
      let node._renderer_web_devicons_marker = [repeat([0], node._renderer_web_devicons_level)][0]
      let current_length = len(node._renderer_web_devicons_marker)

      for ii in range(min([len(last_marker), current_length]))
        let node._renderer_web_devicons_marker[ii] = last_marker[ii]
      endfor

      if node._renderer_web_devicons_last is# 1 && i isnot# 0
        let node._renderer_web_devicons_marker[current_length - 1] = 1
      endif
    endfor
  endif
  
  if &filetype ==# "fern"
    cal clearmatches()
  endif
  let Profile = fern#profile#start('fern#renderer#web_devicons#s:render')
  return s:AsyncLambda.map(copy(a:nodes), { v, idx -> s:render_node(v, base, options, idx) })
        \.catch({ e -> execute("echom " . string(e)) })
        \.finally({ -> Profile() })
endfunction

function! s:syntax() abort
  syntax match FernLeaf   /\s*\zs.*[^/].*$/ transparent contains=FernLeafSymbol
  syntax match FernBranch /\s*\zs.*\/.*$/   transparent contains=FernBranchSymbol
  syntax match FernRoot   /\%1l.*/     transparent contains=FernRootSymbol
  execute printf(
        \ 'syntax match FernRootSymbol /%s/ contained nextgroup=FernRootText',
        \ escape(g:fern#renderer#web_devicons#root_symbol, s:PATTERN),
        \)

  syntax match FernLeafSymbol   /. / contained nextgroup=FernLeafText
  syntax match FernBranchSymbol /. / contained nextgroup=FernBranchText

  syntax match FernRootText   /.*\ze.*$/ contained nextgroup=FernBadgeSep
  syntax match FernLeafText   /.*\ze.*$/ contained nextgroup=FernBadgeSep
  syntax match FernBranchText /.*\ze.*$/ contained nextgroup=FernBadgeSep
  syntax match FernBadgeSep   //         contained conceal nextgroup=FernBadge
  syntax match FernBadge      /.*/         contained

  syntax match FernIndentMarkers /[│└]/
  setlocal concealcursor=nvic conceallevel=2
endfunction

function! s:highlight() abort
  highlight default link FernRootSymbol    Comment
  highlight default link FernRootText      Comment
  highlight default link FernLeafSymbol    Directory
  highlight default link FernLeafText      None
  highlight default link FernBranchSymbol  Statement
  highlight default link FernBranchText    Statement
  highlight default link FernIndentMarkers NonText
endfunction

function! s:render_node(node, base, options, idx) abort
  let level = len(a:node.__key) - a:base
  if level is# 0
    let suffix = a:node.label =~# '/$' ? '' : '/'
    let padding = a:options.root_symbol ==# '' ? '' : a:options.padding
    return a:options.root_leading . a:options.root_symbol . padding . a:node.label . suffix . '' . a:node.badge
  endif
  let leading = ''

  if a:options.indent_markers
    let indent_length = len(a:node._renderer_web_devicons_marker)

    for i in range(indent_length)
      let indent = a:node._renderer_web_devicons_marker[i]

      if indent is# 0
        let leading = leading . '│ '
      elseif indent is# 1 && i is# indent_length - 1
        let leading = leading . '└ '
      else
        let leading = leading . '  '
      endif
    endfor
  else
    let leading = repeat(a:options.leading, level - 1)
  endif

  let symbol_hlgroup = s:get_node_symbol(a:node)
  let symbol = symbol_hlgroup[0]
  let hlgroup = symbol_hlgroup[1]
  if hlgroup !=# ""
    if &filetype ==# "fern"
      cal matchaddpos(hlgroup, [[a:idx + 1, strlen(a:options.root_leading . leading) + 1]])
    endif
  endif
  let suffix = a:node.status ? '/' : ''
  return a:options.root_leading . leading . symbol . a:node.label . suffix . '' . a:node.badge
endfunction

function! s:get_node_symbol(node) abort
  let hlgroup = ""
  if a:node.status is# s:STATUS_NONE
    let filename = fnamemodify(a:node.bufname, ':t')
    let extension = fnamemodify(a:node.bufname, ':e')
    let symbol_hlgroup = luaeval(printf('{ require"nvim-web-devicons".get_icon("%s", "%s", {default = true}) }', filename, extension))
    let symbol = symbol_hlgroup[0]
    let hlgroup  = symbol_hlgroup[1]

  elseif a:node.status is# s:STATUS_COLLAPSED
    let symbol = ""
  else
    let symbol = ""
  endif
  return [symbol . ' ', hlgroup]
endfunction

call s:Config.config(expand('<sfile>:p'), {
      \ 'leading': ' ',
      \ 'padding': ' ',
      \ 'root_symbol': '',
      \ 'indent_markers': 0,
      \ 'root_leading': ' ',
      \})

let g:fern#renderer#web_devicons#root_leading = get(g:, 'fern#renderer#web_devicons#root_leading', g:fern#renderer#web_devicons#leading)
