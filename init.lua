local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "c", "cpp", "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "yaml", "html", "toml", "css" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
  end,
})

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
  },
})

require("lazy").setup({
  { -- colorschemes
    { "catppuccin/nvim",        name = "catppuccin", priority = 1000 },
    { "rose-pine/neovim",       name = "rose-pine",  priority = 1000 },
    { "vague-theme/vague.nvim", name = "vague",      priority = 1000 },
  },
  { -- misc editor
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = true,
    },
    {
      "kylechui/nvim-surround",
      version = "*",
      event = "VeryLazy",
      opts = {},
    },
    {
      "stevearc/oil.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("oil").setup({
          view_options = { show_hidden = true },
          default_file_explorer = true,
        })
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
      end,
    },
  },
  { -- git integration
    {
      "lewis6991/gitsigns.nvim",
      event = "VeryLazy",
      config = true,
    },
    {
      "NeogitOrg/neogit",
      dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
      cmd = "Neogit",
      keys = {
        { "<leader>gs", "<cmd>Neogit<cr>", desc = "Git Status" },
      },
      config = true,
    },
  },
  { -- ai
    {
      "olimorris/codecompanion.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "ravitemer/mcphub.nvim",
      },
      cmd = { "CodeCompanion", "CodeCompanionChat" },
      keys = {
        { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI Chat Toggle" },
        { "<leader>ac", "<cmd>CodeCompanion<cr>",            mode = { "n", "v" },    desc = "AI Inline Action" },
      },
      opts = {
        adapters = {
          http = {
            litellm = function()
              return require("codecompanion.adapters").extend("openai_compatible", {
                env = {
                  url = "http://localhost:4000",
                  api_key = "nope",
                  chat_url = "/v1/chat/completions",
                },
              })
            end,
          },
        },
        strategies = {
          chat = { adapter = "litellm", model = "gpt-oss-20b" },
          inline = { adapter = "litellm", model = "gpt-oss-20b" },
        },
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              make_vars = true,
              make_slash_commands = true,
              show_result_in_chat = true,
            },
          },
        },
      },
    },
    {
      "hansmrtn/clanker.nvim",
      opts = {
        api_url = "http://localhost:4000",
        model = "gpt-oss-20b",
        context_lines = 50,
      },
    },
  },
  { -- lsp
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      main = "nvim-treesitter.configs",
      opts = {
        ensure_installed = {
          "c", "lua", "vim", "vimdoc", "query", "python", "rust", "go", "javascript", "typescript", "markdown"
        },
        highlight = { enable = true },
      },
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = { "saghen/blink.cmp" },
      config = function()
        local lspconfig = require("lspconfig")
        vim.opt.completeopt = { "menu", "menuone", "noselect" }
        local on_attach = function(client, bufnr)
          if vim.lsp.completion then
            vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
          end

          local opts = { buffer = bufnr }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "grn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "gca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "]d", function()
            vim.diagnostic.jump({ count = 1, float = true })
          end, { desc = "Next Diagnostic" })
          vim.keymap.set("n", "[d", function()
            vim.diagnostic.jump({ count = -1, float = true })
          end, { desc = "Prev Diagnostic" })
          vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show Diagnostic Error" })
          vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic Quickfix List" })
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function() vim.lsp.buf.format({ async = false }) end,
          })
        end

        local servers = {
          "ty",
          "rust_analyzer",
          "clangd",
          "gopls",
          "ts_ls",
          "marksman",
          "lua_ls",
        }

        for _, server in ipairs(servers) do
          vim.lsp.config[server] = { on_attach = on_attach }
          vim.lsp.enable(server)
        end
      end,
    },
  },
})

vim.cmd.colorscheme("vague")
