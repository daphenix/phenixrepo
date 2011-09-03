--[[
	New Game Player Template
]]

gamePlayer.games.newgame = {}
gamePlayer.games.newgame.version = "0.1"
gamePlayer.games.newgame.name = "My New Game Player"
gamePlayer.games.newgame.isPlayable = false  -- true to cause game plugin to load a startup button in launcher
gamePlayer.games.newgame.isCasinoGame = true  -- true if interacting with Casino plugin
gamePlayer.games.newgame.soundDir = "newgame/"

-- List all used sounds here
local sounds = {
	--{name="sound filename", length=2000}
}

-- Game UI
local function NewGame (game)
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

function gamePlayer.games.newgame.CreateGameContent (launcher, game)
	game.ui = gamePlayer.games:CreateBasicUI (launcher, game)
	game.ui:SetMainContent (NewGame (game))
end