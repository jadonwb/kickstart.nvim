local last_run = nil
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'theHamsta/nvim-dap-virtual-text',
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'jbyuki/one-small-step-for-vimkind',
    'nvim-telescope/telescope.nvim',
    'nvim-telescope/telescope-dap.nvim',
  },
  ft = { 'c', 'lua', 'rust' },
  keys = {
    {
      '<F3>',
      function()
        require('dapui').toggle()
      end,
      desc = 'DAP toggle UI',
    },
    {
      '<F4>',
      function()
        require('dap').pause()
      end,
      desc = 'DAP pause (thread)',
    },
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'DAP launch or continue',
    },
    {
      '<F6>',
      function()
        require('dap').step_into()
      end,
      desc = 'DAP step into',
    },
    {
      '<F7>',
      function()
        require('dap').step_over()
      end,
      desc = 'DAP step over',
    },
    {
      '<F8>',
      function()
        require('dap').step_out()
      end,
      desc = 'DAP step out',
    },
    {
      '<F9>',
      function()
        require('dap').step_back()
      end,
      desc = 'DAP step back',
    },
    {
      '<F10>',
      function()
        -- Reimplement last_run to store the config
        -- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
        if last_run and last_run.config then
          require('dap').run(last_run.config)
        else
          require('dap').continue()
        end
      end,
      desc = 'DAP run last',
    },
    {
      '<F12>',
      function()
        require('dap').terminate()
      end,
      desc = 'DAP terminate',
    },
    {
      '<leader>dd',
      function()
        require('dap').disconnect { terminateDebuggee = false }
      end,
      desc = 'DAP disconnect',
    },
    {
      '<leader>dt',
      function()
        require('dap').disconnect { terminateDebuggee = true }
      end,
      desc = 'DAP disconnect and terminate',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'DAP toggle breakpoint',
    },
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'DAP set breakpoint with condition',
    },
    {
      '<leader>dp',
      function()
        require('dap').set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
      end,
      desc = 'DAP set breakpoint with log point message',
    },
    {
      '<leader>de',
      function()
        require('dapui').eval()
      end,
      desc = 'DAP eval',
    },
  },
  config = function()
    local dap = require 'dap'
    require 'dapui'

    -- Store the config for 'dap.last_run()'
    dap.listeners.after.event_initialized['store_config'] = function(session)
      if session.config then
        last_run = {
          config = session.config,
        }
      end
    end

    require('nvim-dap-virtual-text').setup {
      -- Use eol instead of inline
      virt_text_pos = 'eol',
    }

    local telescope_dap = require('telescope').extensions.dap
    local keymap = vim.keymap.set

    keymap({ 'n', 'v' }, '<leader>d?', function()
      telescope_dap.commands {}
    end, { silent = true, desc = 'DAP builtin commands' })
    keymap({ 'n', 'v' }, '<leader>dl', function()
      telescope_dap.list_breakpoints {}
    end, { silent = true, desc = 'DAP breakpoint list' })
    keymap({ 'n', 'v' }, '<leader>df', function()
      telescope_dap.frames()
    end, { silent = true, desc = 'DAP frames' })
    keymap({ 'n', 'v' }, '<leader>dv', function()
      telescope_dap.variables()
    end, { silent = true, desc = 'DAP variables' })
    keymap({ 'n', 'v' }, '<leader>dc', function()
      telescope_dap.configurations()
    end, { silent = true, desc = 'DAP debugger configurations' })

    require('telescope').load_extension 'dap'

    -- configure dap-ui and language adapaters
    require 'kickstart.plugins.dap.ui'
    if vim.fn.executable 'gdb' == 1 then
      require 'kickstart.plugins.dap.c'
    end
    if vim.fn.executable 'rust-gdb' == 1 then
      require 'kickstart.plugins.dap.rust'
    end
    require 'kickstart.plugins.dap.lua'
  end,
}
