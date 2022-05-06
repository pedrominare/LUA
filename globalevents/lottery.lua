local config = {
        lottery_hour = "algumas horas", -- Tempo ate a proxima loteria (Esse tempo vai aparecer somente como broadcast message)
        rewards_id = {12734, 6527, 12662, 12710, 12655, 12653, 12733, 12730, 12611}, -- ID dos Itens Sorteados na Loteria
        crystal_counts = 30, -- Usado somente se a rewards_id for crystal coin (ID: 2160).
		premium_coin = 5, -- quantidade de premium coins caso ele seja escolhido
        website = "yes", -- Only if you have php scripts and table `lottery` in your database!
        days = {
                "Monday-10:00",
                "Monday-17:00",
                "Monday-22:00",

                "Tuesday-10:00",
                "Tuesday-17:00",
                "Tuesday-22:00",

                "Wednesday-10:00",
                "Wednesday-17:00",
                "Wednesday-22:00",

                "Thursday-10:00",
                "Thursday-17:00",
                "Thursday-22:00",

                "Friday-10:00",
                "Friday-17:00",
                "Friday-22:00",

                "Saturday-10:00",
                "Saturday-17:00",
                "Saturday-22:00",

                "Sunday-10:00",
                "Sunday-17:00",
                "Sunday-22:00"
                }
        }
local function getPlayerWorldId(cid)
    if not(isPlayer(cid)) then
        return false
    end
    local pid = getPlayerGUID(cid)
    local worldPlayer = 0
    local result_plr = db.getResult("SELECT * FROM `players` WHERE `id` = "..pid..";")
    if(result_plr:getID() ~= -1) then
        worldPlayer = tonumber(result_plr:getDataInt("world_id"))
        result_plr:free()
        return worldPlayer
    end
    return false
end

local function getOnlineParticipants()
    local players = {}
    for _, pid in pairs(getPlayersOnline()) do
        if getPlayerAccess(pid) <= 2 and getPlayerStorageValue(pid, 300) <= os.time() then
            table.insert(players, pid)
        end
    end
    if #players > 0 then
        return players
    end
    return false
end
     
function onThink(cid, interval)
    if table.find(config.days, os.date("%A-%H:%M")) then
        if(getWorldCreatures(o) <= 0)then
            return true
        end

        local query = db.query or db.executeQuery
        local random_item = config.rewards_id[math.random(1, #config.rewards_id)]
        local item_name = getItemNameById(random_item)  
        local data = os.date("%d/%m/%Y - %H:%M:%S")
        local online = getOnlineParticipants()
       
        if online then
            local winner = online[math.random(1, #online)]
            local world = tonumber(getPlayerWorldId(winner))
           
            if(random_item == 12725) then -- event coins
                doPlayerSetStorageValue(winner, 300, os.time() + 3600 * 24)
                doPlayerAddItem(winner, random_item, config.crystal_counts)
                doBroadcastMessage("[LOTTERY SYSTEM] Ganhador da Loteria: " .. getCreatureName(winner) .. ", Premio: " .. config.crystal_counts .." " .. getItemNameById(random_item) .. "s! Parabens! (Proxima loteria em " .. config.lottery_hour .. ")")
            elseif (random_item == 12662) then -- gold nugget
				doPlayerSetStorageValue(winner, 300, os.time() + 3600 * 24)
                doPlayerAddItem(winner, random_item, config.crystal_counts)
                doBroadcastMessage("[LOTTERY SYSTEM] Ganhador da Loteria: " .. getCreatureName(winner) .. ", Premio: " .. config.crystal_counts .." " .. getItemNameById(random_item) .. "s! Parabens! (Proxima loteria em " .. config.lottery_hour .. ")")
            elseif (random_item == 12734) then -- premium coin
				doPlayerSetStorageValue(winner, 300, os.time() + 3600 * 24)
                doPlayerAddItem(winner, random_item, config.premium_coin)
                doBroadcastMessage("[LOTTERY SYSTEM] Ganhador da Loteria: " .. getCreatureName(winner) .. ", Premio: " .. config.premium_coin .." " .. getItemNameById(random_item) .. "s! Parabens! (Proxima loteria em " .. config.lottery_hour .. ")")
            else
                doPlayerSetStorageValue(winner, 300, os.time() + 3600 * 24)
                doBroadcastMessage("[LOTTERY SYSTEM] Ganhador da Loteria: " .. getCreatureName(winner) .. ", Premio: " ..getItemNameById(random_item) .. "! Parabens! (Proxima loteria em " .. config.lottery_hour .. ")")
                doPlayerAddItem(winner, random_item, 1)
            end
            if(config.website == "yes") then
                query("INSERT INTO `lottery` (`name`, `item`, `world_id`, `item_name`, `date`) VALUES ('".. getCreatureName(winner).."', '".. random_item .."', '".. world .."', '".. item_name .."', '".. data .."');")
            end
        else
            print("Ninguem OnLine pra ganhar na loteria")
        end
    end
    return true
end