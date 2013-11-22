local tooltipinfo = iup.label{title="", font=Font.H6}
ToolTip = iup.dialog{
--	iup.stationmainframe{
--		iup.stationbuttonframe{
			iup.hbox{tooltipinfo, margin="4x4",},
--		},
--	},
	bgcolor="96 96 96 200 *",
	topmost="YES",
	active="NO",
	border="YES",
	menubox="NO",
	resize="NO",
}

-- if x is negative then x is right side of dlg
-- if y is negative then y is bottom of dlg
function ShowTooltip(x,y,text)
	tooltipinfo.title = tostring(text)
	ToolTip.size=nil
	ToolTip:map()
	x = tonumber(x)
	y = tonumber(y)
	if x < 0 then
		x = -x - tonumber(ToolTip.w)
	end
	if y < 0 then
		y = -y - tonumber(ToolTip.h)
	end
	ShowDialog(ToolTip, x,y)	
end

function HideTooltip()
	if ToolTip.visible == "YES" then
		HideDialog(ToolTip)
	end
end
