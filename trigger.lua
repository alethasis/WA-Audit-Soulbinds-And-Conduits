function (allstates, event, ...)
    local index = 0
    local nextState = allstates

    for _, state in pairs(allstates) do
        state.show = false
        state.changed = true
    end

    -- nextState, index, soulbindAuditPassed =
    --     aura_env.checkLegendary(nextState, index)

    nextState, index =
        aura_env.checkSoulbind(nextState, index)

    nextState, index =
        aura_env.checkConduits(nextState, index)

    WeakAuras.ScanEvents("AUDIT_DATA", index)

    allstates = nextState

    return true
end

