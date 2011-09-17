--[[
	Game Configuration Tab screen for Casino
	
	Each supported game has a launch button for it config dialog
]]

function casino.ui:CreateGameConfigTab ()
	-- Row Width.  The number of buttons in a rows
	local rowWidth = 3

	-- Setup holder for buttons
	local buttonPanel = iup.vbox {
		iup.label {title = "Configure Individual Games Here", align = "ACENTER", expand = "HORIZONTAL"},
		iup.fill {size = 25};
		expand = "YES"
	}
	
	-- Loop through all the discovered games and add buttons for their configurations
	local k, game, button, rowPanel
	local index = 1
	for k, game in pairs (casino.games) do
		if type (game) == "table" and game.name then
			-- Game exists
			button = iup.stationbutton {
				title = game.name,
				size = "150x",
				font = casino.ui.font,
				action = function ()
					casino.games:CreateConfigUI (game)
				end
			}
			if index % rowWidth == 1 then
				rowPanel = iup.hbox {iup.fill {size = 5}, button, iup.fill {size = 5}, expand = "YES"}
			else
				iup.Append (rowPanel, button)
				iup.Append (rowPanel, iup.fill {size = 5})
			end
			if index % rowWidth == 0 then
				iup.Append (buttonPanel, rowPanel)
				rowPanel = nil
			end
			index = index + 1
		end
	end
	if rowPanel then
		iup.Append (buttonPanel, rowPanel)
	end
	iup.Append (buttonPanel, iup.fill {})

	local gameConfigTab = iup.pdasubframe_nomargin {
		iup.hbox {
			iup.fill {size = 5},
			buttonPanel,
			iup.fill {};
			expand = "YES"
		};
		tabtitle="Game Configs",
		font=casino.ui.font,
		expand = "YES"
	}
	
	function gameConfigTab:ReloadData ()
	end
	
	function gameConfigTab:DoSave ()
	end
	
	return gameConfigTab
end