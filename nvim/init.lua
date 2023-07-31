vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
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
  'tpope/vim-commentary',
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
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
        local cmp = require 'cmp'
        cmp.setup { ---@diagnostic disable-line: missing-fields
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
    'L3MON4D3/LuaSnip',
    version = '2.*',
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup { ---@diagnostic disable-line: missing-fields
        ensure_installed = {'c', 'cpp', 'lua', 'python', 'vim'},
        highlight = {
          enable = true,
          disable = function(_, buf) -- disable on large files
              local max_filesize = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                  return true
              end
          end,
        },
      }
    end,
  },
  {
    'williamboman/mason.nvim',
    dependencies = 'williamboman/mason-lspconfig.nvim',
    build = ':MasonUpdate', -- :MasonUpdate updates registry contents
    config = function()
      require('mason').setup {ui = {border = 'single'}}
      require('mason-lspconfig').setup {
        ensure_installed = {'clangd', 'lua_ls', 'pyright'},
      }
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
    },
    tag = '0.1.2',
    config = function()
      require('telescope').load_extension('fzf')
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<Leader>fa', builtin.builtin)
      vim.keymap.set('n', '<Leader>ff', builtin.find_files)
      vim.keymap.set('n', '<Leader>fg', builtin.live_grep)
      vim.keymap.set('n', '<Leader>fb', builtin.buffers)
      vim.keymap.set('n', '<Leader>fh', builtin.help_tags)
      require('telescope').setup {defaults = {preview = {treesitter = false}}} -- slow treesitter can cause huge previewer lag
    end,
  },
  {'nvim-tree/nvim-web-devicons', lazy = true},
  {
    'nvim-lualine/lualine.nvim',
    init = function() vim.o.showmode = false end,
    opts = {
      options = {theme = 'base16'},
      sections = {lualine_c = {{'filename', path = 1}}}, -- show relative path
      tabline = {lualine_a = {'buffers'}},
      extensions = {'lazy', 'man', 'quickfix'},
    },
  },
  'folke/neodev.nvim',

  -- colorschemes
  {
    'RRethy/nvim-base16',
    lazy = false,
    priority = 1000,
    config = function()
      require('base16-colorscheme').setup('tomorrow-night', {telescope_borders = true})
      vim.cmd.colorscheme 'base16-tomorrow-night'
    end,
  },
  {'ellisonleao/gruvbox.nvim', lazy = true},
}, {ui = {border = 'single'}})

vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('B16TomorrowNight', {clear = true}),
    pattern = 'base16-tomorrow-night',
    callback = function()
        vim.api.nvim_set_hl(0, 'Identifier', {})
        vim.api.nvim_set_hl(0, 'TSVariable', {})
        vim.api.nvim_set_hl(0, 'TSError', {})
    end,
})
require('lspconfig.ui.windows').default_options.border = 'single'
vim.diagnostic.config {float = {border = 'single'}}
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {border = 'single', title = 'hover'})
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {border = 'single', title = 'signature'})

require('neodev').setup {} -- needs to be before lspconfig
local lspconfig = require 'lspconfig'
local capabilities = require('cmp_nvim_lsp').default_capabilities()
if true then
  lspconfig.clangd.setup {capabilities = capabilities}
else
  lspconfig.ccls.setup {cache = {directory = '/tmp/ccls'}, capabilities = capabilities}
end
lspconfig.pyright.setup {capabilities = capabilities}
lspconfig.lua_ls.setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      completion = {callSnippet = 'Replace'},
      telemetry = {enable = false},
      workspace = {checkThirdParty = false},
    },
  },
}

vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist)

local lsp_cfg_augroup = vim.api.nvim_create_augroup('UserLspConfig', {clear = true})
vim.api.nvim_create_autocmd('LspAttach', {group = lsp_cfg_augroup,
  callback = function()
    local function bufmap(mode, lhs, rhs)
      vim.keymap.set(mode, lhs, rhs, {buffer = true})
    end

    bufmap('n', 'gd', vim.lsp.buf.definition)
    bufmap('n', 'gD', vim.lsp.buf.declaration)
    bufmap('n', 'K', vim.lsp.buf.hover)
    bufmap('n', '<Leader>k', vim.lsp.buf.signature_help)
    bufmap('n', '<Leader>i', vim.lsp.buf.implementation)
    bufmap('n', '<Leader>t', vim.lsp.buf.type_definition)
    bufmap('n', '<Leader>rn', vim.lsp.buf.rename)
    bufmap({ 'n', 'v' }, '<Leader>ca', vim.lsp.buf.code_action)
    bufmap('n', 'gr', vim.lsp.buf.references)
  end,
})
vim.api.nvim_create_autocmd('FileType', {group = lsp_cfg_augroup, pattern = {'c', 'cpp', 'lua', 'python'},
  callback = function()
    vim.opt_local.number = true
    vim.opt_local.signcolumn = 'number'
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

vim.o.background = 'dark'
vim.o.termguicolors = true
vim.keymap.set('n', '<Leader>n', '<Cmd>nohlsearch<CR>', {silent = true})
vim.keymap.set('n', '<Leader>w', '<Cmd>update<CR>', {silent = true})
vim.keymap.set('n', '<C-p>', '<Cmd>bp<CR>', {silent = true})
vim.keymap.set('n', '<C-n>', '<Cmd>bn<CR>', {silent = true})

local misc_augroup = vim.api.nvim_create_augroup('misc', {clear = true})
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
vim.api.nvim_create_autocmd('FileType', {group = misc_augroup, pattern = {'c', 'cpp'}, callback = function() vim.bo.commentstring = '//%s' end})
