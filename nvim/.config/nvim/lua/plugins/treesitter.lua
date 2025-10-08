return {
	{ "nvim-treesitter/playground", cmd = "TSPlaygroundToggle" },

	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate", -- Auto-updates parsers on install/update
		event = { "BufReadPre", "BufNewFile" }, -- Lazy-load on file open
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		opts = {
			ensure_installed = {
				"astro",
				"cmake",
				"cpp",
				"css",
				"fish",
				"gitignore",
				"go",
				"graphql",
				"http",
				"java",
				"php",
				"rust",
				"scss",
				"sql",
				"svelte",
				"asm",
				"c_sharp",
				"git_config",
				"git_rebase",
				"gitcommit",
				"ron",
				-- Neovim essentials (added for completeness)
				"lua",
				"vim",
				"vimdoc",
				"query",
			},

			sync_install = false, -- Install in parallel (faster)
			auto_install = true, -- Auto-install missing parsers

			highlight = {
				enable = true, -- Syntax highlighting
				additional_vim_regex_highlighting = false, -- Disable vim regex for treesitter langs
			},

			indent = { enable = true }, -- Auto-indent

			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = "<C-s>",
					node_decremental = "<C-backspace>",
				},
			},

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
				},
			},

			-- Your existing settings (uncomment matchup if needed)
			-- matchup = {
			--   enable = true,
			-- },

			-- https://github.com/nvim-treesitter/playground#query-linter
			query_linter = {
				enable = true,
				use_virtual_text = true,
				lint_events = { "BufWrite", "CursorHold" },
			},

			playground = {
				enable = true,
				disable = {},
				updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
				persist_queries = true, -- Whether the query persists across vim sessions
				keybindings = {
					toggle_query_editor = "o",
					toggle_hl_groups = "i",
					toggle_injected_languages = "t",
					toggle_anonymous_nodes = "a",
					toggle_language_display = "I",
					focus_language = "f",
					unfocus_language = "F",
					update = "R",
					goto_node = "<cr>",
					show_help = "?",
				},
			},
		},
		config = function(_, opts)
			-- Safely require with pcall to avoid crashes if not loaded
			local ok, configs = pcall(require, "nvim-treesitter.configs")
			if not ok then
				vim.notify("nvim-treesitter not installed; run :Lazy sync", vim.log.levels.WARN)
				return
			end

			configs.setup(opts)

			-- Your MDX filetype setup
			vim.filetype.add({
				extension = {
					mdx = "mdx",
				},
			})
			vim.treesitter.language.register("markdown", "mdx")
		end,
	},
}

-- return {
-- 	{ "nvim-treesitter/playground", cmd = "TSPlaygroundToggle" },
--
-- 	{
-- 		"nvim-treesitter/nvim-treesitter",
-- 		opts = {
-- 			ensure_installed = {
-- 				"astro",
-- 				"cmake",
-- 				"cpp",
-- 				"css",
-- 				"fish",
-- 				"gitignore",
-- 				"go",
-- 				"graphql",
-- 				"http",
-- 				"java",
-- 				"php",
-- 				"rust",
-- 				"scss",
-- 				"sql",
-- 				"svelte",
-- 				"asm",
-- 				"c_sharp",
-- 				"git_config",
-- 				"git_rebase",
-- 				"gitcommit",
-- 				"rust",
-- 				"ron",
-- 			},
--
-- 			-- matchup = {
-- 			-- 	enable = true,
-- 			-- },
--
-- 			-- https://github.com/nvim-treesitter/playground#query-linter
-- 			query_linter = {
-- 				enable = true,
-- 				use_virtual_text = true,
-- 				lint_events = { "BufWrite", "CursorHold" },
-- 			},
--
-- 			playground = {
-- 				enable = true,
-- 				disable = {},
-- 				updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
-- 				persist_queries = true, -- Whether the query persists across vim sessions
-- 				keybindings = {
-- 					toggle_query_editor = "o",
-- 					toggle_hl_groups = "i",
-- 					toggle_injected_languages = "t",
-- 					toggle_anonymous_nodes = "a",
-- 					toggle_language_display = "I",
-- 					focus_language = "f",
-- 					unfocus_language = "F",
-- 					update = "R",
-- 					goto_node = "<cr>",
-- 					show_help = "?",
-- 				},
-- 			},
-- 		},
-- 		config = function(_, opts)
-- 			require("nvim-treesitter.configs").setup(opts)
--
-- 			-- MDX
-- 			vim.filetype.add({
-- 				extension = {
-- 					mdx = "mdx",
-- 				},
-- 			})
-- 			vim.treesitter.language.register("markdown", "mdx")
-- 		end,
-- 	},
-- }
