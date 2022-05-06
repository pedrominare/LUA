domodlib('EventPoints')

local storageIdGreen = 10001
local storageIdRed = 10002

-- apenas para rapida alteracao de quantidade de kills para acabar o evento, a titulo de testes.
local eventconfigs = {
	narrow = 3,
	constante = 1
}

-- variaveis a serem manipuladas no evento
local config = {
	pos_rock_green = {x=489, y=281, z=7, stackpos=1},
	pos_TP_green = {x=488, y=278, z=7, stackpos=1},
	pos_rock_red = {x=479, y=278, z=7, stackpos=1},
	pos_TP_red = {x=477, y=281, z=7, stackpos=1},
	townid = 13
}

-- remove teleport da posicao inicial do player para o proximo round e escolher novo time
--function removeTp(posChooseNewTeam)
--	local t = getTileItemById(posChooseNewTeam, 1387)
--	if t then
--		doRemoveItem(t.uid, 1)
--		doSendMagicEffect(posChooseNewTeam, CONST_ME_POFF)
--	end
--end

-- recebe mensagem quando mata no evento
function onKill(cid, target)

	if isPlayer(cid) and isPlayer(target) then 
		if getPlayerStorageValue(cid, eventconfig.storageIdRed) == 1 and getPlayerStorageValue(target, eventconfig.storageIdGreen) == 1 then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Seu time recebeu ponto ! Você possui: ["..getPlayerStorageValue(cid, eventconfig.GSR).."/"..eventconfig.narrow.."] kills.")		
		end
		
		if getPlayerStorageValue(cid, eventconfig.storageIdGreen) == 1 and getPlayerStorageValue(target, eventconfig.storageIdRed) == 1 then
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Seu time recebeu ponto ! Você possui: ["..getPlayerStorageValue(cid, eventconfig.GSG).."/"..eventconfig.narrow.."] kills.")
		end
	end

return true
end

-- efeito do evento
function onThink(cid, interval)
	if getPlayerStorageValue(cid, eventconfig.storageIdGreen) == 1 and getPlayerStorageValue(cid, eventconfig.effect_storage) ~= 1 then
--		addEvent(SendEffect, 2000, cid, 18, "GREEN", TEXTCOLOR_GREEN)
		SendEffect(cid, 18, "GREEN", TEXTCOLOR_GREEN)
		SendSquare(cid, 60)
		setPlayerStorageValue(cid, eventconfig.effect_storage, 1)
	elseif getPlayerStorageValue(cid, eventconfig.storageIdRed) == 1 and getPlayerStorageValue(cid, eventconfig.effect_storage) ~= 1 then
--		addEvent(SendEffect, 2000, cid, 19, "RED", TEXTCOLOR_RED)
		SendEffect(cid, 19, "RED", TEXTCOLOR_RED)
		SendSquare(cid, 401)
		setPlayerStorageValue(cid, eventconfig.effect_storage, 1)
	end
end

--Impedindo troca de outfit durante o evento
function onOutfit(cid, old, current)
    if getPlayerStorageValue(cid, eventconfig.storageIdRed) == 1 or getPlayerStorageValue(cid, eventconfig.storageIdGreen) == 1  then
        doPlayerSendCancel(cid, "Você não pode mudar seu outfit enquanto estiver no evento!")
        return false
	else
		return true
    end
end

-- atacar membro do proprio time
function onCombat(cid, target)
	if isPlayer(cid) and isPlayer(target) then
		if getPlayerStorageValue(target, eventconfig.storageIdGreen) == 1 and getPlayerStorageValue(cid, eventconfig.storageIdGreen) == 1 then
			--doPlayerSendCancel(cid, "Você não pode atacar membros do seu time!")
			doCreatureSetSkullType(cid, 0)
			return false
		end
		if getPlayerStorageValue(target, eventconfig.storageIdRed) == 1 and getPlayerStorageValue(cid, eventconfig.storageIdRed) == 1 then
			--doPlayerSendCancel(cid, "Você não pode atacar membros do seu time!")
			doCreatureSetSkullType(cid, 0)
			return false
		end	
	end
return true
end

-- a funcao principal do evento, a que vai entregar os pontos para os times que forem matando
function onPrepareDeath(cid, deathList, lastHitKiller, mostDamageKiller)

	if isPlayer(cid) then
		if getPlayerStorageValue(cid, storageIdRed) == 1 or getPlayerStorageValue(cid, storageIdGreen) == 1 then
			if getPlayerStorageValue(cid, eventconfig.GSR) < 0 then
				setPlayerStorageValue(cid, eventconfig.GSR, 0)
			end
			if getPlayerStorageValue(cid, eventconfig.GSG) < 0 then
				setPlayerStorageValue(cid, eventconfig.GSG, 0)
			end
		end

		if getPlayerStorageValue(cid, storageIdRed) == 1 then
			-- aqui o time verde recebe um ponto a cada vez que um membro do time vermelho morrer.
			setGlobalStorageValue(eventconfig.green_team_kills, getGlobalStorageValue(eventconfig.green_team_kills) + 1) -- aqui o global storage e salvo para o green team porque foi um membro do red team que morreu.
			doBroadcastMessage("A equipe VERDE possui : ["..getGlobalStorageValue(eventconfig.green_team_kills).."/"..eventconfig.narrow.."] pontos.", MESSAGE_STATUS_CONSOLE_ORANGE)
			-- fim das edicoes
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você deu ponto para a equipe adversária ! Você possui : ["..getPlayerStorageValue(cid, eventconfig.GSR).."/"..eventconfig.narrow.."] pontos.")
					for i = 1, #deathList do
						setPlayerStorageValue(deathList[i], eventconfig.GSG, getPlayerStorageValue(deathList[i], eventconfig.GSG) + eventconfigs.constante)
					end
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "O(a) "..getCreatureName(deathList[1]).." possui um total de: ["..getPlayerStorageValue(deathList[1], eventconfig.GSG).."/"..eventconfig.narrow.."] pontos.")		
		end
		if getPlayerStorageValue(cid, storageIdGreen) == 1 then
		-- aqui o time vermelho recebe um ponto a cada vez que um membro do time verde morrer.
		setGlobalStorageValue(eventconfig.red_team_kills, getGlobalStorageValue(eventconfig.red_team_kills) + 1) -- aqui o global storage e salvo para o red team porque foi um membro do green team que morreu.
		doBroadcastMessage("A equipe VERMELHA possui : ["..getGlobalStorageValue(eventconfig.red_team_kills).."/"..eventconfig.narrow.."] pontos.", MESSAGE_STATUS_CONSOLE_ORANGE)
		-- fim das edicoes
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Você deu ponto para a equipe adversária ! Voce possui : ["..getPlayerStorageValue(cid, eventconfig.GSG).."/"..eventconfig.narrow.."] pontos.")
					for i = 1, #deathList do
						setPlayerStorageValue(deathList[i], eventconfig.GSR, getPlayerStorageValue(deathList[i], eventconfig.GSR) + eventconfigs.constante)
					end
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "O(a) "..getCreatureName(deathList[1]).." possui um total de: ["..getPlayerStorageValue(deathList[1], eventconfig.GSR).."/"..eventconfig.narrow.."] pontos.")
		end

-- fim do evento
-- antiga verificacao por players individualmente e nao pelo time
-- if getPlayerStorageValue(deathList[1], eventconfig.GSR) >= eventconfig.narrow or getPlayerStorageValue(deathList[1], eventconfig.GSG) >= eventconfig.narrow then
-- Agora verificando as mortes por time

		if (getGlobalStorageValue(eventconfig.green_team_kills) >= eventconfig.narrow or getGlobalStorageValue(eventconfig.red_team_kills) >= eventconfig.narrow) then
			if (getGlobalStorageValue(eventconfig.red_team_kills) >= eventconfig.narrow) then
				doBroadcastMessage("{RED TEAM} VENCE O EVENTO ! FRAGS -> ["..getGlobalStorageValue(eventconfig.red_team_kills).."] KILLS !", MESSAGE_STATUS_CONSOLE_ORANGE)
				FinishEventRedWinner()			
			end
			
			-- if getPlayerStorageValue(deathList[1], eventconfig.storageIdGreen) == 1 then
			if (getGlobalStorageValue(eventconfig.green_team_kills) >= eventconfig.narrow) then
				doBroadcastMessage("{GREEN TEAM} VENCE O EVENTO ! FRAGS -> ["..getGlobalStorageValue(eventconfig.green_team_kills).."] KILLS !", MESSAGE_STATUS_CONSOLE_ORANGE)
				FinishEventGreenWinner()
			end

		FinishEvent()
-- criando a pedra em frente ao tp para evitar que players entrem antes do prazo estipulado
		create_stones(eventconfig.normal_stone, eventconfig.posChooseNewTeamInFrontOf)
		doCreateTeleport(1387, eventconfig.saladeespera, eventconfig.posChooseNewTeam)
		addEvent(Seta, 1000, eventconfig.posChooseNewTeam, 30)
-- tempo para remover a pedra que fica em frente ao tp de choose team que surge na sala de espera no proximo round
		addEvent(removeStone, eventconfig.timeBackChooseTeam*1000, eventconfig.posChooseNewTeamInFrontOf, eventconfig.normal_stone)
		addEvent(removeTp, eventconfig.timeBackChooseTeamTP*1000, eventconfig.posChooseNewTeam) -- remover o tp que fica no meio da sala de espera para dividir os times a partir do 2 round
	end
end

return true
end