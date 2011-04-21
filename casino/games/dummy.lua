function casino.games.Dummy (game)
	local dummy = casino.games:Game (game)
	
	function dummy:Play (req)
		--SendChat (string.format ("Game: %s for player: %s", game.name, game.player), "PRIVATE", game.player)
		print (string.format ("Game: %s for player: %s", game.name, game.player))
	end
	
	return dummy
end