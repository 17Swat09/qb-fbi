-- Variables

local Plates = {}
local PlayerStatus = {}
local Casings = {}
local BloodDrops = {}
local FingerDrops = {}
local Objects = {}
local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

local function UpdateBlips()
    local dutyPlayers = {}
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        if (v.PlayerData.job.name == "fbi" or v.PlayerData.job.name == "ambulance") and v.PlayerData.job.onduty then
            local coords = GetEntityCoords(GetPlayerPed(v.PlayerData.source))
            local heading = GetEntityHeading(GetPlayerPed(v.PlayerData.source))
            dutyPlayers[#dutyPlayers+1] = {
                source = v.PlayerData.source,
                label = v.PlayerData.metadata["callsign"],
                job = v.PlayerData.job.name,
                location = {
                    x = coords.x,
                    y = coords.y,
                    z = coords.z,
                    w = heading
                }
            }
        end
    end
    TriggerClientEvent("fbi:client:UpdateBlips", -1, dutyPlayers)
end

local function CreateBloodId()
    if BloodDrops then
        local bloodId = math.random(10000, 99999)
        while BloodDrops[bloodId] do
            bloodId = math.random(10000, 99999)
        end
        return bloodId
    else
        local bloodId = math.random(10000, 99999)
        return bloodId
    end
end

local function CreateFingerId()
    if FingerDrops then
        local fingerId = math.random(10000, 99999)
        while FingerDrops[fingerId] do
            fingerId = math.random(10000, 99999)
        end
        return fingerId
    else
        local fingerId = math.random(10000, 99999)
        return fingerId
    end
end

local function CreateCasingId()
    if Casings then
        local caseId = math.random(10000, 99999)
        while Casings[caseId] do
            caseId = math.random(10000, 99999)
        end
        return caseId
    else
        local caseId = math.random(10000, 99999)
        return caseId
    end
end

local function CreateObjectId()
    if Objects then
        local objectId = math.random(10000, 99999)
        while Objects[objectId] do
            objectId = math.random(10000, 99999)
        end
        return objectId
    else
        local objectId = math.random(10000, 99999)
        return objectId
    end
end

local function IsVehicleOwned(plate)
    local result = exports.oxmysql:scalarSync('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    return result
end

local function GetCurrentCops()
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        if v.PlayerData.job.name == "fbi" and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    return amount
end

local function DnaHash(s)
    local h = string.gsub(s, ".", function(c)
        return string.format("%02x", string.byte(c))
    end)
    return h
end

-- Commands

QBCore.Commands.Add("spikestrip", "Place Spike Strip (fbi Only)", {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
            TriggerClientEvent('fbi:client:SpawnSpikeStrip', src)
        end
    end
end)

QBCore.Commands.Add("givelicense", "Grant a license to someone", {{name = "id", help = "ID of a person"}, {name = "license", help = "License Type"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.grade.level >= 2 then
        if args[2] == "driver" or args[2] == "weapon" then
            local SearchedPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
            if SearchedPlayer then
                local licenseTable = SearchedPlayer.PlayerData.metadata["licences"]
                licenseTable[args[2]] = true
                SearchedPlayer.Functions.SetMetaData("licences", licenseTable)
                TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, "You have been granted a license",
                    "success", 5000)
                TriggerClientEvent('QBCore:Notify', src, "Has granted a license", "success", 5000)
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "Invalid license type", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "You have to be an Inspector to grant licenses!", "error")
    end
end)

QBCore.Commands.Add("revokelicense", "Revoke a license from someone", {{name = "id", help = "ID of a person"}, {name = "license", help = "License Type"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.grade.level >= 2 then
        if args[2] == "driver" or args[2] == "weapon" then
            local SearchedPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
            if SearchedPlayer then
                local licenseTable = SearchedPlayer.PlayerData.metadata["licences"]
                licenseTable[args[2]] = false
                SearchedPlayer.Functions.SetMetaData("licences", licenseTable)
                TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, "License revoked",
                    "error", 5000)
                TriggerClientEvent('QBCore:Notify', src, "Revoked a license", "success", 5000)
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "Invalid license type", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "You have to be an Inspector to revoke licenses!", "error")
    end
end)

QBCore.Commands.Add("pobject", "Place/Delete An Object (fbi Only)", {{name = "type",help = "Type object you want or 'delete' to delete"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local type = args[1]:lower()
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        if type == "pion" then
            TriggerClientEvent("fbi:client:spawnCone", src)
        elseif type == "barier" then
            TriggerClientEvent("fbi:client:spawnBarier", src)
        elseif type == "schotten" then
            TriggerClientEvent("fbi:client:spawnSchotten", src)
        elseif type == "tent" then
            TriggerClientEvent("fbi:client:spawnTent", src)
        elseif type == "light" then
            TriggerClientEvent("fbi:client:spawnLight", src)
        elseif type == "delete" then
            TriggerClientEvent("fbi:client:deleteObject", src)
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Only for on-duty police officers', 'error')
    end
end)

QBCore.Commands.Add("cuff", "Cuff/Uncuff Player (fbi Only)", {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        TriggerClientEvent("fbi:client:CuffPlayer", src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("scortplayer", "Escort Player", {}, false, function(source, args)
    local src = source
    TriggerClientEvent("fbi:client:EscortPlayer", src)
end)

QBCore.Commands.Add("callsign", "Give Yourself A Callsign", {{name = "name", help = "Name of your callsign"}}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.SetMetaData("callsign", table.concat(args, " "))
end)

QBCore.Commands.Add("clearcasings", "Clear Area of Casings (fbi Only)", {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        TriggerClientEvent("evidence:client:ClearCasingsInArea", src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("jail", "Jail Player (fbi Only)", {{name = "id", help = "Player ID"}, {name = "time", help = "Time they have to be in jail"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        local playerId = tonumber(args[1])
        local time = tonumber(args[2])
        if time > 0 then
            TriggerClientEvent("fbi:client:JailCommand", src, playerId, time)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Cannot be sentenced for 0', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("unjail", "Unjail Player (fbi Only)", {{name = "id", help = "Player ID"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        local playerId = tonumber(args[1])
        TriggerClientEvent("prison:client:UnjailPerson", playerId)
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("clearblood", "Clear The Area of Blood (fbi Only)", {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        TriggerClientEvent("evidence:client:ClearBlooddropsInArea", src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("seizecash", "Seize Cash (fbi Only)", {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        TriggerClientEvent("fbi:client:SeizeCash", src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("sc", "Soft Cuff (fbi Only)", {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        TriggerClientEvent("fbi:client:CuffPlayerSoft", src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("cam", "View Security Camera (fbi Only)", {{name = "camid", help = "Camera ID"}}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        TriggerClientEvent("fbi:client:ActiveCamera", src, tonumber(args[1]))
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("flagplate", "Flag A Plate (fbi Only)", {{name = "plate", help = "License"}, {name = "reason", help = "Reason of flagging the vehicle"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        local reason = {}
        for i = 2, #args, 1 do
            reason[#reason+1] = args[i]
        end
        Plates[args[1]:upper()] = {
            isflagged = true,
            reason = table.concat(reason, " ")
        }
        TriggerClientEvent('QBCore:Notify', src, "Vehicle (" .. args[1]:upper() .. ") is marked for: " .. table.concat(reason, " "))
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("unflagplate", "Unflag A Plate (fbi Only)", {{name = "plate", help = "License plate"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        if Plates and Plates[args[1]:upper()] then
            if Plates[args[1]:upper()].isflagged then
                Plates[args[1]:upper()].isflagged = false
                TriggerClientEvent('QBCore:Notify', src, "Vehicle (" .. args[1]:upper() .. ") is not marked")
            else
                TriggerClientEvent('QBCore:Notify', src, 'Vehicle not marked', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'Vehicle not marked', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("runplate", "Run A Plate (fbi Only)", {{name = "plate",help = "License plate"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        if Plates and Plates[args[1]:upper()] then
            if Plates[args[1]:upper()].isflagged then
                TriggerClientEvent('QBCore:Notify', src, 'Vehicle ' .. args[1]:upper() .. ' has been marked for: ' .. Plates[args[1]:upper()].reason)
            else
                TriggerClientEvent('QBCore:Notify', src, 'Vehicle not marked', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'Vehicle not marked', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("depot", "Impound With Price (fbi Only)", {{name = "price", help = "Price for how much the person has to pay (may be empty)"}}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        TriggerClientEvent("fbi:client:ImpoundVehicle", src, false, tonumber(args[1]))
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("impound", "Impound A Vehicle (fbi Only)", {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        TriggerClientEvent("fbi:client:ImpoundVehicle", src, true)
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("paytow", "Pay Tow Driver (fbi Only)", {{name = "id",help = "ID of the player"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        local playerId = tonumber(args[1])
        local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
        if OtherPlayer then
            if OtherPlayer.PlayerData.job.name == "tow" then
                OtherPlayer.Functions.AddMoney("bank", 500, "fbi-tow-paid")
                TriggerClientEvent('QBCore:Notify', OtherPlayer.PlayerData.source, 'You were paid $500', 'success')
                TriggerClientEvent('QBCore:Notify', src, 'You have paid the tow truck driver')
            else
                TriggerClientEvent('QBCore:Notify', src, 'Not a tow truck driver', 'error')
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("paylawyer", "Pay Lawyer (fbi, Judge Only)", {{name = "id",help = "ID of the player"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" or Player.PlayerData.job.name == "judge" then
        local playerId = tonumber(args[1])
        local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
        if OtherPlayer then
            if OtherPlayer.PlayerData.job.name == "lawyer" then
                OtherPlayer.Functions.AddMoney("bank", 500, "fbi-lawyer-paid")
                TriggerClientEvent('QBCore:Notify', OtherPlayer.PlayerData.source, 'You were paid $500', 'success')
                TriggerClientEvent('QBCore:Notify', src, 'You have paid a lawyer')
            else
                TriggerClientEvent('QBCore:Notify', src, 'The person is not a lawyer', "error")
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("trackinganklet", "Attach Tracking Anklet (fbi Only)", {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        TriggerClientEvent("fbi:client:CheckDistance", src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("ankletlocation", "Get the location of a persons anklet", {{name="cid", help="Citizen ID of the person"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        if args[1] then
            local citizenid = args[1]
            local Target = QBCore.Functions.GetPlayerByCitizenId(citizenid)
            if Target then
                if Target.PlayerData.metadata["tracker"] then
                    TriggerClientEvent("fbi:client:SendTrackerLocation", Target.PlayerData.source, src)
                else
                    TriggerClientEvent('QBCore:Notify', src, 'This person is not wearing an anklet.', 'error')
                end
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("removeanklet", "Remove Tracking Anklet (fbi Only)", {{name="cid", help="Citizen ID of person"}}, true,function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        if args[1] then
            local citizenid = args[1]
            local Target = QBCore.Functions.GetPlayerByCitizenId(citizenid)
            if Target then
                if Target.PlayerData.metadata["tracker"] then
                    TriggerClientEvent("fbi:client:SendTrackerLocation", Target.PlayerData.source, src)
                else
                    TriggerClientEvent('QBCore:Notify', src, 'This person does not have an anklet', 'error')
                end
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("takedrivinglicense", "Seize Drivers License (fbi Only)", {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "fbi" and Player.PlayerData.job.onduty then
        TriggerClientEvent("fbi:client:SeizeDriverLicense", source)
    else
        TriggerClientEvent('QBCore:Notify', src, 'For on-duty police officers only', 'error')
    end
end)

QBCore.Commands.Add("takedna", "Take a DNA sample from a person (empty evidence bag needed) (fbi Only)", {{name="id", help="ID of the person"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local OtherPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if ((Player.PlayerData.job.name == "fbi") and Player.PlayerData.job.onduty) and OtherPlayer then
        if Player.Functions.RemoveItem("empty_evidence_bag", 1) then
            local info = {
                label = "DNA Sample",
                type = "dna",
                dnalabel = DnaHash(OtherPlayer.PlayerData.citizenid)
            }
            if Player.Functions.AddItem("filled_evidence_bag", 1, false, info) then
                TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["filled_evidence_bag"], "add")
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "You must have an empty evidence bag with you", "error")
        end
    end
end)

RegisterNetEvent('fbi:server:SendTrackerLocation', function(coords, requestId)
    local Target = QBCore.Functions.GetPlayer(source)
    local msg = "The location of " .. Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname .. " is marked on your map."
    local alertData = {
        title = "Anklet location",
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        description = msg
    }
    TriggerClientEvent("fbi:client:TrackerMesge", requestId, msg, coords)
    TriggerClientEvent("qb-phone:client:addfbiAlert", requestId, alertData)
end)

QBCore.Commands.Add('911fbi', 'fbi Report', {{name='message', help='Message to be sent'}}, false, function(source, args)
	local src = source
	if args[1] then message = table.concat(args, " ") else message = 'Civilian call' end
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetQBPlayers()
    for k,v in pairs(players) do
        if v.PlayerData.job.name == 'fbi' and v.PlayerData.job.onduty then
            local alertData = {title = 'New call to 911', coords = {coords.x, coords.y, coords.z}, description = message}
            TriggerClientEvent("qb-phone:client:addfbiAlert", v.PlayerData.source, alertData)
            TriggerClientEvent('fbi:client:fbiAlert', v.PlayerData.source, coords, message)
        end
    end
end)

-- Items

QBCore.Functions.CreateUseableItem("handcuffs", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.GetItemByName(item.name) then
        TriggerClientEvent("fbi:client:CuffPlayerSoft", src)
    end
end)

QBCore.Functions.CreateUseableItem("moneybag", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.GetItemByName(item.name) then
        if item.info and item.info ~= "" then
            if Player.PlayerData.job.name ~= "fbi" then
                if Player.Functions.RemoveItem("moneybag", 1, item.slot) then
                    Player.Functions.AddMoney("cash", tonumber(item.info.cash), "used-moneybag")
                end
            end
        end
    end
end)

-- Callbacks

QBCore.Functions.CreateCallback('fbi:server:isPlayerDead', function(source, cb, playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    cb(Player.PlayerData.metadata["isdead"])
end)

QBCore.Functions.CreateCallback('fbi:GetPlayerStatus', function(source, cb, playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    local statList = {}
    if Player then
        if PlayerStatus[Player.PlayerData.source] and next(PlayerStatus[Player.PlayerData.source]) then
            for k, v in pairs(PlayerStatus[Player.PlayerData.source]) do
                statList[#statList+1] = PlayerStatus[Player.PlayerData.source][k].text
            end
        end
    end
    cb(statList)
end)

QBCore.Functions.CreateCallback('fbi:IsSilencedWeapon', function(source, cb, weapon)
    local Player = QBCore.Functions.GetPlayer(source)
    local itemInfo = Player.Functions.GetItemByName(QBCore.Shared.Weapons[weapon]["name"])
    local retval = false
    if itemInfo then
        if itemInfo.info and itemInfo.info.attachments then
            for k, v in pairs(itemInfo.info.attachments) do
                if itemInfo.info.attachments[k].component == "COMPONENT_AT_AR_SUPP_02" or
                    itemInfo.info.attachments[k].component == "COMPONENT_AT_AR_SUPP" or
                    itemInfo.info.attachments[k].component == "COMPONENT_AT_PI_SUPP_02" or
                    itemInfo.info.attachments[k].component == "COMPONENT_AT_PI_SUPP" then
                    retval = true
                end
            end
        end
    end
    cb(retval)
end)

QBCore.Functions.CreateCallback('fbi:GetDutyPlayers', function(source, cb)
    local dutyPlayers = {}
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        if v.PlayerData.job.name == "fbi" and v.PlayerData.job.onduty then
            dutyPlayers[#dutyPlayers+1] = {
                source = Player.PlayerData.source,
                label = Player.PlayerData.metadata["callsign"],
                job = Player.PlayerData.job.name
            }
        end
    end
    cb(dutyPlayers)
end)

QBCore.Functions.CreateCallback('fbi:GetImpoundedVehicles', function(source, cb)
    local vehicles = {}
    exports.oxmysql:execute('SELECT * FROM player_vehicles WHERE state = ?', {2}, function(result)
        if result[1] then
            vehicles = result
        end
        cb(vehicles)
    end)
end)

QBCore.Functions.CreateCallback('fbi:IsPlateFlagged', function(source, cb, plate)
    local retval = false
    if Plates and Plates[plate] then
        if Plates[plate].isflagged then
            retval = true
        end
    end
    cb(retval)
end)

QBCore.Functions.CreateCallback('fbi:GetCops', function(source, cb)
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        if v.PlayerData.job.name == "fbi" and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    cb(amount)
end)

QBCore.Functions.CreateCallback('fbi:server:IsfbiForcePresent', function(source, cb)
    local retval = false
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        if v.PlayerData.job.name == "fbi" and v.PlayerData.job.grade.level >= 2 then
            retval = true
            break
        end
    end
    cb(retval)
end)

-- Events

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CreateThread(function()
            exports.oxmysql:execute('DELETE FROM stashitems WHERE stash="fbitrash"')
        end)
    end
end)

RegisterNetEvent('fbi:server:fbiAlert', function(text)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetQBPlayers()
    for k,v in pairs(players) do
        if v.PlayerData.job.name == 'fbi' and v.PlayerData.job.onduty then
            local alertData = {title = 'New Call', coords = {coords.x, coords.y, coords.z}, description = text}
            TriggerClientEvent("qb-phone:client:addfbiAlert", v.PlayerData.source, alertData)
            TriggerClientEvent('fbi:client:fbiAlert', v.PlayerData.source, coords, text)
        end
    end
end)

RegisterNetEvent('fbi:server:TakeOutImpound', function(plate)
    local src = source
    exports.oxmysql:execute('UPDATE player_vehicles SET state = ? WHERE plate  = ?', {0, plate})
    TriggerClientEvent('QBCore:Notify', src, "Vehicle not confiscated!", 'success')
end)

RegisterNetEvent('fbi:server:CuffPlayer', function(playerId, isSoftcuff)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local CuffedPlayer = QBCore.Functions.GetPlayer(playerId)
    if CuffedPlayer then
        if Player.Functions.GetItemByName("handcuffs") or Player.PlayerData.job.name == "fbi" then
            TriggerClientEvent("fbi:client:GetCuffed", CuffedPlayer.PlayerData.source, Player.PlayerData.source, isSoftcuff)
        end
    end
end)

RegisterNetEvent('fbi:server:EscortPlayer', function(playerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if EscortPlayer then
        if (Player.PlayerData.job.name == "fbi" or Player.PlayerData.job.name == "ambulance") or (EscortPlayer.PlayerData.metadata["ishandcuffed"] or EscortPlayer.PlayerData.metadata["isdead"] or EscortPlayer.PlayerData.metadata["inlaststand"]) then
            TriggerClientEvent("fbi:client:GetEscorted", EscortPlayer.PlayerData.source, Player.PlayerData.source)
        else
            TriggerClientEvent('QBCore:Notify', src, "The civilian is neither handcuffed nor dead", 'error')
        end
    end
end)

RegisterNetEvent('fbi:server:KidnapPlayer', function(playerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if EscortPlayer then
        if EscortPlayer.PlayerData.metadata["ishandcuffed"] or EscortPlayer.PlayerData.metadata["isdead"] or
            EscortPlayer.PlayerData.metadata["inlaststand"] then
            TriggerClientEvent("fbi:client:GetKidnappedTarget", EscortPlayer.PlayerData.source, Player.PlayerData.source)
            TriggerClientEvent("fbi:client:GetKidnappedDragger", Player.PlayerData.source, EscortPlayer.PlayerData.source)
        else
            TriggerClientEvent('QBCore:Notify', src, "The civilian is neither handcuffed nor dead", 'error')
        end
    end
end)

RegisterNetEvent('fbi:server:SetPlayerOutVehicle', function(playerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if EscortPlayer then
        if EscortPlayer.PlayerData.metadata["ishandcuffed"] or EscortPlayer.PlayerData.metadata["isdead"] then
            TriggerClientEvent("fbi:client:SetOutVehicle", EscortPlayer.PlayerData.source)
        else
            TriggerClientEvent('QBCore:Notify', src, "The civilian is neither handcuffed nor dead", 'error')
        end
    end
end)

RegisterNetEvent('fbi:server:PutPlayerInVehicle', function(playerId)
    local src = source
    local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if EscortPlayer then
        if EscortPlayer.PlayerData.metadata["ishandcuffed"] or EscortPlayer.PlayerData.metadata["isdead"] then
            TriggerClientEvent("fbi:client:PutInVehicle", EscortPlayer.PlayerData.source)
        else
           TriggerClientEvent('QBCore:Notify', src, "The civilian is neither handcuffed nor dead", 'error')
        end
    end
end)

RegisterNetEvent('fbi:server:BillPlayer', function(playerId, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
    if Player.PlayerData.job.name == "fbi" then
        if OtherPlayer then
            OtherPlayer.Functions.RemoveMoney("bank", price, "paid-bills")
            TriggerEvent('qb-bossmenu:server:addAccountMoney', "fbi", price)
            TriggerClientEvent('QBCore:Notify', OtherPlayer.PlayerData.source, "Received from a fine of $" .. price)
        end
    end
end)

RegisterNetEvent('fbi:server:JailPlayer', function(playerId, time)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local OtherPlayer = QBCore.Functions.GetPlayer(playerId)
    local currentDate = os.date("*t")
    if currentDate.day == 31 then
        currentDate.day = 30
    end

    if Player.PlayerData.job.name == "fbi" then
        if OtherPlayer then
            OtherPlayer.Functions.SetMetaData("injail", time)
            OtherPlayer.Functions.SetMetaData("criminalrecord", {
                ["hasRecord"] = true,
                ["date"] = currentDate
            })
            TriggerClientEvent("fbi:client:SendToJail", OtherPlayer.PlayerData.source, time)
            TriggerClientEvent('QBCore:Notify', src, "You have sent the person to prison for " .. time .. " month")
        end
    end
end)

RegisterNetEvent('fbi:server:SetHandcuffStatus', function(isHandcuffed)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.SetMetaData("ishandcuffed", isHandcuffed)
    end
end)

RegisterNetEvent('heli:spotlight', function(state)
    local serverID = source
    TriggerClientEvent('heli:spotlight', -1, serverID, state)
end)

-- RegisterNetEvent('police:server:FlaggedPlateTriggered', function(camId, plate, street1, street2, blipSettings)
--     local src = source
--     for k, v in pairs(QBCore.Functions.GetPlayers()) do
--         local Player = QBCore.Functions.GetPlayer(v)
--         if Player then
--             if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
--                 if street2 then
--                     TriggerClientEvent("112:client:SendPoliceAlert", v, "flagged", {
--                         camId = camId,
--                         plate = plate,
--                         streetLabel = street1 .. " " .. street2
--                     }, blipSettings)
--                 else
--                     TriggerClientEvent("112:client:SendPoliceAlert", v, "flagged", {
--                         camId = camId,
--                         plate = plate,
--                         streetLabel = street1
--                     }, blipSettings)
--                 end
--             end
--         end
--     end
-- end)

RegisterNetEvent('fbi:server:SearchPlayer', function(playerId)
    local src = source
    local SearchedPlayer = QBCore.Functions.GetPlayer(playerId)
    if SearchedPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Found $'..SearchedPlayer.PlayerData.money["cash"]..' on the citizen')
        TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, "You are being searched")
    end
end)

RegisterNetEvent('fbi:server:SeizeCash', function(playerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local SearchedPlayer = QBCore.Functions.GetPlayer(playerId)
    if SearchedPlayer then
        local moneyAmount = SearchedPlayer.PlayerData.money["cash"]
        local info = { cash = moneyAmount }
        SearchedPlayer.Functions.RemoveMoney("cash", moneyAmount, "fbi-cash-seized")
        Player.Functions.AddItem("moneybag", 1, false, info)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["moneybag"], "add")
        TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, 'His money was confiscated')
    end
end)

RegisterNetEvent('fbi:server:SeizeDriverLicense', function(playerId)
    local src = source
    local SearchedPlayer = QBCore.Functions.GetPlayer(playerId)
    if SearchedPlayer then
        local driverLicense = SearchedPlayer.PlayerData.metadata["licences"]["driver"]
        if driverLicense then
            local licenses = {["driver"] = false, ["business"] = SearchedPlayer.PlayerData.metadata["licences"]["business"]}
            SearchedPlayer.Functions.SetMetaData("licences", licenses)
            TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, 'Your drivers license has been confiscated')
        else
            TriggerClientEvent('QBCore:Notify', src, 'No drivers license', 'error')
        end
    end
end)

RegisterNetEvent('fbi:server:RobPlayer', function(playerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local SearchedPlayer = QBCore.Functions.GetPlayer(playerId)
    if SearchedPlayer then
        local money = SearchedPlayer.PlayerData.money["cash"]
        Player.Functions.AddMoney("cash", money, "fbi-player-robbed")
        SearchedPlayer.Functions.RemoveMoney("cash", money, "fbi-player-robbed")
        TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source, "You have been robbed $" .. money)
        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, "You have stolen $" .. money)
    end
end)

RegisterNetEvent('fbi:server:UpdateBlips', function()
    -- KEEP FOR REF BUT NOT NEEDED ANYMORE.
end)

RegisterNetEvent('fbi:server:spawnObject', function(type)
    local src = source
    local objectId = CreateObjectId()
    Objects[objectId] = type
    TriggerClientEvent("fbi:client:spawnObject", src, objectId, type, src)
end)

RegisterNetEvent('fbi:server:deleteObject', function(objectId)
    TriggerClientEvent('fbi:client:removeObject', -1, objectId)
end)

RegisterNetEvent('fbi:server:Impound', function(plate, fullImpound, price, body, engine, fuel)
    local src = source
    local price = price and price or 0
    if IsVehicleOwned(plate) then
        if not fullImpound then
            exports.oxmysql:execute(
                'UPDATE player_vehicles SET state = ?, depotprice = ?, body = ?, engine = ?, fuel = ? WHERE plate = ?',
                {0, price, body, engine, fuel, plate})
            TriggerClientEvent('QBCore:Notify', src, "Vehicle brought to the depot by $" .. price .. "!")
        else
            exports.oxmysql:execute(
                'UPDATE player_vehicles SET state = ?, body = ?, engine = ?, fuel = ? WHERE plate = ?',
                {2, body, engine, fuel, plate})
            TriggerClientEvent('QBCore:Notify', src, "Vehicle seized")
        end
    end
end)

RegisterNetEvent('evidence:server:UpdateStatus', function(data)
    local src = source
    PlayerStatus[src] = data
end)

RegisterNetEvent('evidence:server:CreateBloodDrop', function(citizenid, bloodtype, coords)
    local bloodId = CreateBloodId()
    BloodDrops[bloodId] = {
        dna = citizenid,
        bloodtype = bloodtype
    }
    TriggerClientEvent("evidence:client:AddBlooddrop", -1, bloodId, citizenid, bloodtype, coords)
end)

RegisterNetEvent('evidence:server:CreateFingerDrop', function(coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local fingerId = CreateFingerId()
    FingerDrops[fingerId] = Player.PlayerData.metadata["fingerprint"]
    TriggerClientEvent("evidence:client:AddFingerPrint", -1, fingerId, Player.PlayerData.metadata["fingerprint"], coords)
end)

RegisterNetEvent('evidence:server:ClearBlooddrops', function(blooddropList)
    if blooddropList and next(blooddropList) then
        for k, v in pairs(blooddropList) do
            TriggerClientEvent("evidence:client:RemoveBlooddrop", -1, v)
            BloodDrops[v] = nil
        end
    end
end)

RegisterNetEvent('evidence:server:AddBlooddropToInventory', function(bloodId, bloodInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem("empty_evidence_bag", 1) then
        if Player.Functions.AddItem("filled_evidence_bag", 1, false, bloodInfo) then
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["filled_evidence_bag"], "add")
            TriggerClientEvent("evidence:client:RemoveBlooddrop", -1, bloodId)
            BloodDrops[bloodId] = nil
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "You must have an empty evidence bag with you", "error")
    end
end)

RegisterNetEvent('evidence:server:AddFingerprintToInventory', function(fingerId, fingerInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem("empty_evidence_bag", 1) then
        if Player.Functions.AddItem("filled_evidence_bag", 1, false, fingerInfo) then
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["filled_evidence_bag"], "add")
            TriggerClientEvent("evidence:client:RemoveFingerprint", -1, fingerId)
            FingerDrops[fingerId] = nil
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "You must have an empty evidence bag with you", "error")
    end
end)

RegisterNetEvent('evidence:server:CreateCasing', function(weapon, coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local casingId = CreateCasingId()
    local weaponInfo = QBCore.Shared.Weapons[weapon]
    local serieNumber = nil
    if weaponInfo then
        local weaponItem = Player.Functions.GetItemByName(weaponInfo["name"])
        if weaponItem then
            if weaponItem.info and weaponItem.info ~= "" then
                serieNumber = weaponItem.info.serie
            end
        end
    end
    TriggerClientEvent("evidence:client:AddCasing", -1, casingId, weapon, coords, serieNumber)
end)

RegisterNetEvent('fbi:server:UpdateCurrentCops', function()
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for k, v in pairs(players) do
        if v.PlayerData.job.name == "fbi" and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    TriggerClientEvent("fbi:SetCopCount", -1, amount)
end)

RegisterNetEvent('evidence:server:ClearCasings', function(casingList)
    if casingList and next(casingList) then
        for k, v in pairs(casingList) do
            TriggerClientEvent("evidence:client:RemoveCasing", -1, v)
            Casings[v] = nil
        end
    end
end)

RegisterNetEvent('evidence:server:AddCasingToInventory', function(casingId, casingInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem("empty_evidence_bag", 1) then
        if Player.Functions.AddItem("filled_evidence_bag", 1, false, casingInfo) then
            TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["filled_evidence_bag"], "add")
            TriggerClientEvent("evidence:client:RemoveCasing", -1, casingId)
            Casings[casingId] = nil
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "You must have an empty evidence bag with you", "error")
    end
end)

RegisterNetEvent('fbi:server:showFingerprint', function(playerId)
    local src = source
    TriggerClientEvent('fbi:client:showFingerprint', playerId, src)
    TriggerClientEvent('fbi:client:showFingerprint', src, playerId)
end)

RegisterNetEvent('fbi:server:showFingerprintId', function(sessionId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local fid = Player.PlayerData.metadata["fingerprint"]
    TriggerClientEvent('fbi:client:showFingerprintId', sessionId, fid)
    TriggerClientEvent('fbi:client:showFingerprintId', src, fid)
end)

RegisterNetEvent('fbi:server:SetTracker', function(targetId)
    local src = source
    local Target = QBCore.Functions.GetPlayer(targetId)
    local TrackerMeta = Target.PlayerData.metadata["tracker"]
    if TrackerMeta then
        Target.Functions.SetMetaData("tracker", false)
        TriggerClientEvent('QBCore:Notify', targetId, 'Your anklet is being removed.', 'error', 5000)
        TriggerClientEvent('QBCore:Notify', src, 'You removed an ankle bracelet of ' .. Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname, 'error', 5000)
        TriggerClientEvent('fbi:client:SetTracker', targetId, false)
    else
        Target.Functions.SetMetaData("tracker", true)
        TriggerClientEvent('QBCore:Notify', targetId, 'You wear a bracelet on your ankle.', 'error', 5000)
        TriggerClientEvent('QBCore:Notify', src, 'You wear a bracelet on your ankle for ' .. Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname, 'error', 5000)
        TriggerClientEvent('fbi:client:SetTracker', targetId, true)
    end
end)

RegisterNetEvent('fbi:server:SendTrackerLocation', function(coords, requestId)
    local Target = QBCore.Functions.GetPlayer(source)
    local msg = "The location of " .. Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname .. " is marked on your map."
    local alertData = {
        title = "Location of the anklet",
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        description = msg
    }
    TriggerClientEvent("fbi:client:TrackerMessage", requestId, msg, coords)
    TriggerClientEvent("qb-phone:client:addfbiAlert", requestId, alertData)
end)

RegisterNetEvent('fbi:server:SyncSpikes', function(table)
    TriggerClientEvent('fbi:client:SyncSpikes', -1, table)
end)

-- Threads

CreateThread(function()
    while true do
        Wait(1000 * 60 * 10)
        local curCops = GetCurrentCops()
        TriggerClientEvent("fbi:SetCopCount", -1, curCops)
    end
end)

CreateThread(function()
    while true do
        Wait(5000)
        UpdateBlips()
    end
end)
