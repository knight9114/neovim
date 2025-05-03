return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-treesitter/nvim-treesitter" },
      { "ravitemer/mcphub.nvim" },
    },
    opts = {
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
      strategies = {
        chat = { adapter = "ollama/qwen3" },
        inline = { adapter = "ollama/qwen3" },
        cmd = { adapter = "ollama/qwen3" },
      },
      adapters = {
        ["ollama/qwen3"] = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "ollama/qwen3",
            schema = {
              model = { default = "qwen3:8b" },
            },
          })
        end,
        ["ollama/deepseek-r1"] = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "ollama/deepseek-r1",
            schema = {
              model = { default = "deepseek-r1:7b" },
            },
          })
        end,
      }
    },
  }
}
