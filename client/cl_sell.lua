local QBCore = exports['qb-core']:GetCoreObject()
local nearSellPoint = false

-- Sell point location (Butcher)
local SellPoint = {
    coords = vector3(-1337.23, -1278.11, 4.88), -- Butcher shop
    heading = 0.0,
    model = `s_m_y_butcher_01`,
}

-- Spawn sell point NPC
Citizen.CreateThread(function()
    RequestModel(SellPoint.model)
    while not HasModelLoaded(SellPoint.model) do
        Wait(1)
    end
    
    local sellPed = CreatePed(4, SellPoint.model, SellPoint.coords.x, SellPoint.coords.y, SellPoint.coords.z - 1, SellPoint.heading, false, true)
    SetPedFleeAttributes(sellPed, 0, 0)
    SetPedDiesWhenInjured(sellPed, false)
    SetPedKeepTask(sellPed, true)
    SetBlockingOfNonTemporaryEvents(sellPed, true)
    SetEntityInvincible(sellPed, true)
    FreezeEntityPosition(sellPed, true)
    
    -- Create blip for sell point
    local blip = AddBlipForCoord(SellPoint.coords.x, SellPoint.coords.y, SellPoint.coords.z)
    SetBlipSprite(blip, 141) -- Hunting/animal icon
    SetBlipColour(blip, 1) -- Red
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Hunting Sell Point')
    EndTextCommandSetBlipName(blip)
    
    print("Hunting sell point NPC spawned at: " .. SellPoint.coords.x .. ", " .. SellPoint.coords.y .. ", " .. SellPoint.coords.z)
end)

-- Check distance to sell point
Citizen.CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - SellPoint.coords)
        
        if distance < 3.0 then
            if not nearSellPoint then
                nearSellPoint = true
                exports['qb-core']:DrawText('[E] - Sell Carcasses', 'left')
            end
        else
            if nearSellPoint then
                nearSellPoint = false
                exports['qb-core']:HideText()
            end
        end
        Citizen.Wait(500)
    end
end)

-- Sell controls
Citizen.CreateThread(function()
    while true do
        if nearSellPoint then
            if IsControlJustReleased(0, 38) then -- E key
                exports['qb-core']:HideText()
                TriggerServerEvent('qb-hunting:server:sell')
            end
        end
        Citizen.Wait(1)
    end
end)