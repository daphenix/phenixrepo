--[[
	Blackjack Client
]]

gamePlayer.games.blackjack = {}
gamePlayer.games.blackjack.version = "0.1"
gamePlayer.games.blackjack.name = "Blackjack"
gamePlayer.games.blackjack.gameName = "blackjack"
gamePlayer.games.blackjack.isPlayable = true  -- true to cause game plugin to load a startup button in launcher
gamePlayer.games.blackjack.isCasinoGame = true  -- true if interacting with Casino plugin
gamePlayer.games.blackjack.soundDir = "blackjack/"

-- List all used sounds here
local sounds = {
	--{name="sound filename", length=2000}
}

-- Game UI
local function Blackjack (game)
	-- Generate the GUI for the game
	local content = iup.hbox {
		iup.fill {size=5},
		iup.vbox {
			-- Main Content goes here
		},
		iup.fill {size=5};
		expand="YES"
	}
	
	return content
end

function gamePlayer.games.blackjack.CreateGameContent (launcher, game)
	game.ui = gamePlayer.games:CreateBasicUI (launcher, game)
	game.ui:SetMainContent (Blackjack (game))
end