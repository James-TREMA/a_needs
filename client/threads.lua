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
    
    -- Attendre un peu puis afficher l'UI
    Wait(2000)
    ShowUI(true)
    SendNUIUpdate()
end)