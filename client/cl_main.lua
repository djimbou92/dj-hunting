local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local isLoggedIn = false
local huntingShopOpen = false
local nearHuntingShop = false
local huntingShopPed = nil

-- Player data events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true
    print("Player loaded - hunting shop script active")
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

-- Initialize if already logged in
Citizen.CreateThread(function()
    if LocalPlayer.state.isLoggedIn then
        PlayerData = QBCore.Functions.GetPlayerData()
        isLoggedIn = true
        print("Player already logged in - hunting shop script active")
    end
end)

-- Hunting Shop Configuration
local HuntingShop = {
    coords = vector3(-680.42, 5838.3, 17.33), -- Paleto Bay hunting area
    heading = 225.0,
    model = `ig_hunter`,
    scenario = "WORLD_HUMAN_SMOKING",
}

-- Shop Items
local ShopItems = {
    [1] = {
        name = "weapon_musket", 
        price = 8000,
        amount = 1,
        info = {},
        type = "item",
        slot = 1,
    },
    [2] = {
        name = "huntingbait",
        price = 250,
        amount = 10,
        info = {},
        type = "item",
        slot = 2,
    },
    [3] = {
        name = "skinning_knife",
        price = 150,
        amount = 1,
        info = {},
        type = "item",
        slot = 3,
    },
}

-- Spawn hunting shop NPC
Citizen.CreateThread(function()
    RequestModel(HuntingShop.model)
    while not HasModelLoaded(HuntingShop.model) do
        Wait(1)
    end
    
    huntingShopPed = CreatePed(4, HuntingShop.model, HuntingShop.coords.x, HuntingShop.coords.y, HuntingShop.coords.z - 1, HuntingShop.heading, false, true)
    SetPedFleeAttributes(huntingShopPed, 0, 0)
    SetPedDiesWhenInjured(huntingShopPed, false)
    TaskStartScenarioInPlace(huntingShopPed, HuntingShop.scenario, 0, true)
    SetPedKeepTask(huntingShopPed, true)
    SetBlockingOfNonTemporaryEvents(huntingShopPed, true)
    SetEntityInvincible(huntingShopPed, true)
    FreezeEntityPosition(huntingShopPed, true)
    
    -- Create blip for hunting shop
    local blip = AddBlipForCoord(HuntingShop.coords.x, HuntingShop.coords.y, HuntingShop.coords.z)
    SetBlipSprite(blip, 141) -- Hunting/animal icon
    SetBlipColour(blip, 2) -- Green
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Hunting Shop')
    EndTextCommandSetBlipName(blip)
    
    print("Hunting shop NPC spawned at: " .. HuntingShop.coords.x .. ", " .. HuntingShop.coords.y .. ", " .. HuntingShop.coords.z)
end)

-- Create hunting zone blips
Citizen.CreateThread(function()
    for _, zone in pairs(Config.HuntingZones) do
        -- Create zone blip
        local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
        SetBlipSprite(blip, 442) -- Hunting zone icon
        SetBlipColour(blip, 5) -- Yellow
        SetBlipScale(blip, 1.0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(zone.name)
        EndTextCommandSetBlipName(blip)
        
        -- Create radius blip
        local radiusBlip = AddBlipForRadius(zone.coords.x, zone.coords.y, zone.coords.z, zone.radius)
        SetBlipColour(radiusBlip, 5) -- Yellow
        SetBlipAlpha(radiusBlip, 100) -- Semi-transparent
    end
end)

-- Main thread for checking player distance
Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - HuntingShop.coords)
            
            if distance < 3.0 then
                if not nearHuntingShop then
                    nearHuntingShop = true
                    print("Near hunting shop - showing E prompt")
                    exports['qb-core']:DrawText('[E] - Open Hunting Shop', 'left')
                end
            else
                if nearHuntingShop then
                    nearHuntingShop = false
                    print("Left hunting shop - hiding E prompt")
                    exports['qb-core']:HideText()
                end
            end
        end
        Citizen.Wait(500)
    end
end)

-- Key Controls
Citizen.CreateThread(function()
    while true do
        if nearHuntingShop and not huntingShopOpen and isLoggedIn then
            if IsControlJustReleased(0, 38) then -- E key
                OpenHuntingShop()
            end
        end
        Citizen.Wait(1)
    end
end)

-- Open hunting shop
function OpenHuntingShop()
    huntingShopOpen = true
    exports['qb-core']:HideText()
    print("Opening hunting shop with items:")
    for i, item in pairs(ShopItems) do
        print("Slot " .. i .. ": " .. item.name .. " - $" .. item.price)
    end
    
    -- Try original inventory shop first
    TriggerEvent("inventory:client:OpenShop", ShopItems)
    
    -- If that doesn't work, create a simple purchase menu
    Citizen.SetTimeout(1000, function()
        if huntingShopOpen then
            OpenCustomShop()
        end
    end)
end

-- Custom shop menu as backup
function OpenCustomShop()
    local shopMenu = {
        {
            header = "🎯 Hunting Shop",
            isMenuHeader = true
        },
        {
            header = "🔫 Musket",
            txt = "Classic hunting musket - $8,000",
            params = {
                event = "qb-hunting:client:buyWeapon",
                args = {
                    weapon = "weapon_musket",
                    price = 8000
                }
            }
        },
        {
            header = "🔪 Skinning Knife",
            txt = "Sharp knife for skinning animals only - $150",
            params = {
                event = "qb-hunting:client:buyItem",
                args = {
                    item = "skinning_knife",
                    price = 150,
                    amount = 1
                }
            }
        },
        {
            header = "🎣 Hunting Bait (10x)",
            txt = "Attract animals to your location - $250",
            params = {
                event = "qb-hunting:client:buyItem",
                args = {
                    item = "huntingbait",
                    price = 250,
                    amount = 10
                }
            }
        },
        {
            header = "🔫 Reload Ammo",
            txt = "Reload hunting weapon - $500",
            params = {
                event = "qb-hunting:client:buyAmmo",
                args = {
                    price = 500
                }
            }
        },
        {
            header = "❌ Close",
            params = {
                event = "qb-hunting:client:closeShop"
            }
        }
    }
    
    exports['qb-menu']:openMenu(shopMenu)
end

-- Client events for purchases
RegisterNetEvent('qb-hunting:client:buyWeapon', function(data)
    TriggerServerEvent('qb-hunting:buy:weapon', data.weapon, data.price)
    exports['qb-menu']:closeMenu()
    huntingShopOpen = false
end)

RegisterNetEvent('qb-hunting:client:buyItem', function(data)
    TriggerServerEvent('qb-hunting:buy:item', data.item, data.price, data.amount)
    exports['qb-menu']:closeMenu()
    huntingShopOpen = false
end)

RegisterNetEvent('qb-hunting:client:buyAmmo', function(data)
    TriggerServerEvent('qb-hunting:buy:ammo')
    exports['qb-menu']:closeMenu()
    huntingShopOpen = false
end)

RegisterNetEvent('qb-hunting:client:closeShop', function()
    exports['qb-menu']:closeMenu()
    huntingShopOpen = false
    if nearHuntingShop then
        exports['qb-core']:DrawText('[E] - Open Hunting Shop', 'left')
    end
end)

-- Close hunting shop
RegisterNetEvent('inventory:client:ShopClose', function()
    huntingShopOpen = false
    if nearHuntingShop then
        exports['qb-core']:DrawText('[E] - Open Hunting Shop', 'left')
    end
end)

-- Set ammo after purchase
RegisterNetEvent('qb-hunting:setammo', function()
    local ped = PlayerPedId()
    GiveWeaponToPed(ped, GetHashKey("weapon_musket"), 30, false, true)
end)

-- Check if player is in hunting zone
function IsPlayerInHuntingZone()
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    for _, zone in pairs(Config.HuntingZones) do
        local distance = #(playerCoords - zone.coords)
        if distance <= zone.radius then
            return true, zone.name
        end
    end
    
    return false, nil
end

-- Weapon damage restriction for hunting weapons
Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            local playerPed = PlayerPedId()
            local currentWeapon = GetSelectedPedWeapon(playerPed)
            
            -- Check if player has hunting weapon equipped
            for _, weapon in pairs(Config.HuntingWeapons) do
                if currentWeapon == GetHashKey(weapon) then
                    local inZone, zoneName = IsPlayerInHuntingZone()
                    
                    if not inZone then
                        -- Remove weapon if outside hunting zone
                        RemoveWeaponFromPed(playerPed, currentWeapon)
                        QBCore.Functions.Notify('Hunting weapons can only be used in designated hunting zones!', 'error')
                    end
                    break
                end
            end
        end
        Citizen.Wait(2000) -- Check every 2 seconds
    end
end)

-- Prevent PvP damage from hunting weapons
AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        local attacker = args[2]
        local weapon = args[7]
        
        -- Check if victim is a player and weapon is hunting weapon
        if IsPedAPlayer(victim) and IsPedAPlayer(attacker) then
            for _, huntingWeapon in pairs(Config.HuntingWeapons) do
                if weapon == GetHashKey(huntingWeapon) then
                    -- Cancel damage to players from hunting weapons
                    SetEntityHealth(victim, GetEntityMaxHealth(victim))
                    TriggerEvent('QBCore:Notify', 'Hunting weapons cannot be used against players!', 'error')
                    break
                end
            end
        end
    end
end)
