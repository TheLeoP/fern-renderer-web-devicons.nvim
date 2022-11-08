if exists('g:fern_renderer_web_devicons_loaded')
  finish
endif
let g:fern_renderer_web_devicons_loaded = 1

call extend(g:fern#renderers, {
      \ 'nvim-web-devicons': function('fern#renderer#web_devicons#new'),
      \})
