vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.loaded_python3_provider = 0 -- disable Python plugin support to speed up startup

-- Install plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath})
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      {'Failed to clone lazy.nvim:\n', 'ErrorMsg'},
      {out, 'WarningMsg'},
      {'\nPress any key to exit...'},
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local function base16_mods()
  vim.api.nvim_set_hl(0, 'Identifier', {})
  vim.api.nvim_set_hl(0, 'TSVariable', {})
  vim.api.nvim_set_hl(0, 'TSError', {})
end

local function set_number_signcolumn()
  vim.wo.number = true
  vim.wo.signcolumn = 'yes'
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
        indent = {
          enable = true,
          disable = function(lang, buf)
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
    'mason-org/mason.nvim',
    dependencies = 'mason-org/mason-lspconfig.nvim',
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
      telescope.load_extension('fzf')
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<Leader>fa', builtin.builtin)
      vim.keymap.set('n', '<Leader>ff', builtin.find_files)
      vim.keymap.set('n', '<Leader>fg', builtin.live_grep)
      vim.keymap.set('n', '<Leader>fb', builtin.buffers)
      vim.keymap.set('n', '<Leader>fh', builtin.help_tags)
      vim.keymap.set('n', '<Leader>fm', builtin.man_pages)
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
  {'folke/lazydev.nvim', ft = 'lua', opts = {library = {path = '${3rd}/luv/library', words = {'vim%.uv'}}}},
  {'stevearc/dressing.nvim', opts = {}},
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons'},
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {sign = {enabled = false}},
  },
  {
    'lewis6991/gitsigns.nvim',
    ---@module 'gitsigns'
    ---@type Gitsigns.Config
    opts = { ---@diagnostic disable-line: missing-fields
      signs = {add = {text = '+'}}, ---@diagnostic disable-line: missing-fields
      signs_staged = {add = {text = '+'}}, ---@diagnostic disable-line: missing-fields
      on_attach = function(bufnr)
        set_number_signcolumn()
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({']c', bang = true})
          else
            gitsigns.nav_hunk('next', {target = 'all'})
          end
        end)

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({'[c', bang = true})
          else
            gitsigns.nav_hunk('prev', {target = 'all'})
          end
        end)

        -- Actions
        map('n', '<leader>hs', gitsigns.stage_hunk)
        map('n', '<leader>hr', gitsigns.reset_hunk)

        map('v', '<leader>hs', function()
          gitsigns.stage_hunk({vim.fn.line('.'), vim.fn.line('v')})
        end)

        map('v', '<leader>hr', function()
          gitsigns.reset_hunk({vim.fn.line('.'), vim.fn.line('v')})
        end)

        map('n', '<leader>hS', gitsigns.stage_buffer)
        map('n', '<leader>hR', gitsigns.reset_buffer)
        map('n', '<leader>hp', gitsigns.preview_hunk)
        map('n', '<leader>hi', gitsigns.preview_hunk_inline)

        map('n', '<leader>hb', function()
          gitsigns.blame_line({full = true})
        end)

        map('n', '<leader>hd', gitsigns.diffthis)

        map('n', '<leader>hD', function()
          gitsigns.diffthis('~')
        end)

        map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
        map('n', '<leader>hq', gitsigns.setqflist)

        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
        map('n', '<leader>tw', gitsigns.toggle_word_diff)

        map({'o', 'x'}, 'ih', gitsigns.select_hunk) -- Text object
      end
    },
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
    ---@module 'catppuccin'
    ---@type CatppuccinOptions
    opts = {
      lsp_styles = {
        underlines = {
          errors = {'undercurl'},
          hints = {'undercurl'},
          warnings = {'undercurl'},
          information = {'undercurl'},
          ok = {'undercurl'},
        },
      },
      integrations = {
        blink_cmp = true,
        diffview = true,
        mason = true,
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
    set_number_signcolumn()
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
vim.o.cursorline = true
vim.o.virtualedit = 'block'
vim.o.wildmode = 'longest:full,full'
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.undofile = true
vim.o.wrap = false
vim.o.list = true
vim.opt.listchars = {tab = '» ', trail = '·', nbsp = '␣'}

vim.keymap.set('n', '<Leader>n', '<Cmd>nohlsearch<CR>', {silent = true})
vim.keymap.set('n', '<Leader>w', '<Cmd>update<CR>', {silent = true})
vim.keymap.set('n', '<C-p>', '<Cmd>bp<CR>', {silent = true})
vim.keymap.set('n', '<C-n>', '<Cmd>bn<CR>', {silent = true})

local misc_augroup = vim.api.nvim_create_augroup('misc', {})

-- :help restore-cursor
vim.api.nvim_create_autocmd('BufReadPre', {group = misc_augroup,
  callback = function(args)
    vim.api.nvim_create_autocmd('FileType', {
      buffer = args.buf,
      once = true,
      callback = function()
        local line = vim.fn.line("'\"")
        local last_line = vim.fn.line('$')
        local filetype = vim.bo.filetype
        if line >= 1 and line <= last_line
            and not filetype:match('commit')
            and filetype ~= 'xxd'
            and filetype ~= 'gitrebase' then
          vim.cmd('normal! g`"')
        end
      end
    })
  end
})

-- file-specific settings
vim.filetype.add({filename = {gitconfig = 'gitconfig'}})
vim.api.nvim_create_autocmd('FileType', {group = misc_augroup, pattern = 'lua',
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
  end,
})
vim.api.nvim_create_autocmd('FileType', {group = misc_augroup, pattern = {'c', 'cpp'},
  callback = function() vim.bo.commentstring = '// %s' end})
vim.api.nvim_create_autocmd('FileType', {group = misc_augroup, pattern = 'gitconfig',
  callback = function() vim.bo.expandtab = false end})
