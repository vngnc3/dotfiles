require "nvchad.options"
-- Make Neovim background transparent
vim.cmd [[
  augroup TransparentBackground
  autocmd!
  autocmd ColorScheme * highlight Normal ctermbg=none guibg=none
  autocmd ColorScheme * highlight NonText ctermbg=none guibg=none
  augroup END
]]

-- vim.opt.termguicolors = false

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
