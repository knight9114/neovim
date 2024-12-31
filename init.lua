--[[ Core Options ]]

-- leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- nerd fonts
vim.g.have_nerd_font = false

-- clipboard
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- mouse
vim.opt.mouse = "a"

-- render
vim.opt.cursorline = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.showmode = false
vim.opt.termguicolors = true

-- scrolling
vim.opt.scrolloff = 0

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"

-- splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- undofile
vim.opt.undofile = true

-- misc
vim.opt.breakindent = true
vim.opt.updatetime = 250


--[[ Keymaps ]]

vim.keymap.set("n", "<esc>", vim.cmd.nohlsearch, { desc = "Clear search highlights" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<c-h>", "<c-w><c-h>", { desc = "Focus left window" })
vim.keymap.set("n", "<c-j>", "<c-w><c-j>", { desc = "Focus lower window" })
vim.keymap.set("n", "<c-k>", "<c-w><c-k>", { desc = "Focus upper window" })
vim.keymap.set("n", "<c-l>", "<c-w><c-l>", { desc = "Focus right window" })


-- [[ Auto-Commands ]]

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("highlight-on-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})


-- [[ Plugins ]]

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local msg = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. msg)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- colorschemes
  {
    { "cpwrs/americano.nvim" },
    { "Vallen217/eidolon.nvim" },
    { "catppuccin/nvim", name = "catppuccin" },
    { "rose-pine/neovim", name = "rose-pine" },
    { "eldritch-theme/eldritch.nvim" },
    { "folke/tokyonight.nvim" },
  },

  -- quality of life
  {
    { "tpope/vim-sleuth" },
    {
      "folke/todo-comments.nvim",
      event = "VimEnter",
      dependencies = {
        { "nvim-lua/plenary.nvim" },
      },
      opts = { signs = false },
    },
  },

  -- snacks
  {
    {
      "folke/snacks.nvim",
      lazy = false,
      priority = 1000,
      opts = {
        bigfile = { enable = true },
        bufdelete = { enable = true },
        dashboard = { example = "compact_files" },
        notifier = { enabled = true },
        quickfile = { enabled = true },
        words = { enabled = true },
      },
      keys = {
        { "<leader>z", function() Snacks.zen() end, desc = "[Z]en Mode" },
        { "<leader>Z", function() Snacks.zen.zoom() end, desc = "[Z]oom" },
        { "<leader>bdd", function() Snacks.bufdelete() end, desc = "[B]uffer [D]elete" },
        { "<leader>bda", function() Snacks.bufdelete.all() end, desc = "[B]uffers [D]elete [A]ll" },
        { "<leader>bdo", function() Snacks.bufdelete.other() end, desc = "[B]uffers [D]elete [O]thers" },
      },
    },
  },

  -- mini
  {
    {
      "echasnovski/mini.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        require("mini.icons").setup({})
        require("mini.indentscope").setup({})
        require("mini.pairs").setup({})
        require("mini.surround").setup({})
        require("mini.statusline").setup({ use_icons = vim.g.have_nerd_font })
        require("mini.files").setup({})
      end,
      keys = {
        { "<leader>m", function() if not MiniFiles.close() then MiniFiles.open() end end, desc = "Toggle [M]ini-Files" },
      },
    },
  },

  -- git
  {
    {
      "lewis6991/gitsigns.nvim",
      opts = {
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
      },
    },
  },
  
  -- ui
  {
    "folke/which-key.nvim",
    event = "VimEnter",
    opts = {
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = "<Up> ",
          Down = "<Down> ",
          Left = "<Left> ",
          Right = "<Right> ",
          C = "<C-…> ",
          M = "<M-…> ",
          D = "<D-…> ",
          S = "<S-…> ",
          CR = "<CR> ",
          Esc = "<Esc> ",
          ScrollWheelDown = "<ScrollWheelDown> ",
          ScrollWheelUp = "<ScrollWheelUp> ",
          NL = "<NL> ",
          BS = "<BS> ",
          Space = "<Space> ",
          Tab = "<Tab> ",
          F1 = "<F1>",
          F2 = "<F2>",
          F3 = "<F3>",
          F4 = "<F4>",
          F5 = "<F5>",
          F6 = "<F6>",
          F7 = "<F7>",
          F8 = "<F8>",
          F9 = "<F9>",
          F10 = "<F10>",
          F11 = "<F11>",
          F12 = "<F12>",
        },
      },
      spec = {
        { "<leader>s", group = "[S]earch" },
        { "<leader>l", group = "[L]SP" },
      },
    },
  },

  -- telescope
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable "make" == 1
        end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    },
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })

      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
      vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
      vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
      vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
      vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[S]earch Recent Files ('.' for repeat)" })
      vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[S]earch [B]uffers" })

      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = "[/] Fuzzily search in current buffer" })

      vim.keymap.set("n", "<leader>s/", function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        }
      end, { desc = "[S]earch [/] in Open Files" })

      vim.keymap.set("n", "<leader>sn", function()
        builtin.find_files { cwd = vim.fn.stdpath "config" }
      end, { desc = "[S]earch [N]eovim files" })
    end,
  },

  -- treesitter
  {
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      main = "nvim-treesitter.configs",
      dependencies = {
        { "nvim-treesitter/nvim-treesitter-context" },
        { "nvim-treesitter/nvim-treesitter-textobjects" },
      },
      opts = {
        ensure_installed = {
          "bash",
          "c",
          "diff",
          "html",
          "lua",
          "luadoc",
          "markdown",
          "markdown_inline",
          "query",
          "vim",
          "vimdoc",
          "python",
          "rust",
          "go",
          "zig",
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
            selection_modes = {
              ["@parameter.outer"] = "v",
              ["@function.outer"] = "V",
              ["@class.outer"] = "<c-v>",
            },
            include_surrounding_whitespace = true,
          },
        },
      },
    },
    {
      "aaronik/treewalker.nvim",
      opts = {
        highlight = true,
      },
    },
  },

  -- lsp
  {
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          { path = "luvit-meta/library", words = { "vim%.uv" } },
        },
      },
    },
    { "Bilal2453/luvit-meta", lazy = true },
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        { "j-hui/fidget.nvim", opts = {} },
        { "hrsh7th/cmp-nvim-lsp" },
      },
      config = function()
        vim.api.nvim_create_autocmd("LspAttach", {
          group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
          callback = function(event)
            local map = function(keys, func, desc, mode)
              mode = mode or "n"
              vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "[L]SP " .. desc })
            end

            local builtin = require("telescope.builtin")
            map("<leader>ld", builtin.lsp_definitions, "go-to [D]efinition")
            map("<leader>lD", vim.lsp.buf.declaration, "go-to [D]eclaration")
            map("<leader>lr", builtin.lsp_references, "go-to [R]eferences")
            map("<leader>lI", builtin.lsp_implementations, "go-to [I]mplementation")
            map("<leader>lt", builtin.lsp_type_definitions, "go-to [T]ype Definition")
            map("<leader>ls", builtin.lsp_document_symbols, "Document [S]ymbols")
            map("<leader>lS", builtin.lsp_dynamic_workspace_symbols, "Workspace [S]ymbols")
            map("<leader>lR", vim.lsp.buf.rename, "[R]ename Symbol")
            map("<leader>la", vim.lsp.buf.code_action, "Code [A]ction", { "n", "x" })

            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
              local hlgroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
              vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = event.buf,
                group = hlgroup,
                callback = vim.lsp.buf.document_highlight,
              })

              vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = event.buf,
                group = hlgroup,
                callback = vim.lsp.buf.clear_references,
              })

              vim.api.nvim_create_autocmd("LspDetach", {
                group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
                callback = function(ev)
                  vim.lsp.buf.clear_references()
                  vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = ev.buf })
                end,
              })
            end

            if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
              map("<leader>lh", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
              end, "toggle Inlay [H]ints")
            end
          end,
        })

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

        local lspconfig = require("lspconfig")
        lspconfig.rust_analyzer.setup({
          capabilities = capabilities,
          settings = {
            ["rust-analyzer"] = {
              check = { command = "clippy" },
              diagnostics = { enable = true },
            },
          }
        })
        lspconfig.ruff.setup({})
        lspconfig.clangd.setup({})
        lspconfig.zls.setup({})
        lspconfig.gopls.setup({})
      end,
    },
  },

  -- auto-complete
  {
    {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      dependencies = {
        {
          "L3MON4D3/LuaSnip",
          build = (function()
            if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
              return
            end
            return "make install_jsregexp"
          end)(),
          dependencies = {
            {
              "rafamadriz/friendly-snippets",
              config = function()
                require("luasnip.loaders.from_vscode").lazy_load()
              end,
            },
          },
        },
        { "saadparwaiz1/cmp_luasnip" },
        { "hrsh7th/cmp-nvim-lsp" },
        { "hrsh7th/cmp-path" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-latex-symbols" },
      },
      config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        luasnip.config.setup({})

        cmp.setup({
          snippet = {
            expand = function(args)
              vim.fn["vsnip#anonymous"](args.body)
            end,
          },
          completion = { completopt = "menu,menuone,noinsert" },
          mapping = cmp.mapping.preset.insert({
            ["<c-n>"] = cmp.mapping.select_next_item(),
            ["<c-p>"] = cmp.mapping.select_prev_item(),
            ["<c-b>"] = cmp.mapping.scroll_docs(-4),
            ["<c-f>"] = cmp.mapping.scroll_docs(4),
            ["<cr>"] = cmp.mapping.confirm({ select = true }),
            ["<c-l>"] = cmp.mapping(function()
              if luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
              end
            end, { "i", "s" }),
            ["<c-h>"] = cmp.mapping(function()
              if luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
              end
            end, { "i", "s" }),
          }),
          sources = {
            { name = "lazydev", group_index = 0 },
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "path" },
            { name = "latex_symbols" },
            { name = "buffer" },
          },
        })
      end,
    },
  },

  -- formatting
  {
  },

  -- debugging
  {
  },
})

-- vim: ts=2 sts=2 sw=2 et
