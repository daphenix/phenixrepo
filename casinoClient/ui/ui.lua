--[[
	UI Elements
]]
casinoClient.ui = {}
casinoClient.ui.font = 14 * (gkinterface.GetYResolution () / 600)
casinoClient.ui.fontSmall = 10 * (gkinterface.GetYResolution () / 600)
casinoClient.ui.bgcolor = "255 10 10 10*"
casinoClient.ui.highlight = "255 150 150 150*"
casinoClient.ui.fgcolor = "200 200 50"
casinoClient.ui.alertcolor = "200 50 50"
casinoClient.ui.okaycolor = "50 200 50"

function casinoClient.ui:GetOnOffSetting (flag)
	if (flag) then
		return "ON"
	else
		return "OFF"
	end
end

function casinoClient.ui:CreateLauncherUI ()
	-- Build Launcher root
	local content = iup.pdarootframe {}
	local launcher = iup.dialog {
		content,
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
		bgcolor = casinoClient.ui.bgcolor
	}
	-- Setup holder for buttons
	local buttonPanel = iup.vbox {
		iup.label {title = "Configure Individual Games Here", align = "ACENTER", expand = "HORIZONTAL"},
		iup.fill {size = 25};
		expand = "YES"
	}
	
	-- Loop through all the games in the gameslist and built launcher buttons for them
	local k, game, button, rowPanel
	local index = 1
	for k, game in pairs (casino.games) do
		if type (game) == "table" and game.name then
		end
	end
	
	
	
	
	local pda = iup.hbox {
		iup.fill {size = 5},
		;
		expand = "YES"
	}
	
	launcher.defaultesc = pda:GetCancelButton ()
	
end
