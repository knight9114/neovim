-- [[ Locals ]]
local is_nvim_v11 = vim.fn.has("nvim-0.11") == 1
local github_root_url = "https://github.com/"
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"


-- [[ Bootstrap Package Manager ]]

if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = github_root_url .. "folke/lazy.nvim.git"
  print("Installing `lazy.nvim` to " .. path)
  local msg = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    lazyrepo,
    "--branch=stable",
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "ERROR: failed to clone `lazy.nvim`:\n", "ErrorMsg" },
      { msg, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)


-- [[ Pre-Plugin Options ]]

vim.o.number = true
vim.o.relativenumber = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = false
vim.o.showmode = false
vim.o.termguicolors = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300


-- [[ Keymaps ]]

vim.g.mapleader = vim.keycode("<Space>")
vim.keymap.set({ "n", "x", "o" }, "gy", '"+y', { desc = "Copy to System Clipboard" })
vim.keymap.set({ "n", "x", "o" }, "gp", '"+p', { desc = "Paste from System Clipboard" })
vim.keymap.set({ "n" }, "j", "gj")
vim.keymap.set({ "n" }, "k", "gk")


-- [[ Initialize Package Manager ]]

require("lazy").setup({
  spec = {
    -- [[ colorschemes ]]
    { "rebelot/kanagawa.nvim" },
    { "catppuccin/nvim", name = "catppuccin" },
    { "rose-pine/neovim", name = "rose-pine" },
    { "folke/tokyonight.nvim" },
    { "ficcdaf/ashen.nvim" },
    { "comfysage/evergarden", opts = { variant = "hard" } },

    -- [[ coding ]]
    {
      "neovim/nvim-lspconfig",
      config = function()
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

            if vim.lsp.inlay_hint then
              vim.lsp.inlay_hint.enable(true)
              map(
                "grL",
                function()
                  if vim.lsp.inlay_hint.is_enabled() then
                    vim.lsp.inlay_hint.enable(false, { event.buf })
                  else
                    vim.lsp.inlay_hint.enable(true, { event.buf })
                  end
                end,
                "Toggle Inlay Hints"
              )
            end
          end,
        })

        local lspconfig = require("lspconfig")
        lspconfig.rust_analyzer.setup({
          settings = {
            ["rust-analyzer"] = {
              diagnostics = {
                enable = true,
              }
            }
          }
        })
        lspconfig.ruff.setup({})
        lspconfig.zls.setup({})
        lspconfig.clangd.setup({})
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        local configs = require("nvim-treesitter.configs")
        configs.setup({
          highlight = {
            enable = true,
          },
          auto_install = true,
          ensure_installed = {
            "lua",
            "vim",
            "vimdoc",
            "json",
            "python",
            "rust",
            "go",
            "c",
            "zig",
          },
        })
      end,
    },
    {
      "aaronik/treewalker.nvim",
      opts = {
        highlight = true,
        highlight_duration = 250,
      },
      keys = {
        { "<C-k>", "<cmd>Treewalker Up<cr>", mode = { "n", "v" } },
        { "<C-j>", "<cmd>Treewalker Down<cr>", mode = { "n", "v" } },
        { "<C-l>", "<cmd>Treewalker Right<cr>", mode = { "n", "v" } },
        { "<C-h>", "<cmd>Treewalker Left<cr>", mode = { "n", "v" } },
        -- TODO: requires enabling Ctrl-Shift in terminal emulator
        -- { "<C-S-k>", "<cmd>Treewalker SwapUp<cr>", mode = "n" },
        -- { "<C-S-j>", "<cmd>Treewalker SwapDown<cr>", mode = "n" },
        -- { "<C-S-l>", "<cmd>Treewalker SwapRight<cr>", mode = "n" },
        -- { "<C-S-h>", "<cmd>Treewalker SwapLeft<cr>", mode = "n" },
      },
    },
    {
      "jiaoshijie/undotree",
      dependencies = {
        { "nvim-lua/plenary.nvim" },
      },
      config = true,
      keys = {
        { "<leader>u", function() require("undotree").toggle() end, desc = "Toggle Undotree" },
      },
    },

    -- [[ ui ]]
    {
      "folke/which-key.nvim",
      config = function()
        local wk = require("which-key")
        wk.setup({
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
        wk.add({
          { "<leader>f", group = "Fuzzy Find" },
          { "<leader>b", group = "Buffer" },
        })
      end
    },
    {
      "folke/zen-mode.nvim",
      opts = {},
      keys = {
        { "<leader>zz", function() require("zen-mode").toggle({ window = { width = 0.75 } }) end, desc = "Toggle Zen Mode" },
      },
    },
    {
      "folke/twilight.nvim",
      opts = {
        exclude = { "text" },
      },
      keys = {
        { "<leader>zt", "<cmd>Twilight<cr>", desc = "Toggle Twilight" },
      },
    },

    -- [[ mini ]]
    {
      "echasnovski/mini.nvim",
      branch = "main",
      config = function()
        require("mini.icons").setup({ style = "ascii" })
        require("mini.ai").setup({ n_lines = 500 })
        require("mini.comment").setup({})
        require("mini.surround").setup({})
        require("mini.extra").setup({})
        require("mini.statusline").setup({})
        require("mini.pairs").setup({})
        require("mini.starter").setup({})

        require("mini.completion").setup({})
        vim.keymap.set("i", "<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
        vim.keymap.set("i", "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })

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
      end,
    },

    -- [[ ai ]]
    {
      "Aaronik/GPTModels.nvim",
      dependencies = {
        { "MunifTanjim/nui.nvim" },
        { "nvim-telescope/telescope.nvim" },
      },
      keys = {
        { "<leader>ac", "<cmd>GPTModelsCode<cr>", desc = "AI Code" },
        { "<leader>aq", "<cmd>GPTModelsCode<cr>", desc = "AI Chat" },
      },
    },
  },
  install = {
    colorscheme = { "catppuccin-mocha" },
  },
  checker = {
    enabled = true,
  },
})


-- [[ Post-Plugin Options ]]

vim.cmd.colorscheme("catppuccin-mocha")


-- vim: ts=2 sts=2 sw=2 et
