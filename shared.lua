Config = {}

Config.BaitCooldown = 1

-- Hunting Zones Configuration
Config.UseZones = true -- Only allow hunting in specific zones
Config.HuntingZones = {
    {
        name = "Paleto Bay Hunting Area",
        coords = vector3(-680.42, 5838.3, 17.33),
        radius = 500.0, -- 500 meter radius
    },
    {
        name = "Mount Chiliad Hunting Area", 
        coords = vector3(501.0, 5604.0, 797.0),
        radius = 400.0,
    },
    {
        name = "Grapeseed Hunting Area",
        coords = vector3(2560.0, 4680.0, 34.0),
        radius = 300.0,
    }
}

-- Weapon restrictions
Config.HuntingWeapons = {
    'weapon_musket'
}

Config.EnableShopBlip = true

--Config.TimeBeforeBaitStarts = 5000 -- (20000 = 20 seconds, this is to give the player enough time to move away from the bait )
--Config.GiveOtherItem = false -- If you want to give other item or not
--Config.DistanceAnimalsSpook = 1 -- Distance the player can get to a baited target before it runs(Mtlions will attack at this range)

--Config.EnablePoaching = false
--Config.IllegalPelt = 'illegalcarcass'

--Config.HuntingAnimals = {'a_c_boar','a_c_deer','a_c_coyote','a_c_mtlion'}

--Config.UseZones = true -- If true, Only allow hunting in specific Zones
--Config.Zones = {
--  'MTCHIL',
--  'CANNY',
--  'MTGORDO',
--  'CMSW',
--  'MTJOSE'
--}