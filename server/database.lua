-- ============================================
-- A_NEEDS - Server Database
-- Gestion de la persistance avec oxmysql
-- ============================================

-- ============================================
-- CONFIGURATION TABLE
-- ============================================

local tableName = Config.Database.useCustomTable and Config.Database.customTableName or 'users'

-- ============================================
-- FONCTIONS DE BASE DE DONNÉES
-- ============================================

---Charge les statistiques d'un joueur depuis la BDD
---@param identifier string Identifier ESX du joueur
---@param callback function Callback avec les données (hunger, thirst)
function LoadPlayerStats(identifier, callback)
    local query = string.format('SELECT hunger, thirst FROM %s WHERE identifier = ?', tableName)
    
    MySQL.query(query, { identifier }, function(result)
            if result and result[1] then
                callback(
                    result[1].hunger or Config.DefaultState.hunger,
                    result[1].thirst or Config.DefaultState.thirst
                )
            else
                -- Joueur non trouvé, utiliser les valeurs par défaut
                callback(Config.DefaultState.hunger, Config.DefaultState.thirst)
            end
        end
    )
end

---Sauvegarde les statistiques d'un joueur dans la BDD
---@param identifier string Identifier ESX du joueur
---@param hunger number Valeur de faim
---@param thirst number Valeur de soif
function SavePlayerStats(identifier, hunger, thirst)
    if not identifier then return end
    
    local validHunger = ValidateInput(hunger) or Config.DefaultState.hunger
    local validThirst = ValidateInput(thirst) or Config.DefaultState.thirst
    
    local query = string.format('UPDATE %s SET hunger = ?, thirst = ? WHERE identifier = ?', tableName)
    
    MySQL.update(query, { math.floor(validHunger), math.floor(validThirst), identifier }, function(affectedRows)
            if affectedRows == 0 then
                print(('[^3A_NEEDS^7] Aucune ligne mise à jour pour %s'):format(identifier))
            end
        end
    )
end

---Sauvegarde asynchrone sans callback (pour déconnexion rapide)
---@param identifier string Identifier ESX du joueur
---@param hunger number Valeur de faim
---@param thirst number Valeur de soif
function SavePlayerStatsAsync(identifier, hunger, thirst)
    if not identifier then return end
    
    local validHunger = ValidateInput(hunger) or Config.DefaultState.hunger
    local validThirst = ValidateInput(thirst) or Config.DefaultState.thirst
    
    local query = string.format('UPDATE %s SET hunger = ?, thirst = ? WHERE identifier = ?', tableName)
    
    MySQL.update.await(query, { math.floor(validHunger), math.floor(validThirst), identifier })
end

-- ============================================
-- INITIALISATION DE LA BASE DE DONNÉES
-- ============================================

---Initialise les colonnes hunger/thirst dans la table
local function InitializeDatabase()
    local query = string.format([[
        ALTER TABLE %s 
        ADD COLUMN IF NOT EXISTS hunger INT DEFAULT 100,
        ADD COLUMN IF NOT EXISTS thirst INT DEFAULT 100
    ]], tableName)
    
    MySQL.query(query, {}, function(success)
        if success then
            print(('[^2A_NEEDS^7] Colonnes hunger/thirst vérifiées dans table %s'):format(tableName))
        end
    end)
end

-- Exécuter l'initialisation au démarrage
CreateThread(function()
    -- Attendre que MySQL soit prêt
    Wait(1000)
    InitializeDatabase()
    if Config.Debug then
        print('[^2A_NEEDS^7] Base de données initialisée')
    end
end)
