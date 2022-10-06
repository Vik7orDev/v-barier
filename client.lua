local ESX = nil
local PlayerData = {}
local trackedEntities = {
    'prop_roadcone02a',
    'prop_barrier_work05',
    'p_ld_stinger_s',
    'prop_boxpile_07d',
    'hei_prop_cash_crate_half_full'
}

Citizen.CreateThread(function()
    while ESX == nil do
      TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
      Citizen.Wait(1000)
    end
  
    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer   
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

RegisterCommand('barier1', function()
    CreateObject('prop_roadcone02a')
end)

RegisterCommand('barier2', function()
    CreateObject('prop_barrier_work05')
end)

RegisterCommand('barier3', function()
    CreateObject('p_ld_stinger_s')
end)

RegisterCommand('pickup', function()
    DeleteObject()
end)

function CreateObject(name)
    if ESX.PlayerData.job.name == 'police' then
        local ped = GetPlayerPed(-1)
        local coords = GetEntityCoords(ped)
        local forward = GetEntityForwardVector(ped)
        local x, y, z = table.unpack(coords + forward * 1.0)

        exports['progressBars']:startUI(3000, "Spawn prop...")
        Citizen.Wait(3000)

        if name == 'prop_roadcone02a' then
            z = z - 2.0
        end

        ESX.Game.SpawnObject(name, {x = x, y = y, z = z}, function(obj)
            SetEntityHeading(obj, GetEntityHeading(ped))
            PlaceObjectOnGroundProperly(obj)
        end)
    else
        exports['mythic_notify']:DoHudText('error', 'Вие не сте полицай')
    end
end

function DeleteObject()
    local ped = PlayerPedId()
    local coords    = GetEntityCoords(ped)

    local closestDistance = -1
    local closestEntity   = nil

    for i=1, #trackedEntities, 1 do
        local object = GetClosestObjectOfType(coords, 3.0, GetHashKey(trackedEntities[i]), false, false, false)

        if DoesEntityExist(object) then
            local objCoords = GetEntityCoords(object)
            local distance  = GetDistanceBetweenCoords(coords, objCoords, true)

            if closestDistance == -1 or closestDistance > distance then
                closestDistance = distance

                exports['progressBars']:startUI(3000, "Delete prop...")
                Citizen.Wait(3000)
                DeleteEntity(object)
            end
        end
    end
end
