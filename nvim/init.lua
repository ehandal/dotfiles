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

local function has_words_before()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local function base16_mods()
  vim.api.nvim_set_hl(0, 'Identifier', {})
  vim.api.nvim_set_hl(0, 'TSVariable', {})
  vim.api.nvim_set_hl(0, 'TSError', {})
end

vim.o.winborder = 'rounded'

require('lazy').setup({
  'christoomey/vim-tmux-navigator',
  {
    'edkolev/tmuxline.vim',
    init = function()
      vim.g.tmuxline_powerline_separators = 1
      vim.g.tmuxline_preset = {
        a       = '#S',
        win     = {'#I', '#W'},
        cwin    = {'#I', '#W'},
        z       = '#H',
        options = {['status-justify'] = 'left'},
      }
    end,
    cmd = 'Tmuxline',
  },
  {'godlygeek/tabular', cmd = 'Tabularize'},
  'tpope/vim-fugitive',
  'tpope/vim-repeat',
  'tpope/vim-surround',
  'tpope/vim-unimpaired',

  'neovim/nvim-lspconfig',
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-path',

      {'L3MON4D3/LuaSnip', version = '2.*', build = 'make install_jsregexp'},
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
        local cmp = require 'cmp'
        cmp.setup {
            snippet = {expand = function(args) require('luasnip').lsp_expand(args.body) end},
            window = {completion = cmp.config.window.bordered(), documentation = cmp.config.window.bordered()},
            mapping = cmp.mapping.preset.insert {
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm {select = true},
                ['<Tab>'] = cmp.mapping(function(fallback)
                  local luasnip = require 'luasnip'
                  if cmp.visible() then
                    cmp.select_next_item()
                  -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
                  -- that way you will only jump inside the snippet region
                  elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                  elseif has_words_before() then
                    cmp.complete()
                  else
                    fallback()
                  end
                end, {'i', 's'}),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                  local luasnip = require 'luasnip'
                  if cmp.visible() then
                    cmp.select_prev_item()
                  elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                  else
                    fallback()
                  end
                end, {'i', 's'}),
            },
            sources = cmp.config.sources({
                {name = 'nvim_lsp'},
                {name = 'nvim_lsp_signature_help'},
                {name = 'luasnip'},
            }, {
                {name = 'path'},
                {name = 'buffer'},
            }),
        }
    end,
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
      sections = {lualine_c = {{'filename', path = 1}}}, -- show relative path
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
      integrations = {
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

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lsp_configs = { ---@type table<string, vim.lsp.Config>
  clangd = {capabilities = capabilities},
  pyright = {
    capabilities = capabilities,
    settings = {
      pyright = {disableOrganizeImports = true}, -- using Ruff's import organizer
    },
  },
  ruff = {
    capabilities = capabilities,
    init_options = {settings = {showSyntaxErrors = false}}, -- only get syntax errors from Pyright
    on_attach = function(client, _)
      if client.name == 'ruff' then
        client.server_capabilities.hoverProvider = false -- disable hover in favor of Pyright
      end
    end,
  },
  lua_ls = {
    capabilities = capabilities,
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
