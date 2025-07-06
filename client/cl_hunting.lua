local QBCore = exports['qb-core']:GetCoreObject()
local baitCooldown = false

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

-- Use bait event
RegisterNetEvent('qb-hunting:usedBait', function()
    if not baitCooldown then
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        
        -- Check if player is in hunting zone
        local inZone, zoneName = IsPlayerInHuntingZone()
        if not inZone then
            QBCore.Functions.Notify('You can only use hunting bait in designated hunting zones!', 'error')
            return
        end
        
        baitCooldown = true
        
        -- Play animation
        RequestAnimDict("amb@world_human_gardener_plant@male@base")
        while not HasAnimDictLoaded("amb@world_human_gardener_plant@male@base") do
            Citizen.Wait(100)
        end
        
        TaskPlayAnim(playerPed, "amb@world_human_gardener_plant@male@base", "base", 8.0, 8.0, 3000, 1, 0, false, false, false)
        
        QBCore.Functions.Progressbar("placing_bait", "Placing hunting bait in " .. zoneName .. "...", 3000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            ClearPedTasksImmediately(playerPed)
            TriggerServerEvent('qb-hunting:removeBait')
            QBCore.Functions.Notify('Bait placed in ' .. zoneName .. '! Animals will be attracted to this area.', 'success')
            
            -- Spawn hunting animals after delay
            Citizen.SetTimeout(5000, function()
                SpawnHuntingAnimals(coords)
            end)
            
            -- Reset cooldown
            Citizen.SetTimeout(Config.BaitCooldown * 60000, function()
                baitCooldown = false
            end)
        end, function() -- Cancel
            ClearPedTasksImmediately(playerPed)
            QBCore.Functions.Notify('Cancelled placing bait', 'error')
        end)
    else
        QBCore.Functions.Notify('You must wait before using bait again', 'error')
    end
end)

-- Spawn hunting animals
function SpawnHuntingAnimals(coords)
    local animalModels = {
        `a_c_boar`,
        `a_c_deer`,
        `a_c_coyote`,
        `a_c_mtlion`
    }
    
    local randomModel = animalModels[math.random(1, #animalModels)]
    local randomOffset = math.random(10, 25)
    local randomAngle = math.random(0, 360)
    
    local spawnX = coords.x + (math.cos(math.rad(randomAngle)) * randomOffset)
    local spawnY = coords.y + (math.sin(math.rad(randomAngle)) * randomOffset)
    local spawnZ = coords.z
    
    RequestModel(randomModel)
    while not HasModelLoaded(randomModel) do
        Citizen.Wait(100)
    end
    
    local animal = CreatePed(28, randomModel, spawnX, spawnY, spawnZ, 0.0, true, false)
    SetPedAsNoLongerNeeded(animal)
    SetEntityHealth(animal, 100)
    
    print("Animal spawned at: " .. spawnX .. ", " .. spawnY .. ", " .. spawnZ)
    print("Animal entity ID: " .. animal)
    
    -- Make animal flee when player gets too close
    Citizen.CreateThread(function()
        while DoesEntityExist(animal) do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local animalCoords = GetEntityCoords(animal)
            local distance = #(playerCoords - animalCoords)
            
            if distance < 5.0 and not IsPedDeadOrDying(animal) then
                TaskSmartFleePed(animal, PlayerPedId(), 100.0, -1, false, false)
            end
            
            Citizen.Wait(1000)
        end
    end)
    
    -- Check if animal is killed
    Citizen.CreateThread(function()
        while DoesEntityExist(animal) do
            if IsPedDeadOrDying(animal) then
                print("Animal is dead - checking for player proximity")
                local netId = NetworkGetNetworkIdFromEntity(animal)
                local animalCoords = GetEntityCoords(animal)
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - animalCoords)
                
                print("Distance to dead animal: " .. distance)
                
                if distance < 3.0 then
                    print("Showing skin animal prompt")
                    exports['qb-core']:DrawText('[E] - Skin Animal', 'left')
                    
                    if IsControlJustReleased(0, 38) then -- E key
                        print("Player pressed E to skin animal")
                        exports['qb-core']:HideText()
                        SkinAnimal(animal, netId)
                        break
                    end
                else
                    exports['qb-core']:HideText()
                end
            end
            Citizen.Wait(100) -- Faster check for better responsiveness
        end
    end)
end

-- Skin animal
function SkinAnimal(animal, netId)
    local playerPed = PlayerPedId()
    
    print("Starting skinning process...")
    
    RequestAnimDict("amb@world_human_gardener_plant@male@base")
    while not HasAnimDictLoaded("amb@world_human_gardener_plant@male@base") do
        Citizen.Wait(100)
    end
    
    TaskPlayAnim(playerPed, "amb@world_human_gardener_plant@male@base", "base", 8.0, 8.0, 5000, 1, 0, false, false, false)
    
    QBCore.Functions.Progressbar("skinning_animal", "Skinning animal...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        print("Skinning completed successfully")
        ClearPedTasksImmediately(playerPed)
        TriggerServerEvent('qb-hunting:skinReward')
        TriggerServerEvent('qb-hunting:delete', netId)
        QBCore.Functions.Notify('Animal skinned successfully!', 'success')
    end, function() -- Cancel
        print("Skinning was cancelled")
        ClearPedTasksImmediately(playerPed)
        QBCore.Functions.Notify('Cancelled skinning', 'error')
    end)
end