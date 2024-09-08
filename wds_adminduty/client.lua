ESX = exports['es_extended']:getSharedObject()
local showName = true
local isOnAdminDuty = false

-- Várakozás az ESX adatainak betöltésére
Citizen.CreateThread(function()
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
end)

-- /beallitasok parancs kezelés
RegisterCommand('beallitasok', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open'
    })
end)

-- /admin parancs kezelés
RegisterCommand('admin', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openAdminPanel',
        isOnAdminDuty = isOnAdminDuty
    })
end)

-- NUI Callback a név megjelenítésének kapcsolásához
RegisterNUICallback('toggleName', function(data, cb)
    showName = data.showName
    cb('ok')
end)

-- NUI Callback az admin duty állapotának kezeléséhez
RegisterNUICallback('toggleAdminDuty', function(data, cb)
    isOnAdminDuty = data.isOnAdminDuty
    if isOnAdminDuty then
        TriggerServerEvent('adminDuty:enter')
    else
        TriggerServerEvent('adminDuty:exit')
    end
    cb('ok')
end)

-- NUI Callback az ablak bezárásához
RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
    cb('ok')
end)

-- A karakter neve és admin státusz megjelenítése
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if showName then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local characterName = GetPlayerCharacterName()
            local playerId = GetPlayerServerId(PlayerId())
            local isAdmin = IsPlayerAdmin()

            if characterName then
                local displayName = "[" .. playerId .. "] " .. characterName
                if isAdmin and isOnAdminDuty then
                    displayName = displayName .. " ~g~[Admin]"
                end
                DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z + 1.0, displayName)
            end
        end
    end
end)

-- Karakter név lekérése
function GetPlayerCharacterName()
    local playerData = ESX.GetPlayerData()
    local firstName = playerData.firstName
    local lastName = playerData.lastName
    return firstName .. ' ' .. lastName
end

-- Admin státusz ellenőrzése
function IsPlayerAdmin()
    local playerData = ESX.GetPlayerData()
    return playerData.group == 'admin' or playerData.group == 'superadmin'
end

-- Szöveg megjelenítése 3D-ben
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(pX, pY, pZ, x, y, z, 1)
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        SetTextScale(0.35 * scale, 0.35 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 0)
        SetTextEdge(0, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
