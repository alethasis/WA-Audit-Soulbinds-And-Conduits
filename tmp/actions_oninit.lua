aura_env.get = function(allstates)
    local index = 0
    local slotNames = {
        "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot",
        "ShirtSlot", "TabardSlot", "WristSlot", "HandsSlot", "WaistSlot",
        "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot",
        "Trinket1Slot", "MainHandSlot", "SecondaryHandSlot", "AmmoSlot"
    }

    -- Talents
    index = aura_env.createBlankIcon(allstates, "Talents", index)
    for i = 1, 7 do
        for j = 1, 3 do
            local talentID, name, texture, selected, available, spellId =
                GetTalentInfo(i, j, 1)
            if selected then
                index = index + 1
                allstates[name] = {
                    show = true,
                    changed = true,
                    name = name,
                    icon = texture,
                    progressType = "static",
                    autoHide = false,
                    spellId = spellId,
                    index = index
                }
            end
        end
    end
    if index == 1 then allstates[1] = nil end

    -- Soulbinds & Conduits
    local covenantID = C_Covenants.GetActiveCovenantID()
    if covenantID then
        local covenantData = C_Covenants.GetCovenantData(covenantID)
        if covenantData and covenantData.soulbindIDs then
            local currentSoulbindID = C_Soulbinds.GetActiveSoulbindID()
            if currentSoulbindID then
                local soulbindData = C_Soulbinds.GetSoulbindData(
                                         currentSoulbindID)
                if soulbindData and soulbindData.tree and
                    soulbindData.tree.nodes then
                    local soulbindNodes = soulbindData.tree.nodes

                    -- Soulbinds
                    index = aura_env.createBlankIcon(allstates, "Soulbind",
                                                     index)
                    local soulbindsAdded = 0
                    for nodeId, node in pairs(soulbindNodes) do
                        if node.state == 3 and node.spellID ~= 0 then
                            local name, rank, icon, castTime, minRange,
                                  maxRange, spellId = GetSpellInfo(node.spellID)
                            local link = GetSpellLink(node.spellID)
                            index = index + 1
                            soulbindsAdded = soulbindsAdded + 1
                            allstates[name] = {
                                show = true,
                                changed = true,
                                name = name,
                                icon = icon,
                                progressType = "static",
                                autoHide = false,
                                spellId = node.spellID,
                                index = index
                            }
                        end
                    end
                    local deltaSoulbinds = 7 - soulbindsAdded
                    if deltaSoulbinds > 0 then
                        index = aura_env.createFiller(allstates, deltaSoulbinds,
                                                      index)
                    end

                    -- Conduits
                    index = aura_env.createBlankIcon(allstates, "Conduits",
                                                     index)
                    local conduitsAdded = 0
                    for nodeId, node in pairs(soulbindNodes) do
                        if node.state == 3 and node.spellID == 0 then
                            local spellID =
                                C_Soulbinds.GetConduitSpellID(node.conduitID,
                                                              node.conduitRank)
                            local name, rank, icon, castTime, minRange,
                                  maxRange, spellId = GetSpellInfo(spellID)
                            if (name) then
                                local link = GetSpellLink(node.spellID)
                                index = index + 1
                                conduitsAdded = conduitsAdded + 1

                                allstates[name] = {
                                    show = true,
                                    changed = true,
                                    name = name,
                                    icon = icon,
                                    progressType = "static",
                                    autoHide = false,
                                    spellId = spellID,
                                    index = index
                                }
                            end
                        end
                    end
                    local deltaConduits = 7 - conduitsAdded
                    if deltaConduits > 0 then
                        index = aura_env.createFiller(allstates, deltaConduits,
                                                      index)
                    end
                end
            end
        end
    end

    -- Gear (Legendaries & Trinkets)
    index = aura_env.createBlankIcon(allstates, "Gear", index)
    local gearTitleIndex = index
    local trinkets = {}
    local legendaries = {}
    for slot = 1, #slotNames do
        local slotId = GetInventorySlotInfo(slotNames[slot])
        local item = GetInventoryItemLink("player", slotId)
        if item then
            local itemName, _, itemRarity, _, _, _, _, _, _, itemIcon =
                GetItemInfo(item)
            if itemRarity == 5 then
                legendaries[itemName] = {
                    name = itemName,
                    icon = itemIcon,
                    custom = itemName,
                    link = item
                }
            elseif slotNames[slot] == "Trinket0Slot" or slotNames[slot] ==
                "Trinket1Slot" then
                trinkets[itemName] = {
                    name = itemName,
                    icon = itemIcon,
                    link = item
                }
            end
        end
    end
    for k, v in pairs(legendaries) do
        index = index + 1
        allstates[k] = {
            show = true,
            changed = true,
            name = v.name,
            icon = v.icon,
            progressType = "static",
            autoHide = false,
            custom = v.custom:gsub(" ", "\r\n"),
            index = index,
            link = v.link
        }
    end
    for k, v in pairs(trinkets) do
        index = index + 1
        allstates[k] = {
            show = true,
            changed = true,
            name = v.name,
            icon = v.icon,
            progressType = "static",
            autoHide = false,
            index = index,
            link = v.link
        }
    end

    if index == gearTitleIndex then allstates[gearTitleIndex] = nil end

end

aura_env.createFiller = function(allstates, number, index)
    for i = 0, number do
        index = index + 1
        aura_env.createBlankIcon(allstates, "", index)
    end
    return index
end

aura_env.createBlankIcon = function(allstates, text, index)
    index = index + 1
    allstates[index] = {
        show = true,
        changed = true,
        name = index,
        icon = texture,
        progressType = "static",
        autoHide = false,
        title = text,
        index = index
    }
    return index
end
