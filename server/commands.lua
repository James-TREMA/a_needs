-- ============================================
-- A_NEEDS - Commandes Admin
-- ============================================

---Commande pour se restaurer complètement (admin)
RegisterCommand('needs', function(source, args, rawCommand)
    local src = source
    
    -- Vérifier si le joueur est admin (via ACE permissions)
    if not IsPlayerAceAllowed(src, 'command.needs') then
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = false,
            args = {"[A_NEEDS]", "Vous n'avez pas la permission d'utiliser cette commande"}
        })
        return
    end
    
    -- Restaurer la faim et la soif à 100
    exports['a_needs']:SetHunger(src, 100)
    exports['a_needs']:SetThirst(src, 100)
    
    TriggerClientEvent('chat:addMessage', src, {
        color = {0, 255, 0},
        multiline = false,
        args = {"[A_NEEDS]", "Faim et soif restaurées à 100%"}
    })
    
    if Config.Debug then
        print(('[A_NEEDS] Commande /needs utilisée par le joueur %d'):format(src))
    end
end, false)

---Commande pour restaurer un autre joueur (admin)
RegisterCommand('needsheal', function(source, args, rawCommand)
    local src = source
    
    -- Vérifier si le joueur est admin
    if not IsPlayerAceAllowed(src, 'command.needsheal') then
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = false,
            args = {"[A_NEEDS]", "Vous n'avez pas la permission d'utiliser cette commande"}
        })
        return
    end
    
    local targetId = tonumber(args[1])
    
    if not targetId then
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = false,
            args = {"[A_NEEDS]", "Usage: /needsheal [ID]"}
        })
        return
    end
    
    -- Vérifier si le joueur existe
    if GetPlayerName(targetId) == nil then
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = false,
            args = {"[A_NEEDS]", "Joueur introuvable"}
        })
        return
    end
    
    -- Restaurer la faim et la soif du joueur cible
    exports['a_needs']:SetHunger(targetId, 100)
    exports['a_needs']:SetThirst(targetId, 100)
    
    TriggerClientEvent('chat:addMessage', src, {
        color = {0, 255, 0},
        multiline = false,
        args = {"[A_NEEDS]", string.format("Joueur %d restauré à 100%%", targetId)}
    })
    
    TriggerClientEvent('chat:addMessage', targetId, {
        color = {0, 255, 0},
        multiline = false,
        args = {"[A_NEEDS]", "Un administrateur vous a restauré"}
    })
    
    if Config.Debug then
        print(('[A_NEEDS] Commande /needsheal utilisée par %d sur %d'):format(src, targetId))
    end
end, false)

if Config.Debug then
    print('[^2A_NEEDS^7] Commandes admin chargées')
end