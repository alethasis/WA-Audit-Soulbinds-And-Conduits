function (allstates, event, ...)
    if (event == "AUDIT_DATA") then
        local subEvent, count = ...

        if (count > 0) then
            local currentSpec = GetSpecialization()
            local currentSpecName = currentSpec and
                                        select(2, GetSpecializationInfo(
                                                   currentSpec))

            local uppercaseSpecName = string.upper(currentSpecName)

            local summaryPrefix = count > 1 and "WARNINGS" or "WARNING"

            allstates["AUDIT_TITLE"] = {
                show = true,
                changed = true,
                auditFailed = true,
                count = count,
                specName = uppercaseSpecName,
                summaryPrefix = summaryPrefix
            }
        else
            allstates["AUDIT_TITLE"] = {
                show = false,
                changed = true,
                auditFailed = false,
                count = count
            }
        end

        return true
    end
end
