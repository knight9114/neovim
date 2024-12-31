vim.o.number = true
vim.o.relativenumber = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = false
vim.o.showmode = false
vim.o.termguicolors = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.g.mapleader = vim.keycode("<Space>")

vim.keymap.set({ "n", "x", "o" }, "gy", '"+y', { desc = "Copy to System Clipboard" })
vim.keymap.set({ "n", "x", "o" }, "gp", '"+p', { desc = "Paste from System Clipboard" })

local is_nvim_v11 = vim.fn.has("nvim-0.11") == 1

local github_root_url = "https://github.com/"
local lazy = {}

function lazy.install(path)
  if not vim.uv.fs_stat(path) then
    print("Installing `lazy.nvim` to " .. path)
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      github_root_url .. "folke/lazy.nvim.git",
      "--branch=stable",
      path,
    })
  end
end

function lazy.setup(plugins)
  if vim.g.plugins_ready then
    return
  end

  lazy.install(lazy.path)
  vim.opt.rtp:prepend(lazy.path)

  require("lazy").setup(plugins, lazy.opts)
  vim.g.plugins_ready = true
end

lazy.path = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "lazy.nvim")
lazy.opts = {}

lazy.setup({
  -- [[ colorschemes ]]
  { "rebelot/kanagawa.nvim" },
  { "catppuccin/nvim", name = "catppuccin" },
  { "rose-pine/neovim", name = "rose-pine" },
  { "folke/tokyonight.nvim" },

  -- [[ coding ]]
  { "neovim/nvim-lspconfig" },
  { "nvim-treesitter/nvim-treesitter" },

  -- [[ ui ]]
  { "folke/which-key.nvim" },

  -- [[ utilities ]]
  { "folke/snacks.nvim" },
  { "echasnovski/mini.nvim", branch = "main" },
})

vim.cmd.colorscheme("catppuccin")

require("nvim-treesitter.configs").setup({
  highlight = { enable = true },
  auto_install = true,
  ensure_installed = { "lua", "vim", "vimdoc", "json", "python", "rust", "go", "c", "zig" },
})

require("which-key").setup({
  icons = {
    mappings = false,
    keys = {
      Space = "Space",
      Esc = "Esc",
      BS = "Backspace",
      C = "Ctrl-",
    },
  },
})

require("which-key").add({
  { "<leader>f", group = "Fuzzy Find" },
  { "<leader>b", group = "Buffer" },
})

require("mini.icons").setup({ style = "ascii" })
require("mini.ai").setup({ n_lines = 500 })
require("mini.comment").setup({})
require("mini.surround").setup({})
require("mini.extra").setup({})
require("mini.statusline").setup({})
require("mini.pairs").setup({})
require("mini.completion").setup({})

require("mini.notify").setup({ lsp_progress = { enable = false } })
vim.notify = require("mini.notify").make_notify({})

require("mini.bufremove").setup({})
vim.keymap.set("n", "<leader>bc", function() require("mini.bufremove").delete() end, { desc = "Close Buffer" })

local mini_files = require("mini.files")
mini_files.setup({})
vim.keymap.set("n", "<leader>m", function()
  if mini_files.close() then
    return
  end
  mini_files.open()
end, { desc = "File Explorer" })

require("mini.pick").setup({})
vim.keymap.set("n", "<leader>?", require("mini.pick").builtin.help, { desc = "Search Help" })
vim.keymap.set("n", "<leader>fh", "<cmd>Pick oldfiles<cr>", { desc = "File History" })
vim.keymap.set("n", "<leader>fb", require("mini.pick").builtin.buffers, { desc = "Find Buffers" })
vim.keymap.set("n", "<leader>ff", require("mini.pick").builtin.files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", require("mini.pick").builtin.grep_live, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fd", "<cmd>Pick diagnostic<cr>", { desc = "Find Diagnostics" })
vim.keymap.set("n", "<leader>fs", "<cmd>Pick buf_lines<cr>", { desc = "Search in Local Buffer" })

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP Actions",
  callback = function(event)
    local map = function(key, fn, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, key, fn, { desc = desc, buffer = event.buf })
    end

    -- [[ Backwards Compatibility: Neovim v0.11 LSP Defaults ]]
    if not is_nvim_v11 then
      map("grn", vim.lsp.buf.references, "References")
      map("gri", vim.lsp.buf.implementation, "Implementation")
      map("grn", vim.lsp.buf.rename, "Rename Symbol")
      map("gra", vim.lsp.buf.code_action, "Code Action")
      map("gO", vim.lsp.buf.document_symbol, "Document Symbols")
      map("<C-s>", vim.lsp.buf.signature_help, "Signature Help", { "i", "s" } )
      map("gq", function() vim.lsp.buf.format({ async = true }) end, "Format", { "n", "x" } )
    end

    map("K", vim.lsp.buf.hover, "Hover")
    map("gd", vim.lsp.buf.definition, "Definition")
    map("grt", vim.lsp.buf.type_definition, "Type Definition")
    map("grd", vim.lsp.buf.declaration, "Declaration")

    local client_id = vim.tbl_get(event, "data", "client_id")
    local client = client_id and vim.lsp.get_client_by_id(client_id)
    if is_nvim_v11 and client and client.supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client_id, event.buf, {})
    end
  end,
})

require("snacks").setup({
  bigfile = { enabled = true },
  dashboard = { example = "compact_files" },
  git = { enabled = true },
  indent = { enabled = true },
})

local lspconfig = require("lspconfig")
lspconfig.rust_analyzer.setup({})
lspconfig.ruff.setup({})
lspconfig.zls.setup({})
lspconfig.clangd.setup({})

-- vim: ts=2 sts=2 sw=2 et
