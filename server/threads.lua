-- ============================================
-- A_NEEDS - Server Threads
-- Thread unique pour gérer tous les joueurs
-- ============================================

-- ============================================
-- THREAD: Gestion de la décroissance
-- ============================================

CreateThread(function()
    while true do
        Wait(1000)  -- Toutes les secondes
        
        -- Parcourir tous les joueurs en cache
        for src, data in pairs(PlayerData) do
            if data then
                -- Décroissance de la faim
                local newHunger = math.max(0, data.hunger - Config.HungerDecayRate)
                
                -- Décroissance de la soif
                local newThirst = math.max(0, data.thirst - Config.ThirstDecayRate)
                
                -- Mettre à jour le cache
                data.hunger = newHunger
                data.thirst = newThirst
                data.lastUpdate = os.time()
                
                -- Envoyer la mise à jour au client pour l'UI
                TriggerClientEvent('a_needs:client:sync', src, {
                    hunger = newHunger,
                    thirst = newThirst
                })
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
                    local ped = GetPlayerPed(src)
                    
                    if ped and ped > 0 then
                        local damage = Config.DamageWhenEmpty
                        
                        -- Double dégâts si les deux sont à 0
                        if data.hunger <= 0 and data.thirst <= 0 then
                            damage = damage * 2
                        end
                        
                        -- Appliquer les dégâts via natives FiveM
                        local currentHealth = GetEntityHealth(ped)
                        local newHealth = math.max(100, currentHealth - damage)  -- 100 = mort dans GTA
                        SetEntityHealth(ped, newHealth)
                        
                        if Config.Debug then
                            print(('[A_NEEDS] Dégâts appliqués: joueur %d, -%d HP (nouveau: %d)'):format(src, damage, newHealth))
                        end
                    end
                end
            end
        end
    end
end)

if Config.Debug then
    print('[^2A_NEEDS^7] Thread serveur initialisé')
end