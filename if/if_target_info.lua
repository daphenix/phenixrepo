function CreateTargetInfo()
	local container
	local targetname, targethealth, targetdistance, targetfaction, targetship
	local targetshield
	local update_timer

	update_timer = Timer()
	
	targetname = iup.label{title="", fgcolor=tabunseltextcolor, expand="HORIZONTAL", size="1", wordwrap="NO"}
	targetdistance = iup.label{title="", fgcolor=tabunseltextcolor, expand="HORIZONTAL", size="1", wordwrap="NO"}
	targetfaction = iup.label{title="", expand="HORIZONTAL", size="1", wordwrap="NO"}
	targetship = iup.label{title="", fgcolor=tabunseltextcolor, expand="HORIZONTAL", size="1", wordwrap="NO"}
	targethealth = iup.stationprogressbar{title="(none)", active="NO", expand="YES", size="1"}
	targethealth.minvalue = 0
	targethealth.maxvalue = 100
	targethealth.uppercolor = "128 128 128 255 *"
	targethealth.lowercolor = "64 255 64 255 *"
	targethealth.value = 25
	targetshield = iup.stationprogressbar{title="(none)", active="NO", expand="HORIZONTAL", visible = "NO", size="x4"}
	targetshield.minvalue = 0
	targetshield.maxvalue = 100
	targetshield.uppercolor = "128 128 128 255 *"
	targetshield.lowercolor = "64 64 255 255 *"
	targetshield.uv = "0 0.25 1 0.75"
	targetshield.value = 100
	targetshield_percentage_color = "00e0ff"
	target_health_percentages = iup.label{title="",expand="HORIZONTAL", visible="NO",font = Font.H5*HUD_SCALE, alignment="ACENTER"}
	
	container = iup.vbox{
		iup.hbox{iup.label{title="Target:", fgcolor=tabunseltextcolor}, targetname},
		iup.hbox{iup.label{title="Health:", fgcolor=tabunseltextcolor},
			iup.zbox{targethealth, iup.vbox{targetshield, iup.fill{}}, target_health_percentages, all="YES"},
			expand="HORIZONTAL"},
		iup.hbox{iup.label{title="Distance:", fgcolor=tabunseltextcolor}, targetdistance},
		iup.hbox{iup.label{title="Faction:", fgcolor=tabunseltextcolor}, targetfaction},
		iup.hbox{iup.label{title="Ship:", fgcolor=tabunseltextcolor}, targetship},
	}
	--Calculates the text of the percentages display. Takes raw health and shield parameters.
	local function calc_percentages_text(health, shieldstrength)
		if health < 0 then health = 0 end
		local g = (1.25*health);	
		local r = (8.0*(1.0 - health));
		if g > 1 then g = 1 end
		if r > 1 then r = 1 end
		health = math.ceil(health * 100)
		r = (r*255) + 10
		g = (g*255) + 10
		if r > 255 then r = 255 end
		if g > 255 then g = 255 end
		local health_color = string.format("%.2x%.2x10", r,g)
		if not shieldstrength or shieldstrength == 0 then
			return string.format("\127%s%d%%",health_color,health)
		end
		shieldstrength = math.floor(shieldstrength * 100)
		return string.format("\127%s%d%%\127ffffff:\127%s%d%%", targetshield_percentage_color,shieldstrength,health_color,health)
	end
	
	local function update()
		local name, health, distance, factionid, guild_tag, shipname, shieldstrength = GetTargetInfo()
		if name and guild_tag and guild_tag ~= "" then
			name = string.format("[%s] %s", guild_tag, name)
		end
		targetname.title = name or "(none)"
		if not health then
			targethealth.visible = "NO"
			targetshield.visible = "NO"
			target_health_percentages.visible = "NO"
		else
			targethealth.visible = "YES"
			target_health_percentages.visible = "YES"
			targethealth.lowercolor = calc_health_color(health, 128)
			targethealth.value = health*100
			target_health_percentages.title = calc_percentages_text(health, shieldstrength)
			if shieldstrength and (shieldstrength > 0) then
				targetshield.visible = "YES"
				targetshield.value = shieldstrength * 100
			else
				targetshield.visible = "NO"
			end
			
		end
		targetdistance.title = string.format("%sm", comma_value(math.floor(distance or 0)))
		if factionid then
			targetfaction.title = tostring(FactionName[factionid] or "none")
			targetfaction.fgcolor = FactionColor_RGB[factionid] or "254 54 233"
			targetfaction.visible = "YES"
		else
			targetfaction.visible = "NO"
		end
--		targetship.title = GetPrimaryShipNameOfPlayer(GetCharacterID(radar.GetRadarSelectionID()) or -1) or ""
		targetship.title = tostring(shipname or "")
	end
	local function update_distance()
		targetdistance.title = string.format("%sm", comma_value(math.floor(GetTargetDistance() or 0)))
	end

	local function timer_cb()
		update_distance()
		update_timer:SetTimeout(100)
	end

	function container:OnShow()
		update()
		RegisterEvent(container, "TARGET_CHANGED")
		RegisterEvent(container, "TARGET_HEALTH_UPDATE")
		update_timer:SetTimeout(100, timer_cb)
	end

	function container:OnHide()
		update_timer:Kill()
	end

	function container:OnEvent(eventname, ...)
		if eventname == "TARGET_CHANGED" or eventname == "TARGET_HEALTH_UPDATE" then
			update()
		end
	end

	return container
end

