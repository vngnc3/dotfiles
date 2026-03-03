require("nvchad.configs.lspconfig").defaults()
-- local nvlsp = require "nvchad.configs.lspconfig"

local servers = { 
  "html", 
  "cssls", 
  "ts_ls"  
}

-- Configure the TypeScript language server using the new API
vim.lsp.config("ts_ls", {
  settings = {
    typescript = {
      preferences = {
        disableSuggestions = false,
      }
    }
  }
})

vim.lsp.enable(servers)
-- read :h vim.lsp.config for changing options of lsp servers 
