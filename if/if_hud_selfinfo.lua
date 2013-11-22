-- HUD self info code

function HUD:CreateSelfInfo()
	self.selfcredits = iup.label{title=" 0",fgcolor="0 192 224", expand="HORIZONTAL", font=Font.H4*font_HUD_SCALE}
	self.selfmass = iup.label{title=" 0kg",fgcolor="0 192 224", expand="HORIZONTAL", font=Font.H4*font_HUD_SCALE}
	self.selfcargo = iup.label{title=" 0 / 12cu",fgcolor="0 192 224", expand="HORIZONTAL", font=Font.H4*font_HUD_SCALE}
	self.selfhealthparts = {
		iup.label{title="",image="", size="64x128", uv=".5 0 .75 .5", expand="NO"},
		iup.label{title="",image="", size="64x128", uv="0 0 .25 .5", expand="NO"},
		iup.label{title="",image="", size="64x128", uv=".75 0 1 .5", expand="NO"},
		iup.label{title="",image="", size="64x128", uv="0 .5 .25 1", expand="NO"},
		iup.label{title="",image="", size="64x128", uv=".25 .5 .5 1", expand="NO"},
		iup.label{title="",image="", size="64x128", uv=".25 0 .5 .5", expand="NO"},
		all="YES",
		}
	self.curdamage = {}
	self.selfhealthimage = iup.zbox(self.selfhealthparts)
	self.selfhealth = iup.label{title="100%", alignment="ACENTER", expand="HORIZONTAL", font=Font.H4*font_HUD_SCALE}
	self.selfinfo = iup.vbox{
		iup.label{title="Credits",fgcolor="0 224 192",expand="HORIZONTAL", font=Font.H4*font_HUD_SCALE},
		self.selfcredits,
		iup.label{title="Mass",fgcolor="0 224 192",expand="HORIZONTAL", font=Font.H4*font_HUD_SCALE},
		self.selfmass,
		iup.label{title="Cargo",fgcolor="0 224 192",expand="HORIZONTAL", font=Font.H4*font_HUD_SCALE},
		self.selfcargo,
		self.selfhealthimage,
		self.selfhealth,
		alignment="ACENTER",
	}
	self.selfinfoframe = iup.hudrightframe{self.selfinfo, expand="NO"}
end

function HUD:SetSelfHealth(areadamage, maxhp, shieldstrength, animate)
	local totalpercent = areadamage[7]/maxhp
	for k=1,6 do
		if self.curdamage[k] ~= areadamage[k] then
			self.curdamage[k] = areadamage[k]
			if animate then
				local counter = 0
				local endfunc
				endfunc = function(control)
						counter = counter + 1
						if counter == 5 then control.alpha = 255 return end
						FadeControl(control, .333, 1, 0, endfunc, control)
					end
				local control = self.selfhealthparts[k]
				FadeControl(control, .333, 1, 0, endfunc, control)
				if self.damage_direction[k] then
					FadeControl(self.damage_direction[k], 2, 2, 0)
				end
			end
		end

		areadamage[k] = areadamage[k]/maxhp
--		totalpercent = totalpercent + areadamage[k]
	end

	if totalpercent > 0 then
		local maxdamage = 0
		for i=1,6 do
			if areadamage[i] > maxdamage then maxdamage = areadamage[i] end
		end

		if maxdamage > 0 then
			maxdamage = totalpercent / maxdamage;
		end

		for i=1,6 do
			areadamage[i] = areadamage[i] * maxdamage;
		end
	end
	totalpercent = 1-totalpercent

	for k,v in ipairs(self.selfhealthparts) do
		v.bgcolor = calc_health_color(1.0 - areadamage[k], 255, "+")
	end

	local percent = math.ceil(100*totalpercent)
	self.selfhealth.title = string.format("%d%%", percent)
	self.selfhealth.fgcolor = calc_health_color(totalpercent)

	self:UpdateGroupMemberHealth(GetCharacterID(), percent, shieldstrength)
end

function HUD:UpdateHealthInfo(animate)
	if self.hudtype == "turret" then
		local curhp, maxhp, shieldstrength = Game.GetTurretHealth()
		self:SetSelfHealth({0,0,0,0,0,0, (maxhp-curhp)}, maxhp, shieldstrength, animate)
	else
		local d1,d2,d3,d4,d5,d6,d7, maxhp, shieldstrength = GetActiveShipHealth()
		if d1 then
			self:SetSelfHealth({d1,d2,d3,d4,d5,d6, d7}, maxhp, shieldstrength, animate)
		end
	end
end

function HUD:ChangeShipInfo()
	if self.hudtype == "turret" then
		for k=1,6 do
			self.selfhealthparts[k].visible = "NO"
			self.selfhealthparts[k].size = "1x1"
		end
	else
		local meshname = GetShipMeshInfo(nil)
		local shipdamageimage = "images/dam_"..tostring(meshname)..".png"

		for k=1,6 do
			self.selfhealthparts[k].image = shipdamageimage
			self.selfhealthparts[k].size = "64x128"
		end
	end
end
