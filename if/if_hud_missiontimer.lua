local __iup_sa = iup.StoreAttribute

-- HUD mission timer code

function HUD:CreateMissionTimerArea()
	local font = Font.H5*font_HUD_SCALE
	self.missiontimer = iup.label{title="0:00:00", fgcolor="192 192 192", expand="HORIZONTAL", font=font}
	self.missiontimerframe = iup.hudrightframe{
		iup.vbox{
			iup.label{title="Mission Timer:", fgcolor="0 224 192", expand="NO", font=font},
			self.missiontimer,
			expand="YES",
			alignment="ALEFT",
		},
		size=HUDSize(.25),
		expand="NO",
	}
end

function HUD:UpdateMissionTimers(...)
	local n = 0
	for k,v in ipairs({...}) do
		if v < 0 then v = 0 end
		__iup_sa(self.missiontimer, "TITLE", format_time(v))
		n = n + 1
	end
	self.nummissiontimers = n
	__iup_sa(self.missiontimerframe, "VISIBLE", n == 0 and "NO" or self.visibility.missiontimers)
	__iup_sa(self.licensewatchframe, "VISIBLE", n == 0 and self.visibility.license or "NO")
end
