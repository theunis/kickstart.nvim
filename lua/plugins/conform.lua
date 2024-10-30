return { -- Autoformat
    "stevearc/conform.nvim",
    enabled = true,
    event = { "BufWritePre" },
    cmd = { "ConformInfo", "Format", "FormatEnable", "FormatDisable" },
    config = function()
        require("conform").setup({
            notify_on_error = false,

            format_on_save = function(bufnr)
                -- Disable with a global or buffer-local variable
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end
                return { timeout_ms = 1000, lsp_format = "fallback" }
            end,
            formatters_by_ft = {
                lua = { "mystylua" },
                python = { "ruff_organize_imports", "ruff_format" }, -- { 'isort', 'black' },
                quarto = { "prettier", "injected" }, -- enables injected-lang formatting for all filetypes
            },
            formatters = {
                mystylua = {
                    command = "stylua",
                    args = { "--indent-type", "Spaces", "--indent-width", "2", "-" },
                },
            },
        })
        require("conform").formatters.prettier = {
            options = { ext_parsers = {
                qmd = "markdown",
            } },
        }
        -- Customize the "injected" formatter
        require("conform").formatters.injected = {
            -- Set the options field
            options = {
                -- Set to true to ignore errors
                ignore_errors = false,
                -- Map of treesitter language to file extension
                -- A temporary file name with this extension will be generated during formatting
                -- because some formatters care about the filename.
                lang_to_ext = {
                    bash = "sh",
                    c_sharp = "cs",
                    elixir = "exs",
                    javascript = "js",
                    julia = "jl",
                    latex = "tex",
                    markdown = "md",
                    python = "py",
                    ruby = "rb",
                    rust = "rs",
                    teal = "tl",
                    r = "r",
                    typescript = "ts",
                },
                -- Map of treesitter language to formatters to use
                -- (defaults to the value from formatters_by_ft)
                lang_to_formatters = {},
            },

            vim.api.nvim_create_user_command("Format", function(args)
                local range = nil
                if args.count ~= -1 then
                    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
                    range = {
                        start = { args.line1, 0 },
                        ["end"] = { args.line2, end_line:len() },
                    }
                end
                require("conform").format({ async = true, lsp_fallback = true, range = range })
            end, { range = true }),
        }

        vim.api.nvim_create_user_command("FormatDisable", function(args)
            if args.bang then
                -- FormatDisable! will disable formatting just for this buffer
                vim.b.disable_autoformat = true
            else
                vim.g.disable_autoformat = true
            end
        end, {
            desc = "Disable autoformat-on-save",
            bang = true,
        })
        vim.api.nvim_create_user_command("FormatEnable", function()
            vim.b.disable_autoformat = false
            vim.g.disable_autoformat = false
        end, {
            desc = "Re-enable autoformat-on-save",
        })
    end,
}
