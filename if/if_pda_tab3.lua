-- character menu
local defaultaccomtext = "Welcome to the Accomplishments display. This area shows medals and accolades which you have gained through your efforts in the universe. If you click on a ribbon on the left, further information about that award will be displayed here. You may also move your mouse over the given ribbon to quickly see a tooltip of the award name."

local licensedescriptions = {
	[0] = "Licenses\n\nThese mark your progress in various specific skillsets. Generally speaking, increases in a given skill area are attained through use of the related item class or activity. The license system exists in the galaxy to keep potentially dangerous addons and craft (be they weapons or simply a large freighter) only in the hands of those with the experience to use them. The actual \"license\" is obtained once you reach the next required skill level. At present, the license is automatically granted upon reaching the related skill level, but this may change in favor of requiring certification through a related mission.\n\nLicenses of various types are required for nearly everything, including (but not limited to) missions, addons and ship availability. License improvement is currently a critical aspect of advancement in the universe. It is also important to remember that not all equipment (ships, weapons, addons) is available at all stations; so while a new license may make new equipment available, that equipment may only be offered by a small number of stations in the galaxy.\n\nFor more information on requirements for individual license types, click on the license name.",
	"Combat\n\nThis license level relates to your general ability in combat, as demonstrated by your mission history and a few other factors. Combat-driven missions are given a particular \"rating\" by the offering party, which is then added to the pilot's history on a successful mission completion. The more combative missions that a pilot completes, the greater their overall combat License level, and the higher esteem they will have in the eyes of the offering corporations and governments. High-level combat missions are often only offered to those with proven Combat ratings, although Faction Standing and past mission history with the offering party may also be a factor.",
	"Light Weapons\n\nThis license reflects your experience with those weapons categorized under galactic statute SAW6242(4).63 \"SMALL ADDON WEAPONRY\". In other words, all weapons which can be attached to spacecraft or stations by use of the Small port. The greater your record of successful use of this class of weaponry in combat scenarios, the more advanced your license, the greater the selection of weapons that become available to you.\n\nIt is noteworthy that most governments (and some localized corporations) who issue the license improvements tend to \"pad\" their license benefits to favor those who use the weapons against local nuisances and problems. For instance, most nations who sustain populations of the rogue Hive bots tend to give out good license benefits to any who help them reduce the local Hive population.",
	"Heavy Weapons\n\nThe Heavy license reflects your experience with weapons categorized by galactic statute SAW6242(5).10 \"LARGE ADDON WEAPONRY\". Successful combat usage of weapons that require attachment via a Large port will result in license improvements. The better the license, the more weapon options become available to you. Improvement of the Heavy Weapons license can be slightly more involved than the Light, as the initial selection of Heavy weapons available to a new pilot can be relatively limited. There is, however, always at least one Heavy weapon available by the time sufficient licenses have been acquired to purchase a ship with Large Port capabilities. This first-use weapon may only be found a small number of stations, so some travel may be required.\n\nAs with Light Weapons, nations and corporations usually give benefits to those who deal with local nuisances. See Light Weapons.",
	"Trading and Commerce\n\nThis license reflects your history as a trader and commercial entity within the galaxy. Any time you sell goods to a station, this will be slightly improved. These goods could be acquired through trading, or through other productive activity, such as mining. Missions related to those activities will generally yield the best license boost, as the entity (corporation or government) offering the mission lends their authority to the pilot's improvement, giving the claim credence.\n\nImprovements in this license can make available more advanced missions, specialized and larger trading vessels, and a wide variety of other benefits relevant to the avid merchant.",
	"Mining\n\nThe mining license demonstrates your experience in mineral and ore extraction, in particular with the various apparatus commonly used for that purpose. Successful use of a mining beam to extract minerals or ores will improve this license. Missions to extract specific ores or minerals may lend added bonuses. As higher license levels are achieved, more mining-related equipment, missions, and other options will become available. Keep in mind that some mining-related equipment is only found in those areas where it is produced, such as stations owned by certain corporations in UIT space.",
}

local function create_char_stats_tab()
	local reset = true
	local isvisible = false
	local container
	local stats, statshelp
	local name, alignment, credits, homestation
	local licensetexts = {}

	name = iup.label{title="", font=Font.H3, expand="HORIZONTAL"}
	alignment = iup.label{title="", font=Font.H4, expand="HORIZONTAL"}
	credits = iup.label{title="", font=Font.H4, expand="HORIZONTAL"}
	homestation = iup.label{title="", font=Font.H4, expand="HORIZONTAL"}
	for i=1,5 do
		local index = i
		licensetexts[index] = factioncontroltemplate3(iup.stationsubframe, function()
				statshelp.value = licensedescriptions[index] or "(no description)"
				statshelp.scroll = "TOP"
			end, Font.H4)
		licensetexts[i]:Set(Skills.Names[i].." License",
					string.format("%u (%u/%u)", 0, 0, 0),
					nil,
					0,
					"128 192 255",
					0, 0)
	end
	stats  = iup.stationsubmultiline{readonly="YES", expand="YES",value=""}
	statshelp  = iup.stationsubmultiline{readonly="YES", expand="YES",value=licensedescriptions[0]}

	local update_radiobuttons

	local function setwatchedlicense(index, state)
		if state == 1 then
			gkini.WriteString(GetUserName(), "watchedlicense", index)
			HUD:SetLicenseWatch(index)
		end
	end

	local a = iup.stationradio{title="",expand="VERTICAL", action=function(self,state) setwatchedlicense(1, state) end}
	local b = iup.stationradio{title="",expand="VERTICAL", action=function(self,state) setwatchedlicense(2, state) end}
	local c = iup.stationradio{title="",expand="VERTICAL", action=function(self,state) setwatchedlicense(3, state) end}
	local d = iup.stationradio{title="",expand="VERTICAL", action=function(self,state) setwatchedlicense(4, state) end}
	local e = iup.stationradio{title="",expand="VERTICAL", action=function(self,state) setwatchedlicense(5, state) end}
	local radiobuttons = {a,b,c,d,e}
	local radiocontrol

	update_radiobuttons = function()
		radiocontrol.value = radiobuttons[HUD.watchedlicense]
	end

	radiocontrol = iup.radio{
			iup.vbox{
				iup.hbox{iup.stationsubframebg{a},licensetexts[1], alignment="ACENTER",expand="HORIZONTAL"},
				iup.hbox{iup.stationsubframebg{b},licensetexts[2], alignment="ACENTER",expand="HORIZONTAL"},
				iup.hbox{iup.stationsubframebg{c},licensetexts[3], alignment="ACENTER",expand="HORIZONTAL"},
				iup.hbox{iup.stationsubframebg{d},licensetexts[4], alignment="ACENTER",expand="HORIZONTAL"},
				iup.hbox{iup.stationsubframebg{e},licensetexts[5], alignment="ACENTER",expand="HORIZONTAL"},
			},
			value = radiobuttons[HUD.watchedlicense]
		}

	container = iup.hbox{
		iup.vbox{
			iup.stationsubframebg{iup.vbox{
				name,
				alignment,
				credits,
				homestation,
			}},
			radiocontrol,
			stats,
			expand="VERTICAL",
		},
		statshelp,
	}

	local function setup_char_stats_tab()
		local charkills, chardeaths, charpkills = GetCharacterKillDeaths()
		local killdeathratio = charkills/(chardeaths>0 and chardeaths or 1)
		local stuff = {
			string.format("Kills/Deaths: %s / %s (%2.2f)", comma_value(charkills), comma_value(chardeaths), killdeathratio),
			string.format("Player Kills: %s: %s / %s: %s / %s: %s",
				FactionName[1], comma_value(GetNationKills(1)),
				FactionName[2], comma_value(GetNationKills(2)),
				FactionName[3], comma_value(GetNationKills(3))),
			"Number of missions completed: "..comma_value(GetNumCompletedMissions()),
			"",
		}
		
		table.insert(stuff, GetCharacterDescription())
		stats.value = table.concat(stuff, "\n")

		name.title=GetPlayerName()
		alignment.title="Alignment: "..(FactionNameFull[GetPlayerFaction()] or "??")
		credits.title="Credits: "..comma_value(GetMoney())
		local home_location = GetHomeStation()
		homestation.title="Home: "..((home_location and ShortLocationStr(home_location)) or "None")
		for i=1,5 do
			local cur, max = GetSkillLevel(i)
			local curlicense = GetLicenseLevel(i)
			local min = GetLicenseRequirement(curlicense)
			licensetexts[i]:Set(Skills.Names[i].." License",
					string.format("%u (%s/%s)", curlicense, comma_value(math.max(cur-min, 0)), comma_value(math.max(max-min, 0))),
					nil,
					cur,
					"128 192 255",
					min, max)
		end
	end

	function container:OnShow()
		isvisible = true
		if reset then
			reset = false
			setup_char_stats_tab()
		end
		if update_radiobuttons then
			update_radiobuttons()
		end
	end
	function container:OnHide()
		isvisible = false
	end
	function container:OnEvent(eventname, ...)
		local charid = ...
		if charid == GetCharacterID() and (eventname == "PLAYER_STATS_UPDATED" or eventname == "PLAYER_UPDATE_STATS" or eventname == "PLAYER_UPDATE_SKILLS") then
			if isvisible then
				setup_char_stats_tab()
			else
				reset = true
			end
		elseif eventname == "PLAYER_HOME_CHANGED" then
			local home_location = GetHomeStation()
			homestation.title="Home: "..((home_location and ShortLocationStr(home_location)) or "None")
		end
	end

	RegisterEvent(container, "PLAYER_STATS_UPDATED")
	RegisterEvent(container, "PLAYER_UPDATE_STATS")
	RegisterEvent(container, "PLAYER_UPDATE_SKILLS")
	RegisterEvent(container, "PLAYER_HOME_CHANGED")

	return container
end

local function create_char_faction_tab()
	local reset = true
	local isvisible = false
	local container

	container = FactionStandingWithInfoTemplate()

	function container:OnShow()
		isvisible = true
		if reset then
			reset = false
			self:Setup()
		end
	end
	function container:OnHide()
		isvisible = false
	end
	function container:OnEvent(eventname, ...)
		local charid = ...
		if charid == GetCharacterID() and (eventname == "PLAYER_STATS_UPDATED" or eventname=="PLAYER_UPDATE_FACTIONSTANDINGS") then
			if isvisible then
				self:Setup()
			else
				reset = true
			end
		end
	end

	RegisterEvent(container, "PLAYER_STATS_UPDATED")
	RegisterEvent(container, "PLAYER_UPDATE_FACTIONSTANDINGS")

	return container
end

local function create_char_accomplishment_tab()
	local reset = true
	local isvisible = false
	local container
	local accombox, statshelp
	local medalicondlg
	local medalicon
	local medaltitledesc
	local medaltextdesc

	local function click_cb(text, accomtype, accomlevel)
		local bigtexture = GetAccomplishmentBigTexture(accomtype, accomlevel)
		medalicon.image = bigtexture or ""
		medalicon.size = GetAccomplishmentBigSize(accomtype, accomlevel) or "128x128"
		medalicon.uv = GetAccomplishmentBigUV(accomtype, accomlevel) or "0 0 1 1"
		medalicon.visible = "YES"
		local accomtitle = GetAccomplishmentTitle(accomtype, accomlevel)
		medaltitledesc.title = string.format("\n%s\n", (accomtitle or ""))

		statshelp[1] = nil
		statshelp.value = 0 -- this will cause the sel callback to not send unsel
		if medaltitledesc.attached == true then iup.Detach(medaltitledesc) medaltitledesc.attached = false end
		if medalicondlg.attached == true then iup.Detach(medalicondlg) medalicondlg.attached = false end
		if medaltextdesc.attached == true then iup.Detach(medaltextdesc) medaltextdesc.attached = false end
		if accomtitle then
			iup.Append(statshelp, medaltitledesc) medaltitledesc.attached = true
		end
		if bigtexture then
			iup.Append(statshelp, medalicondlg) medalicondlg.attached = true
		end
		medaltextdesc.title = text
		iup.Append(statshelp, medaltextdesc) medaltextdesc.attached = true
		statshelp:map()
		statshelp[1] = 1
	end

	medalicon = iup.label{title="", image="", size="128x128", visible="NO"}
	medalicondlg = iup.dialog{
		iup.hbox{iup.fill{}, medalicon, iup.fill{}},
		border="NO",menubox="NO",resize="NO",
		shrink="YES",
		bgcolor="0 0 0 0 +",
	}
	medaltitledesc = iup.label{title="title", alignment="ACENTER", font=Font.H2}
	medaltextdesc = iup.label{title="hi"}

	accombox = AccomplishmentTemplate2(click_cb)
	statshelp = iup.itemlisttemplate({size="0x0",marginx=8,marginy=8}, false)

	container = iup.hbox{
		accombox,
		statshelp,
	}

	local function setup_char_accom_tab(self, refresh)
		statshelp[1] = nil
		statshelp.value = 0 -- this will cause the sel callback to not send unsel
		if medaltitledesc.attached == true then iup.Detach(medaltitledesc) medaltitledesc.attached = false end
		if medalicondlg.attached == true then iup.Detach(medalicondlg) medalicondlg.attached = false end
		if medaltextdesc.attached == true then iup.Detach(medaltextdesc) medaltextdesc.attached = false end
		medaltextdesc.title = defaultaccomtext
		iup.Append(statshelp, medaltextdesc) medaltextdesc.attached = true
		statshelp:map()
		statshelp[1] = 1
		accombox:ReloadAccomplishments()
	end

	function container:OnShow()
		isvisible = true
		if reset then
			reset = false
			setup_char_accom_tab()
		end
	end
	function container:OnHide()
		isvisible = false
	end
	function container:OnEvent(eventname, ...)
		local charid = ...
		if charid == GetCharacterID() and (eventname == "PLAYER_STATS_UPDATED" or eventname == "PLAYER_UPDATE_ACCOMPLISHMENTS") then
			if isvisible then
				setup_char_accom_tab()
			else
				reset = true
			end
		end
	end

	RegisterEvent(container, "PLAYER_STATS_UPDATED")
	RegisterEvent(container, "PLAYER_UPDATE_ACCOMPLISHMENTS")

	return container
end

dofile(IF_DIR.."if_inventory_template.lua")

function CreateCharacterPDATab()
	local tab1, tab2, tab3

	tab1 = create_char_stats_tab() tab1.tabtitle="Statistics" tab1.hotkey=iup.K_a
	tab2 = create_char_faction_tab() tab2.tabtitle="Faction Standings"  tab2.hotkey=iup.K_f
	tab3 = create_char_accomplishment_tab() tab3.tabtitle="Accomplishments"  tab3.hotkey=iup.K_l

	tab1.OnHelp = HelpCharStats
	tab2.OnHelp = HelpCharFaction
	tab3.OnHelp = HelpCharAccom

	return iup.subsubtabtemplate{tab1, tab2, tab3}, tab1, tab2, tab3
end
