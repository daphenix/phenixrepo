local __iup_sa = iup.StoreAttribute

-- HUD license watch code
-- mission timer overrides this such that when mission timer is open, this is closed.

function HUD:CreateLicenseWatchArea()
	self.watchedlicense = gkini.ReadInt(GetUserName(), "watchedlicense", DEFAULT_LICENSE_WATCH)
	local font = Font.H5*font_HUD_SCALE
	self.licensewatchlabel = iup.label{title=Skills.Names[self.watchedlicense] and Skills.Names[self.watchedlicense].." License:" or "", fgcolor="0 224 192", expand="HORIZONTAL", font=font}

	local progressbar = iup.stationprogressbar{
		LOWERCOLOR="128 192 255 128 *",
		UPPERCOLOR="0 0 0 64 *",
		MINVALUE=0,
		MAXVALUE=65535,
		type="HORIZONTAL",
		expand="NO",
		size="x"..font-2, -- 12",
	}
	local percenttext = iup.label{
		title="",
		font=font,
		size="x"..font-2, -- 12",
		alignment="ACENTER",
		expand="HORIZONTAL",
	}
	local container = iup.hudrightframe{
		BORDER="0 0 0 0",
		iup.zbox{
			progressbar,
			percenttext,
			all="YES",
			expand="YES",
		},
	}
	self.licensewatch_progress = progressbar
	self.licensewatch_percenttext = percenttext

	self.licensewatchframe = iup.hudrightframe{
		iup.vbox{
			self.licensewatchlabel,
			container,
			expand="YES",
			alignment="ALEFT",
		},
		size=HUDSize(.25),
		expand="NO",
	}
end

function HUD:SetLicenseWatch(index)
	self.watchedlicense = index or self.watchedlicense
	if index >= 1 and index <= 5 then
		self.licensewatchlabel.title = tostring(Skills.Names[index]).." License:"
		self:UpdateLicenseWatch()
		__iup_sa(self.licensewatchframe, "VISIBLE", self.visibility.license)
	else
		__iup_sa(self.licensewatchframe, "VISIBLE", "NO")
	end
end

function HUD:UpdateLicenseWatch()
	local watchedlicense = self.watchedlicense

	if watchedlicense >= 1 and watchedlicense <= 5 then
		local cur, max = GetSkillLevel(watchedlicense)
		local curlicense = GetLicenseLevel(watchedlicense)
		local min = GetLicenseRequirement(curlicense)
		__iup_sa(self.licensewatch_percenttext, "TITLE", string.format("%u (%s/%s)", curlicense, comma_value(math.max(cur-min, 0)), comma_value(math.max(max-min, 0))))
		__iup_sa(self.licensewatch_progress, "VALUE", cur)
		__iup_sa(self.licensewatch_progress, "MINVALUE", min)
		__iup_sa(self.licensewatch_progress, "MAXVALUE", max)
	else
		__iup_sa(self.licensewatchframe, "VISIBLE", "NO")
	end
end
