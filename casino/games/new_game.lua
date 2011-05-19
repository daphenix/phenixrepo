--[[
	New Game Template
	
	Use this template to create additional games
]]
casino.games.newgame = {}
casino.games.newgame.version = "0.1"

function casino.games.mygame.GetController (game)
	local mygame = casino.games:BaseController  (game)
	
	-- Use the canPlay property to determine if the game will accept bets before allowing play
	--mygame.canPlay = true 			-- would allow play immediately.  No bets would be allowed
	--mygame.canPlay = false			-- would require bets to be made before play is allowed
	-- If allowing bets, make sure to set canPlay back to false in the Play function
	
	-- Use this function to send basic help about the game interface back to the user
	function mygame:Help ()
		mygame:SendMessage ("Just send !casino play to play")
	end
	
	-- This is the basic game function
	-- Runs the game for the player and changes any state variables being used by the game
	function mygame:Play (req)
	end
	
	-- Used for processing any commands outside the basic command set (i.e. bet, play, quit)
	-- May set state variables for use by play
	function mygame:ParseKey (key, args)
	end
	
	return mygame
end
