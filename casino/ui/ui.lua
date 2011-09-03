--[[
	UI Elements
]]
casino.ui = {}
casino.ui.font = 14 * (gkinterface.GetYResolution () / 600)
casino.ui.fontSmall = 10 * (gkinterface.GetYResolution () / 600)
casino.ui.bgcolor = "255 10 10 10*"
casino.ui.highlight = "255 150 150 150*"
casino.ui.fgcolor = "200 200 50"
casino.ui.alertcolor = "200 50 50"
casino.ui.okaycolor = "50 200 50"
casino.ui.dateFormat = "%b/%d/%Y %H:%M"
dofile ("ui/control.lua")

function casino.ui:GetOnOffSetting (flag)
	if (flag) then
		return "ON"
	else
		return "OFF"
	end
end

function casino.ui:CreateApprovalUI (msg, acceptMsg, acceptCB, refuseCB)
	local acceptButton = iup.stationbutton {title = "Yes", font = casino.ui.font}
	local refuseButton = iup.stationbutton {title = "No", font = casino.ui.font}
	
	local ui = iup.pdarootframe {
		iup.vbox {
			iup.label {title=msg, expand="HORIZONTAL"},
			iup.label {title=acceptMsg, alignment="ACENTER", expand="HORIZONTAL"},
			iup.hbox {
				iup.fill {},
				acceptButton,
				refuseButton;
				expand="HORIZONTAL"
			};
			expand="YES"
		};
		expand="YES"
	}
	local frame = iup.dialog {
		ui,
	    font = casino.ui.font,
		border = 'YES',
		topmost = 'YES',
		resize = 'YES',
		maxbox = 'NO',
		minbox = 'NO',
		modal = 'YES',
		fullscreen = 'NO',
		expand = "YES",
		active = 'YES',
		menubox = 'NO',
		bgcolor = "255 10 10 10 *",
		defaultesc = refuseButton
	}
	
	acceptButton.action = function ()
		HideDialog (frame)
		frame.active = "NO"
		if acceptCB then acceptCB () end
	end
	
	refuseButton.action = function ()
		HideDialog (frame)
		frame.active = "NO"
		if refuseCB then refuseCB () end
	end
	
	-- Display dialog as created
	ShowDialog (frame, iup.CENTER, iup.CENTER)
	
	return frame
end

function casino.ui:CreateInfoUI (title, msg)
	local okButton = iup.stationbutton {title = "Ok", font = casino.ui.font}
	
	local ui = iup.pdasubsubframebg {
		iup.hbox {
			iup.fill {size = 5},
			iup.vbox {
				iup.label {title=title, expand="HORIZONTAL", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
				iup.fill {size = 10},
				iup.label {title=msg, alignment="ALEFT", expand="HORIZONTAL", font=casino.ui.font},
				iup.hbox {
					iup.fill {},
					okButton;
					expand="HORIZONTAL"
				};
				expand="YES"
			},
			iup.fill {size = 5};
			expand="YES"
		};
		expand="YES"
	}
	local frame = iup.dialog {
		ui,
	    font = casino.ui.font,
		border = 'YES',
		topmost = 'YES',
		resize = 'YES',
		maxbox = 'NO',
		minbox = 'NO',
		modal = 'YES',
		fullscreen = 'NO',
		expand = "YES",
		active = 'YES',
		menubox = 'NO',
		bgcolor = "255 10 10 10 *",
		defaultesc = okButton
	}
	
	okButton.action = function ()
		HideDialog (frame)
		frame.active = "NO"
	end
	
	-- Display dialog as created
	ShowDialog (frame, iup.CENTER, iup.CENTER)
	
	return frame
end
