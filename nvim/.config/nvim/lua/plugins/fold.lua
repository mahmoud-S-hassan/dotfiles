return {
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		config = function()
			-- Basic fold settings
			vim.o.foldcolumn = "1"
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			-- Keymaps
			vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
			vim.keymap.set("n", "zk", function()
				local winid = require("ufo").peekFoldedLinesUnderCursor()
				if not winid then
					pcall(vim.lsp.buf.hover)
				end
			end, { desc = "Peek fold or hover" })

			-------------------------------------------------
			-- Comprehensive C# Folder
			-------------------------------------------------
			local function csharpFoldProvider(bufnr)
				local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
				local folds = {}
				local regionStack = {}
				local blockCommentStack = {}
				local inTripleSlashBlock = false
				local inRegularCommentBlock = false
				local tripleSlashStart, regularCommentStart = nil, nil

				for i, line in ipairs(lines) do
					local lineNum = i - 1
					local trimmedLine = line:match("^%s*(.*)%s*$") or ""

					-- 1. #region / #endregion directives
					if trimmedLine:match("^#region") then
						table.insert(regionStack, lineNum)
					elseif trimmedLine:match("^#endregion") then
						if #regionStack > 0 then
							local startLine = table.remove(regionStack)
							table.insert(folds, { startLine = startLine, endLine = lineNum })
						end
					end

					-- 2. // region / // endregion comments
					if trimmedLine:match("^//%s*region") then
						table.insert(regionStack, lineNum)
					elseif trimmedLine:match("^//%s*endregion") then
						if #regionStack > 0 then
							local startLine = table.remove(regionStack)
							table.insert(folds, { startLine = startLine, endLine = lineNum })
						end
					end

					-- 3. Block comments /* ... */
					if trimmedLine:match("^/%*") then
						table.insert(blockCommentStack, lineNum)
					elseif trimmedLine:match("%*/$") then
						if #blockCommentStack > 0 then
							local startLine = table.remove(blockCommentStack)
							table.insert(folds, { startLine = startLine, endLine = lineNum })
						end
					end

					-- 4. Triple slash comments ///
					if trimmedLine:match("^///") then
						if not inTripleSlashBlock then
							inTripleSlashBlock = true
							tripleSlashStart = lineNum
						end
					elseif inTripleSlashBlock and not trimmedLine:match("^///") then
						inTripleSlashBlock = false
						if tripleSlashStart and lineNum - 1 > tripleSlashStart then
							table.insert(folds, { startLine = tripleSlashStart, endLine = lineNum - 1 })
						end
						tripleSlashStart = nil
					end

					-- 5. Regular comments // (not region/endregion)
					if
						trimmedLine:match("^//[^/]")
						and not trimmedLine:match("^//%s*region")
						and not trimmedLine:match("^//%s*endregion")
					then
						if not inRegularCommentBlock then
							inRegularCommentBlock = true
							regularCommentStart = lineNum
						end
					elseif
						inRegularCommentBlock
						and (
							not trimmedLine:match("^//")
							or trimmedLine:match("^//%s*region")
							or trimmedLine:match("^//%s*endregion")
						)
					then
						inRegularCommentBlock = false
						if regularCommentStart and lineNum - 1 > regularCommentStart then
							table.insert(folds, { startLine = regularCommentStart, endLine = lineNum - 1 })
						end
						regularCommentStart = nil
					end
				end

				-- Close any open blocks at end of file
				if inTripleSlashBlock and tripleSlashStart then
					table.insert(folds, { startLine = tripleSlashStart, endLine = #lines - 1 })
				end
				if inRegularCommentBlock and regularCommentStart then
					table.insert(folds, { startLine = regularCommentStart, endLine = #lines - 1 })
				end
				if #blockCommentStack > 0 then
					for _, startLine in ipairs(blockCommentStack) do
						table.insert(folds, { startLine = startLine, endLine = #lines - 1 })
					end
				end
				if #regionStack > 0 then
					for _, startLine in ipairs(regionStack) do
						table.insert(folds, { startLine = startLine, endLine = #lines - 1 })
					end
				end

				return folds
			end

			-------------------------------------------------
			-- UFO Setup that combines Treesitter + Custom Folding
			-------------------------------------------------
			require("ufo").setup({
				provider_selector = function(bufnr, filetype, buftype)
					if filetype == "cs" then
						return function(bufnr)
							-- First get treesitter folds (for code structure)
							local tsFolds = {}
							local tsOk, tsResult = pcall(require("ufo").getFolds, bufnr, "treesitter")
							if tsOk and tsResult then
								tsFolds = tsResult
							end

							-- Then get our custom folds (for regions and comments)
							local customFolds = csharpFoldProvider(bufnr)

							-- Combine both fold types
							local allFolds = {}

							-- Add treesitter folds first
							for _, fold in ipairs(tsFolds) do
								table.insert(allFolds, fold)
							end

							-- Add custom folds (avoid duplicates)
							for _, customFold in ipairs(customFolds) do
								local isDuplicate = false
								for _, tsFold in ipairs(tsFolds) do
									if
										tsFold.startLine == customFold.startLine
										and tsFold.endLine == customFold.endLine
									then
										isDuplicate = true
										break
									end
								end
								if not isDuplicate then
									table.insert(allFolds, customFold)
								end
							end

							return allFolds
						end
					end
					return { "treesitter", "indent" }
				end,

				fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
					local newVirtText = {}
					local suffix = (" 󰁂 %d "):format(endLnum - lnum)
					local sufWidth = vim.fn.strdisplaywidth(suffix)
					local targetWidth = width - sufWidth
					local curWidth = 0

					for _, chunk in ipairs(virtText) do
						local chunkText = chunk[1]
						local chunkWidth = vim.fn.strdisplaywidth(chunkText)

						if targetWidth > curWidth + chunkWidth then
							table.insert(newVirtText, chunk)
							curWidth = curWidth + chunkWidth
						else
							chunkText = truncate(chunkText, targetWidth - curWidth)
							local hlGroup = chunk[2]
							table.insert(newVirtText, { chunkText, hlGroup })
							curWidth = curWidth + vim.fn.strdisplaywidth(chunkText)
							break
						end
					end

					if curWidth < targetWidth then
						suffix = (" "):rep(targetWidth - curWidth) .. suffix
					end

					table.insert(newVirtText, { suffix, "MoreMsg" })
					return newVirtText
				end,
			})

			-- Debug command to see all detected folds
			vim.api.nvim_create_user_command("DebugFolding", function()
				local bufnr = vim.api.nvim_get_current_buf()

				-- Check treesitter folds
				local tsOk, tsFolds = pcall(require("ufo").getFolds, bufnr, "treesitter")
				if tsOk then
					print("🌳 Treesitter folds:", #tsFolds)
					for i, fold in ipairs(tsFolds) do
						if i <= 3 then
							local startText = vim.api.nvim_buf_get_lines(
								bufnr,
								fold.startLine,
								fold.startLine + 1,
								false
							)[1] or ""
							print(
								string.format(
									"  TS Fold %d: lines %d-%d - %s",
									i,
									fold.startLine + 1,
									fold.endLine + 1,
									startText:gsub("^%s+", ""):sub(1, 30)
								)
							)
						end
					end
					if #tsFolds > 3 then
						print("  ... and " .. (#tsFolds - 3) .. " more")
					end
				else
					print("❌ Treesitter error:", tsFolds)
				end

				print("")

				-- Check custom folds
				local customFolds = csharpFoldProvider(bufnr)
				print("📝 Custom folds:", #customFolds)
				for i, fold in ipairs(customFolds) do
					if i <= 3 then
						local startText = vim.api.nvim_buf_get_lines(bufnr, fold.startLine, fold.startLine + 1, false)[1]
							or ""
						print(
							string.format(
								"  Custom Fold %d: lines %d-%d - %s",
								i,
								fold.startLine + 1,
								fold.endLine + 1,
								startText:gsub("^%s+", ""):sub(1, 30)
							)
						)
					end
				end
				if #customFolds > 3 then
					print("  ... and " .. (#customFolds - 3) .. " more")
				end

				print("")
				print("🎯 Total combined folds:", (tsOk and #tsFolds or 0) + #customFolds)
			end, {})
		end,
	},
} --------------------------------------
------------old
-----------------------------
-- return {
-- 	{
-- 		"kevinhwang91/nvim-ufo",
-- 		dependencies = "kevinhwang91/promise-async",
-- 		config = function()
-- 			-- Basic fold settings
-- 			vim.o.foldcolumn = "1"
-- 			vim.o.foldlevel = 99
-- 			vim.o.foldlevelstart = 99
-- 			vim.o.foldenable = true
--
-- 			-- Keymaps
-- 			vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
-- 			vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
-- 			vim.keymap.set("n", "zk", function()
-- 				local winid = require("ufo").peekFoldedLinesUnderCursor()
-- 				if not winid then
-- 					-- Use pcall to avoid LSP offset encoding warnings
-- 					pcall(vim.lsp.buf.hover)
-- 				end
-- 			end, { desc = "Peek fold or hover" })
--
-- 			-------------------------------------------------
-- 			-- Simple C# Marker Provider
-- 			-------------------------------------------------
-- 			local function csharpMarkerProvider(bufnr)
-- 				local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
-- 				local folds = {}
-- 				local regionStack = {}
--
-- 				for i, line in ipairs(lines) do
-- 					local lineNum = i - 1 -- Convert to 0-based
--
-- 					-- Match #region and related patterns
-- 					if line:match("^%s*#region") or line:match("^%s*//%s*region") then
-- 						table.insert(regionStack, lineNum)
-- 					-- Match #endregion and related patterns
-- 					elseif line:match("^%s*#endregion") or line:match("^%s*//%s*endregion") then
-- 						if #regionStack > 0 then
-- 							local startLine = table.remove(regionStack)
-- 							table.insert(folds, { startLine = startLine, endLine = lineNum })
-- 						end
-- 					end
-- 				end
--
-- 				return folds
-- 			end
--
-- 			-------------------------------------------------
-- 			-- UFO Setup with safe provider selection
-- 			-------------------------------------------------
-- 			require("ufo").setup({
-- 				provider_selector = function(bufnr, filetype, buftype)
-- 					if filetype == "cs" then
-- 						-- For C#, use custom provider that combines markers with indent
-- 						return function(bufnr)
-- 							local markerFolds = csharpMarkerProvider(bufnr)
--
-- 							-- Safely get indent folds
-- 							local indentFolds = {}
-- 							local ok, result = pcall(require("ufo").getFolds, bufnr, "indent")
-- 							if ok and type(result) == "table" then
-- 								indentFolds = result
-- 							end
--
-- 							-- Combine both fold types
-- 							for _, fold in ipairs(markerFolds) do
-- 								table.insert(indentFolds, fold)
-- 							end
--
-- 							return indentFolds
-- 						end
-- 					end
--
-- 					-- For other filetypes, use safe default
-- 					return { "indent" }
-- 				end,
--
-- 				-- Custom fold text
-- 				fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
-- 					local newVirtText = {}
-- 					local suffix = (" 󰁂 %d "):format(endLnum - lnum)
-- 					local sufWidth = vim.fn.strdisplaywidth(suffix)
-- 					local targetWidth = width - sufWidth
-- 					local curWidth = 0
--
-- 					for _, chunk in ipairs(virtText) do
-- 						local chunkText = chunk[1]
-- 						local chunkWidth = vim.fn.strdisplaywidth(chunkText)
--
-- 						if targetWidth > curWidth + chunkWidth then
-- 							table.insert(newVirtText, chunk)
-- 							curWidth = curWidth + chunkWidth
-- 						else
-- 							chunkText = truncate(chunkText, targetWidth - curWidth)
-- 							local hlGroup = chunk[2]
-- 							table.insert(newVirtText, { chunkText, hlGroup })
-- 							curWidth = curWidth + vim.fn.strdisplaywidth(chunkText)
-- 							break
-- 						end
-- 					end
--
-- 					if curWidth < targetWidth then
-- 						suffix = (" "):rep(targetWidth - curWidth) .. suffix
-- 					end
--
-- 					table.insert(newVirtText, { suffix, "MoreMsg" })
-- 					return newVirtText
-- 				end,
-- 			})
--
-- 			-- Add a command to check current LSP clients and their offset encodings
-- 			vim.api.nvim_create_user_command("LSPOffsetInfo", function()
-- 				local bufnr = vim.api.nvim_get_current_buf()
-- 				local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
--
-- 				if #clients == 0 then
-- 					print("No active LSP clients for this buffer")
-- 					return
-- 				end
--
-- 				print("LSP Clients and their offset encodings:")
-- 				for i, client in ipairs(clients) do
-- 					print(string.format("%d. %s: %s", i, client.name, client.offset_encoding or "default"))
-- 				end
-- 			end, {})
--
-- 			-- Optional: Suppress the offset encoding warning if it becomes annoying
-- 			-- vim.lsp.set_log_level("error")
-- 		end,
-- 	},
-- }
