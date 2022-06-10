function (allstates, event, ...)
    local index = 0
    local nextState = allstates
    local soulbindAuditPassed
    local conduitAuditPassed

    for _, state in pairs(allstates) do
        state.show = false
        state.changed = true
    end

    nextState, index, soulbindAuditPassed =
        aura_env.checkSoulbind(nextState, index)

    nextState, index, conduitAuditPassed =
        aura_env.checkConduits(nextState, index)

    -- TITLE
    if (not soulbindAuditPassed or not conduitAuditPassed) then
        local currentSpec = GetSpecialization()
        local currentSpecName = currentSpec and
                                    select(2, GetSpecializationInfo(currentSpec))

        local title = string.upper(currentSpecName) .. " AUDIT"

        local summaryPrefix = index > 1 and "WARNINGS" or "WARNING"
        local summary = summaryPrefix .. " (" .. index .. ")"

        nextState["AUDIT_FAILED"] = {
            show = true,
            changed = true,
            auditFailed = true,
            index = 0,
            summary = summary,
            summaryPrefix = summaryPrefix,
            title = title
        }
    end

    allstates = nextState

    return true
end

