# Hunger & Thirst System

Système de faim et soif optimisé pour FiveM avec interface NUI Svelte. Conçu pour les serveurs multijoueurs avec focus sur la performance et la sécurité.

## Caractéristiques

- **Architecture serveur-side** : Toute la logique métier est gérée côté serveur
- **Performance optimisée** : Un seul thread serveur pour tous les joueurs, aucune boucle client
- **Sécurité renforcée** : Anti-cheat intégré avec détection de manipulation et spam
- **Interface moderne** : NUI Svelte réactive avec seuils visuels
- **Persistance BDD** : Sauvegarde automatique à la déconnexion via oxmysql
- **Compatible ESX** : Intégration native avec es_extended

## Prérequis

- **es_extended** (ESX Legacy ou supérieur)
- **oxmysql** (base de données)
- Table `users` ESX avec colonnes `identifier` (ou table custom selon config)

## Installation

1. Placer le dossier `a_needs` dans `resources/`

2. **Configuration de la base de données** dans `Config/config.lua` :
   ```lua
   Config.Database = {
       useCustomTable = false,  -- false = table users ESX standard
       customTableName = 'zombie_player_stats'
   }
   ```
   - `useCustomTable = false` : Utilise la table `users` standard d'ESX
   - `useCustomTable = true` : Utilise une table custom (configurer `customTableName`)

3. Ajouter dans `server.cfg` :
   ```cfg
   ensure a_needs
   ```

4. Les colonnes `hunger` et `thirst` seront automatiquement ajoutées au démarrage si nécessaire

## Configuration

Fichier : `Config/config.lua`

```lua
-- Valeurs maximales
Config.MaxHunger = 100
Config.MaxThirst = 100

-- Taux de décroissance (par seconde)
Config.HungerDecayRate = 0.05  -- ~5% par minute
Config.ThirstDecayRate = 0.08  -- ~8% par minute

-- Système de dégâts
Config.DamageWhenEmpty = 1
Config.DamageInterval = 5000

-- Anti-cheat
Config.AntiCheat = {
    enabled = true,
    kickOnSpam = true,
    maxSpamAttempts = 3,
    kickOnSuspiciousValues = true,
    suspiciousThreshold = 10
}
```

## Utilisation des Exports

### Côté Serveur

Les exports sont **exclusivement disponibles côté serveur** pour des raisons de sécurité.

#### Ajouter de la faim

```lua
-- Exemple : Consommation d'un item nourriture
exports['a_needs']:AddHunger(source, 20)
```

**Paramètres :**
- `source` (number) : ID du joueur
- `amount` (number) : Quantité à ajouter (0-100)

#### Ajouter de la soif

```lua
-- Exemple : Consommation d'une boisson
exports['a_needs']:AddThirst(source, 30)
```

**Paramètres :**
- `source` (number) : ID du joueur
- `amount` (number) : Quantité à ajouter (0-100)

#### Définir la faim

```lua
-- Exemple : Respawn ou commande admin
exports['a_needs']:SetHunger(source, 100)
```

**Paramètres :**
- `source` (number) : ID du joueur
- `value` (number) : Nouvelle valeur (0-100)

#### Définir la soif

```lua
-- Exemple : Respawn ou commande admin
exports['a_needs']:SetThirst(source, 100)
```

**Paramètres :**
- `source` (number) : ID du joueur
- `value` (number) : Nouvelle valeur (0-100)

### Intégration avec ox_inventory

**Configuration automatique** : a_needs lit les valeurs `client.status.hunger` et `client.status.thirst` depuis les définitions d'items ox_inventory.

#### Configuration rapide (2 étapes)

1. **Modifier vos items dans `ox_inventory/data/items.lua`** :

```lua
['bread'] = {
    label = 'Pain',
    weight = 150,
    client = {
        status = { hunger = 200000 },  -- Sera converti en +20 faim
        anim = 'eating'
    },
    server = {
        export = 'a_needs.consumeFood'
    }
}

['water'] = {
    label = 'Eau',
    weight = 330,
    client = {
        status = { thirst = 200000 },  -- Sera converti en +20 soif
        anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' }
    },
    server = {
        export = 'a_needs.consumeDrink'
    }
}
```

2. **Restart** : `restart ox_inventory` puis `restart a_needs`

#### Conversion automatique

Le système convertit automatiquement les valeurs esx_status (200000 = 20%) :
- `hunger = 200000` → +20 faim
- `thirst = 200000` → +20 soif

Configurable via `Config.UseOxInventory` dans `config/config.lua`.

#### Exports disponibles

- `a_needs.consumeFood` : Nourriture (lit `client.status.hunger`)
- `a_needs.consumeDrink` : Boisson (lit `client.status.thirst`)

**Valeurs par défaut si non configurées** : +20 faim, +30 soif

## Structure des Fichiers

```
a_needs/
├── Config/
│   └── config.lua          # Configuration partagée
├── client/
│   ├── functions.lua       # Fonctions utilitaires client
│   ├── events.lua          # Gestion des events réseau
│   └── threads.lua         # Initialisation
├── server/
│   ├── functions.lua       # Cache et validation
│   ├── database.lua        # Persistance oxmysql
│   ├── events.lua          # Events réseau + anti-cheat
│   ├── threads.lua         # Décroissance + dégâts
│   └── exports.lua         # API publique
├── ui/                     # Interface NUI Svelte
└── fxmanifest.lua
```

## Base de Données

Le script s'adapte à votre configuration via `Config.Database` :

- **Table standard** (`useCustomTable = false`) : Utilise la table `users` d'ESX
- **Table custom** (`useCustomTable = true`) : Utilise la table configurée dans `customTableName`

Les colonnes `hunger` et `thirst` sont automatiquement ajoutées au démarrage si elles n'existent pas.

**Sauvegarde :**
- Automatique à la déconnexion du joueur
- Aucune sauvegarde périodique (optimisation performances)

## Système Anti-Cheat

### Détections

1. **Spam d'events** : Kick après 3 tentatives en 5 secondes
2. **Manipulation de valeurs** : Détection d'augmentation anormale (>10 sans item)

### Configuration

```lua
Config.AntiCheat = {
    enabled = true,              -- Activer/désactiver
    kickOnSpam = true,          -- Kick sur spam
    maxSpamAttempts = 3,        -- Tentatives max
    kickOnSuspiciousValues = true,  -- Kick sur valeurs suspectes
    suspiciousThreshold = 10    -- Seuil de détection
}
```

### Messages de kick

- `[A_NEEDS] Anti-cheat: Spam d'évents détecté`
- `[A_NEEDS] Anti-cheat: Manipulation de valeurs détectée`

## Fonctionnement

### Architecture

1. **Thread serveur unique** : Gère la décroissance pour tous les joueurs (1000ms)
2. **Thread dégâts** : Applique les dégâts via ESX quand hunger/thirst <= 0 (5000ms)
3. **Cache serveur** : Source de vérité, synchronisé avec le client pour l'UI
4. **Client passif** : Reçoit les mises à jour et affiche l'interface

### Flux de données

```
Démarrage serveur → Initialisation threads → Chargement BDD
    ↓
Connexion joueur → Cache serveur → Sync Client (UI)
    ↓
Décroissance (serveur) → Cache mis à jour → Client sync
    ↓
Consommation item → Export → Cache + Client
    ↓
Déconnexion → Sauvegarde BDD → Nettoyage cache
```

## Performance

- **1 thread serveur** pour tous les joueurs (vs N threads clients)
- **0 boucle côté client** (vs 3+ dans solutions classiques)
- **Sauvegarde BDD minimale** (uniquement déconnexion)
- **Cache mémoire** pour accès rapide
- **Validation côté serveur** pour sécurité

## Support

Pour toute question ou problème, vérifiez :
1. Que `es_extended` et `oxmysql` sont démarrés
2. Que la table configurée dans `Config.Database` existe
3. Les logs serveur pour messages d'erreur

## Licence

Propriétaire - Ahero

## Aperçu

![Interface Hunger & Thirst](https://image.noelshack.com/fichiers/2025/52/4/1766680822-hud-faim-soif.jpg)