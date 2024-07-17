ESX = exports.es_extended:getSharedObject()

RegisterNetEvent('giveDeliveryPayment')
AddEventHandler('giveDeliveryPayment', function(category, damagePercent, bonusApplied)
    local xPlayer = ESX.GetPlayerFromId(source)
    local payment = Config.DeliveryLocations[category].price

    if not payment or type(payment) ~= 'number' then
        print('Nieprawidłowa kwota płatności dla kategorii: ' .. tostring(category))
        return
    end

    local finalPayment = math.max(0, math.floor(payment * (1 - (damagePercent / 100))))

    if bonusApplied then
        finalPayment = math.floor(finalPayment * 1.1)
    end

    exports.ox_inventory:AddItem(source, Config.MoneyItem, finalPayment)
    TriggerClientEvent('esx:showNotification', source, "Dostarczono pojazd. Otrzymujesz: $" .. finalPayment)
end)
