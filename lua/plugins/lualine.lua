return {
  -- Set lualine as statusline
  'nvim-lualine/lualine.nvim',
  -- See `:help lualine.txt`
  event = 'VeryLazy',
  config = function()
    local lualine = require 'lualine'
    local function code_companion()
      if package.loaded['code_companion'] then
        return require 'lualine-custom'
      end
      return ''
    end

    local function show_macro_recording()
      local recording_register = vim.fn.reg_recording()
      if recording_register == '' then
        return ''
      else
        return 'Recording @' .. recording_register
      end
    end

    -- -- Define a function to check that ollama is installed and working
    -- local function get_condition()
    --   return package.loaded['ollama'] and require('ollama').status ~= nil
    -- end
    --
    -- -- Define a function to check the status and return the corresponding icon
    -- local function get_status_icon()
    --   local status = require('ollama').status()
    --
    --   if status == 'IDLE' then
    --     return '󱙺' -- nf-md-robot-outline
    --   elseif status == 'WORKING' then
    --     return '󰚩' -- nf-md-robot
    --   end
    -- end

    local function jupyter_line()
      if package.loaded['jupyter_connection'] then
        local jupyter_connection = require 'jupyter_connection'
        local connection_file_basename = jupyter_connection.get_connection_file_basename()
        if connection_file_basename then
          return 'Jupyter: ' .. connection_file_basename
        end
      end
      return ''
    end

    local opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_b = {
          'branch',
          'diff',
          'diagnostics',
          {
            'macro-recording',
            fmt = show_macro_recording,
          },
        },
        lualine_x = {
          { jupyter_line, color = { fg = '#f5e0dc' } },
          code_companion,
          -- 'aerial',
          -- get_status_icon,
          -- get_condition,
          'g:flutter_tools_decorations.app_version',
          'g:flutter_tools_decorations.device',
          'encoding',
          'fileformat',
          'filetype',
        },
      },
    }
    lualine.setup(opts)

    vim.api.nvim_create_autocmd('RecordingEnter', {
      callback = function()
        lualine.refresh {
          place = { 'statusline' },
        }
      end,
    })

    vim.api.nvim_create_autocmd('RecordingLeave', {
      callback = function()
        -- This is going to seem really weird!
        -- Instead of just calling refresh we need to wait a moment because of the nature of
        -- `vim.fn.reg_recording`. If we tell lualine to refresh right now it actually will
        -- still show a recording occuring because `vim.fn.reg_recording` hasn't emptied yet.
        -- So what we need to do is wait a tiny amount of time (in this instance 50 ms) to
        -- ensure `vim.fn.reg_recording` is purged before asking lualine to refresh.
        local timer = vim.loop.new_timer()
        timer:start(
          50,
          0,
          vim.schedule_wrap(function()
            lualine.refresh {
              place = { 'statusline' },
            }
          end)
        )
      end,
    })
  end,
}
