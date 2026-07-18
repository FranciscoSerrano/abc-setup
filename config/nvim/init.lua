-- ~/.config/nvim/init.lua
-- =====================================================================
--  Neovim configuration -- small, commented, and easy to edit.
--  All settings live in this single file.
--
--  Cheatsheet:
--    - Save:              :w
--    - Quit:              :q   (or :q! to quit without saving)
--    - Open a file:       :e path/to/file
--    - Command mode:      press  :  (colon)
--    - Leader key is set to the SPACEBAR (see below).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. BASIC OPTIONS
--    `vim.opt` sets editor options. These are safe to change.
-- ---------------------------------------------------------------------
vim.opt.number = true          -- show line numbers
vim.opt.relativenumber = true  -- number lines relative to the cursor (aids jumps)
vim.opt.mouse = "a"            -- enable mouse support
vim.opt.ignorecase = true      -- case-insensitive search...
vim.opt.smartcase = true       -- ...unless the search contains an uppercase letter
vim.opt.wrap = false           -- do not wrap long lines
vim.opt.tabstop = 2            -- a tab is displayed as 2 spaces
vim.opt.shiftwidth = 2         -- indentation uses 2 spaces
vim.opt.expandtab = true       -- Tab inserts spaces instead of a tab character
vim.opt.termguicolors = true   -- enable 24-bit color (required by the theme)
vim.opt.signcolumn = "yes"     -- always show the sign column (prevents text shifting)
vim.opt.clipboard = "unnamedplus" -- use the system clipboard for copy/paste

-- The "leader" key is a prefix for custom shortcuts. It is set to Space.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Syntax highlighting is enabled by default; Treesitter (below) improves it.


-- ---------------------------------------------------------------------
-- 2. PLUGIN MANAGER (lazy.nvim)
--    This block downloads lazy.nvim automatically on first launch.
--    No manual steps are required -- just run `nvim`.
-- ---------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)  -- add lazy.nvim to the runtime path


-- ---------------------------------------------------------------------
-- 3. PLUGINS
--    Each { ... } entry is one plugin. lazy.nvim installs them on first
--    launch. To add a plugin, copy an entry and change the name.
-- ---------------------------------------------------------------------
require("lazy").setup({

  -- ---- Color scheme: Catppuccin Mocha --------------------------------
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,          -- load before other plugins
    config = function()
      require("catppuccin").setup({ flavour = "mocha" })  -- select the Mocha flavour
      vim.cmd.colorscheme("catppuccin")                   -- apply the color scheme
    end,
  },

  -- ---- Treesitter: smarter, more accurate syntax highlighting --------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",      -- compile/update language parsers on install
    config = function()
      require("nvim-treesitter.configs").setup({
        -- Parsers to install. Add languages here as needed (e.g. "python").
        ensure_installed = { "javascript", "typescript", "go", "racket", "lua", "json", "bash" },
        highlight = { enable = true },  -- enable syntax highlighting
        indent = { enable = true },
      })
    end,
  },

  -- ---- Mason: installs LSP servers automatically (no manual downloads)
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim" },

  -- ---- LSP client configuration --------------------------------------
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Mason installs these servers automatically:
      --   ts_ls  = JavaScript / TypeScript
      --   gopls  = Go
      -- Racket's server is configured separately below because Mason
      -- does not ship it (see section 4).
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "gopls" },
      })

      local lspconfig = require("lspconfig")

      -- JavaScript / TypeScript
      lspconfig.ts_ls.setup({})

      -- Go
      lspconfig.gopls.setup({})

      -- Racket -- uses "racket-langserver", installed via `raco` by the
      -- setup script. Neovim is pointed at it manually here.
      lspconfig.racket_langserver.setup({})

      -- ---- LSP keyboard shortcuts (active only in files with an LSP) --
      -- These are registered whenever a language server attaches.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)   -- go to definition
          vim.keymap.set("n", "K",  vim.lsp.buf.hover, opts)        -- show docs popup
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- rename symbol
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- quick fixes
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- previous error/warning
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- next error/warning
        end,
      })
    end,
  },

  -- ---- Autocompletion (surfaces LSP suggestions) ---------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",   -- feed LSP results into the completion menu
      "L3MON4D3/LuaSnip",       -- snippet engine (required by nvim-cmp)
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args) require("luasnip").lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"]  = cmp.mapping.confirm({ select = true }), -- Enter accepts a suggestion
          ["<Tab>"] = cmp.mapping.select_next_item(),         -- Tab moves down the list
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),       -- Shift-Tab moves up
        }),
        sources = { { name = "nvim_lsp" }, { name = "luasnip" } },
      })

      -- Advertise completion support so the LSP servers send richer results.
      local caps = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")
      for _, server in ipairs({ "ts_ls", "gopls", "racket_langserver" }) do
        lspconfig[server].setup({ capabilities = caps })
      end
    end,
  },

})

-- =====================================================================
--  4. NOTES
--  - The JavaScript and Go LSP servers install automatically via Mason
--    the first time a file of that type is opened. Use  :Mason  to check
--    server status, or  :checkhealth  for diagnostics.
--  - Racket's language server is installed by the setup script with:
--        raco pkg install racket-langserver
--    If Racket highlighting/LSP does not work, confirm `racket` and
--    `raco` are on PATH (open a new terminal after installation).
--  - To add a plugin: copy one of the { ... } blocks above, change the
--    GitHub "author/name", then save and restart Neovim.
-- =====================================================================
