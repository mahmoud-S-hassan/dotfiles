if vim.loader then
	vim.loader.enable()
end

_G.dd = function(...)
	require("util.debug").dump(...)
end
vim.print = _G.dd

require("config.lazy")

-- Function to send the content of the `"+` register to `clip.exe`
local function send_to_windows_clipboard()
	local content = vim.fn.getreg('+')

	-- Send the content to `clip.exe`
	vim.fn.system('clip.exe', content)
end

-- Autocommand to send the content of the `"+` register to `clip.exe` after yanking
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		send_to_windows_clipboard()
	end,
})

-- LSP configuration
local lspconfig = require('lspconfig')

lspconfig.asm_lsp.setup {
	cmd = { "asm-lsp" },
	filetypes = { "asm", "s", "S" },
	root_dir = function(fname)
		return lspconfig.util.root_pattern(".git")(fname) or lspconfig.util.path.dirname(fname)
	end,
}
