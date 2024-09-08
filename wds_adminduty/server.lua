ESX = exports['es_extended']:getSharedObject()

-- Admin duty belépés kezelése
RegisterServerEvent('adminDuty:enter')
AddEventHandler('adminDuty:enter', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and (xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin') then
        TriggerClientEvent('chat:addMessage', -1, {
            args = { '^1[Admin Duty]', xPlayer.getName() .. ' adminszolgálatba lépett!' }
        })
    end
end)

-- Admin duty kilépés kezelése
RegisterServerEvent('adminDuty:exit')
AddEventHandler('adminDuty:exit', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and (xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin') then
        TriggerClientEvent('chat:addMessage', -1, {
            args = { '^1[Admin Duty]', xPlayer.getName() .. ' kilépett az adminszolgálatból!' }
        })
    end
end)
