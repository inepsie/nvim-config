return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    config = function()
      -- Set highlight groups first
      vim.api.nvim_set_hl(0, 'IblIndent', { fg = '#504945' })
      vim.api.nvim_set_hl(0, 'IblScope', { fg = '#ff69b4' })
      
      require('ibl').setup({
        indent = {
          char = '│',
          highlight = { 'IblIndent' },
        },
        scope = {
          highlight = { 'IblScope' },
          show_start = false,
          show_end = false,
        },
      })
    end,
  },
}
