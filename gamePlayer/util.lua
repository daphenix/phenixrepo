--[[
	Utility functions
]]

function gamePlayer:Message (playerName, msg, isPublic)
	local type = "CHANNEL"
	if not isPublic then type = "PRIVATE" end
	if gamePlayer.data.isDebug then type = "GROUP" end
	local message = {
		player = playerName,
		msg = msg,
		type = type,
		Send = function ()
			SendChat (msg, type, playerName)
		end
	}
	
	return message
end

function gamePlayer:SendCasinoMessage (msg)
	gamePlayer:SendMessage (gamePlayer.data.casinoName, "!casino " .. msg)
end

function gamePlayer:SendMessage (playerName, msg)
	gamePlayer:Message (playerName, msg):Send ()
end
		
function gamePlayer:IsPlayerInSector (playerName)
	local result = false
	ForEachPlayer (function (id)
		if GetPlayerName (id) == playerName then result = true end
	end)
	
	return result
end

function gamePlayer:BuildSoundName (game, name)
	return game.name .. "-" .. name
end

function gamePlayer:LoadSounds (game, sounds)
	local sound, name, filename
	for _, sound in ipairs (sounds) do
		name = gamePlayer:BuildSoundName (game, sound.name)
		filename = sound.file or sound.name .. ".ogg"
		gksound.GKLoadSound {soundname = name, filename = gamePlayer.data.gameSoundDir .. game.soundDir .. filename}
		gamePlayer.data.sounds [name] = sound
	end
end

function gamePlayer:PlaySound (game, sound, cb)
	local name = gamePlayer:BuildSoundName (game, sound)
	if gamePlayer.data.sounds [name] then
		local volume = sound.volume or 1
		gksound.GKPlaySound (name, volume)
	end
	if type (cb) == "function" then
		local delay = gamePlayer.data.sounds [name]
		if not delay then delay = 350
		else delay = delay.length - 350 or 1650
		end
		Timer ():SetTimeout (delay, cb)
	end
end

function gamePlayer:PlayAmbiance ()
	if gamePlayer.data.isActive and PlayerInStation () then
		local sound = gamePlayer.data.sounds ["gamePlayer-ambiance"]
		gksound.GKPlaySound (sound.name, sound.volume)
		Timer ():SetTimeout (sound.length, function ()
			gamePlayer:PlayAmbiance ()
		end)
	end
end
