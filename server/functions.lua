-- ============================================
-- A_NEEDS - Server Functions
-- Fonctions utilitaires côté serveur
-- ============================================

ESX = exports["es_extended"]:getSharedObject()

-- ============================================
-- CACHE DYNAMIQUE DES JOUEURS
-- ============================================

---@type table<number, {identifier: string, hunger: number, thirst: number, lastUpdate: number}>
PlayerData = {}

-- ============================================
-- FONCTIONS UTILITAIRES
-- ============================================

---Valide et clamp une valeur entre les limites configurées
---@param value any Valeur à valider
---@return number|nil Valeur validée ou nil si invalide
function ValidateInput(value)
    if type(value) ~= "number" then
        return nil
    end
    
    -- Clamp entre min et max
    return math.max(
        Config.Validation.minValue, 
        math.min(Config.Validation.maxValue, value)
    )
end

---Récupère l'identifier ESX d'un joueur
---@param source number ID du joueur
---@return string|nil identifier ou nil si non trouvé
function GetPlayerIdentifier(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then
        return nil
    end
    
    return xPlayer.identifier
end

---Récupère les données d'un joueur depuis le cache
---@param source number ID du joueur
---@return table|nil Données du joueur ou nil
function GetPlayerData(source)
    return PlayerData[source]
end

---Définit les données d'un joueur dans le cache
---@param source number ID du joueur
---@param identifier string Identifier ESX
---@param hunger number Valeur de faim
---@param thirst number Valeur de soif
function SetPlayerData(source, identifier, hunger, thirst)
    PlayerData[source] = {
        identifier = identifier,
        hunger = ValidateInput(hunger) or Config.DefaultState.hunger,
        thirst = ValidateInput(thirst) or Config.DefaultState.thirst,
        lastUpdate = os.time()
    }
end

---Met à jour les données d'un joueur dans le cache
---@param source number ID du joueur
---@param hunger number|nil Nouvelle valeur de faim (optionnel)
---@param thirst number|nil Nouvelle valeur de soif (optionnel)
---@return boolean Succès de la mise à jour
function UpdatePlayerData(source, hunger, thirst)
    if not PlayerData[source] then
        return false
    end
    
    if hunger then
        local validHunger = ValidateInput(hunger)
        if validHunger then
            PlayerData[source].hunger = validHunger
        end
    end
    
    if thirst then
        local validThirst = ValidateInput(thirst)
        if validThirst then
            PlayerData[source].thirst = validThirst
        end
    end
    
    PlayerData[source].lastUpdate = os.time()
    return true
end

---Supprime un joueur du cache
---@param source number ID du joueur
function RemovePlayerData(source)
    PlayerData[source] = nil
end

---Vérifie si les données sont suspectes (anti-cheat basique)
---@param source number ID du joueur
---@param newHunger number Nouvelle valeur de faim
---@param newThirst number Nouvelle valeur de soif
---@return boolean true si les données sont valides
function ValidatePlayerUpdate(source, newHunger, newThirst)
    local data = PlayerData[source]
    if not data then
        return true -- Pas de données précédentes, accepter
    end
    
    -- Vérifier les variations anormales
    local hungerDiff = newHunger - data.hunger
    local thirstDiff = newThirst - data.thirst
    
    if hungerDiff > Config.AntiCheat.suspiciousThreshold or thirstDiff > Config.AntiCheat.suspiciousThreshold then
        print(('[^1A_NEEDS^7] [ANTI-CHEAT] Valeurs suspectes pour joueur %d: hunger +%d, thirst +%d'):format(
            source, hungerDiff, thirstDiff
        ))
        
        -- Kick si anti-cheat activé
        if Config.AntiCheat.enabled and Config.AntiCheat.kickOnSuspiciousValues then
            DropPlayer(source, '[A_NEEDS] Anti-cheat: Manipulation de valeurs détectée')
            return false
        end
    end
    
    return true
end