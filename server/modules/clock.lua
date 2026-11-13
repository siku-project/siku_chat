local epochAtStart <const> = os.time() * 1000 - GetGameTimer()

ChatClock = {}

---The current time as a millisecond Unix timestamp, precise to the millisecond.
---@return number timestamp
function ChatClock.now()
  return epochAtStart + GetGameTimer()
end
