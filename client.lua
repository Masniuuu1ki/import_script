ESX = exports.es_extended:getSharedObject()

local hasPickedUpVehicle = false
local lastOrderTime = 0
local pickupBlip, deliveryBlip
local currentVehicle, pickupZone, deliveryZone, selectedCategory, deliveryLocation, pickupLocation, endTime, bonusTimeThreshold = nil, nil, nil, nil, nil, nil, nil, nil

exports.qtarget:AddBoxZone("pickupVehicle", vector3(186.93, -1273.01, 29.2), 2.2, 1.8, {
    name = "pickupVehicle",
    heading = 0.0,
    debugPoly = false,
    minZ = 27.0,
    maxZ = 31.0
}, {
    options = {
        {
            event = "openOrderUI",
            icon = "fas fa-car",
            label = "Zlecenie",
        },
    },
    distance = 3.5
})

RegisterNetEvent('openOrderUI')
AddEventHandler('openOrderUI', function()
    local currentTime = GetGameTimer() / 1000
    if currentTime - lastOrderTime < Config.orderCooldown then
        ESX.ShowNotification("Musisz poczekać chwilę przed przyjęciem kolejnego zlecenia.")
        return
    end

    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', locations = Config.DeliveryLocations })
end)

RegisterNUICallback('selectLocation', function(data, cb)
    selectedCategory = data.location
    print('Location category selected: ' .. selectedCategory)

    local categoryData = Config.DeliveryLocations[selectedCategory]
    if not categoryData or #categoryData.locations == 0 then
        ESX.ShowNotification("Brak dostępnych lokalizacji dla wybranej kategorii.")
        cb('error')
        return
    end

    local locationIndex = math.random(1, #categoryData.locations)
    deliveryLocation = categoryData.locations[locationIndex]
    print('Location selected: ' .. deliveryLocation.name)

    local vehicleIndex = math.random(1, #Config.Vehicles)
    local vehicle = Config.Vehicles[vehicleIndex]
    print('Vehicle selected: ' .. vehicle.name)

    local pickupKeys = {}
    for k in pairs(Config.PickupLocations) do
        table.insert(pickupKeys, k)
    end
    local pickupKey = pickupKeys[math.random(#pickupKeys)]
    pickupLocation = Config.PickupLocations[pickupKey]
    print('Pickup location selected: ' .. pickupLocation.name)

    if pickupZone then
        exports.qtarget:RemoveZone(pickupZone)
        RemoveBlip(pickupBlip)
    end

    pickupZone = exports.qtarget:AddBoxZone("pickupVehicle", pickupLocation.coords, 2.2, 1.8, {
        name = "pickupVehicle",
        heading = 0.0,
        debugPoly = false,
        minZ = pickupLocation.coords.z - 2.0,
        maxZ = pickupLocation.coords.z + 2.0
    }, {
        options = {
            {
                event = "pickupVehicle",
                icon = "fas fa-car",
                label = "Odbierz pojazd",
                vehicle = vehicle.model,
                pickupKey = pickupKey
            },
        },
        distance = 3.5
    })

    pickupBlip = AddBlipForCoord(pickupLocation.coords.x, pickupLocation.coords.y, pickupLocation.coords.z)
    SetBlipSprite(pickupBlip, 225)
    SetBlipColour(pickupBlip, 3)
    SetBlipAsShortRange(pickupBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Miejsce odbioru pojazdu")
    EndTextCommandSetBlipName(pickupBlip)

    lastOrderTime = GetGameTimer() / 1000

    cb('ok')

    ESX.ShowNotification("Wybrano lokalizację: " .. deliveryLocation.name .. ". Udaj się do miejsca odbioru pojazdu.")
end)

RegisterNUICallback('hideCursor', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

function MonitorVehicleDamage(vehicle)
    CreateThread(function()
        while DoesEntityExist(vehicle) do
            local damagePercent = (GetEntityMaxHealth(vehicle) - GetEntityHealth(vehicle)) / GetEntityMaxHealth(vehicle) * 100
            local timeLeft = math.floor((endTime - GetGameTimer()) / 1000)
            lib.showTextUI('Procent zniszczeń: ' .. math.floor(damagePercent) .. '%  \n Czas pozostały: ' .. timeLeft .. 's')
            if timeLeft <= 0 then
                lib.showTextUI('Czas na dostawę minął!')
                Wait(5000)
                DeleteVehicle(vehicle)
                exports.qtarget:RemoveZone(deliveryZone)
                RemoveBlip(deliveryBlip)
                hasPickedUpVehicle, currentVehicle = false, nil
                lib.hideTextUI()
                return
            end
            Wait(1000)
        end
        lib.hideTextUI()
    end)
end


RegisterNetEvent('pickupVehicle')
AddEventHandler('pickupVehicle', function(data)
    if hasPickedUpVehicle then
        ESX.ShowNotification("Już odebrałeś pojazd.")
        return
    end

    hasPickedUpVehicle = true

    local pickupCoords = Config.PickupLocations[data.pickupKey].spawnCoords
    
    if pickupZone then
        exports.qtarget:RemoveZone(pickupZone)
        RemoveBlip(pickupBlip)
    end
    
    ESX.Game.SpawnVehicle(data.vehicle, pickupCoords, Config.PickupLocations[data.pickupKey].heading, function(vehicle)
        -- tutaj dodaj event kluczy aby je dodac
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        currentVehicle = vehicle
        
        endTime = GetGameTimer() + (Config.Timer * 1000)
        bonusTimeThreshold = Config.BonusTimer

        MonitorVehicleDamage(vehicle)
    end)

    deliveryZone = exports.qtarget:AddBoxZone("deliveryVehicle", deliveryLocation.coords, 2.2, 1.8, {
        name = "deliveryVehicle",
        heading = 0.0,
        debugPoly = false,
        minZ = deliveryLocation.coords.z - 2.0,
        maxZ = deliveryLocation.coords.z + 2.0
    }, {
        options = {
            {
                event = "deliverVehicle",
                icon = "fas fa-car",
                label = "Dostarcz pojazd",
                location = selectedCategory
            },
        },
        distance = 3.5
    })

    deliveryBlip = AddBlipForCoord(deliveryLocation.coords.x, deliveryLocation.coords.y, deliveryLocation.coords.z)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipColour(deliveryBlip, 1)
    SetBlipAsShortRange(deliveryBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Miejsce dostawy pojazdu")
    EndTextCommandSetBlipName(deliveryBlip)

    ESX.ShowNotification("Odebrałeś pojazd: " .. data.vehicle .. ". Dostarcz go do celu.")
end)

RegisterNetEvent('deliverVehicle')
AddEventHandler('deliverVehicle', function(data)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - vector3(deliveryLocation.coords.x, deliveryLocation.coords.y, deliveryLocation.coords.z))

    if distance < 10.0 then
        local damagePercent = (GetEntityMaxHealth(currentVehicle) - GetEntityHealth(currentVehicle)) / GetEntityMaxHealth(currentVehicle) * 100

        if damagePercent < 20.0 then
            exports.qtarget:RemoveZone(deliveryZone)
            RemoveBlip(deliveryBlip)
            DeleteVehicle(currentVehicle)
            hasPickedUpVehicle, currentVehicle = false, nil
            -- tutaj dodaj event kluczy aby je usunac

            local timeLeft = math.floor((endTime - GetGameTimer()) / 1000)
            local bonusApplied = false
            
            if Config.BonusTimer then
                bonusApplied = timeLeft > bonusTimeThreshold
            end
            
            TriggerServerEvent('giveDeliveryPayment', selectedCategory, damagePercent, bonusApplied)
            lib.hideTextUI()
        else
            ESX.ShowNotification("Pojazd jest zbyt uszkodzony do dostarczenia.")
        end
    else
        ESX.ShowNotification("Musisz być bliżej miejsca dostawy, aby dostarczyć pojazd.")
    end
end)
