--[[
	Game Statistics Tab screen for Casino
	
	GUI management for game statistics
]]

function casino.ui:CreateStatsTab ()
	local winsLabel = iup.label {title=tostring (casino.data.wins), font=casino.ui.font}
	local lossesLabel = iup.label {title=tostring (casino.data.losses), font=casino.ui.font}
	local totalBetsLabel = iup.label {title=tostring (casino.data.totalBet), font=casino.ui.font}
	local totalPayoutsLabel = iup.label {title=tostring (casino.data.totalPaidout), font=casino.ui.font}
	local volumeLabel = iup.label {title=tostring (casino.data.volume), font=casino.ui.font}

	local statsTab = iup.pdasubframe_nomargin {
		iup.hbox {
			iup.fill {size = 5},
			iup.vbox {
				iup.fill {size = 25},
				iup.hbox {
					iup.label {title="Number of wins: ", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
					winsLabel;
					expand = "HORIZONTAL"
				},
				iup.hbox {
					iup.label {title="Number of losses: ", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
					lossesLabel;
					expand = "HORIZONTAL"
				},
				iup.hbox {
					iup.label {title="Total credits bet into bank: ", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
					totalBetsLabel;
					expand = "HORIZONTAL"
				},
				iup.hbox {
					iup.label {title="Total credits paid out by bank: ", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
					totalPayoutsLabel;
					expand = "HORIZONTAL"
				},
				iup.hbox {
					iup.label {title="Volume since Last Reset: ", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
					volumeLabel;
					expand = "HORIZONTAL"
				},
				iup.fill {size=25};
				expand = "VERTICAL"
			},
			iup.fill {};
			expand = "HORIZONTAL"
		};
		tabtitle="Statistics",
		font=casino.ui.font,
		expand = "YES"
	}
	
	function statsTab:ReloadData ()
		winsLabel.title = tostring (casino.data.wins)
		lossesLabel.title = tostring (casino.data.losses)
		totalBetsLabel.title = tostring (casino.data.totalBet)
		totalPayoutsLabel.title = tostring (casino.data.totalPaidout)
		volumeLabel.title = tostring (casino.data.volume)
	end
	
	return statsTab
end