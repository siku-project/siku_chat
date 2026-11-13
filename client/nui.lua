Nui = {}

local PREFIX <const> = 'siku_chat:nui:'

---@param name string The message name, without the resource prefix.
---@param payload table|nil
function Nui.send(name, payload)
  local message <const> = payload or {}

  message.action = PREFIX .. name

  SendNUIMessage(message)
end

---Opens the chat and gives it the keyboard, with the cursor only when asked.
---@param cursor boolean Whether the mouse cursor is shown.
function Nui.show(cursor)
  SetNuiFocus(true, cursor == true)
  SikuUI.sendEnv()
  SikuUI.focused = true
  Nui.send('open')
end

function Nui.hide()
  SetNuiFocus(false, false)
  SikuUI.focused = false
  Nui.send('hide')
end

---@param name string The callback name, without the resource prefix.
---@param handler fun(data: table) Runs in its own thread, after the interface got its answer.
function Nui.on(name, handler)
  RegisterNUICallback(PREFIX .. name, function(data, cb)
    cb({})

    CreateThread(function()
      handler(type(data) == 'table' and data or {})
    end)
  end)
end

---@param name string The callback name, without the resource prefix.
---@param handler fun(data: table): table|nil Answers the interface synchronously.
function Nui.reply(name, handler)
  RegisterNUICallback(PREFIX .. name, function(data, cb)
    cb(handler(type(data) == 'table' and data or {}) or {})
  end)
end
