-- ============================================
-- A_NEEDS - Client Events
-- Gestion des événements réseau côté client
-- ============================================

-- ============================================
-- EVENTS DEPUIS LE SERVEUR
-- ============================================

---Synchronisation des données depuis le serveur
RegisterNetEvent('a_needs:client:sync', function(data)
    if type(data) ~= "table" then return end
    
    if data.hunger and type(data.hunger) == "number" then 
        PlayerState.hunger = math.max(0, math.min(Config.MaxHunger, data.hunger))
    end
    
    if data.thirst and type(data.thirst) == "number" then 
        PlayerState.thirst = math.max(0, math.min(Config.MaxThirst, data.thirst))
    end
    
    PlayerState.isInitialized = true
    SendNUIUpdate()
end)

---Ajout de faim depuis le serveur (consommation d'item)
RegisterNetEvent('a_needs:client:addHunger', function(amount)
    if type(amount) ~= "number" or amount <= 0 then return end
    
    AddHunger(amount)
end)

---Ajout de soif depuis le serveur (consommation d'item)
RegisterNetEvent('a_needs:client:addThirst', function(amount)
    if type(amount) ~= "number" or amount <= 0 then return end
    
    AddThirst(amount)
end)

---Définir faim depuis le serveur (admin, respawn, etc.)
RegisterNetEvent('a_needs:client:setHunger', function(value)
    if type(value) ~= "number" then return end
    
    SetHunger(value)
end)

---Définir soif depuis le serveur (admin, respawn, etc.)
RegisterNetEvent('a_needs:client:setThirst', function(value)
    if type(value) ~= "number" then return end
    
    SetThirst(value)
end)

---Appliquer les dégâts quand faim/soif à 0
RegisterNetEvent('a_needs:client:applyDamage', function(damage)
    if type(damage) ~= "number" then return end
    
    local playerPed = PlayerPedId()
    local currentHealth = GetEntityHealth(playerPed)
    local newHealth = math.max(100, currentHealth - damage)
    SetEntityHealth(playerPed, newHealth)
end)

---Forcer la synchronisation complète
RegisterNetEvent('a_needs:client:forceSync', function(hunger, thirst)
    if type(hunger) == "number" then
        PlayerState.hunger = math.max(0, math.min(Config.MaxHunger, hunger))
    end
    
    if type(thirst) == "number" then
        PlayerState.thirst = math.max(0, math.min(Config.MaxThirst, thirst))
    end
    
    SendNUIUpdate()
end)
