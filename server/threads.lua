-- ============================================
-- A_NEEDS - Server Threads
-- Architecture Delta-Sync optimisée pour la scalabilité
-- ============================================

-- ============================================
-- THREAD 1: Calcul de la décroissance (1s)
-- Calcule les valeurs sans envoyer au réseau
-- ============================================

CreateThread(function()
    while true do
        Wait(1000)  -- Calcul toutes les secondes
        
        -- Parcourir tous les joueurs en cache
        for src, data in pairs(PlayerData) do
            if data then
                -- Décroissance de la faim
                data.hunger = math.max(0, data.hunger - Config.HungerDecayRate)
                
                -- Décroissance de la soif
                data.thirst = math.max(0, data.thirst - Config.ThirstDecayRate)
                
                -- Mettre à jour le timestamp
                data.lastUpdate = os.time()
            end
        end
    end
end)

-- ============================================
-- THREAD 2: Synchronisation réseau (delta-sync)
-- Envoie uniquement si changement significatif
-- ============================================

CreateThread(function()
    while true do
        Wait(Config.SyncInterval)  -- 5000ms par défaut
        
        -- Parcourir tous les joueurs en cache
        for src, data in pairs(PlayerData) do
            if data then
                -- Initialiser les valeurs de dernière sync si absentes
                if not data.lastSyncHunger then
                    data.lastSyncHunger = data.hunger
                    data.lastSyncThirst = data.thirst
                end
                
                -- Calculer les deltas
                local hungerDelta = math.abs(data.hunger - data.lastSyncHunger)
                local thirstDelta = math.abs(data.thirst - data.lastSyncThirst)
                
                -- Sync seulement si changement >= seuil
                if hungerDelta >= Config.SyncDeltaThreshold or thirstDelta >= Config.SyncDeltaThreshold then
                    -- Envoyer la mise à jour au client pour l'UI
                    TriggerClientEvent('a_needs:client:sync', src, {
                        hunger = data.hunger,
                        thirst = data.thirst
                    })
                    
                    -- Sauvegarder les valeurs de la dernière sync
                    data.lastSyncHunger = data.hunger
                    data.lastSyncThirst = data.thirst
                    
                    if Config.Debug then
                        print(('[A_NEEDS] Sync joueur %d: H=%.1f T=%.1f (delta H=%.2f T=%.2f)'):format(
                            src, data.hunger, data.thirst, hungerDelta, thirstDelta
                        ))
                    end
                end
            end
        end
    end
end)

-- ============================================
-- THREAD: Application des dégâts
-- ============================================

CreateThread(function()
    while true do
        Wait(Config.DamageInterval)  -- 5000ms par défaut
        
        -- Parcourir tous les joueurs en cache
        for src, data in pairs(PlayerData) do
            if data then
                -- Vérifier si faim ou soif à 0
                if data.hunger <= 0 or data.thirst <= 0 then
                    local damage = Config.DamageWhenEmpty
                    
                    -- Double dégâts si les deux sont à 0
                    if data.hunger <= 0 and data.thirst <= 0 then
                        damage = damage * 2
                    end
                    
                    -- Envoyer au client pour appliquer les dégâts
                    TriggerClientEvent('a_needs:client:applyDamage', src, damage)
                    
                    if Config.Debug then
                        print(('[A_NEEDS] Dégâts appliqués: joueur %d, -%d HP'):format(src, damage))
                    end
                end
            end
        end
    end
end)

if Config.Debug then
    print('[^2A_NEEDS^7] Thread serveur initialisé')
end