Nui = {}

local PREFIX <const> = 'siku_chat:nui:'

---@param name string The message name, without the resource prefix.
---@param payload table|nil
function Nui.send(name, payload)
  local message <const> = payload or {}

  message.action = PREFIX .. name

  SendNUIMessage(message)
end

function Nui.show()
  SikuUI.open()
  Nui.send('setVisible', { visible = true })
end

function Nui.hide()
  Nui.send('setVisible', { visible = false })
  SikuUI.close()
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

Nui.reply('ready', function()
  return {
    locale = {
      language = TranslationConfig.language,
      translations = { web = Siku.locale.translations().web },
    },
  }
end)

Nui.on('close', function()
  Nui.hide()
end)
