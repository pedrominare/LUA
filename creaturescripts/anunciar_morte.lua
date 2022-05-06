function onDeath(cid, corpse, deathList)

local strings = {""}
local t, position = 1, 1

local deathType = "killed"
local toSlain, toCrushed, toEliminated = 3, 9, 15

if #deathList >= toSlain and #deathList < toCrushed then
deathType = "slain"
elseif #deathList >= toCrushed and #deathList < toEliminated then
deathType = "crushed"
elseif #deathList >= toEliminated then
deathType = "eliminated"
end

for _, pid in ipairs(deathList) do
if isCreature(pid) == true then
strings[position] = t == 1 and "" or strings[position] .. ", "
strings[position] = strings[position] .. getCreatureName(pid) .. ""
t = t + 1
else
strings[position] = t == 1 and "" or strings[position] .. ", "
strings[position] = strings[position] .."a field item"
t = t + 1
end
end

for i, str in ipairs(strings) do
if(str:sub(str:len()) ~= ",") then
str = str .. "."
end

msg = getCreatureName(cid) .. " was " .. deathType .. " at level " .. getPlayerLevel(cid) .. " by " .. str
end

for _, oid in ipairs(getPlayersOnline()) do
doPlayerSendChannelMessage(oid, "Death channel", msg, TALKTYPE_CHANNEL_O, CHANNEL_DEATH)
end
return true
end