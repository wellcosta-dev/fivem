local ESX = nil

-- Initialize ESX
Citizen.CreateThread(function()
    ESX = exports['es_extended']:getSharedObject()
    if ESX then
        print('ESX initialized successfully.')
    else
        print('Failed to initialize ESX.')
    end
end)

-- Handle the admin command to give PP
RegisterCommand('givepp', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer and xPlayer.getGroup() == 'admin' then
        local targetId = tonumber(args[1])
        local amount = tonumber(args[2])

        if targetId and amount then
            local targetPlayer = ESX.GetPlayerFromId(targetId)
            if targetPlayer then
                MySQL.Async.execute('UPDATE users SET premiumpoints = premiumpoints + @points WHERE identifier = @identifier', {
                    ['@points'] = amount,
                    ['@identifier'] = targetPlayer.identifier
                }, function(rowsChanged)
                    TriggerClientEvent('esx:showNotification', source, 'Added ' .. amount .. ' PP to player ' .. targetId)
                end)
            else
                TriggerClientEvent('esx:showNotification', source, 'Player not found')
            end
        else
            TriggerClientEvent('esx:showNotification', source, 'Invalid arguments')
        end
    else
        TriggerClientEvent('esx:showNotification', source, 'You are not an admin')
    end
end, false)

-- Get the premium points for a player
ESX.RegisterServerCallback('getPremiumPoints', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer then
        MySQL.Async.fetchScalar('SELECT premiumpoints FROM users WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier
        }, function(points)
            cb(points or 0)
        end)
    else
        cb(0)
    end
end)
