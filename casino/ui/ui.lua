--[[
	UI Elements
]]
casino.ui = {}
casino.ui.font = 14 * (gkinterface.GetYResolution () / 600)
casino.ui.fontSmall = 10 * (gkinterface.GetYResolution () / 600)
casino.ui.bgcolor = "255 10 10 10*"
casino.ui.fgcolor = "200 200 50"
casino.ui.alertcolor = "200 50 50"
casino.ui.okaycolor = "50 200 50"
dofile ("ui/control.lua")

function casino.ui:GetOnOffSetting (flag)
	if (flag) then
		return "ON"
	else
		return "OFF"
	end
end
