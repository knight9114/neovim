local utils = require("config.utils")

vim.cmd.colorscheme(utils.get_colorscheme())

vim.lsp.enable({
	"lua_ls",
	"rust_analyzer",
	"basedpyright",
	"gopls",
	"clangd",
	"zls",
})
