return {
  '3rd/image.nvim',
  tag = 'v1.1.0',
  -- image nvim options table. Pass to `require('image').setup`
  opts = {
    backend = 'kitty', -- Kitty will provide the best experience, but you need a compatible terminal
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = false,
        download_remote_images = true,
        only_render_image_at_cursor = false,
        filetypes = { 'markdown', 'vimwiki', 'quarto' }, -- markdown extensions (ie. quarto) can go here
      },
    }, -- do whatever you want with image.nvim's integrations
    max_width = 200, -- tweak to preference
    max_height = 24, -- ^
    max_height_window_percentage = math.huge, -- this is necessary for a good experience
    max_width_window_percentage = math.huge,
    window_overlap_clear_enabled = true,
    window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
  },
}
