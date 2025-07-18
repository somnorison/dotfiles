local M = {}
M.want = function(name)                                                 
  local out; if xpcall(                         
      function()  out = require(name) end,           
      function(e) out = e end)
  then return out          -- success                                     
  else return nil, out end -- error                                       
end  

  -- two ways to get buffer filename:
  -- vim.fn.expand('%')
  -- vim.api.nvim_buf_get_name(0) -- buffer 0 is always current buffer

M.current_buffer_dir = function()
  filename = vim.api.nvim_buf_get_name(0)
  dirname = filename:match("(.*[/\\])")
  return dirname
end

return M
