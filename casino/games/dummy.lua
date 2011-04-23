function casino.games.Dummy (game)
	local dummy = casino.games:BaseController  (game)
	dummy.initialResponse = false
	dummy.canPlay = true
	
	function dummy:Play (req)
		if not dummy.initialResponse then
			casino:SendMessage (game.player,  string.format ("Game: %s for player: %s", game.name, game.player))
			dummy.initialResponse = true
		else
			casino:SendMessage (game.player,  string.format ("I know you are, but what am I?  %s", req))
		end
		
		if math.random (1, 100) < 50 then
			dummy:Win (10)
		else
			dummy:Lose ()
		end
	end
	
	return dummy
end