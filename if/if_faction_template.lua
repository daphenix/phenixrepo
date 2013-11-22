function factionfriendlyness(value)
	if not value then return "Unknown" end
	if value == FactionStanding.Max then return "Pillar of Society"
	elseif value > FactionStanding.Love then return "Admire"
	elseif value > FactionStanding.Like then return "Respect"
	elseif value > FactionStanding.Dislike then return "Neutral"
	elseif value > FactionStanding.Hate then return "Dislike"
	elseif value > FactionStanding.Min then return "Hate"
	else return "Kill on Sight" end
end

function factionfriendlynessrange(value)
	if not value then return 0.5 end
	if value == FactionStanding.Max then return 1
	elseif value > FactionStanding.Love then return (value - FactionStanding.Love)/13107
	elseif value > FactionStanding.Like then return (value - FactionStanding.Like)/13107
	elseif value > FactionStanding.Dislike then return (value - FactionStanding.Dislike)/13107
	elseif value > FactionStanding.Hate then return (value - FactionStanding.Hate)/13107
	elseif value > FactionStanding.Min then return (value - FactionStanding.Min)/13107
	else return 0 end
end

function factionfriendlynesscolor(value)
	if not value then return "183 183 183" end
	if value == FactionStanding.Max then return "255 216 0"
	elseif value > FactionStanding.Love then return "6 199 2"
	elseif value > FactionStanding.Like then return "132 191 130"
	elseif value > FactionStanding.Dislike then return "183 183 183"
	elseif value > FactionStanding.Hate then return "190 110 109"
	elseif value > FactionStanding.Min then return "195 3 0"
	else return "104 80 79" end
end


local function factioncontroltemplate(button_cb)
	local currentstanding_text1
	local currentstanding_text2
	local factionname = iup.label{title="", expand="HORIZONTAL",font=Font.H5,size="x12",}
	local factionprogress = iup.progressbar{
		LOWERCOLOR="0 0 0 128 *",
		MIDDLEABOVECOLOR="0 170 0 255 *",
		MIDDLEBELOWCOLOR="170 0 0 255 *",
		UPPERCOLOR="0 0 0 128 *",
		MINVALUE=0,
		MAXVALUE=2200,
		type="HORIZONTAL",
		mode="TRINARY",
		expand="NO",
		size="180x12",
	}
	local factionpercent = iup.label{
		title="",
		font=Font.H5,
		size="x12",
		alignment="ACENTER",
		expand="HORIZONTAL",
		enterwindow_cb=function(self)
			self.title = currentstanding_text2
		end,
		leavewindow_cb=function(self)
			self.title = currentstanding_text1
		end,
	}
	local zbox = iup.zbox{
		factionprogress,
		factionpercent,
		all="YES",
		expand="NO",
	}

	local container = iup.stationsubframe{
		iup.zbox{ all="YES",
			iup.canvas{border="NO",button_cb = button_cb, expand="YES"},
			iup.hbox{
				factionname,
				iup.fill{},
				zbox,
				expand="HORIZONTAL",
			},
		},
	}
	function container:Setup(name, standing)
		factionname.title = name
		local color = factionfriendlynesscolor(standing)
		currentstanding_text1 = factionfriendlyness(standing)
		standing = math.floor(((2000*standing)/65535)-1000)
		currentstanding_text2 = string.format("%+d", standing )
		factionpercent.title = currentstanding_text1
		if standing < 0 then
			standing = standing - 100
			factionprogress.altvalue = 1100 + 100
		else
			standing = standing + 100
			factionprogress.altvalue = 1100 - 100
		end
		standing = standing + 1100
		factionprogress.value = standing
		factionprogress.middleabovecolor = color
		factionprogress.middlebelowcolor = color
	end
	return container
end

local function factioncontroltemplate2()
	local currentstanding_text1
	local currentstanding_text2
	local factionname = iup.label{title="", expand="HORIZONTAL",font=Font.H5,size="x12",}
	local factionprogress = iup.progressbar{
		LOWERCOLOR="0 0 0 128 *",
		MIDDLEABOVECOLOR="0 170 0 255 *",
		MIDDLEBELOWCOLOR="170 0 0 255 *",
		UPPERCOLOR="0 0 0 128 *",
		MINVALUE=0,
		MAXVALUE=200,
		type="HORIZONTAL",
		expand="NO",
		size="180x12",
	}
	local factionpercent = iup.label{
		title="",
		font=Font.H5,
		size="x12",
		alignment="ACENTER",
		expand="HORIZONTAL",
		enterwindow_cb=function(self)
			self.title = currentstanding_text2 or ""
		end,
		leavewindow_cb=function(self)
			self.title = currentstanding_text1 or ""
		end,
	}
	local zbox = iup.zbox{
		factionprogress,
		factionpercent,
		all="YES",
		expand="NO",
	}

	local container = iup.stationsubframe{iup.hbox{
		factionname,
		iup.fill{},
		zbox,
	}}
	function container:Setup(name, standing)
		factionname.title = name
		currentstanding_text1 = factionfriendlyness(standing)
		local range = factionfriendlynessrange(standing)*200
		currentstanding_text2 = string.format("%d / 200", range)
		factionpercent.title = currentstanding_text1
		factionprogress.value = range
		factionprogress.lowercolor = factionfriendlynesscolor(standing)
	end
	return container
end

function factioncontroltemplate3(subframetemplate, click_cb, font)
	local currentstanding_text1
	local currentstanding_text2
	font = font or Font.H5
	local factionname = iup.label{title="", expand="HORIZONTAL",font=font,size="x"..font-2,} -- 12",}
	local factionprogress = iup.stationprogressbar{
		LOWERCOLOR="0 0 0 128 *",
		MIDDLEABOVECOLOR="0 170 0 255 *",
		MIDDLEBELOWCOLOR="170 0 0 255 *",
		UPPERCOLOR="0 0 0 128 *",
		MINVALUE=0,
		MAXVALUE=65535,
		type="HORIZONTAL",
		expand="NO",
		size="180x"..font-2, -- 12",
	}
	local factionpercent = iup.label{
		title="",
		font=font,
		size="x"..font-2, -- 12",
		alignment="ACENTER",
		expand="HORIZONTAL",
		enterwindow_cb=function(self)
			if currentstanding_text2 then
				self.title = currentstanding_text2 or ""
			end
		end,
		leavewindow_cb=function(self)
			if currentstanding_text2 then
				self.title = currentstanding_text1 or ""
			end
		end,
	}
	local zbox = iup.zbox{
		factionprogress,
		factionpercent,
		all="YES",
		expand="NO",
	}

	local container = subframetemplate{
		iup.zbox{
			iup.canvas{border="NO",button_cb = click_cb, expand="YES", size="1x1"},
			iup.hbox{
				factionname,
				iup.fill{},
				zbox,
			},
			all="YES",
			expand="HORIZONTAL",
		}
	}
	function container:Set(name, text1, text2, value, color, min, max)
		factionname.title = name
		currentstanding_text1 = text1
		factionpercent.title = currentstanding_text1
		factionprogress.value = value
		factionprogress.lowercolor = color
		currentstanding_text2 = text2
		if min then
			factionprogress.MINVALUE = min
		end
		if max then
			factionprogress.MAXVALUE = max
		end
	end
	function container:Setup(name, standing)
		local standing2 = math.floor(((2000*standing)/65535)-1000)
		self:Set(name,
				factionfriendlyness(standing),
				string.format("%+d", standing2 ),
				standing,
				factionfriendlynesscolor(standing)
			)
	end
	return container
end

function FactionStandingTemplate(button_cb, subframetemplate, framefillertemplate, expand)
	local container = {expand=expand or "VERTICAL"}
	local zcontainer = {}
	
	for k=0,12 do
		local index = k+1
		local cb
		if button_cb then
			cb = function() button_cb(index) end
		end
		container[1+k*2] = framefillertemplate()
		zcontainer[index] = {factioncontroltemplate3(subframetemplate, cb),framefillertemplate(), expand="HORIZONTAL"}
		container[2+k*2] = iup.zbox(zcontainer[index])
	end
	container[1+13*2] = framefillertemplate()
	for i=1,13 do
		zcontainer[i][1]:Setup(FactionNameFull[i], 0)
	end

	local control = iup.vbox(container)
	function control:Setup(charid)
		local fs
		for i=1,13 do
			fs = GetPlayerFactionStanding(i, charid)
			local index = 2+(i-1)*2
			if fs then
				zcontainer[i][1]:Setup(FactionNameFull[i], fs)
				container[index].value = zcontainer[i][1]
				container[index].size = nil
			else
				container[index].value = zcontainer[i][2]
				container[index].size = "1x1"
			end
		end
	end
	function control:HideAll()
		for i=1,13 do
			container[2+(i-1)*2].value = zcontainer[i][2]
			container[2+(i-1)*2].size = "1x1"
		end
	end
	return control
end

function FactionStandingWithInfoTemplate()
	local stats, statsinfo

	local click_cb = function(index)
		statsinfo.value = GetFactionInfo(index)
		statsinfo.scroll = "TOP"
	end

	statsinfo  = iup.stationsubmultiline{readonly="YES", expand="YES",value=
[[Factions are the competing entities of the galaxy. They include the major Nations, corporations, and even organized crime. Every pilot has a certain "standing" in the eyes of each faction, which equates to how well the pilot is liked by a given faction. As standing with a faction increases or decreases, the respect and admiration of that faction impacts a wide variety of parameters affecting the pilot's interactions with the faction. Each faction controls stations and sometimes larger areas of space, it is while interacting with the various factions at their respective bases or homeworlds that standing becomes critical.

For example, a pilot with high standing will be offered special missions, discounts on ships and equipment, and special ship/equipment availability. A pilot with low standing may have to deal with increased prices, lack of permission to dock with related stations, and even be attacked or hunted by the faction if relations are sufficiently hostile.

Standing is impacted by the behaviour of the pilot. For instance, if a UIT pilot attacks an Itani ship, and the Itani government finds out about it, the UIT pilot's standing with the Itani will be degraded. Not only that, but if the Itani ship in question had a very high standing with other factions, relations may be degraded with them as well. However, if the attack takes place in an area of "unmonitored" space, then the faction(s) in question may never find out. Monitored sectors include those "owned" by a particular major nation, as well as any containing stations or wormhole areas.

Conversely, standing can be increased with a faction by doing tasks beneficial to the related entity. Taking missions, for example, will usually improve standing with the faction offering the mission. Other tasks, like ridding an area of nuisances (such as Hive bots) can improve standing.

Every pilot begins with certain base standings derived from his or her home nation. The Serco and Itani are at war and hate each other, the UIT get along fairly well with everyone. The corporations will mostly work with anyone who will make them a profit. How the pilot chooses to relate to the different factions from this starting point is up to them.

IMPORTANT: standing can be easy to lose and slow to gain. Be sure you are aware of the faction of any target you attack. Attacking anything other than Hive vessels indiscriminately is ill advised, unless you are prepared to deal with the ramifications.

Click on the individual faction names for further information.]]
}
	stats = FactionStandingTemplate(click_cb, iup.stationsubframe, iup.stationsubframebgfiller)

	local container = iup.hbox{
		stats,
		statsinfo,
	}

	function container:Setup(charid)
		stats:Setup(charid)
	end

	return container
end

