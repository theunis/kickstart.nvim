local M = {}
local command = vim.api.nvim_create_user_command

---for python, type `df.columns` to print names of columns
---in REPL, and then type `yi]` to yank the inner part of the list,
---then switch back to the python file buffer and then call this function
---
---for R, type `colnames(df)` to print names of columns
---in REPL, and then type `yap` to yank the whole region
---then switch back to the R file buffer and then call this function
---
---Currently, the names of columns cannot contain special characters and white characters
---due to how the processing is handled
---@param df string | nil @the data frame name for yanked columns
---@param use_customized_parser boolean | nil @whether use customized parser (impl by myself)
function M.create_tags_for_yanked_columns(df, use_customized_parser)
  local ft = vim.bo.filetype
  if not (ft == 'r' or ft == 'python' or ft == 'rmd' or ft == 'quarto') then
    return
  end

  if ft == 'quarto' then
    ft = 'python'
  end

  local bufid = vim.api.nvim_get_current_buf()

  local filepath_head = vim.fn.expand '%:h'
  local filename_tail = vim.fn.expand '%:t'

  local filename_without_extension = filename_tail:match '(.+)%..+'
  local newfile = filepath_head .. '/.tags_' .. filename_without_extension

  vim.cmd.edit(newfile) -- open a file whose name is .tags_$current_file
  local newtag_bufid = vim.api.nvim_get_current_buf()

  vim.cmd [[normal! Go]] -- go to the end of the buffer and create a new line
  vim.cmd [[normal! "0p]] -- paste the content just yanked into this buffer

  -- flag ge means: replace every occurrences in every line, and
  -- when there are no matched patterns in the document, do not issue an error
  if ft == 'python' then
    vim.cmd [[%s/,//ge]] -- remove every occurrence of ,
  else
    vim.cmd [[g/^r\$>.\+$/d]] -- remove line starts with r$> which usually is the REPL prompt
    vim.cmd [[%s/\[\d\+\]//ge]] -- remove every occurrence of [xxx], where xxx is a number
  end
  vim.cmd [[%s/\s\+/\r/ge]] -- break multiple spaces into a new line
  vim.cmd [[g/^$/d]] -- remove any blank lines

  if use_customized_parser then
    M.generate_code_for_tagging_with_customized_parser(ft, df)
  else
    M.generate_code_for_tagging_without_customized_parser(ft, df)
  end

  vim.cmd.sort 'u' -- remove duplicated entry
  vim.cmd.write() -- save current buffer

  local newfile_shell_escaped = vim.fn.shellescape(newfile)
  -- replace . by \. such that it is recognizable by vim regex
  -- replace / by \/
  local newfile_vim_regexed = newfile_shell_escaped:gsub('%.', [[\.]])
  newfile_vim_regexed = newfile_vim_regexed:gsub('/', [[\/]])
  newfile_vim_regexed = newfile_vim_regexed:sub(2, -2) -- remove the first and last chars, i.e. ' and '

  vim.cmd.edit '.tags_columns' -- open the file where ctags stores the tags
  local tag_bufid = vim.api.nvim_get_current_buf()

  vim.cmd.global { [[/^[[:alnum:]_.]\+\s\+]] .. newfile_vim_regexed .. [[\s.\+/d]] }
  -- remove existed entries for the current newtag file
  vim.cmd.write()

  if ft == 'rmd' then
    ft = 'r'
  end

  vim.cmd['!'] {
    'ctags',
    '-a',
    '-f',
    '.tags_columns',
    [[--fields='*']],
    '--language-force=' .. ft,
    newfile_shell_escaped,
  }
  -- let ctags tag current newtag file

  vim.api.nvim_win_set_buf(0, bufid)
  vim.cmd.bdelete { count = newtag_bufid, bang = true } -- delete the buffer created for tagging
  vim.cmd.bdelete { count = tag_bufid, bang = true } -- delete the ctags tag buffer
  vim.cmd.nohlsearch() -- remove matched pattern's highlight
end

function M.generate_code_for_tagging_without_customized_parser(ft, df)
  if ft == 'python' then
    vim.cmd [[%s/'//ge]] -- remove '
    vim.cmd.global { [[/^\w\+$/normal!]], [[A="]] .. df .. [["]] } -- show which dataframe this column belongs to
    -- use " instead of ', for incremental tagging, since ' will be removed.
  else
    vim.cmd [[%s/"//ge]]
    vim.cmd.global { [[/^[[:alnum:]_.]\+$/normal!]], [[A=']] .. df .. [[']] }
    -- r use " to quote strings, in contrary to python
  end
end

function M.generate_code_for_tagging_with_customized_parser(ft, df)
  if df == nil then
    df = 'df'
  end

  if ft == 'python' then
    vim.cmd [[g/^'.\+'$/normal! A]="nameattr"]]
    vim.cmd.global { [[/^'.\+"$/normal!]], 'I' .. df .. '[' }
  else
    vim.cmd [=[g/^".\+"$/normal! A]]<-'nameattr']=]
    vim.cmd.global { [[/^".\+'$/normal!]], 'I' .. df .. '[[' }
  end
end

command('TagYankedColumns', function(options)
  local df = options.args
  M.create_tags_for_yanked_columns(df, true)
end, {
  nargs = '?',
})

command('TagYankedColumnsVanilla', function(options)
  local df = options.args
  M.create_tags_for_yanked_columns(df, false)
end, {
  nargs = '?',
})

