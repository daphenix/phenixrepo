--[[
	Games modules installed
]]

casinoClient.games = {}

-- All games installable
dofile ("games/front_desk.lua")
dofile ("games/slots.lua")

casinoClient.games.gamesList = {}

function casinoClient.games:SetupGames ()
	-- Define list of games available
	local game
	casinoClient.games.gamesList = {}
	for _, game in pairs (casinoClient.games) do
		if type (game) == "table" and game.isPlayable then
			table.insert (casinoClient.games.gamesList, game)
		end
	end
end

function casinoClient.games:CreateGameLauncherUI (launcher, game)
	local gui = game.CreateGameUI or casinoClient.games.frontend.CreateGameUI
	local content = gui (game)
	
	local frame = iup.dialog {
		iup.pdarootframe {
			content;
		},
	    font = casinoClient.ui.font,
		border = 'YES',
		topmost = 'YES',
		resize = 'YES',
		maxbox = 'NO',
		minbox = 'NO',
		modal = 'NO',
		fullscreen = 'NO',
		expand = 'YES',
		active = 'NO',
		menubox = 'NO',
		bgcolor = casinoClient.ui.bgcolor,
		defaultesc = content:GetCloseButton ()
	}
	
	content:GetCloseButton ().action = function ()
		content:DoClose ()
		HideDialog (frame)
		frame.active = "NO"
		ShowDialog (launcher, iup.CENTER, iup.CENTER)
		launcher.active = "YES"
	end
	
	HideDialog (launcher)
	launcher.active = "NO"
	ShowDialog (frame, iup.CENTER, iup.CENTER)
	frame.active = "YES"
end