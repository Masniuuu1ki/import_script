Config = {}

Config.Timer = 100 -- w sekundach ((czas w ktory musi dostarczyc pojazd inaczej pojazd zniknie))
Config.BonusTimer = 40 -- bonusowy czas w sekundach ((gracz dostaje bonus gdy zostanie mu np. 300 sekund)) / lub false
Config.MoneyItem = 'money' -- item pieniedzy
Config.orderCooldown = 60 -- w sekundach ((co ile gracz moze robic zlecenie))

Config.Vehicles = {
    {model = "adder", name = "Adder"},
    {model = "zentorno", name = "Zentorno"}, -- pojazdy ktore gracz dostarcza
    {model = "t20", name = "T20"}
}

Config.PickupLocations = {
    odbior1 = {
        name = "odbior1",
        coords = vector3(301.93, -191.22, 61.57), -- target
        spawnCoords = vector3(298.09, -195.46, 60.85), -- spawn pojazdu
        heading = 180.53
    },
    odbior2 = {
        name = "odbior2",
        coords = vector3(436.34, -647.20, 28.74), -- target
        spawnCoords = vector3(430.80, -642.91, 27.78), -- spawn pojazdu
        heading = 65.66
    },
    odbior3 = {
        name = "odbior3",
        coords = vector3(943.36, -1458.63, 31.47), -- target 
        spawnCoords = vector3(929.16, -1449.18, 30.44), -- spawn pojazdu
        heading = 266.53
    }
}

Config.DeliveryLocations = {
    ["Los Santos"] = {
        price = 500, -- cena poczatkowa za dostarczenie ((zmienia się automatycznie również w UI))
        locations = {
            {name = "Centrum", coords = vector3(215.32, -810.54, 30.73)}, -- miejsce dostawy ((target))
            {name = "Vinewood", coords = vector3(-46.91, -1108.18, 26.67)}, -- miejsce dostawy ((target))
            {name = "Plaża", coords = vector3(-867.63, -1274.60, 5.15)} -- miejsce dostawy ((target))
        }
    },
    ["Grapseed"] = {
        price = 600,
        locations = {
            {name = "Farm", coords = vector3(1707.52, 4730.26, 42.16)}, -- miejsce dostawy ((target)) 
            {name = "Main Street", coords = vector3(1682.79, 4689.28, 43.06)}, -- miejsce dostawy ((target)) 
            {name = "Gas Station", coords = vector3(1696.32, 4785.07, 42.03)} -- miejsce dostawy ((target))
        }
    },
    ["Paleto Bay"] = {
        price = 1500,
        locations = {
            {name = "Pier", coords = vector3(-347.61, 6225.25, 31.88)}, -- miejsce dostawy ((target)) 
            {name = "Main Street", coords = vector3(-326.58, 6228.38, 31.50)}, -- miejsce dostawy ((target)) 
            {name = "Sheriff's Office", coords = vector3(-84.88, 6497.51, 31.49)} -- miejsce dostawy ((target))
        }
    }
}