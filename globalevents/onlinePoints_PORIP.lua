function giveOnlinePoints(cid, quant)
	if getCreatureName(cid) ~= "Account Manager" and doConvertIntegerToIp(getPlayerIp(cid)) ~= "0.0.0.0" then -- lembrar sempre de usar isso com o comando de getipqueststatus !
		local onlinePoints_status = getIpQuestStatus(cid, onlinePoints.str)
		-- isso foi necessario para restringir o premio apenas para o player que tiver registrado o valor no banco de dados, ou seja, o que logou primeiro.
		local search_player_count = db.getResult("SELECT COUNT(id) as count FROM `player_ip_storage` WHERE `ip` = \"" .. doConvertIntegerToIp(getPlayerIp(cid)) .. "\" and `storage` = ".. onlinePoints.str ..";")
		if (search_player_count:getDataInt("count") > 0) then
			local search_player = db.getResult("SELECT `player_id` FROM `player_ip_storage` WHERE `ip` = \"" .. doConvertIntegerToIp(getPlayerIp(cid)) .. "\" and `storage` = ".. onlinePoints.str ..";")
			if (search_player:getID() ~= LUA_ERROR) then
				local playerid = search_player:getDataInt("player_id")
				search_player:free()
			else
				local playerid = nil
			end
		else
			local playerid = nil
		end
		--debugando
		--doCreatureSay(getCreatureByName(getCreatureName(cid)), "[ONLINE REWARD System] Valor da sua storage: ".. op_storage .." / Valor do seu id: "..getPlayerGUID(cid).." / valor do ID registrado: "..op_playerid.."", TALKTYPE_PRIVATE, false, cid)
		if (onlinePoints_status <= os.time() and playerid == getPlayerGUID(cid)) then
			if getPlayerLevel(cid) >= 100 then
				if (math.random(1, 100) < onlinePoints.chance) then
					doSendMagicEffect(getThingPos(cid), 49)
					doPlayerAddItem(cid, onlinePoints.pbox, 1)
					doCreatureSay(cid, "[LUCKY]", 19)
					setIpQuestStatus(cid, onlinePoints.str, os.time() + onlinePoints.online_time)
					doCreatureSay(getCreatureByName(getCreatureName(cid)), "[ONLINE REWARD System] SORTUDO! Você ganhou uma PREMIUM BOX por estar online! Próximo prêmio em 1h !", TALKTYPE_PRIVATE, false, cid)
					return true
				else
					doCreatureSay(cid, "[POINTS]", 19)
					doSendMagicEffect(getThingPos(cid), 48)
					doPlayerAddGuildPoints(cid, quant)
					setIpQuestStatus(cid, onlinePoints.str, os.time() + onlinePoints.online_time)
					doCreatureSay(getCreatureByName(getCreatureName(cid)), "[ONLINE REWARD System] Parabéns! Você recebeu +".. onlinePoints.points .." guild point por estar online! Você possui ".. getPlayerGuildPoints(cid) .." guild points. Próximo prêmio em 1h !", TALKTYPE_PRIVATE, false, cid)
					return true
				end
			else
				return doCreatureSay(getCreatureByName(getCreatureName(cid)), "[ONLINE REWARD System] Você não possui level 100+ para receber seu prêmio !", TALKTYPE_PRIVATE, false, cid)
			end
		end
	end
end

function onThink(interval)
	for i, v in pairs(getPlayersOnline()) do
		giveOnlinePoints(v, onlinePoints.points)
	end

return true
end