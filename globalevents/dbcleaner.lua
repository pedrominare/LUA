------------------------------------------------------------------------------*
----- [[> Automated Database Cleanup 1.1 Structure //By Cybermaster <]] ------|
-------------- [[> System 2.0 Revamped by Teh Maverick <3 <]] ----------------|
------------- [[>  Removal of empty accounts by darkaos :) <]] ---------------|
--------------- [[> Function getDBPlayersCount() by Elf <]] ------------------|
------------------------------------------------------------------------------|
------------------------------------------------------------------------------|
--- ~!READ THIS!~ ------------------------------------------------------------|
--- Be sure to back up your database and test this on your server first, -----|
--- I(Teh Maverick) cannot guarantee it will work the same for every core. ---|
--- It is very easy to test, with the log file and values that are printed ---|
-----------------------------------Enjoy!-------------------------------------|
------------------------------------------------------------------------------*
 
function countRowsWhereInTable(table, field, condition)
    local result = db.getResult("SELECT COUNT(" .. field .. ") as count FROM " .. table .. " WHERE " .. field .. " = '" .. condition .. "';")
    local tmp = result:getDataInt("count")
    result:free()
    return tmp
end
 
function getDBPlayersCount()
    local result = db.getResult("SELECT COUNT(id) as count FROM `players`;")
    local tmp = result:getDataInt("count")
    result:free()
    return tmp
end
 
function getDBAccountsCount()
    local result = db.getResult("SELECT COUNT(id) as count FROM `accounts`;")
    local tmp = result:getDataInt("count")
    result:free()
    return tmp
end
 
function onStartup()
    local DB_BEFORE = {players = getDBPlayersCount(), accounts = getDBAccountsCount()}
    local result,result1, ii, numPlayersToDelete, numAccountsDeleted, tmp = 0, 0, 0, 0, 0
    local pid, aid = {}, {}
    local dropCount = {players={},accounts={}}
 
    local config = {
        deleteAccountWithNoPlayers = true,
        cleanChildTables = true,
        printResult = true,
        saveResultToFile = true,
        logFileName = 'db_cleanup.txt'
    }
 
    --In each table, players with below specified level, and days of inactivity will be deleted from db on server startup
    local cleanup = {
	[1] = {level = 50, time = 10 * 24 * 60 * 60}, -- calculado para que, caso o player do level especificado fique offline por mais de 3h (0.125), seu char sera deletado.
    [2] = {level = 200, time = 12 * 24 * 60 * 60},
    [3] = {level = 300, time = 14 * 24 * 60 * 60},
	[4] = {level = 400, time = 16 * 24 * 60 * 60},
	[5] = {level = 500, time = 18 * 24 * 60 * 60},
	[6] = {level = 600, time = 20 * 24 * 60 * 60}
    }
 
    local childAttributeTables = {
        players = {
            [1] = {table = "`player_viplist`", idField = "`player_id`"},
            [2] = {table = "`player_storage`", idField = "`player_id`"},
            [3] = {table = "`player_spells`", idField = "`player_id`"},
            [4] = {table = "`player_skills`", idField = "`player_id`"},
            [5] = {table = "`player_namelocks`", idField = "`player_id`"},
            [6] = {table = "`player_items`", idField = "`player_id`"},
            [7] = {table = "`player_depotitems`", idField = "`player_id`"},
            [8] = {table = "`player_deaths`", idField = "`player_id`"},
            [9] = {table = "`guild_invites`", idField = "`player_id`"},
            [10] = {table = "`houses`", idField = "`owner`"},
            [11] = {table = "`house_auctions`", idField = "`player_id`"},
            [12] = {table = "`players`", idField = "`id`"} -- Keep this as the last item in the array
            --Note: `houses` and `bans` are in the DB triggers for TFS so don't worry about them.
            --Also I did not want to put killers, or deaths on here because that is historic data,
            --do so at your ouwn risk.
        },
        accounts = {
            [1] = {table = "`accounts`", idField = "`id`"},
            [2] = {table = "`account_viplist`", idField = "`account_id`"}
        }
    }
 
    --Clean up all the players and player data
    for i = 1, #cleanup do
        result = db.getResult("SELECT `id`,`name`,`account_id` FROM `players` WHERE `level` < ".. cleanup[i].level .." AND `name` NOT IN('Account Manager', 'Sorcerer Sample', 'Druid Sample', 'Paladin Sample', 'Knight Sample', 'Rook Sample') AND `group_id` < 2 AND `lastlogin` < UNIX_TIMESTAMP() - ".. cleanup[i].time ..";")
        if(result:getID() ~= -1) then
            ii = 1
            repeat
                pid[ii] = result:getDataInt("id") -- list the players id into an array
                aid[ii] = result:getDataInt("account_id") -- list the account id of each player being removed into an array
                ii = ii + 1
            until not(result:next())
            result:free()
        end
        numPlayersToDelete = ii - 1
 
        --Drop players and their child table attribute data such as skills, items, etc.
        for j = 1, numPlayersToDelete do
 
            if(config.cleanChildTables) then
                for k = 1, #childAttributeTables.players do
                    dropCount.players[k] = ((dropCount.players[k] or 0) + countRowsWhereInTable(childAttributeTables.players[k].table, childAttributeTables.players[k].idField, pid[j]))
                    db.query("DELETE FROM " .. childAttributeTables.players[k].table .. " WHERE " .. childAttributeTables.players[k].idField .. " = '" .. pid[j] .. "';")
                end
            else
                db.query("DELETE FROM `players` WHERE `id` = '" .. pid[j] .. "';")
            end
        end
    end
 
    --Drop all the accounts that have 0 players linked to them (at the moment its only checking from the list of players removed)
    if config.deleteAccountWithNoPlayers then
	-- SCRIPT MADE BY PEDRO
		accs_sem_players = db.getResult("SELECT COUNT(id) as semplayers FROM `accounts` WHERE `id` NOT IN (SELECT `account_id` FROM `players`) AND `page_access` = 0 AND `backup_points` = 0;")
		no_players = accs_sem_players:getDataInt("semplayers") -- recebe o valor da consulta de "accs_sem_players" e salva a quantidade de contas sem players e sem pontos salvos na variavel no_players.
		-- deletar accounts que nao possuem players
		db.query("DELETE FROM `accounts` WHERE `id` NOT IN (SELECT `account_id` FROM `players`) AND `page_access` = 0 AND `backup_points` = 0;")
		-- deletar registros de compras de accounts que foram deletadas
		db.query("DELETE FROM `pagseguro_transactions` WHERE `name` NOT IN (SELECT `id` FROM `accounts` WHERE `accounts`.`name` = `pagseguro_transactions`.`name`);")
		-- deletar registros de storage e skills de players deletados
		db.query("DELETE FROM `player_storage` WHERE `player_id` NOT IN (SELECT `id` FROM `players` WHERE `player_storage`.`player_id` = `players`.`id`);")
		db.query("DELETE FROM `player_skills` WHERE `player_id` NOT IN (SELECT `id` FROM `players` WHERE `player_skills`.`player_id` = `players`.`id`);")
        --This part was scripted by Darkhaos, modified/fixed by Teh Maverick --[[
        for acc = 1, #aid do
            result1 = db.getResult("SELECT `id` FROM `accounts` WHERE `id` = '" .. aid[acc] .. "';")
            if result1:getID() ~= -1 then -- check to make sure the account exists
                result1:free()
                for i = 1, #childAttributeTables.accounts do
                    --Make sure there are no other players on the account
                    result1 = db.getResult("SELECT COUNT(id) as count FROM `players` WHERE `account_id` = '" .. aid[acc] .. "';")
					bkpoints = db.getResult("SELECT `backup_points` FROM `accounts` WHERE `id` = '" .. aid[acc] .. "';")
                    tmp = result1:getDataInt("count")
                    if(tmp <= 0) then
                        --Remove accounts if bk points <= 0
						if (bkpoints == 0) then
							dropCount.accounts[i] = ((dropCount.accounts[i] or 0) + countRowsWhereInTable(childAttributeTables.accounts[i].table, childAttributeTables.accounts[i].idField, aid[acc]))
							db.query("DELETE FROM " .. childAttributeTables.accounts[i].table .. " WHERE " .. childAttributeTables.accounts[i].idField .. " = '" .. aid[acc] .. "';")
						end
                    end
                end
            end
        end
    end
    --]]
 
    --Print and Save results (configurable)
    local DB_NOW = {players = DB_BEFORE.players - getDBPlayersCount(), accounts = DB_BEFORE.accounts - getDBAccountsCount()}
    if DB_NOW.players > 0 or DB_NOW.accounts > 0 then
        local text = ">> [DBCLEANUP] " .. DB_NOW.players .. " inactive players" .. (config.deleteAccountWithNoPlayers and " and " .. DB_NOW.accounts .. " empty accounts" or "") .. " have been deleted from the database."
 
        --Write to console
        if config.printResult then
            print("")
            print(text)
            if config.cleanChildTables then
                --Write player info
                for i = 1,#dropCount.players do
                    print("[!] --> Dropped: " .. dropCount.players[i] .. " from " .. childAttributeTables.players[i].table .. " table")
                end
                --Write account info
                if config.deleteAccountWithNoPlayers then
				-- alteracao feita por Pedro:
					print("[!] --> Dropped: " .. no_players .. " accounts without players and saved points from the database.")
				--
                    for i = 1,#dropCount.accounts do
                        print("[!] --> Dropped: " .. dropCount.accounts[i] .. " from " .. childAttributeTables.accounts[i].table .. " table")
                    end
                end
                print("")
            end
        end
 
        --Write to file
        if config.saveResultToFile then
 
            local file = io.open("data/logs/"..config.logFileName, "a")
            file:write("[" .. os.date("%d %B %Y %X ", os.time()) .. "] " .. text .. "\n")
 
            if config.cleanChildTables then
                --Write player info
                for i = 1, #dropCount.players do
                    file:write("[!] --> Dropped: " .. dropCount.players[i] .. " from " .. childAttributeTables.players[i].table .. " table\n")
                end
                --Write account info
                if config.deleteAccountWithNoPlayers then
                    for i = 1, #dropCount.accounts do
                        file:write("[!] --> Dropped: " .. dropCount.accounts[i] .. " from " .. childAttributeTables.accounts[i].table .. " table\n")
                    end
                end
                file:write("\n")
            end
            file:close()
        end
    end
    return true
end