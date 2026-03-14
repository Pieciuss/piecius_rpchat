local pendingGlobalDo = {}
local pendingId = 0

local function GetCharacterName(source)
    local xPlayer = FW.GetPlayer(source)
    if xPlayer then
        return xPlayer.getName()
    end
    return GetPlayerName(source)
end

local function GetNearbyPlayers(source, range)
    local src = tonumber(source)
    local srcPed = GetPlayerPed(src)
    local srcCoords = GetEntityCoords(srcPed)
    local nearby = {}

    for _, playerId in ipairs(GetPlayers()) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)
        local dist = #(srcCoords - targetCoords)

        if dist <= range then
            table.insert(nearby, tonumber(playerId))
        end
    end

    return nearby
end

local function GetTimeNow()
    return os.date('%H:%M')
end

local MaterialIcons = {
    me       = 'theater_comedy',
    ['do']   = 'landscape',
    try      = 'casino',
    ooc      = 'chat_bubble',
    med      = 'local_hospital',
    twt      = 'alternate_email',
    dw       = 'vpn_lock',
    globaldo = 'public',
}

local function SendRPMessage(targets, msgType, playerName, text, extra)
    local label = Config.Labels[msgType] or string.upper(msgType)
    local icon = MaterialIcons[msgType] or 'chat'
    local time = GetTimeNow()

    local templates = {
        me = '<span class="rp-me">'
            .. '<span class="rp-header"><span class="rp-mi">' .. icon .. '</span>'
            .. '<span class="rp-label">' .. label .. '</span><span class="rp-sep">|</span>'
            .. '<span class="rp-name">' .. playerName .. '</span>'
            .. '<span class="rp-time">' .. time .. '</span></span>'
            .. '<span class="rp-body"><span class="rp-text">' .. text .. '</span></span>'
            .. '</span>',

        ['do'] = '<span class="rp-do">'
            .. '<span class="rp-header"><span class="rp-mi">' .. icon .. '</span>'
            .. '<span class="rp-label">' .. label .. '</span><span class="rp-sep">|</span>'
            .. '<span class="rp-name">' .. playerName .. '</span>'
            .. '<span class="rp-time">' .. time .. '</span></span>'
            .. '<span class="rp-body"><span class="rp-text">' .. text .. '</span></span>'
            .. '</span>',

        try = '<span class="rp-try">'
            .. '<span class="rp-header"><span class="rp-mi">' .. icon .. '</span>'
            .. '<span class="rp-label">' .. label .. '</span><span class="rp-sep">|</span>'
            .. '<span class="rp-name">' .. playerName .. '</span>'
            .. '<span class="rp-time">' .. time .. '</span></span>'
            .. '<span class="rp-body"><span class="rp-text">' .. text .. '</span>' .. (extra or '') .. '</span>'
            .. '</span>',

        ooc = '<span class="rp-ooc">'
            .. '<span class="rp-header"><span class="rp-mi">' .. icon .. '</span>'
            .. '<span class="rp-label">' .. label .. '</span><span class="rp-sep">|</span>'
            .. '<span class="rp-name">' .. playerName .. '</span>'
            .. '<span class="rp-time">' .. time .. '</span></span>'
            .. '<span class="rp-body"><span class="rp-text">' .. text .. '</span></span>'
            .. '</span>',

        med = '<span class="rp-med">'
            .. '<span class="rp-header"><span class="rp-mi">' .. icon .. '</span>'
            .. '<span class="rp-label">' .. label .. '</span><span class="rp-sep">|</span>'
            .. '<span class="rp-name">' .. playerName .. '</span>'
            .. '<span class="rp-time">' .. time .. '</span></span>'
            .. '<span class="rp-body"><span class="rp-text">' .. text .. '</span></span>'
            .. '</span>',

        twt = '<span class="rp-twt">'
            .. '<span class="rp-header"><span class="rp-mi">' .. icon .. '</span>'
            .. '<span class="rp-label">Twitter</span><span class="rp-sep">|</span>'
            .. '<span class="rp-name">@' .. playerName .. '</span>'
            .. '<span class="rp-time">' .. time .. '</span></span>'
            .. '<span class="rp-body"><span class="rp-text">' .. text .. '</span></span>'
            .. '</span>',

        dw = '<span class="rp-dw">'
            .. '<span class="rp-header"><span class="rp-mi">' .. icon .. '</span>'
            .. '<span class="rp-label">' .. label .. '</span><span class="rp-sep">|</span>'
            .. '<span class="rp-name">Anonymous</span>'
            .. '<span class="rp-time">' .. time .. '</span></span>'
            .. '<span class="rp-body"><span class="rp-text">' .. text .. '</span></span>'
            .. '</span>',

        globaldo = '<span class="rp-globaldo">'
            .. '<span class="rp-header"><span class="rp-mi">' .. icon .. '</span>'
            .. '<span class="rp-label">' .. label .. '</span><span class="rp-sep">|</span>'
            .. '<span class="rp-name">' .. playerName .. '</span>'
            .. '<span class="rp-time">' .. time .. '</span></span>'
            .. '<span class="rp-body"><span class="rp-text">' .. text .. '</span></span>'
            .. '</span>',
    }

    local html = templates[msgType]
    if not html then return end

    local message = {
        template = html,
        args = {},
    }

    if type(targets) == 'table' then
        for _, targetId in ipairs(targets) do
            TriggerClientEvent('chat:addMessage', targetId, message)
        end
    else
        TriggerClientEvent('chat:addMessage', targets, message)
    end
end

local function SendAdminNotification(id, playerName, text)
    local html = '<span class="rp-admin-notify"><span class="rp-header"><span class="rp-mi">gavel</span><span class="rp-label">GLOBALDO</span><span class="rp-sep">|</span><span class="rp-name">' .. playerName .. '</span><span class="rp-time">' .. GetTimeNow() .. '</span></span><span class="rp-body"><span class="rp-text">' .. text .. '</span> <span class="rp-hint">/acceptglobaldo ' .. id .. ' · /denyglobaldo ' .. id .. '</span></span></span>'

    local message = {
        template = html,
        args = {},
    }

    for _, playerId in ipairs(GetPlayers()) do
        if IsPlayerAceAllowed(playerId, Config.GlobalDoAdminAce) then
            TriggerClientEvent('chat:addMessage', playerId, message)
        end
    end
end

local function EscapeHtml(str)
    return str:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('"', '&quot;'):gsub("'", '&#039;')
end

RegisterCommand('me', function(source, args, rawCommand)
    if source == 0 then return end
    local text = table.concat(args, ' ')
    if text == '' then return end

    text = EscapeHtml(text)
    local playerName = GetCharacterName(source)
    local range = Config.Ranges.me

    local targets
    if range == -1 then
        targets = -1
    else
        targets = GetNearbyPlayers(source, range)
    end

    SendRPMessage(targets, 'me', playerName, text)

    if type(targets) == 'table' then
        for _, t in ipairs(targets) do
            TriggerClientEvent('rpchat:show3DHint', t, source, 'me', playerName, text)
        end
    else
        TriggerClientEvent('rpchat:show3DHint', targets, source, 'me', playerName, text)
    end
end, false)

RegisterCommand('do', function(source, args, rawCommand)
    if source == 0 then return end
    local text = table.concat(args, ' ')
    if text == '' then return end

    text = EscapeHtml(text)
    local playerName = GetCharacterName(source)
    local range = Config.Ranges['do']

    local targets
    if range == -1 then
        targets = -1
    else
        targets = GetNearbyPlayers(source, range)
    end

    SendRPMessage(targets, 'do', playerName, text)

    if type(targets) == 'table' then
        for _, t in ipairs(targets) do
            TriggerClientEvent('rpchat:show3DHint', t, source, 'do', playerName, text)
        end
    else
        TriggerClientEvent('rpchat:show3DHint', targets, source, 'do', playerName, text)
    end
end, false)

RegisterCommand('try', function(source, args, rawCommand)
    if source == 0 then return end
    local text = table.concat(args, ' ')
    if text == '' then return end

    text = EscapeHtml(text)
    local playerName = GetCharacterName(source)
    local success = math.random(1, 2) == 1

    local resultHtml, resultHint
    if success then
        resultHtml = '<span class="rp-result rp-success"> ✓ Udane</span>'
        resultHint = '<span class="rp-hint-result rp-hint-success"> ✓ Udane</span>'
    else
        resultHtml = '<span class="rp-result rp-fail"> ✗ Nieudane</span>'
        resultHint = '<span class="rp-hint-result rp-hint-fail"> ✗ Nieudane</span>'
    end

    local range = Config.Ranges.try
    local targets
    if range == -1 then
        targets = -1
    else
        targets = GetNearbyPlayers(source, range)
    end

    SendRPMessage(targets, 'try', playerName, text, resultHtml)

    if type(targets) == 'table' then
        for _, t in ipairs(targets) do
            TriggerClientEvent('rpchat:show3DHint', t, source, 'try', playerName, text, resultHint)
        end
    else
        TriggerClientEvent('rpchat:show3DHint', targets, source, 'try', playerName, text, resultHint)
    end
end, false)

AddEventHandler('chatMessage', function(source, name, message)
    if source == 0 then return end
    if string.sub(message, 1, 1) == '/' then return end
    CancelEvent()

    local text = EscapeHtml(message)
    local playerName = GetCharacterName(source)
    local time = GetTimeNow()

    local html = '<span class="rp-ooc">'
        .. '<span class="rp-header"><span class="rp-mi">chat_bubble</span>'
        .. '<span class="rp-label">OOC</span><span class="rp-sep">|</span>'
        .. '<span class="rp-name">' .. playerName .. '</span>'
        .. '<span class="rp-time">' .. time .. '</span></span>'
        .. '<span class="rp-body"><span class="rp-text">' .. text .. '</span></span>'
        .. '</span>'

    TriggerClientEvent('chat:addMessage', -1, {
        template = html,
        args = {}
    })
end)

RegisterCommand('med', function(source, args, rawCommand)
    if source == 0 then return end
    local text = table.concat(args, ' ')
    if text == '' then return end

    text = EscapeHtml(text)
    local playerName = GetCharacterName(source)
    local range = Config.Ranges.med

    local targets
    if range == -1 then
        targets = -1
    else
        targets = GetNearbyPlayers(source, range)
    end

    SendRPMessage(targets, 'med', playerName, text)

    if type(targets) == 'table' then
        for _, t in ipairs(targets) do
            TriggerClientEvent('rpchat:show3DHint', t, source, 'med', playerName, text)
        end
    else
        TriggerClientEvent('rpchat:show3DHint', targets, source, 'med', playerName, text)
    end
end, false)

RegisterCommand('twt', function(source, args, rawCommand)
    if source == 0 then return end
    local text = table.concat(args, ' ')
    if text == '' then return end

    text = EscapeHtml(text)
    local playerName = GetCharacterName(source)

    SendRPMessage(-1, 'twt', playerName, text)
end, false)

RegisterCommand('dw', function(source, args, rawCommand)
    if source == 0 then return end
    local text = table.concat(args, ' ')
    if text == '' then return end

    text = EscapeHtml(text)
    local playerName = GetCharacterName(source)

    SendRPMessage(-1, 'dw', playerName, text)
end, false)

RegisterCommand('globaldo', function(source, args, rawCommand)
    if source == 0 then return end
    local text = table.concat(args, ' ')
    if text == '' then return end

    text = EscapeHtml(text)
    local playerName = GetCharacterName(source)

    pendingId = pendingId + 1
    pendingGlobalDo[pendingId] = {
        source = source,
        name = playerName,
        message = text,
        timestamp = os.time()
    }

    TriggerClientEvent('chat:addMessage', source, {
        template = '<span class="rp-admin-notify"><span class="rp-header"><span class="rp-mi">hourglass_top</span><span class="rp-label">GLOBALDO</span></span><span class="rp-body"><span class="rp-text">Twoja wiadomość została wysłana do zatwierdzenia.</span></span></span>',
        args = {}
    })

    SendAdminNotification(pendingId, playerName, text)
end, false)

RegisterCommand('acceptglobaldo', function(source, args, rawCommand)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.GlobalDoAdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            template = '<span class="rp-admin-notify"><span class="rp-header"><span class="rp-mi">block</span><span class="rp-label">SYSTEM</span></span><span class="rp-body"><span class="rp-text">Brak uprawnień.</span></span></span>',
            args = {}
        })
        return
    end

    local id = tonumber(args[1])
    if not id or not pendingGlobalDo[id] then
        local target = source == 0 and -1 or source
        TriggerClientEvent('chat:addMessage', target, {
            template = '<span class="rp-admin-notify"><span class="rp-header"><span class="rp-mi">error</span><span class="rp-label">SYSTEM</span></span><span class="rp-body"><span class="rp-text">Nie znaleziono GlobalDo o podanym ID.</span></span></span>',
            args = {}
        })
        return
    end

    local data = pendingGlobalDo[id]
    SendRPMessage(-1, 'globaldo', data.name, data.message)

    local adminName = source == 0 and 'Console' or GetPlayerName(source)

    if GetPlayerName(data.source) then
        TriggerClientEvent('chat:addMessage', data.source, {
            template = '<span class="rp-admin-notify"><span class="rp-header"><span class="rp-mi">check_circle</span><span class="rp-label">GLOBALDO</span></span><span class="rp-body"><span class="rp-text">Twoja wiadomość GlobalDo została zatwierdzona!</span></span></span>',
            args = {}
        })
    end

    pendingGlobalDo[id] = nil
end, true)

RegisterCommand('denyglobaldo', function(source, args, rawCommand)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.GlobalDoAdminAce) then
        TriggerClientEvent('chat:addMessage', source, {
            template = '<span class="rp-admin-notify"><span class="rp-header"><span class="rp-mi">block</span><span class="rp-label">SYSTEM</span></span><span class="rp-body"><span class="rp-text">Brak uprawnień.</span></span></span>',
            args = {}
        })
        return
    end

    local id = tonumber(args[1])
    if not id or not pendingGlobalDo[id] then
        local target = source == 0 and -1 or source
        TriggerClientEvent('chat:addMessage', target, {
            template = '<span class="rp-admin-notify"><span class="rp-header"><span class="rp-mi">error</span><span class="rp-label">SYSTEM</span></span><span class="rp-body"><span class="rp-text">Nie znaleziono GlobalDo o podanym ID.</span></span></span>',
            args = {}
        })
        return
    end

    local data = pendingGlobalDo[id]
    local adminName = source == 0 and 'Console' or GetPlayerName(source)

    if GetPlayerName(data.source) then
        TriggerClientEvent('chat:addMessage', data.source, {
            template = '<span class="rp-admin-notify"><span class="rp-header"><span class="rp-mi">cancel</span><span class="rp-label">GLOBALDO</span></span><span class="rp-body"><span class="rp-text">Twoja wiadomość GlobalDo została odrzucona.</span></span></span>',
            args = {}
        })
    end

    pendingGlobalDo[id] = nil
end, true)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)
        local now = os.time()
        for id, data in pairs(pendingGlobalDo) do
            if now - data.timestamp > 600 then
                pendingGlobalDo[id] = nil
            end
        end
    end
end)

print('[^2Piecius_rpchat^7] RP Chat zaladowany — /me /do /twt /dw /globaldo /try /med /ooc')