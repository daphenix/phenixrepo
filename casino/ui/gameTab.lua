--[[
	Game Tab screen for Casino
	
	GUI management for game list functions
]]
function casino.ui:CreateGameTab (bannedTab)
	local addGameButton = iup.stationbutton {title="Add Game", font=casino.ui.font}
	local removeGameButton = iup.stationbutton {title="Remove Game", font=casino.ui.font, active="NO"}
	local banPlayerButton = iup.stationbutton {title="Ban Player", font=casino.ui.font, active="NO"}
	local selectedRow = 0

	local function SetButtonState ()
		removeGameButton.active = "NO"
		banPlayerButton.active = "NO"
		if selectedRow > 0 then
			removeGameButton.active = "YES"
			banPlayerButton.active = "YES"
		end
	end

	-- Build Data Matrix
	local matrix = iup.pdasubmatrix {
		numcol = 3,
		numlin = 1,
		numlin_visible = 10,
		heightdef = 15,
		expand = "YES",
		scrollbar = "YES",
		widthdef = 120,
		font = casino.ui.font,
		bgcolor = casino.ui.bgcolor
	}
	
	-- Set Headers
	matrix:setcell (0, 1, "Name")
	matrix:setcell (0, 2, "Game")
	matrix:setcell (0, 3, "Date Started")
	matrix:setcell (1, 1, string.rep (" ", 27))
	matrix:setcell (1, 2, string.rep (" ", 30))
	matrix:setcell (1, 3, string.rep (" ", 25))
	
	function matrix:SetSelectedRow (self, row)
		-- Set all bgcolors
		selectedRow = row
		local l, bgcolor
		for l=1, self.numlin do
			bgcolor = string.format ("bgcolor%d:*", l)
			if l == row then
				self [bgcolor] = casino.ui.highlight
			else
				self [bgcolor] = casino.ui.bgcolor
			end
		end
	end
	
	function matrix:Set (row, data)
		if data then
			matrix:setcell (row, 1, tostring (data.player))
			matrix:setcell (row, 2, tostring (data.name))
			matrix:setcell (row, 3, tostring (data.startdate))
		end
		matrix.alignment1 = "ALEFT"
		matrix.alignment2 = "ALEFT"
		matrix.alignment3 = "ALEFT"
		matrix.width1 = 175
		matrix.width2 = 125
		matrix.width3 = 175
	end
	
	function matrix.click_cb (self, row, col)
		self:SetSelectedRow (self, row)
		return SetButtonState ()
	end
	
	local gameTab = iup.pdasubframe_nomargin {
		iup.hbox {
			iup.fill {size = 5},
			iup.vbox {
				matrix,
				iup.fill {size = 25},
				iup.hbox {
					iup.fill {},
					addGameButton,
					removeGameButton,
					banPlayerButton;
					expand = "HORIZONTAL"
				},
				iup.fill {};
				expand = "YES"
			};
			expand = "YES"
		};
		tabtitle="Games",
		font=casino.ui.font,
		expand = "YES"
	}
	
	function gameTab:ClearData ()
		local i
		for i=1, tonumber (matrix.numlin) do
			matrix.dellin = 1
		end
	end
	
	function gameTab:ReloadData ()
		local list = {}
		local name, game, v
		for name, game in pairs (casino.data.tables) do
			table.insert (list, {
				name = game.name,
				player = game.player,
				startdate = game.startdate
			})
		end
		table.sort (list, function (a,b)
			return a.player < b.player
		end)
		gameTab:ClearData ()
		local row = 0
		matrix.heightdef = 15
		matrix.redraw = "ALL"
		if #list > 0 then
			for _,v in ipairs (list) do
				matrix.addlin = row
				matrix.font = casino.ui.font
				row = row + 1
				matrix:Set (row, v)
			end
			matrix.numlin = row
		else
			matrix.addlin = row
			matrix:Set (0)
		end
		iup.Refresh (gameTab)
	end
	gameTab:ReloadData ()
	
	-- Define local popup for new accounts
	local playerName = iup.text {value = "", size="150x"}
	local gameName = iup.text {value = "", size="100x"}
	local newGamePopup = nil
	
	local function GetNewGamePopup ()
		if not newGamePopup then
			local createButton = iup.stationbutton {title="Create", font=casino.ui.font}
			local cancelButton = iup.stationbutton {title="Cancel", font=casino.ui.font}
		
			local frame = iup.dialog {
				iup.pdarootframe {
					iup.vbox {
						iup.hbox {
							iup.fill {size = 5},
							iup.label {title="Player Name: ", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
							playerName,
							iup.fill {size=5};
							expand = "HORIZONTAL"
						},
						iup.fill {size=5},
						iup.hbox {
							iup.fill {size=5},
							iup.label {title="Game to Play: ", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
							gameName,
							iup.fill {size=5};
							expand = "HORIZONTAL"
						},
						iup.fill {size=15},
						iup.hbox {
							iup.fill {},
							createButton,
							cancelButton;
							expand = "HORIZONTAL"
						};
					};
				},
			    font = casino.ui.font,
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
				bgcolor = "255 10 10 10 *",
				defaultesc = cancelButton
			}
			
			function createButton:action ()
				casino.data.tables [playerName.value] = casino.games:CreateGame (gameName.value, playerName.value)
				casino.data.volume = casino.data.volume + 1
				HideDialog (frame)
				frame.active = "NO"
				gameTab:ReloadData ()
			end
			
			function cancelButton:action ()
				HideDialog (frame)
				frame.active = "NO"
			end
			newGamePopup = frame
		else
			playerName.value = ""
			gameName.value = ""
		end
		
		return newGamePopup
	end
	
	function addGameButton.action ()
		local frame = GetNewGamePopup ()
		ShowDialog (frame, iup.CENTER, gkinterface.GetYResolution () / 4 - 35)
		frame.active = "YES"
		return SetButtonState ()
	end
	
	function removeGameButton.action ()
		casino.data.tables [matrix:getcell (selectedRow, 1)] = nil
		selectedRow = 0
		return SetButtonState ()
	end
	
	function banPlayerButton.action ()
		local frame = casino.ui:GetBanPlayerPopup (matrix:getcell (selectedRow, 1), gameTab, bannedTab)
		ShowDialog (frame, iup.CENTER, gkinterface.GetYResolution () / 4 - 35)
		frame.active = "YES"
		selectedRow = 0
		return SetButtonState ()
	end
	
	return gameTab
end