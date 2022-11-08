# 🌿 fern-renderer-devicons.vim

[![fern renderer](https://img.shields.io/badge/🌿%20fern-plugin-yellowgreen)](https://github.com/lambdalisue/fern.vim)

[fern.vim](https://github.com/lambdalisue/fern.vim) plugin which add file type icons through [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons).

## Requirements

- [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
- Patched font
  - [Nerd Fonts](https://www.nerdfonts.com/)
  - [Cica](https://github.com/miiton/Cica)
  - [Others](https://github.com/ryanoasis/nerd-fonts#patched-fonts)

## Usage

Set `g:fern#renderer` to `"nvim-web-devicons"` like:

```vim
let g:fern#renderer = "nvim-web-devicons"
```

Or using lua:

```lua
vim.g["fern#renderer"] = "nvim-web-devicons"
```

## See also

- [lambdalisue/glyph-palette.vim](https://github.com/lambdalisue/glyph-palette.vim) - Apply individual colors on icons
