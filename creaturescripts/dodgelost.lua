local config = {
	storagedodge = 48902,
	level = 500
	}
function onPrepareDeath(cid, lastHitKiller, mostDamageKiller)
	
	if (getPlayerStorageValue(cid, config.storagedodge) > 1) then
		if (getCreatureSkullType(cid) >= 4 or getPlayerLevel(cid) >= config.level) then
			setPlayerStorageValue(cid, config.storagedodge, getPlayerStorageValue(cid, config.storagedodge)-1)
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE ,"Voce perdeu 1 dodge pela sua morte! Agora voce tem ["..(getPlayerStorageValue(cid, config.storagedodge)).."/600].")
		end
	end
	
return 1
end