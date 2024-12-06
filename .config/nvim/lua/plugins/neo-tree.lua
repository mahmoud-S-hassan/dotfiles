return {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
        filesystem = {
            filtered_items = {
                visible = true,
                show_hidden_count = true,
                hide_dotfiles = false,
                hide_gitignored = true,
                hide_by_name = {
                    -- '.git',
                    -- '.DS_Store',
                    -- 'thumbs.db',
                    -- ".github",
                    -- ".gitignore",
                    -- "package-lock.json",
                },
                never_show = {},
            },
        },
        window = {
            width = 30,    -- Set the width of the Neo-tree window
            height = 100,  -- Set the height (if vertical) or use it for split sizes
            position = "left", -- "left", "right", "top", or "bottom"
        }
    }
}
