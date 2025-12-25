-- ============================================
-- A_NEEDS - Exports Serveur
-- ============================================

---Ajoute de la faim à un joueur
---@param src number ID du joueur
---@param amount number Quantité à ajouter
exports('AddHunger', function(src, amount)
    if type(src) ~= 'number' or type(amount) ~= 'number' or amount <= 0 then return end
    local data = GetPlayerData(src)
    if data then
        local newHunger = math.min(Config.MaxHunger, data.hunger + amount)
        UpdatePlayerData(src, newHunger, nil)
        TriggerClientEvent('a_needs:client:addHunger', src, amount)
    end
end)

---Ajoute de la soif à un joueur
---@param src number ID du joueur
---@param amount number Quantité à ajouter
exports('AddThirst', function(src, amount)
    if type(src) ~= 'number' or type(amount) ~= 'number' or amount <= 0 then return end
    local data = GetPlayerData(src)
    if data then
        local newThirst = math.min(Config.MaxThirst, data.thirst + amount)
        UpdatePlayerData(src, nil, newThirst)
        TriggerClientEvent('a_needs:client:addThirst', src, amount)
    end
end)

---Définit la faim d'un joueur (admin, respawn, etc.)
---@param src number ID du joueur
---@param value number Nouvelle valeur
exports('SetHunger', function(src, value)
    local validValue = ValidateInput(value)
    if type(src) ~= 'number' or not validValue then return end
    UpdatePlayerData(src, validValue, nil)
    TriggerClientEvent('a_needs:client:setHunger', src, validValue)
end)

---Définit la soif d'un joueur (admin, respawn, etc.)
---@param src number ID du joueur
---@param value number Nouvelle valeur
exports('SetThirst', function(src, value)
    local validValue = ValidateInput(value)
    if type(src) ~= 'number' or not validValue then return end
    UpdatePlayerData(src, nil, validValue)
    TriggerClientEvent('a_needs:client:setThirst', src, validValue)
end)

-- ============================================
-- INTÉGRATION OX_INVENTORY
-- ============================================

---Export pour items de nourriture (ox_inventory)
---@param event string Type d'event ('usedItem', etc.)
---@param item table Données de l'item
---@param inventory table Inventaire du joueur
---@param slot number Slot de l'item
---@param data table Métadonnées
exports('consumeFood', function(event, item, inventory, slot, data)
    if event == 'usedItem' then
        local amount = 20  -- Ajuster selon l'item
        exports['a_needs']:AddHunger(inventory.id, amount)
    end
end)

---Export pour items de boisson (ox_inventory)
---@param event string Type d'event ('usedItem', etc.)
---@param item table Données de l'item
---@param inventory table Inventaire du joueur
---@param slot number Slot de l'item
---@param data table Métadonnées
exports('consumeDrink', function(event, item, inventory, slot, data)
    if event == 'usedItem' then
        local amount = 30  -- Ajuster selon l'item
        exports['a_needs']:AddThirst(inventory.id, amount)
    end
end)
