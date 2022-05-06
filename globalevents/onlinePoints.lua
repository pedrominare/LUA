function giveOnlinePoints(cid, quant)
	if getCreatureName(cid) ~= "Account Manager" and doConvertIntegerToIp(getPlayerIp(cid)) ~= "0.0.0.0" then -- lembrar sempre de usar isso com o comando de getipqueststatus !
		if (getPlayerStorageValue(cid, onlinePoints.str) <= os.time()) then
			if getPlayerLevel(cid) >= 100 then
				if (math.random(1, 100) < onlinePoints.chance) then
					doSendMagicEffect(getThingPos(cid), 49)
					doPlayerAddItem(cid, onlinePoints.pbox, 1)
					doCreatureSay(cid, "[LUCKY]", 19)
					setPlayerStorageValue(cid, onlinePoints.str, os.time() + onlinePoints.online_time)
					doCreatureSay(getCreatureByName(getCreatureName(cid)), "[ONLINE REWARD System] SORTUDO! Voc� ganhou uma PREMIUM BOX por estar online! Pr�ximo pr�mio em 1h !", TALKTYPE_PRIVATE, false, cid)
					return true
				else
					doCreatureSay(cid, "[POINTS]", 19)
					doSendMagicEffect(getThingPos(cid), 48)
					doPlayerAddGuildPoints(cid, quant)
					setPlayerStorageValue(cid, onlinePoints.str, os.time() + onlinePoints.online_time)
					doCreatureSay(getCreatureByName(getCreatureName(cid)), "[ONLINE REWARD System] Parab�ns! Voc� recebeu +".. onlinePoints.points .." guild point por estar online! Voc� possui ".. getPlayerGuildPoints(cid) .." guild points. Pr�ximo pr�mio em 1h !", TALKTYPE_PRIVATE, false, cid)
					return true
				end
			else
				return false
				--doCreatureSay(getCreatureByName(getCreatureName(cid)), "[ONLINE REWARD System] Voc� n�o possui level 100+ para receber seu pr�mio !", TALKTYPE_PRIVATE, false, cid)
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