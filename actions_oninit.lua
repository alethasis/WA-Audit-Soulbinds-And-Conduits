-- CONSTANTS
aura_env.SOULBIND_MAP = {
    [1] = {[1] = 7, [2] = 13, [3] = 18},
    [2] = {[1] = 8, [2] = 9, [3] = 3},
    [3] = {[1] = 1, [2] = 2, [3] = 6},
    [4] = {[1] = 4, [2] = 5, [3] = 10}
}

aura_env.CONDUIT_TYPE_MAP = {
    [0] = "FINESSE",
    [1] = "POTENCY",
    [2] = "ENDURANCE"
}

aura_env.EMPTY_COVENANT_SELECTION = 4

-- UTIL
aura_env.getSoulbindState = function(payload)
    return {
        show = true,
        changed = true,
        displayId = payload.displayId,
        index = payload.index,
        soulbindName = payload.soulbindName,
        tooltip = payload.soulbindName
    }
end

aura_env.getConduitState = function(payload)
    return {
        show = true,
        changed = true,
        conduitName = payload.conduitName,
        conduitSpecName = payload.conduitSpecName,
        icon = payload.icon,
        index = payload.index,
        link = payload.link
    }
end

-- TODO: Use WA Dynamic Group display function instead of this
local function __genOrderedIndex(t)
    local orderedIndex = {}
    for key in pairs(t) do table.insert(orderedIndex, key) end
    table.sort(orderedIndex)
    return orderedIndex
end

local function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil

    if (state == nil) then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex(t)
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1, table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i + 1]
            end
        end
    end

    if (key) then return key, t[key] end

    -- No more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function aura_env.orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end

-- MODULE
aura_env.checkSoulbind = function(allstates, index)
    local soulbindAuditPassed = true
    local covenantID = C_Covenants.GetActiveCovenantID()

    if (covenantID) then
        local currentSpec = GetSpecialization()
        local currentSoulbindID = C_Soulbinds.GetActiveSoulbindID()

        if (currentSoulbindID) then
            local selectedSoulbind =
                aura_env.config[tostring(covenantID)][tostring(currentSpec)]

            if (selectedSoulbind ~= aura_env.EMPTY_COVENANT_SELECTION) then
                local configSoulbindID =
                    aura_env.SOULBIND_MAP[covenantID][selectedSoulbind]

                local key = "SOULBIND_PORTRAIT"

                if (configSoulbindID ~= nil and configSoulbindID ~=
                    currentSoulbindID) then

                    local soulbindData =
                        C_Soulbinds.GetSoulbindData(currentSoulbindID)

                    local soulbindDisplayID =
                        soulbindData.modelSceneData.creatureDisplayInfoID

                    index = index + 1

                    soulbindAuditPassed = false

                    local payload = {
                        displayId = soulbindDisplayID,
                        index = index,
                        link = link,
                        soulbindName = soulbindData.name
                    }

                    allstates[key] = aura_env.getSoulbindState(payload)
                end

                return allstates, index, soulbindAuditPassed
            end
        end
    end

    return allstates, index, soulbindAuditPassed
end

aura_env.checkConduits = function(allstates, index)
    local conduitAuditPassed = true
    local covenantID = C_Covenants.GetActiveCovenantID()

    if (covenantID) then
        local currentSpec = GetSpecialization()
        local currentSpecName = currentSpec and
                                    select(2, GetSpecializationInfo(currentSpec))
        local covenantData = C_Covenants.GetCovenantData(covenantID)

        if (covenantData and covenantData.soulbindIDs) then
            local activeSoulbindID = C_Soulbinds.GetActiveSoulbindID()

            if (activeSoulbindID) then
                local soulbindData = C_Soulbinds.GetSoulbindData(
                                         activeSoulbindID)

                if (soulbindData and soulbindData.tree and
                    soulbindData.tree.nodes) then
                    local soulbindNodes = soulbindData.tree.nodes

                    local nodeBuckets = {
                        ["SOULBINDS"] = {},
                        ["POTENCY"] = {},
                        ["ENDURANCE"] = {},
                        ["FINESSE"] = {}
                    }

                    for _, node in pairs(soulbindNodes) do
                        if (node.state == 3) then -- Node is selected in tree
                            local rowID = node.row + 1

                            if (node.spellID == 0) then -- Is Conduit
                                local conduitType =
                                    aura_env.CONDUIT_TYPE_MAP[node.conduitType]

                                local conduitSpellID =
                                    C_Soulbinds.GetConduitSpellID(
                                        node.conduitID, node.conduitRank)

                                nodeBuckets[conduitType][rowID] = {
                                    conduitID = node.conduitID,
                                    rank = node.conduitRank,
                                    spellID = conduitSpellID
                                }
                            else -- Is Soulbind
                                nodeBuckets.SOULBINDS[rowID] = {
                                    spellID = node.spellID
                                }
                            end
                        end
                    end

                    for _, nodeBucket in pairs({
                        nodeBuckets.SOULBINDS, nodeBuckets.POTENCY,
                        nodeBuckets.FINESSE, nodeBuckets.ENDURANCE
                    }) do
                        for rowID, node in aura_env.orderedPairs(nodeBucket) do
                            local conduitID = node.conduitID
                            local conduitSpellID = node.spellID

                            if (conduitID and conduitSpellID ~= 0) then
                                local name, _, icon = GetSpellInfo(
                                                          conduitSpellID)

                                local link = GetSpellLink(conduitSpellID)

                                local conduitCollectionData =
                                    C_Soulbinds.GetConduitCollectionData(
                                        conduitID)
                                local conduitSpecName =
                                    conduitCollectionData.conduitSpecName

                                local isWrongConduitForSpec =
                                    conduitSpecName and
                                        (conduitSpecName ~= currentSpecName)

                                if (isWrongConduitForSpec) then
                                    local key = "SOULBIND" .. rowID

                                    index = index + 1

                                    conduitAuditPassed = false

                                    local payload = {
                                        conduitName = name,
                                        conduitSpecName = conduitSpecName,
                                        icon = icon,
                                        index = index,
                                        link = link
                                    }

                                    allstates[key] =
                                        aura_env.getConduitState(payload)
                                end
                            end
                        end
                    end

                    return allstates, index, conduitAuditPassed
                end
            end
        end
    end

    return allstates, index, conduitAuditPassed
end

WeakAuras.ScanEvents("LOADED")
