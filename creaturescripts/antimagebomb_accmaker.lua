local config = {
	max = 10, -- Número de players permitido com o mesmo IP.
	group_id = 2 -- Kikar apenas player com o group id 1.
}

local accepted_ip_list = {"179.54.148.181"} -- Lista dos players permitidos a usar MC, exemplo: {"200.85.3.60", "201.36.5.222"}

local function antiMC(p)
	if #getPlayersByIp(getPlayerIp(p.pid)) >= p.max then
		doRemoveCreature(p.pid)
	end
	return true
end

function onLogin(cid)

	if getPlayerGroupId(cid) == config.group_id then -- nao quero um anti-mc por enquanto, apenas um anti magebomb
		if isInArray(accepted_ip_list,doConvertIntegerToIp(getPlayerIp(cid))) == false then
			addEvent(antiMC, 200, {pid = cid, max = config.max+1})
		end
	end
	return true
end