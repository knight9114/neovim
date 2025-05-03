return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "python",
        "go",
        "rust",
        "zig",
      },
      highlight = { enable = true },
      indent = { enable = true },
    }
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {},
  },
}
