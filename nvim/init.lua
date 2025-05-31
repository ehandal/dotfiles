vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.loaded_python3_provider = 0 -- disable Python plugin support to speed up startup

-- Install plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

local function base16_mods()
  vim.api.nvim_set_hl(0, 'Identifier', {})
  vim.api.nvim_set_hl(0, 'TSVariable', {})
  vim.api.nvim_set_hl(0, 'TSError', {})
end

vim.o.winborder = 'rounded'

require('lazy').setup({
  'christoomey/vim-tmux-navigator',
  {'godlygeek/tabular', cmd = 'Tabularize'},
  'tpope/vim-fugitive',
  'tpope/vim-repeat',
  'tpope/vim-surround',
  'tpope/vim-unimpaired',

  'neovim/nvim-lspconfig',

  {
    'saghen/blink.cmp',
    version = '1.*',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {keymap = {preset = 'enter'}},
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup { ---@diagnostic disable-line: missing-fields
        ensure_installed = {'c', 'cpp', 'lua', 'python', 'vim'},
        highlight = {enable = true},
        indent = {enable = true},
      }
    end,
  },
  {
    'williamboman/mason.nvim',
    dependencies = 'williamboman/mason-lspconfig.nvim',
    build = ':MasonUpdate', -- :MasonUpdate updates registry contents
    config = function()
      require('mason').setup {ui = {border = vim.o.winborder}}
      require('mason-lspconfig').setup { ---@diagnostic disable-line: missing-fields
        ensure_installed = {'clangd', 'lua_ls', 'pyright', 'ruff'},
      }
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup {defaults = {border = false}} -- workaround for winborder support https://github.com/nvim-telescope/telescope.nvim/issues/3436
      telescope.load_extension('fzf')
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<Leader>fa', builtin.builtin)
      vim.keymap.set('n', '<Leader>ff', builtin.find_files)
      vim.keymap.set('n', '<Leader>fg', builtin.live_grep)
      vim.keymap.set('n', '<Leader>fb', builtin.buffers)
      vim.keymap.set('n', '<Leader>fh', builtin.help_tags)
    end,
  },
  {'nvim-tree/nvim-web-devicons', lazy = true},
  {
    'nvim-lualine/lualine.nvim',
    init = function() vim.o.showmode = false end,
    opts = {
      options = {
        -- separators for better matching tmux catppuccin
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
      },
      sections = {
        lualine_b = {
          'branch',
          'diff',
          {'diagnostics', sections = {'error', 'warn', 'info'}}, --exclude hints
        },
        lualine_c = {{'filename', path = 1}}, -- show relative path
      },
      tabline = {lualine_a = {'buffers'}},
      extensions = {'lazy', 'man', 'quickfix'},
    },
  },
  {'folke/lazydev.nvim', ft = 'lua', opts = {library = {path = '${3rd}/luv/library', words = {'vim%.uv'}}},
  },
  {'stevearc/dressing.nvim', opts = {}},
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons'},
    opts = {},
  },

  -- colorschemes
  {
    'RRethy/nvim-base16',
    lazy = true,
    config = function()
      require('base16-colorscheme').setup('tomorrow-night', {telescope_borders = true})
      -- vim.cmd.colorscheme 'base16_mods-tomorrow-night'
      -- base16_mods()
    end,
  },
  {'ellisonleao/gruvbox.nvim', lazy = true},
  {
    'catppuccin/nvim', name = 'catppuccin', priority = 1000,
    opts = {
      custom_highlights = function(colors)
        return {
          Pmenu = {bg = colors.none},
          BlinkCmpMenu = { fg = colors.text, bg = colors.none},
          BlinkCmpMenuBorder = { fg = colors.overlay0, bg = colors.none},
          BlinkCmpMenuSelection = { bg = colors.surface0 },
          BlinkCmpLabel = { fg = colors.text },
          BlinkCmpDocBorder = { fg = colors.overlay0, bg = colors.none},
          BlinkCmpDoc = { fg = colors.text, bg = colors.none},
        }
      end,
      integrations = {
        blink_cmp = true,
        mason = true,
        native_lsp = {underlines = {
          errors = {'undercurl'},
          hints = {'undercurl'},
          warnings = {'undercurl'},
          information = {'undercurl'},
          ok = {'undercurl'},
        }},
      },
    },
  },
}, {ui = {border = vim.o.winborder}}) ---@diagnostic disable-line: missing-fields

vim.cmd.colorscheme 'catppuccin'

vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('B16TomorrowNight', {}),
    pattern = 'base16-*',
    callback = base16_mods,
})

local lsp_configs = { ---@type table<string, vim.lsp.Config>
  clangd = {},
  pyright = {
    settings = {
      pyright = {disableOrganizeImports = true}, -- using Ruff's import organizer
    },
  },
  ruff = {
    init_options = {settings = {showSyntaxErrors = false}}, -- only get syntax errors from Pyright
    on_attach = function(client, _)
      if client.name == 'ruff' then
        client.server_capabilities.hoverProvider = false -- disable hover in favor of Pyright
      end
    end,
  },
  lua_ls = {
    settings = {
      Lua = {
        completion = {callSnippet = 'Replace'},
        telemetry = {enable = false},
        workspace = {checkThirdParty = false},
      },
    },
  },
}
for server, config in pairs(lsp_configs) do
  vim.lsp.enable(server)
  vim.lsp.config(server, config)
end

vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldlevel = 99

vim.keymap.set('n', '<Leader>q', require('telescope.builtin').diagnostics)

local lsp_cfg_augroup = vim.api.nvim_create_augroup('UserLspConfig', {})
vim.api.nvim_create_autocmd('LspAttach', {group = lsp_cfg_augroup,
  callback = function(ev)
    local function bufmap(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, {buffer = ev.buf, desc = 'LSP: ' .. desc})
    end

    local telesope_builtin = require('telescope.builtin')
    bufmap('n', 'gd', telesope_builtin.lsp_definitions, 'Go to definition')
    bufmap('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
    bufmap('n', '<Leader>k', vim.lsp.buf.signature_help, 'Signature help')
    bufmap('n', 'gri', telesope_builtin.lsp_implementations, 'Go to implementation')
    bufmap('n', 'grt', telesope_builtin.lsp_type_definitions, 'Type definition')
    bufmap('n', 'gO', telesope_builtin.lsp_document_symbols, 'Document symbols')
    bufmap('n', 'gS', telesope_builtin.lsp_dynamic_workspace_symbols, 'Workspace symbols')
    bufmap('n', 'grr', telesope_builtin.lsp_references, 'Go to references')
    bufmap({ 'n', 'x' }, 'grf', vim.lsp.buf.format, 'Code format')

    -- Prefer LSP folding if client supports it
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client ~= nil and client:supports_method('textDocument/foldingRange') then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end

    local virtual_lines_opts = { ---@type vim.diagnostic.Opts.VirtualLines
      current_line = true,
      format = function(diagnostic)
        if diagnostic.severity > vim.diagnostic.severity.INFO then
          return nil
        end
        if diagnostic.code then
          return string.format('%s [%s]', diagnostic.message, diagnostic.code)
        end
        return diagnostic.message
      end,
    }
    vim.diagnostic.config {
      virtual_lines = virtual_lines_opts,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '',
        },
      },
      float = {source = 'if_many'},
      severity_sort = true,
      jump = {severity = {min = vim.diagnostic.severity.INFO}},
    }

    bufmap('n', 'gK', function()
      if vim.diagnostic.config().virtual_lines then
        vim.diagnostic.config({virtual_lines = false})
      else
        vim.diagnostic.config({virtual_lines = virtual_lines_opts})
      end
    end, 'Toggle diagnostic virtual_lines')
  end,
})

-- general settings
vim.o.virtualedit = 'block'
vim.o.wildmode = 'longest:full,full'
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.undofile = true
vim.o.wrap = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.list = true
vim.opt.listchars = {tab = '» ', trail = '·', nbsp = '␣'}

vim.o.background = 'dark'
vim.o.termguicolors = true
vim.keymap.set('n', '<Leader>n', '<Cmd>nohlsearch<CR>', {silent = true})
vim.keymap.set('n', '<Leader>w', '<Cmd>update<CR>', {silent = true})
vim.keymap.set('n', '<C-p>', '<Cmd>bp<CR>', {silent = true})
vim.keymap.set('n', '<C-n>', '<Cmd>bn<CR>', {silent = true})

local misc_augroup = vim.api.nvim_create_augroup('misc', {})
vim.api.nvim_create_autocmd('BufReadPost', {group = misc_augroup,
  callback = function()
    vim.cmd [[if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif]] -- :help last-position-jump
  end,
})
vim.api.nvim_create_autocmd('FileType', {group = misc_augroup, pattern = 'lua',
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
  end,
})
vim.api.nvim_create_autocmd('FileType', {group = misc_augroup, pattern = {'c', 'cpp'},
  callback = function() vim.bo.commentstring = '// %s' end,
})
vim.api.nvim_create_autocmd('FileType', {group = misc_augroup, pattern = {'c', 'cpp', 'lua', 'python'},
  callback = function()
    vim.wo.number = true
    vim.wo.relativenumber = true
    vim.wo.signcolumn = 'number'
  end,
})
