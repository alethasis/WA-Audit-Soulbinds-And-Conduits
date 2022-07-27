function (allstates, event, ...)
  local SUB_EVENT = "CONDUIT_AUDIT"

  for _, state in pairs(allstates) do
      state.show = false
      state.changed = true
  end

  local count = 0
  local nextState = allstates

  nextState, count =
      aura_env.checkConduits(nextState, count)

  WeakAuras.ScanEvents("AUDIT_DATA", SUB_EVENT, count)

  allstates = nextState

  return true
end

