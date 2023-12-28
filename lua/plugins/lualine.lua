return {
  -- Set lualine as statusline
  'nvim-lualine/lualine.nvim',
  -- See `:help lualine.txt`
  lazy=false,
  opts = {
    options = {
      icons_enabled = true,
      theme = 'auto',
      component_separators = '|',
      section_separators = '',
    },
    sections = {
      lualine_x = { 'aerial', 'g:flutter_tools_decorations.app_version', 'g:flutter_tools_decorations.device', 'encoding', 'fileformat', 'filetype' },
    },
  },
}
