local ESX = nil

-- Initialize ESX
Citizen.CreateThread(function()
    ESX = exports['es_extended']:getSharedObject()
end)

-- Open Premium Points UI
RegisterCommand('pp', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
end, false)

-- Handle NUI callbacks
RegisterNUICallback('close', function()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end)

-- Handle NUI callbacks
RegisterNUICallback('getPP', function(_, cb)
    if ESX then
        ESX.TriggerServerCallback('getPremiumPoints', function(points)
            cb({ points = points })
        end)
    else
        cb({ points = 0 })
    end
end)
