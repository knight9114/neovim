return {
	{ "neovim/nvim-lspconfig" },
	{
		"saghen/blink.cmp",
		dependencies = {
			{ "rafamadriz/friendly-snippets" },
		},
		build = "rustup run nightly cargo build --release",
		opts = {
			keymap = { preset = "enter" },
			appearance = { nerd_font_variant = "mono" },
			completion = { documentation = { auto_show = false } },
			sources = { default = { "lsp", "path", "snippets", "buffer" } },
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		opts_extend = { "sources.default" },
	},
}
