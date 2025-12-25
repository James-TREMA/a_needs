-- ============================================
-- A_NEEDS - Client Initialization
-- ============================================

CreateThread(function()
    -- Attendre que la session réseau soit démarrée
    while not NetworkIsSessionStarted() do
        Wait(100)
    end
    
    -- Attendre qu'ESX soit prêt
    while not ESX do
        Wait(100)
    end
    
    -- Demander les données au serveur
    TriggerServerEvent('a_needs:server:requestData')
    
    -- Attendre que les données soient initialisées (synchronisation serveur)
    while not PlayerState.isInitialized do
        Wait(100)
    end
    
    -- Maintenant afficher l'UI avec les vraies données
    ShowUI(true)
    SendNUIUpdate()
end)