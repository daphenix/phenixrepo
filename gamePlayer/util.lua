--[[
	Utility functions
]]

function gamePlayer:SendCasinoMessage (msg)
	if gamePlayer.data.isDebug then
		gamePlayer.messaging:Send (gamePlayer.data.casinoName, "!casino " .. msg, "GROUP")
	else
		gamePlayer.messaging:Send (gamePlayer.data.casinoName, "!casino " .. msg, "PRIVATE")
	end
end

function gamePlayer:SendMessage (playerName, msg)
	gamePlayer.messaging:Send (playerName, msg, "PRIVATE")
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
