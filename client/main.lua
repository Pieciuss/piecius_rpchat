Citizen.CreateThread(function()
    Citizen.Wait(2000)

    TriggerEvent('chat:addSuggestion', '/me', Config.Descriptions.me, {
        { name = 'akcja', help = 'np. wyciąga dokumenty z kieszeni' }
    })

    TriggerEvent('chat:addSuggestion', '/do', Config.Descriptions['do'], {
        { name = 'opis', help = 'np. Na stole leży broń' }
    })

    TriggerEvent('chat:addSuggestion', '/try', Config.Descriptions.try, {
        { name = 'akcja', help = 'np. próbuje otworzyć drzwi' }
    })

    TriggerEvent('chat:addSuggestion', '/med', Config.Descriptions.med, {
        { name = 'wiadomość', help = 'np. Potrzebna pomoc medyczna!' }
    })

    TriggerEvent('chat:addSuggestion', '/twt', Config.Descriptions.twt, {
        { name = 'tweet', help = 'Treść tweeta' }
    })

    TriggerEvent('chat:addSuggestion', '/dw', Config.Descriptions.dw, {
        { name = 'wiadomość', help = 'Treść wiadomości Dark Web' }
    })

    TriggerEvent('chat:addSuggestion', '/globaldo', Config.Descriptions.globaldo, {
        { name = 'opis', help = 'Globalny opis sytuacji RP' }
    })

    TriggerEvent('chat:addSuggestion', '/acceptglobaldo', 'Zatwierdź oczekujące GlobalDo (admin)', {
        { name = 'id', help = 'Numer ID wiadomości' }
    })

    TriggerEvent('chat:addSuggestion', '/denyglobaldo', 'Odrzuć oczekujące GlobalDo (admin)', {
        { name = 'id', help = 'Numer ID wiadomości' }
    })
end)

local activeHints = {}
local hintCounter = 0
local HINT_DURATION = 8000
local HINT_OFFSET_Z = 1.05

RegisterNetEvent('rpchat:show3DHint')
AddEventHandler('rpchat:show3DHint', function(serverId, hintType, playerName, text, extra)
    hintCounter = hintCounter + 1
    local hintId = 'hint_' .. hintCounter

    activeHints[hintId] = {
        serverId = serverId,
        expireAt = GetGameTimer() + HINT_DURATION
    }

    SendNUIMessage({
        action = 'createHint',
        data = {
            id = hintId,
            type = hintType,
            name = playerName,
            text = text,
            extra = extra or '',
            duration = HINT_DURATION
        }
    })
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 200
        local now = GetGameTimer()
        local positions = {}
        local toRemove = {}

        for hintId, data in pairs(activeHints) do
            if now > data.expireAt then
                toRemove[#toRemove + 1] = hintId
            else
                local ped = GetPlayerPed(GetPlayerFromServerId(data.serverId))
                if ped and DoesEntityExist(ped) then
                    sleep = 0
                    local coords = GetEntityCoords(ped)
                    local headZ = coords.z + HINT_OFFSET_Z
                    local onScreen, sx, sy = GetScreenCoordFromWorldCoord(coords.x, coords.y, headZ)

                    if onScreen then
                        local myCoords = GetEntityCoords(PlayerPedId())
                        local dist = #(myCoords - coords)
                        local scale = 1.0 - (dist / 30.0)

                        positions[#positions + 1] = {
                            id = hintId,
                            x = sx,
                            y = sy,
                            scale = scale
                        }
                    end
                end
            end
        end

        for _, hintId in ipairs(toRemove) do
            activeHints[hintId] = nil
        end

        if #positions > 0 then
            SendNUIMessage({
                action = 'updateHintPositions',
                data = positions
            })
        end

        Citizen.Wait(sleep)
    end
end)