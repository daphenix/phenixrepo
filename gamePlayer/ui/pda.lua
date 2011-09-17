--[[
	Adds game controls to bar environment
]]

gamePlayer.pda = {}
function gamePlayer.pda:CreateBarUI (barTab)
	-- Build Exchange Buttons
	local content = iup.vbox {
		iup.label {title="Games   -   v" .. gamePlayer.version, font=gamePlayer.ui.font, fgcolor=gamePlayer.ui.fgcolor, expand="HORIZONTAL"},
		iup.hbox {
			iup.stationbutton {title="Enter Casino", font=gamePlayer.ui.font, action=gamePlayer.Start};
		};
	}
	
	iup.Append (barTab [1][1], content)
	iup.Refresh (barTab)
end