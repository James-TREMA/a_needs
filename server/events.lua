-- ============================================
-- A_NEEDS - Server Events
-- Gestion des événements réseau côté serveur
-- ============================================

-- ============================================
-- EVENTS DEPUIS LES CLIENTS
-- ============================================

---Joueur demande ses données (connexion)

local lastRequestData = {}
local spamAttempts = {}
local REQUESTDATA_COOLDOWN = 5 -- secondes

RegisterNetEvent('a_needs:server:requestData', function()
    local src = source
    local now = os.time()
    
    -- Vérifier le spam
    if lastRequestData[src] and now - lastRequestData[src] < REQUESTDATA_COOLDOWN then
        -- Incrémenter le compteur de spam
        spamAttempts[src] = (spamAttempts[src] or 0) + 1
        
        print(('[^1A_NEEDS^7] [ANTI-CHEAT] requestData spam détecté pour %d (tentative %d/%d)'):format(
            src, spamAttempts[src], Config.AntiCheat.maxSpamAttempts
        ))
        
        -- Kick si trop de tentatives
        if Config.AntiCheat.enabled and Config.AntiCheat.kickOnSpam and spamAttempts[src] >= Config.AntiCheat.maxSpamAttempts then
            DropPlayer(src, '[A_NEEDS] Anti-cheat: Spam d\'évents détecté')
            spamAttempts[src] = nil
            lastRequestData[src] = nil
        end
        return
    end
    
    -- Réinitialiser le compteur si pas de spam
    spamAttempts[src] = 0
    lastRequestData[src] = now

    -- Attendre qu'ESX charge le joueur (asynchrone)
    CreateThread(function()
        local xPlayer = nil
        local attempts = 0
        local maxAttempts = 10
        
        -- Attendre jusqu'à 5 secondes que ESX charge le joueur
        while not xPlayer and attempts < maxAttempts do
            xPlayer = ESX.GetPlayerFromId(src)
            if not xPlayer then
                attempts = attempts + 1
                Wait(500)
            end
        end
        
        if not xPlayer then 
            print(('[^1A_NEEDS^7] Impossible de récupérer l\'identifier pour le joueur %d après %d secondes'):format(src, maxAttempts * 0.5))
            return 
        end

        -- Charger depuis la BDD
        LoadPlayerStats(xPlayer.identifier, function(hunger, thirst)
            -- Mettre en cache
            SetPlayerData(src, xPlayer.identifier, hunger, thirst)

            -- Envoyer au client
            TriggerClientEvent('a_needs:client:sync', src, {
                hunger = hunger,
                thirst = thirst
            })

            if Config.Debug then
                print(('[^2A_NEEDS^7] Données chargées pour joueur %d: hunger=%d, thirst=%d'):format(
                    src, math.floor(hunger), math.floor(thirst)
                ))
            end
        end)
    end)
end)

-- ============================================
-- GESTION DE LA DÉCONNEXION
-- ============================================

---Sauvegarde à la déconnexion du joueur
AddEventHandler('playerDropped', function(reason)
    local src = source
    local data = GetPlayerData(src)
    
    if data then
        -- Sauvegarder une dernière fois de manière synchrone
        SavePlayerStatsAsync(data.identifier, data.hunger, data.thirst)
        
        print(('[^2A_NEEDS^7] Données sauvegardées pour joueur %d (déconnexion: %s)'):format(
            src, reason or 'unknown'
        ))
        
        -- Nettoyer le cache
        RemovePlayerData(src)
    end
    
    -- Nettoyer les données anti-cheat
    lastRequestData[src] = nil
    spamAttempts[src] = nil
end)

if Config.Debug then
    print('[^2A_NEEDS^7] Serveur initialisé')
end