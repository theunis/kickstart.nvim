local config = function()
  require("nvim-treesitter.configs").setup({

    ensure_installed = {
      "bash",
      "c",
      "html",
      "json",
      "jsonc",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "query",
      "regex",
      "vim",
      "vimdoc",
      "python",
      "yaml",
      "r",
    },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    -- indent = { enable = true },
    indent = {
      enable = true,
      disable = { "dart" },
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
    include_surrounding_whitespace = true,
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["aa"] = { query = "@parameter.outer", desc = "Select outer part of argument" },
          ["ia"] = { query = "@parameter.inner", desc = "Select inner part of argument" },
          ["af"] = { query = "@function.outer", desc = "Select outer part of a function region" },
          ["if"] = { query = "@function.inner", desc = "Select inner part of a function region" },
          ["ac"] = { query = "@class.outer", desc = "Select outer part of a class region" },
          ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
          ["ab"] = { query = "@block.outer", desc = "Select outer part of a code block" },
          ["ib"] = { query = "@block.inner", desc = "Select inner part of a code block" },
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.inner",
          -- ['<C-n>'] = '@class.outer',
          ["]a"] = "@attribute.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.inner",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.inner",
          -- ['<C-p>'] = '@class.outer',
          ["[a"] = "@attribute.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.inner",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>a"] = "@parameter.inner",
          ["<leader>b"] = "@block.outer",
        },
        swap_previous = {
          ["<leader>A"] = "@parameter.inner",
          ["<leader>B"] = "@block.outer",
        },
      },
    },
  })

  local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

  -- Repeat movement with ; and ,
  -- ensure ; goes forward and , goes backward regardless of the last direction
  vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
  vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

  -- vim way: ; goes to the direction you were moving.
  -- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
  -- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

  -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
  vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
  vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
  vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
  vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
end

return {
  -- Highlight, edit, and navigate code
  "nvim-treesitter/nvim-treesitter",
  config = config,
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    {
      "chrisgrieser/nvim-various-textobjs",
      event = "UIEnter",
      opts = { useDefaultKeymaps = true },
    },
    "nvim-treesitter/nvim-treesitter-context",
  },
  build = ":TSUpdate",
}
