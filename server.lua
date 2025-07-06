QBCore = exports['qb-core']:GetCoreObject()


RegisterServerEvent('qb-hunting:skinReward')
AddEventHandler('qb-hunting:skinReward', function()
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  local randomAmount = math.random(1,100)
  local item = 'huntingcarcass1' -- Default to lowest quality

  if randomAmount >= 1 and randomAmount <= 60 then
    item = 'huntingcarcass1'  -- 60% chance
  elseif randomAmount >= 61 and randomAmount <= 85 then
    item = 'huntingcarcass2'  -- 25% chance
  elseif randomAmount >= 86 and randomAmount <= 95 then
    item = 'huntingcarcass3'  -- 10% chance
  elseif randomAmount >= 96 and randomAmount <= 100 then
    item = 'huntingcarcass4'  -- 5% chance
  end

  Player.Functions.AddItem(item, 1)
  TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add")
end)

RegisterServerEvent('qb-hunting:removeBait')
AddEventHandler('qb-hunting:removeBait', function()
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  Player.Functions.RemoveItem("huntingbait", 1)
end)

RegisterServerEvent('qb-hunting:buy:ammo')
AddEventHandler('qb-hunting:buy:ammo', function()
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  if Player.PlayerData.money['cash'] >= 500 then
    Player.Functions.RemoveMoney('cash', 500)
    TriggerClientEvent("qb-hunting:setammo", src)
    TriggerClientEvent("QBCore:Notify", src, 'Ammo purchased and loaded!', 'success')
  else
    TriggerClientEvent("QBCore:Notify", src, 'Not enough cash on you.', 'error')
  end
end)

RegisterServerEvent('qb-hunting:buy:bait')
AddEventHandler('qb-hunting:buy:bait', function()
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  if Player.PlayerData.money['cash'] >= 250 then
    Player.Functions.RemoveMoney('cash', 250)
    Player.Functions.AddItem('huntingbait', 5)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['huntingbait'], "add", 5)
    TriggerClientEvent("QBCore:Notify", src, 'Hunting bait purchased!', 'success')
  else
    TriggerClientEvent("QBCore:Notify", src, 'Not enough cash on you.', 'error')
  end
end)

RegisterServerEvent('qb-hunting:buy:knife')
AddEventHandler('qb-hunting:buy:knife', function()
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  if Player.PlayerData.money['cash'] >= 150 then
    Player.Functions.RemoveMoney('cash', 150)
    Player.Functions.AddItem('skinning_knife', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['skinning_knife'], "add", 1)
    TriggerClientEvent("QBCore:Notify", src, 'Skinning knife purchased!', 'success')
  else
    TriggerClientEvent("QBCore:Notify", src, 'Not enough cash on you.', 'error')
  end
end)

QBCore.Functions.CreateUseableItem("huntingbait", function(source, item)
  local Player = QBCore.Functions.GetPlayer(source)

  TriggerClientEvent('qb-hunting:usedBait', source)
end)


local carcasses = {
  huntingcarcass1 = 450,
  huntingcarcass2 = 800,
  huntingcarcass3 = 2100,
  huntingcarcass4 = 2600
}

RegisterServerEvent('qb-hunting:server:sell')
AddEventHandler('qb-hunting:server:sell', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local whatSold = {};
    local total = 0;

    for k,v in pairs(carcasses) do
        local item = Player.Functions.GetItemByName(k)
        if item ~= nil then
            if Player.Functions.RemoveItem(k, item.amount) then
                local price = v * item.amount;
                table.insert(whatSold, ('`%dx` %s - `$%d`'):format(item.amount, item.label, price));
                total = total + price;
            end
        end
    end

    Player.Functions.AddMoney('cash', total)

end)

RegisterNetEvent('qb-hunting:delete', function(netId)
  local ent = NetworkGetEntityFromNetworkId(netId)
  if DoesEntityExist(ent) then
    DeleteEntity(ent)
  end
end)

-- Shop purchase events
RegisterServerEvent('qb-hunting:buy:weapon')
AddEventHandler('qb-hunting:buy:weapon', function(weaponName, price)
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  
  if Player.PlayerData.money['cash'] >= price then
    Player.Functions.RemoveMoney('cash', price)
    Player.Functions.AddItem(weaponName, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[weaponName], "add", 1)
    TriggerClientEvent("QBCore:Notify", src, 'Weapon purchased successfully!', 'success')
  else
    TriggerClientEvent("QBCore:Notify", src, 'Not enough cash on you.', 'error')
  end
end)

RegisterServerEvent('qb-hunting:buy:item')
AddEventHandler('qb-hunting:buy:item', function(itemName, price, amount)
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  
  if Player.PlayerData.money['cash'] >= price then
    Player.Functions.RemoveMoney('cash', price)
    Player.Functions.AddItem(itemName, amount or 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "add", amount or 1)
    TriggerClientEvent("QBCore:Notify", src, 'Item purchased successfully!', 'success')
  else
    TriggerClientEvent("QBCore:Notify", src, 'Not enough cash on you.', 'error')
  end
end)