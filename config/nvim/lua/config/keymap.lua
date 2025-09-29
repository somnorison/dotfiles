local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap("n", "<Space>", "", opts)
-- vim.g.mapleader = " "
-- vim.g.maplocalleader = " "

keymap("n", "<C-i>", "<C-i>", opts)

-- Better window navigation
-- keymap("n", "<m-h>", "<C-w>h", opts)
-- keymap("n", "<m-j>", "<C-w>j", opts)
-- keymap("n", "<m-k>", "<C-w>k", opts)
-- keymap("n", "<m-l>", "<C-w>l", opts)
keymap("n", "<m-tab>", "<c-6>", opts)

keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

keymap("t", "<C-h>", "<C-\\><C-n><C-w>h", opts)
keymap("t", "<C-j>", "<C-\\><C-n><C-w>j", opts)
keymap("t", "<C-k>", "<C-\\><C-n><C-w>k", opts)
keymap("t", "<C-l>", "<C-\\><C-n><C-w>l", opts)


-- plugin agnostic please
local lua_config_dir = vim.fn.stdpath("config") .. "/lua/config"
keymap("n", "<leader>csc", ":source $MYVIMRC<CR>", opts)
keymap("n", "<leader>cso", ":source " .. lua_config_dir .. "/vimOpt.lua<CR>", opts)
keymap("n", "<leader>csk", ":source " .. lua_config_dir .. "/keymap.lua<CR>", opts)
keymap("n", "<leader>cs5", ":source %<CR>", opts)
keymap("n", "<leader>coc", ":e $MYVIMRC<CR>", opts)
keymap("n", "<leader>cok", ":e " .. lua_config_dir .. "/keymap.lua<CR>", opts)
-- https://vimdoc.sourceforge.net/htmldoc/eval.html#expand()
-- 			:p		expand to full path
-- 			:h		head (last path component removed)
-- 			:t		tail (last path component only)
-- 			:r		root (one extension removed)
-- 			:e		extension only
-- keymap("n", "-", ":e %:h<CR>", opts) -- same as :Explore<CR> ?
-- don't forget about :Sex, :Vex, and :Tex
keymap("n", "-", ":Explore<CR>", opts)

-- get out of the terminal
keymap("t", "<leader>;", "<C-\\><C-n>", opts)
keymap("t", ";;", "<C-\\><C-n>", opts)

-- what
-- keymap("n", "n", "nzz", opts)
-- keymap("n", "N", "Nzz", opts)
-- keymap("n", "*", "*zz", opts)
-- keymap("n", "#", "#zz", opts)
-- keymap("n", "g*", "g*zz", opts)
-- keymap("n", "g#", "g#zz", opts)

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- echo foo bar
-- foo bar
-- vmap <space> "xy:@x<CR>
-- too powerful
-- keymap("v", "<space>", "execute 'r !eval '.shellescape(@\", 1)")

keymap("x", "p", [["_dP]])

vim.cmd [[:amenu 10.100 mousemenu.Goto\ Definition <cmd>lua vim.lsp.buf.definition()<CR>]]
vim.cmd [[:amenu 10.110 mousemenu.References <cmd>lua vim.lsp.buf.references()<CR>]]
-- vim.cmd [[:amenu 10.120 mousemenu.-sep- *]]

vim.keymap.set("n", "<RightMouse>", "<cmd>:popup mousemenu<CR>")
vim.keymap.set("n", "<Tab>", "<cmd>:popup mousemenu<CR>")

-- more good
keymap({ "n", "o", "x" }, "<s-h>", "^", opts)
keymap({ "n", "o", "x" }, "<s-l>", "g_", opts)

-- tailwind bearable to work with
-- keymap({ "n", "x" }, "j", "gj", opts)
-- keymap({ "n", "x" }, "k", "gk", opts)
-- keymap("n", "<leader>w", ":lua vim.wo.wrap = not vim.wo.wrap<CR>", opts)

if helpers.want("which-key") then
  local wk = require("which-key")
  wk.add({
    {"<leader>h", function() print("hello") end, desc = "Debug"}
  })
  wk.add({
    { "<leader>c", group = "Configuration" },
    { "<leader>cs", group = "Apply" },
    { "<leader>co", group = "Open" },
  })

  if helpers.want("telescope") then
    wk.add({
      { "<leader>f", group = "Find" },
      { "<leader>fm", "<cmd>Telescope keymaps<cr>", desc = "Mappings" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fa", "<cmd>Telescope marks<cr>", desc = "Marks" },
      { "<leader>f<space>", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    })
  end

  if helpers.want("nvim-tree") then
    wk.add({
      { "<leader>ot", "<cmd>NvimTreeToggle<cr>", desc = "Toggle Tree View" }
    })
  end
 --  wk.add({
 --     { "<leader>f", group = "file" }, -- group
 --     { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File", mode = "n" },
 --     { "<leader>fb", function() print("hello") end, desc = "Foobar" },
 --     { "<leader>fn", desc = "New File" },
 --     { "<leader>f1", hidden = true }, -- hide this keymap
 --     { "<leader>w", proxy = "<c-w>", group = "windows" }, -- proxy to window mappings
 --     { "<leader>b", group = "buffers", expand = function()
 --         return require("which-key.extras").expand.buf()
 --       end
 --     },
end
