-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  config = function()
    -- Configuration Neo-tree avec recette officielle auto-close
    require("neo-tree").setup({
      filesystem = {
        follow_current_file = { enabled = true, leave_dirs_open = false },
        hijack_netrw_behavior = "open_current",
        window = {
          mappings = {
            ['.'] = 'set_root',
          },
        },
      },
      event_handlers = {
        {
          event = "file_open_requested",
          handler = function()
            -- auto close
            vim.cmd("Neotree close")
          end
        },
      }
    })

    -- Mappings pour Neo-tree
    vim.keymap.set('n', '<leader>.', function()
      if vim.bo.filetype == "neo-tree" then
        vim.cmd('Neotree close')
      else
        local current_file = vim.fn.expand('%:p')
        if current_file ~= '' then
          local current_dir = vim.fn.fnamemodify(current_file, ':h')
          vim.cmd('Neotree dir=' .. current_dir .. ' reveal')
        else
          vim.cmd('Neotree reveal')
        end
      end
    end, { desc = "Toggle/Reveal file tree at current dir", silent = true })
    
    vim.keymap.set('n', '<leader>/', ':Neotree reveal<CR>', { desc = "Reveal current file in tree", silent = true })
    vim.keymap.set('n', '<leader>ft', ':Neotree toggle<CR>', { desc = '[F]ile [T]ree toggle' })
  end
}
