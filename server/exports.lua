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
        if Config.Debug then
            print(('[A_NEEDS] AddHunger: joueur %d, +%d faim (nouveau: %d)'):format(src, amount, math.floor(newHunger)))
        end
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
        if Config.Debug then
            print(('[A_NEEDS] AddThirst: joueur %d, +%d soif (nouveau: %d)'):format(src, amount, math.floor(newThirst)))
        end
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

-- Fonction pour récupérer la définition d'un item ox_inventory
local function GetOxItemDef(itemName)
    if not Config.UseOxInventory then return nil end
    if GetResourceState('ox_inventory') ~= 'started' then return nil end
    
    local success, items = pcall(exports.ox_inventory.Items, exports.ox_inventory)
    if success and items and items[itemName] then
        return items[itemName]
    end
    return nil
end

---Convertit automatiquement les valeurs status (compatibilité esx_status)
---@param statusValue number Valeur du status (20 ou 200000)
---@return number amount Valeur convertie (sur 100)
local function ConvertStatusValue(statusValue)
    if not statusValue or type(statusValue) ~= 'number' then
        return 20 -- Valeur par défaut
    end
    
    -- Si ox_inventory est utilisé, convertir les valeurs esx_status (200000 = 20%)
    if Config.UseOxInventory and statusValue > 1000 then
        return math.floor(statusValue / 10000)
    end
    
    -- Sinon utiliser la valeur telle quelle
    return math.floor(statusValue)
end

---Export pour items de nourriture (ox_inventory)
---@param event string Type d'event ('usedItem', etc.)
---@param item table Données de l'item côté serveur
---@param inventory table Inventaire du joueur
---@param slot number Slot de l'item
---@param data table Métadonnées
exports('consumeFood', function(event, item, inventory, slot, data)
    if event == 'usedItem' then
        local hungerValue = 20
        
        local itemDef = GetOxItemDef(item.name)
        if itemDef and itemDef.client and itemDef.client.status and itemDef.client.status.hunger then
            hungerValue = itemDef.client.status.hunger
        end
        
        local amount = ConvertStatusValue(hungerValue)
        local playerId = type(inventory) == 'table' and inventory.id or inventory
        
        if playerId and type(playerId) == 'number' then
            exports['a_needs']:AddHunger(playerId, amount)
            
            if Config.Debug then
                print(('[A_NEEDS] %s consommé: +%d faim (joueur %d)'):format(item.name, amount, playerId))
            end
        end
        
        return true
    end
end)

---Export pour items de boisson (ox_inventory)
---@param event string Type d'event ('usedItem', etc.)
---@param item table Données de l'item côté serveur
---@param inventory table Inventaire du joueur
---@param slot number Slot de l'item
---@param data table Métadonnées
exports('consumeDrink', function(event, item, inventory, slot, data)
    if event == 'usedItem' then
        local thirstValue = 30
        
        local itemDef = GetOxItemDef(item.name)
        if itemDef and itemDef.client and itemDef.client.status and itemDef.client.status.thirst then
            thirstValue = itemDef.client.status.thirst
        end
        
        local amount = ConvertStatusValue(thirstValue)
        local playerId = type(inventory) == 'table' and inventory.id or inventory
        
        if playerId and type(playerId) == 'number' then
            exports['a_needs']:AddThirst(playerId, amount)
            
            if Config.Debug then
                print(('[A_NEEDS] %s consommé: +%d soif (joueur %d)'):format(item.name, amount, playerId))
            end
        end
        
        return true
    end
end)