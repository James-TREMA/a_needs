-- ============================================
-- A_NEEDS - Configuration Partagée
-- Fichier de configuration centralisé
-- ============================================

Config = {}

-- ============================================-- PARAMÈTRES GÉNÉRAUX
-- ============================================

-- Nom de la ressource (utilisé dans les events et exports)
Config.ResourceName = 'a_needs'

-- Mode debug (affiche les logs console)
-- false = Production (pas de logs)
-- true = Développement (logs actifs)
Config.Debug = false

-- Utilisation d'ox_inventory pour la conversion automatique des valeurs status
-- true = Convertit les valeurs esx_status (200000 → 20)
-- false = Utilise les valeurs directes sans conversion (20 = 20)
Config.UseOxInventory = true

-- ============================================-- PARAMÈTRES SYSTÈME
-- ============================================

-- Valeurs maximales
Config.MaxHunger = 100
Config.MaxThirst = 100

-- Taux de décroissance (par seconde)
Config.HungerDecayRate = 0.02  -- ~2% par minute (~50 min pour vider)
Config.ThirstDecayRate = 0.03  -- ~3% par minute (~33 min pour vider)

-- Seuils d'alerte UI
Config.CriticalThreshold = 20  -- Seuil critique (rouge)
Config.WarningThreshold = 40   -- Seuil d'avertissement (orange)

-- Système de dégâts
Config.DamageWhenEmpty = 1     -- Dégâts quand à 0
Config.DamageInterval = 5000   -- Intervalle des dégâts (ms)

-- Optimisation réseau (delta-sync)
Config.SyncInterval = 5000     -- Intervalle de sync client (ms) - 5s par défaut
Config.SyncDeltaThreshold = 1  -- Sync seulement si changement >= ce seuil

-- ============================================
-- ÉTAT PAR DÉFAUT DU JOUEUR
-- ============================================

Config.DefaultState = {
    hunger = 100,
    thirst = 100
}

-- ============================================
-- BASE DE DONNÉES
-- ============================================

-- Table à utiliser pour la persistance
Config.Database = {
    -- true = Table custom zombie_player_stats (Protocol87)
    -- false = Table users ESX standard
    useCustomTable = false,
    customTableName = 'zombie_player_stats'
}

-- ============================================
-- VALIDATION DES DONNÉES
-- ============================================

-- Limites pour la validation serveur
Config.Validation = {
    minValue = 0,
    maxValue = 100,
    maxDecayPerSave = 10  -- Décroissance max acceptable entre deux sauvegardes (anti-cheat)
}

-- ============================================
-- SYSTÈME ANTI-CHEAT
-- ============================================

Config.AntiCheat = {
    enabled = true,                    -- Activer/désactiver l'anti-cheat
    kickOnSpam = true,                -- Kick si spam d'évents
    maxSpamAttempts = 3,              -- Nombre de tentatives de spam avant kick
    kickOnSuspiciousValues = true,    -- Kick si valeurs suspectes détectées
    suspiciousThreshold = 10          -- Augmentation anormale (>10 sans item = cheat)
}