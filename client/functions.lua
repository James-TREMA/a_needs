-- ============================================
-- A_NEEDS - Client Functions
-- Fonctions utilitaires côté client
-- ============================================

ESX = exports["es_extended"]:getSharedObject()

-- ============================================
-- ÉTAT LOCAL DU JOUEUR (Runtime)
-- ============================================

PlayerState = {
    hunger = Config.DefaultState.hunger,
    thirst = Config.DefaultState.thirst,
    isVisible = true,
    isInitialized = false
}

-- ============================================
-- NUI COMMUNICATION
-- ============================================

---Envoie une mise à jour de l'UI
function SendNUIUpdate()
    SendNUIMessage({
        action = 'update',
        hunger = PlayerState.hunger,
        thirst = PlayerState.thirst,
        maxHunger = Config.MaxHunger,
        maxThirst = Config.MaxThirst,
        criticalThreshold = Config.CriticalThreshold,
        warningThreshold = Config.WarningThreshold
    })
end

---Affiche ou masque l'UI
---@param visible boolean
function ShowUI(visible)
    PlayerState.isVisible = visible
    SendNUIMessage({
        action = 'setVisible',
        visible = visible
    })
end

-- ============================================
-- FONCTIONS DE MODIFICATION D'ÉTAT
-- ============================================

---Ajoute de la faim (nourriture consommée)
---@param amount number Quantité à ajouter
function AddHunger(amount)
    if type(amount) ~= "number" or amount <= 0 then return end
    
    local oldHunger = PlayerState.hunger
    PlayerState.hunger = math.min(Config.MaxHunger, PlayerState.hunger + amount)
    
    if Config.Debug then
        print(('[A_NEEDS CLIENT] AddHunger: +%d faim (ancien: %d, nouveau: %d)'):format(
            amount, math.floor(oldHunger), math.floor(PlayerState.hunger)
        ))
    end
    
    SendNUIUpdate()
    
    -- Effet visuel
    SendNUIMessage({ action = 'pulse', type = 'hunger' })
end

---Ajoute de la soif (boisson consommée)
---@param amount number Quantité à ajouter
function AddThirst(amount)
    if type(amount) ~= "number" or amount <= 0 then return end
    
    local oldThirst = PlayerState.thirst
    PlayerState.thirst = math.min(Config.MaxThirst, PlayerState.thirst + amount)
    
    if Config.Debug then
        print(('[A_NEEDS CLIENT] AddThirst: +%d soif (ancien: %d, nouveau: %d)'):format(
            amount, math.floor(oldThirst), math.floor(PlayerState.thirst)
        ))
    end
    
    SendNUIUpdate()
    
    -- Effet visuel
    SendNUIMessage({ action = 'pulse', type = 'thirst' })
end

---Définit la valeur de faim
---@param value number Nouvelle valeur
function SetHunger(value)
    if type(value) ~= "number" then return end
    
    PlayerState.hunger = math.max(0, math.min(Config.MaxHunger, value))
    SendNUIUpdate()
end

---Définit la valeur de soif
---@param value number Nouvelle valeur
function SetThirst(value)
    if type(value) ~= "number" then return end
    
    PlayerState.thirst = math.max(0, math.min(Config.MaxThirst, value))
    SendNUIUpdate()
end
