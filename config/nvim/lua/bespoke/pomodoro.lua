local M = {}

local STOPPED = 0
local RUNNING = 1
local MAIN = 0
local BREAK = 0

M.data = {
  notifier = "notify-send",
  status = STOPPED,
  seconds_left = 0,
  timer = nil,
  timer_type = "MAIN" -- or "BREAK"
}

M.finish = function()
  vim.system({M.config.notifier, "Timer finished"})
  M.config.status = STOPPED
  M.data.seconds_left = 0
  vim.notify("timer finished")
end

M.start = function(seconds)
  if M.data.status == RUNNING then
    vim.notify("timer already running")
  else
    M.data.status = RUNNING
    M.data.seconds_left = seconds
    M.data.timer = vim.uv.new_timer()
    M.notify("timer started")
    M.data.timer:start(1000, 0, function()
      if M.data.seconds_left < 0 then
        M.data.timer:stop()
        M.data.status = STOPPED
        M.notify("timer finished")
      elseif M.data.status == RUNNING then
        M.data.seconds_left = M.data.seconds_left - 1
      end
    end)
    M.data.timer:set_repeat(1000)
  end
end

M.notify = function(msg)
  vim.system({M.data.notifier, msg})
end

M.pause = function()
  M.data.status = STOPPED
  M.notify("timer paused")
end

M.string = function() 
  local sec = M.data.seconds_left
  local stat = ""
  if M.data.status == RUNNING then
    stat = "running: "
  else
    stat = "stopped: "
  end
  return stat .. string.format("%02.0f:%02.0f", sec / 60, sec % 60)
end

M.toggle = function()
  if M.data.status == RUNNING then
    M.data.status = STOPPED
  else
    M.start(25 * 60)
  end
end

M.configure = function()
  local statusline = helpers.want("bespoke.statusline")
  if statusline then
    vim.notify("registering statusline callback")
    statusline.add_callback(M.string)
  end

  local wk = helpers.want("which-key") 
  if wk then
    wk.add({
      {"<leader>p", group = "pomo" },
      {"<leader>ps", function() M.start(25 * 60) end, desc = "start main timer"},
      {"<leader>pb", function() M.start(5 * 60) end, desc = "start break timer"},
      {"<leader>pt", function() M.pause() end, desc = "pause timer"},
      {"<leader>pk", function() M.finish() end, desc = "kill timer"},
    })
  end
end
-- how shall we create a pomodoro timer in neovim?
-- here is my vision: I run a command "PomoStart"
--  a timer is started for 25 minutes
--  a sound is played
-- during the timer run:
--  the status bar indicates the current time in mm:ss
-- at the end of the timer run:
--  a sound is played
--  a notification is spawned in neovim
--  a system notification is spawned

-- There are several pieces of the puzzle here:
-- neovim timer control -- we use the `uv.timer_*` functions
  -- help uv.timer_
-- subprocess control   -- 
-- notifications        -- since I write for linux, I can use "notify-send"
-- statusbar control    -- hm

return M
