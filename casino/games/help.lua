function casino.games.Dummy (game)
	local dummy = casino.games:BaseController  (game)
	dummy.canPlay = true
	
	function dummy:Play (req)
		dummy:SendMessage ("Send play, bet or quit")
	end
	
	return dummy
end