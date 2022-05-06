function onLogin(cid)
	registerCreatureEvent(cid, "aloot_kill")
	return true
end
 
local stor = 7575
 
function autoloot(cid, target, pos)
	local function doStack(cid, itemid, new)
		local count = getPlayerItemCount(cid, itemid)
		if (count > 100) then
			count = count - math.floor(count / 100) * 100
		end
		local newCount = count + new
		if (count ~= 0) then
			local find = getPlayerItemById(cid, true, itemid, count).uid
			if (find > 0) then
				doRemoveItem(find)
			else
				newCount = new
			end
		end
		local item = doCreateItemEx(itemid, newCount)
		doPlayerAddItemEx(cid, item, true)
	end
 
	local function scanContainer(cid, uid, list)
		for k = (getContainerSize(uid) - 1), 0, -1 do
			local tmp = getContainerItem(uid, k)
			if (isInArray(list, tmp.itemid)) then
				if isItemStackable(tmp.itemid) and (getPlayerItemCount(cid, tmp.itemid) > 0) then
					doStack(cid, tmp.itemid, tmp.type)
				else
					local item = doCreateItemEx(tmp.itemid, tmp.type)
					doPlayerAddItemEx(cid, item, true)
				end
				doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, 'Looted ' .. tmp.type .. ' ' .. getItemNameById(tmp.itemid) .. '.')
				doRemoveItem(tmp.uid)
			elseif isContainer(tmp.uid) then
				scanContainer(cid, tmp.uid, list)
			end
		end
	end
 
	local items = {}
	for i = getTileInfo(pos).items, 1, -1 do
		pos.stackpos = i
		table.insert(items, getThingFromPos(pos))
	end
 
	if (#items == 0) then
		return
	end
 
	local corpse = -1
	for _, item in ipairs(items) do
		local name = getItemName(item.uid):lower()
		if name:find(target:lower()) then
			corpse = item.uid
			break
		end
	end
 
	if (corpse ~= -1) and isContainer(corpse) then
		scanContainer(cid, corpse, tostring(getPlayerStorageValue(cid, stor)):gsub('_', ''):explode(','))
	end
end
 
function onKill(cid, target, lastHit)
	if not isPlayer(target) then
		local infos = getPlayerStorageValue(cid, stor)
		if (infos == -1) then
			return true
		end
		local list = tostring(infos):explode(',')
		if (#list == 0) then
			return true
		end
		addEvent(autoloot, 150, cid, getCreatureName(target), getCreaturePosition(target))
	end
	return true
end