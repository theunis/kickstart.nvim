local on_attach = require("util.lsp").on_attach
local diagnostic_signs = require("util.lsp").diagnostic_signs

local config = function()
  require("neoconf").setup({})
  local cmp_nvim_lsp = require("cmp_nvim_lsp")
  local lspconfig = require("lspconfig")

  for type, icon in pairs(diagnostic_signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend("force", capabilities, cmp_nvim_lsp.default_capabilities())
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  -- local capabilities = cmp_nvim_lsp.default_capabilities()
  --
  -- capabilities.textDocument.foldingRange = {
  --   dynamicRegistration = false,
  --   lineFoldingOnly = true,
  -- }

  -- lua
  lspconfig.lua_ls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    settings = { -- custom settings for lua
      Lua = {
        -- make the language server recognize "vim" global
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          -- make language server aware of runtime files
          library = {
            -- THIS MAKES IT BREAK in 0.10.0:
            -- [vim.fn.expand '$VIMRUNTIME/lua'] = true,
            -- [vim.fn.stdpath 'config' .. '/lua'] = true,
          },
        },
      },
    },
  })

  -- also needs:
  -- $home/.config/marksman/config.toml :
  -- [core]
  -- markdown.file_extensions = ["md", "markdown", "qmd"]
  lspconfig.marksman.setup({
    capabilities = capabilities,
    filetypes = { "markdown", "quarto" },
    root_dir = lspconfig.util.root_pattern(".git", ".marksman.toml", "_quarto.yml"),
  })

  local function get_quarto_resource_path()
    local function strsplit(s, delimiter)
      local result = {}
      for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
      end
      return result
    end

    local f = assert(io.popen("quarto --paths", "r"))
    local s = assert(f:read("*a"))
    f:close()
    return strsplit(s, "\n")[2]
  end

  local lua_library_files = vim.api.nvim_get_runtime_file("", true)
  local lua_plugin_paths = {}
  local resource_path = get_quarto_resource_path()
  if resource_path == nil then
    vim.notify_once("quarto not found, lua library files not loaded")
  else
    table.insert(lua_library_files, resource_path .. "/lua-types")
    table.insert(lua_plugin_paths, resource_path .. "/lua-plugin/plugin.lua")
  end

  -- python
  lspconfig.pyright.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      pyright = {
        -- Using Ruff's import organizer
        disableOrganizeImports = false,
        disableTaggedHints = false,
        disableLanguageServices = false,
        analysis = {
          useLibraryCodeForTypes = false,
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          autoImportCompletions = true,
        },
      },
      python = {
        analysis = {
          -- Ignore all files for analysis to exclusively use Ruff for linting
          ignore = { "*" },
        },
      },
    },
    before_init = function(_, config)
      local Path = require("plenary.path")
      local venv = Path:new((config.root_dir:gsub("/", Path.path.sep)), "venv")
      local dotvenv = Path:new((config.root_dir:gsub("/", Path.path.sep)), ".venv")
      if venv:joinpath("bin"):is_dir() then
        config.settings.python.pythonPath = tostring(venv:joinpath("bin", "python"))
      elseif dotvenv:joinpath("bin"):is_dir() then
        config.settings.python.pythonPath = tostring(dotvenv:joinpath("bin", "python"))
      else
        config.settings.python.pythonPath = tostring(venv:joinpath("Scripts", "python"))
      end
    end,
    root_dir = function(fname)
      return lspconfig.util.root_pattern(".git", "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt")(fname)
        or lspconfig.util.path.dirname(fname)
    end,
  })

  -- require("lspconfig").ruff.setup({
  -- init_options = {
  --   settings = {
  --     -- Ruff language server settings go here
  --   },
  -- },
  -- })

  lspconfig.jsonls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
  })

  -- dart
  lspconfig.dartls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
  })

  local luacheck = require("efmls-configs.linters.luacheck")
  local stylua = require("efmls-configs.formatters.stylua")
  local flake8 = require("efmls-configs.linters.flake8")
  local black = require("efmls-configs.formatters.black")
  -- local darker = require("efmls-configs.formatters.darker")
  local dartanalyzer = require("linters.dart_analyze")
  local dartfmt = require("efmls-configs.formatters.dartfmt")
  -- configure efm server
  lspconfig.efm.setup({
    filetypes = {
      "lua",
      "python",
      "dart",
    },
    init_options = {
      documentFormatting = true,
      documentRangeFormatting = true,
      hover = true,
      documentSymbol = true,
      codeAction = true,
      completion = true,
    },
    settings = {
      languages = {
        lua = { luacheck, stylua },
        python = { flake8, black },
        dart = { dartanalyzer, dartfmt },
      },
    },
  })
end

return {
  "neovim/nvim-lspconfig",
  config = config,
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "LspInfo", "LspInstall", "LspUninstall" },
  dependencies = {
    "windwp/nvim-autopairs",
    "williamboman/mason.nvim",
    "creativenull/efmls-configs-nvim",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-nvim-lsp",
    { "j-hui/fidget.nvim", opts = {} },
  },
}
