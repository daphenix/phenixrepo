local __iup_sa = iup.StoreAttribute

-- HUD target info
local SELECTION_COLORS = {
	[0] = {r=255,g=0,b=0},
	[1] = {r=255,g=0,b=0},
	[2] = {r=255,g=0,b=0},
	[3] = {r=0,g=255,b=0},
	[4] = {r=192,g=192,b=192},
}

function HUD:CreateTargetArea()
	local fontsize = Font.H5*font_HUD_SCALE
	self.targetname = iup.label{title="(none)", fgcolor="192 192 192", size=HUDSize(.17), wordwrap="NO", font=fontsize, expand="HORIZONTAL"}
	self.targetshield = iup.stationprogressbar{title="(none)", active="NO", expand="HORIZONTAL", visible = "NO", size="x4"}
	self.targetshield.minvalue = 0
	self.targetshield.maxvalue = 100
	self.targetshield.uppercolor = "128 128 128 255 *"
	self.targetshield.lowercolor = "64 64 255 255 *"
	self.targetshield.uv = "0 0.25 1 0.75"
	self.targetshield.value = 100
	self.targethealth = iup.stationprogressbar{title="(none)", active="NO", expand="YES"}
	self.targethealth.minvalue = 0
	self.targethealth.maxvalue = 100
	self.targethealth.uppercolor = "128 128 128 128 *"
	self.targethealth.lowercolor = "64 255 64 128 *"
	self.targethealth.value = 25
	self.targetdistance = iup.label{title="0m", fgcolor="192 192 192", expand="HORIZONTAL", wordwrap="NO", font=fontsize}
	self.targetnation = iup.label{title="Itani", fgcolor="192 192 192", expand="HORIZONTAL", wordwrap="NO", font=fontsize}
	self.targetshiptype = iup.label{title="", fgcolor="192 192 192", expand="HORIZONTAL", wordwrap="NO", font=fontsize}
	self.target_health_percentages = iup.label{title="",expand="HORIZONTAL", visible="NO", alignment="ACENTER",font = Font.H5*font_HUD_SCALE}
	self.targetframe = iup.hudrightframe{iup.vbox{
		iup.hbox{iup.label{title="Target:", fgcolor="0 224 192", expand="NO", font=fontsize},self.targetname},
		iup.hbox{iup.label{title="Health:", fgcolor="0 224 192", expand="NO", font=fontsize},
			iup.zbox{self.targethealth, iup.vbox{self.targetshield, iup.fill{}},self.target_health_percentages, all="YES"},
			expand="HORIZONTAL"},
		iup.hbox{iup.label{title="Distance:", fgcolor="0 224 192", expand="NO", font=fontsize},self.targetdistance},
		iup.hbox{iup.label{title="Faction:", fgcolor="0 224 192", expand="NO", font=fontsize},self.targetnation},
		iup.hbox{iup.label{title="Ship:", fgcolor="0 224 192", expand="NO", font=fontsize},self.targetshiptype, expand="HORIZONTAL"},
		expand="HORIZONTAL",
		},
		size=HUDSize(.25),
		expand="NO",
	}
end

function HUD:UpdateTargetInfo()
	local name, health, distance, factionid, guild_tag, shipname, shieldstrength = GetTargetInfo()
	if name and guild_tag and guild_tag ~= "" then
		name = string.format("[%s] %s", guild_tag, name)
	end
	self:SetTargetName(name)
	self:SetTargetFaction(factionid)
	self:SetTargetHealth(health, shieldstrength)
	self:SetTargetDistance(distance)
	__iup_sa(self.targetshiptype, "TITLE", tostring(shipname or ""))

	local status = health and GetTargetFriendlyStatus() or 4
	local color = SELECTION_COLORS[status]
	radar.SetSelColor(color.r, color.g, color.b)
end

function HUD:SetTargetDistance(distance)
	__iup_sa(self.targetdistance, "TITLE", distance and string.format("%sm", comma_value(math.floor(distance))) or "0m")
--	self.targetdistance.title = distance and string.format("%dm", math.floor(distance)) or "0m"
end

function HUD:SetTargetName(name)
	__iup_sa(self.targetname, "TITLE", tostring(name or "(none)"))
--	self.targetname.title = tostring(name or "(none)")
end

function HUD:SetTargetFaction(factionid)
	if factionid then
		self.targetnation.title = FactionName[factionid] or "none"
		self.targetnation.fgcolor = FactionColor_RGB[factionid]
		self.targetnation.visible = "YES"
	else
		self.targetnation.visible = "NO"
	end
end

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


function HUD:SetTargetHealth(health, shieldstrength)
	if not health then
		self.targethealth.visible = "NO"
		self.targetshield.visible = "NO"
		self.target_health_percentages.visible = "NO"
		return
	else
		self.targethealth.visible = "YES"
		self.target_health_percentages.visible = "YES"
--		if true then
		if shieldstrength and (shieldstrength > 0) then
			self.targetshield.visible = "YES"
			self.targetshield.value = shieldstrength * 100
		else
			self.targetshield.visible = "NO"
		end
	end
	self.targethealth.lowercolor = calc_health_color(health, 128)
	self.targethealth.value = health*100
	self.target_health_percentages.title = calc_percentages_text(health, shieldstrength)
end
