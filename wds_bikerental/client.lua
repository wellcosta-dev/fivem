local pedModel = 'a_m_m_business_01'
local pedCoords = vector3(-234.0723, -965, 30)
local pedHeading = 245.5642

local blipCoords = vector3(-234.0723, -968.9327, 29.2879)
local markerSize = 1.0 -- Marker mérete

local bikeSpawned = false
local bikeEntity = nil
local timer = 0
local showNUI = false
local bikeSpawnTime = 0
local countdownInterval = 1000 -- 1 másodperc

-- Create ped and blip on resource start
Citizen.CreateThread(function()
    -- Load ped model
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Citizen.Wait(500)
    end

    -- Create ped
    local ped = CreatePed(4, pedModel, pedCoords.x, pedCoords.y, pedCoords.z, pedHeading, false, true)
    SetPedAsNoLongerNeeded(ped)

    -- Create blip
    local blip = AddBlipForCoord(blipCoords)
    SetBlipSprite(blip, 348)
    SetBlipColour(blip, 2) -- Zöld szín
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Biciklibérlő")
    EndTextCommandSetBlipName(blip)

    -- Marker és NUI kezelése
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        -- Marker megjelenítése
        if GetDistanceBetweenCoords(playerCoords, blipCoords, true) < 10.0 then
            DrawMarker(38, blipCoords.x, blipCoords.y, blipCoords.z - 1.0, 0, 0, 0, 0, 0, 0, markerSize, markerSize, markerSize, 0, 255, 0, 255, false, false, 2, false, false, false, false)

            -- NUI megjelenítése, ha a játékos az egyenlő távolságon belül van és lenyomja az "E" gombot
            if GetDistanceBetweenCoords(playerCoords, blipCoords, true) < 2.0 then
                if IsControlJustPressed(1, 38) then -- E billentyű
                    showNUI = true
                    SetNuiFocus(true, true)
                    SendNUIMessage({ action = 'show' })
                end
            end
        else
            if showNUI then
                SetNuiFocus(false, false)
                SendNUIMessage({ action = 'hide' })
                showNUI = false
            end
        end
    end
end)

-- NUI callbackok kezelése
RegisterNUICallback('rentBike', function(data, cb)
    if not bikeSpawned then
        -- Bicikli spawnolása
        local playerPed = PlayerPedId()
        local bike = CreateVehicle(GetHashKey('tribike3'), pedCoords.x + 2, pedCoords.y, pedCoords.z, pedHeading, true, false)
        TaskWarpPedIntoVehicle(playerPed, bike, -1)
        bikeEntity = bike
        bikeSpawned = true
        timer = GetGameTimer()
        bikeSpawnTime = GetGameTimer()
        SetEntityAsNoLongerNeeded(bike)
        -- NUI bezárása
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'hide' })
        showNUI = false
        TriggerEvent('chat:addMessage', { args = { 'A biciklit sikeresen kibérelted!' } })
    end
    cb({ success = true })
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide' })
    showNUI = false
    cb({ success = true })
end)

-- Bicikli kezelése
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(countdownInterval) -- Ellenőrzés minden másodpercben
        if bikeSpawned and bikeEntity then
            local playerPed = PlayerPedId()
            local bikeCoords = GetEntityCoords(bikeEntity)
            local playerCoords = GetEntityCoords(playerPed)
            local currentTime = GetGameTimer()

            -- Ellenőrzés, hogy a játékos eltávolodott-e a bicikliről
            if GetDistanceBetweenCoords(playerCoords, bikeCoords, true) > 10.0 and not IsPedInAnyVehicle(playerPed, false) then
                local elapsedTime = currentTime - bikeSpawnTime
                local remainingTime = 900000 - elapsedTime -- 15 perc = 900000 ms

                if remainingTime <= 0 then
                    DeleteVehicle(bikeEntity)
                    bikeSpawned = false
                else
                    -- Chat értesítések
                    if remainingTime <= 5000 then
                        TriggerEvent('chat:addMessage', { args = { '5 másodperc van hátra, a bicikli törlődik!' } })
                    elseif remainingTime <= 10000 then
                        TriggerEvent('chat:addMessage', { args = { '10 másodperc van hátra, a bicikli törlődik!' } })
                    elseif remainingTime <= 30000 then
                        TriggerEvent('chat:addMessage', { args = { '5 perc van hátra, a bicikli törlődik!' } })
                    elseif remainingTime <= 60000 then
                        TriggerEvent('chat:addMessage', { args = { '10 perc van hátra, a bicikli törlődik!' } })
                    elseif remainingTime <= 300000 then
                        TriggerEvent('chat:addMessage', { args = { '15 perc múlva törlődik a biciklid!' } })
                    end
                end
            else
                bikeSpawnTime = currentTime -- Újraindítjuk a számlálót, ha a játékos visszaül
            end
        end
    end
end)
