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
    source = true,
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP Actions",
  callback = function(event)
    local opts = { buffer = event.buf }
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gri", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "grn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "grr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "grt", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "gO", vim.lsp.buf.document_symbol, opts)
    vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
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
      buffer = event.buf,
      callback = function() vim.lsp.buf.format({ async = false }) end,
    })
  end,
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
          chat = { adapter = "litellm", model = "olmo-3-7b" },
          inline = { adapter = "litellm", model = "olmo-3-7b" },
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
  },
  { -- lsp
    {
      "nvim-treesitter/nvim-treesitter",
      lazy = false,
      event = "BufRead",
      branch = "main",
      build = ":TSUpdate",
      ---@class TSConfig
      opts = {
        -- custom handling of parsers
        ensure_installed = {
          "bash",
          "c",
          "css",
          "diff",
          "go",
          "gomod",
          "gosum",
          "html",
          "javascript",
          "json",
          "json5",
          "lua",
          "luadoc",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "regex",
          "toml",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
          "zig",
        },
      },
      config = function(_, opts)
        if opts.ensure_installed and #opts.ensure_installed > 0 then
          require("nvim-treesitter").install(opts.ensure_installed)
          for _, parser in ipairs(opts.ensure_installed) do
            local filetypes = parser
            vim.treesitter.language.register(parser, filetypes)

            vim.api.nvim_create_autocmd({ "FileType" }, {
              pattern = filetypes,
              callback = function(event)
                vim.treesitter.start(event.buf, parser)
              end,
            })
          end
        end

        vim.api.nvim_create_autocmd("BufRead", {
          callback = function(event)
            local bufnr = event.buf
            local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

            if filetype == "" then
              return
            end

            for _, filetypes in pairs(opts.ensure_installed) do
              local ft_table = type(filetypes) == "table" and filetypes or { filetypes }
              if vim.tbl_contains(ft_table, filetype) then
                return
              end
            end

            local parser_name = vim.treesitter.language.get_lang(filetype)
            if not parser_name then
              return
            end

            local parser_configs = require("nvim-treesitter.parsers")
            if not parser_configs[parser_name] then
              return
            end

            local parser_installed = pcall(vim.treesitter.get_parser, bufnr, parser_name)

            if not parser_installed then
              require("nvim-treesitter").install({ parser_name }):wait(30000)
            end

            parser_installed = pcall(vim.treesitter.get_parser, bufnr, parser_name)

            if parser_installed then
              vim.treesitter.start(bufnr, parser_name)
            end
          end,
        })
      end,
    },
    {
      "saghen/blink.cmp",
      dependencies = { "rafamadriz/friendly-snippets" },
      build = "rustup run nightly cargo build --release",
      opts = {},
    },
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          {
            path = "${3rd}/luv/library",
            words = { "vim%.uv" },
          },
        },
      },
    },
  },
})

local servers = {
  "ty",
  "rust_analyzer",
  "clangd",
  "gopls",
  "ts_ls",
  "marksman",
  "lua_ls",
}

vim.lsp.enable(servers)
vim.lsp.set_log_level("off")

vim.cmd.colorscheme("vague")
