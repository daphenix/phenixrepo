
local function uvconvert(x0,y0,x1,y1, w,h)
	return string.format("%f %f %f %f", x0/w, y0/h, x1/w, y1/h)
end

local UV1 = uvconvert(0,0,96,32, 256,256)
local UV2 = uvconvert(0,32,96,64, 256,256)
local UV3 = uvconvert(0,64,96,96, 256,256)
local UV4 = uvconvert(0,96,96,128, 256,256)
local UV5 = uvconvert(0,128,96,160, 256,256)
local UV6 = uvconvert(0,160,96,192, 256,256)
local UV7 = uvconvert(0,192,96,224, 256,256)
local UV8 = uvconvert(0,224,96,256, 256,256)
local UV9 = uvconvert(96,0,192,32, 256,256)
local UV10 = uvconvert(96,32,192,64, 256,256)
local UV11 = uvconvert(96,64,192,96, 256,256)
local UV12 = uvconvert(96,96,192,128, 256,256)
local UV13 = uvconvert(96,128,192,160, 256,256)
local UV14 = uvconvert(96,160,192,192, 256,256)
local UV15 = uvconvert(96,192,192,224, 256,256)
local UV16 = uvconvert(96,224,192,256, 256,256)

local hivequeenhunterdesc = "This award is given in appreciation to those brave enough to take on and defeat the formidable Hive Queens. Destruction of the Queens helps to keep the Hive at bay, and is a service to the galaxy as a whole. There are four possible variations of the award, this individual has <current> of <nextvalue> kills required to reach the next award level."
local lasthivequeenhunterdesc = "This award is given in appreciation to those brave enough to take on and defeat the formidable Hive Queens. Destruction of the Queens helps to keep the Hive at bay, and is a service to the galaxy as a whole. There are four possible variations of the award, of which this is the highest."
local leviathanhunterdesc = "You have been recognized as a brave and worthy individual who has been willing to face, and help destroy, the mighty Leviathan. Destroying these masters of the Hive is a critical aspect of keeping the Hive at bay, and maintaining the safety and economic future of the human species. There are four possible variations of the award, this individual has <current> of <nextvalue> kills required to reach the next award level."
local lastleviathanhunterdesc = "You have been recognized as a brave and worthy individual who has been willing to face, and help destroy, the mighty Leviathan. Destroying these masters of the Hive is a critical aspect of keeping the Hive at bay, and maintaining the safety and economic future of the human species. There are four possible variations of the award, of which this is the highest."
local traderdesctail = " There are twelve levels to this award, this individual has <diffvalue>c profit remaining to reach the next award level."
local traderdesc = "This achievement signifies that the bearer has traded profitably, helping sustain the production and economy of the galaxy."..traderdesctail
local lasttraderdesctail = " There are twelve levels to this award, of which this is the highest."
local hivehunterdesctail = " There are ten variations of the award, this individual has <current> of <nextvalue> kills required to reach the next award level."
local hivehunterdesc = "In recognition of those brave souls who willingly engage the Hive in combat on behalf of their Nation, their factions and their people."..hivehunterdesctail
local lasthivehunterdesctail = " There are ten variations of the award, of which this is the highest."
local pvpvetdesctail = " While this award does not stipulate the experience or equipment of the opposing pilots, this is nonetheless a significant achievement. There are ten variations of this award, at 25, 100, 500, 1000, 2000, 5000, 10000, 20000, 50000 and 100000 kills."
local pvpvetdesc = "This individual has proven themselves in direct combat with other pilots."..pvpvetdesctail
local bushunterdesc = "This brave and dauntless individual of surpassing skill has killed 50 other pilots, while piloting the most basic of ships, the EC-88 or EC-89."
local basicminerdesctail = " There are thirteen levels to this award, this individual has <diffvalue>cu remaining to reach the next award level."
local basicminerdesc = "This achievement signifies that the bearer has successfully mined ores and minerals, helping sustain the production levels of the galaxy."..basicminerdesctail
local lastbasicminerdesctail = " There are thirteen levels to this award, of which this is the highest."
local denicminerdesc = "This miner has successfully prospected and extracted Denic Ore, a valuable resource in the galaxy and one of the rarer ores. There are four levels to this award, this individual has <diffvalue>cu remaining to reach the next award level."
local lastdenicminerdesc = "This miner has successfully prospected and extracted Denic Ore, a valuable resource in the galaxy and one of the rarer ores. There are four levels to this award, of which this is the highest."
local pentricminerdesc = "This miner has successfully prospected and extracted Pentric Ore, a very rare ore that is a critical ingredient in many major production technologies. Although there are four levels to this award, the scarcity of the ore makes the top level a rare archievement. This individual has <diffvalue>cu remaining to reach the next award level."
local lastpentricminerdesc = "This miner has successfully prospected and extracted Pentric Ore, a very rare ore that is a critical ingredient in many major production technologies. Although there are four levels to this award, the scarcity of the ore makes the top level a rare archievement. This is the highest award level."
local helioceneminerdesc = "This miner has successfully prospected and extracted Heliocene Ore, one of the rarest and most valuable ores in the galaxy. There are four levels to this award, but the scarcity of the ore makes the highest level a difficult achievement. This individual has <diffvalue>cu remaining to reach the next award level."
local lasthelioceneminerdesc = "This miner has successfully prospected and extracted Heliocene Ore, one of the rarest and most valuable ores in the galaxy. There are four levels to this award, but the scarcity of the ore makes the highest level a difficult achievement. This is the highest award level."

-- ug, i messed the higher pvpvet levels up, which caused pvpvet3 to be replaced by the higher levels.
-- it should have created a new ribbon that gets replaced from pvpvet4 on up.
-- this hack hides the problem from the user but it's still present in the database until I get around to fixing it there.
local pvpvet3_hack = {
			name="PVP Veteran - 500 Kills",
			texture="images/medals/ribbons2.png", uv=UV7, size="96x32",
			bigtexture="images/medals/medal_500kills.png", biguv="0 0 1 1", bigsize="128x128",
			desc=pvpvetdesc,
			category="combat",
		}

local accomplishmentlist = {
	{type="alpha",
	 	{
			name="Alpha Tester",
			texture="images/medals/ribbons_special.png", uv=UV1, size="96x32",
			bigtexture="images/medals/medal_alpha.png", biguv="0 0 1 1", bigsize="128x128",
			desc="This individual has the heartfelt thanks of Guild Software for their aid in testing the game during the Alpha period of development from 2002 to early 2004.",
			category="special",
		},
	},
	{type="beta",
		{
			name="Beta Tester",
			texture="images/medals/ribbons_special.png", uv=UV2, size="96x32",
			bigtexture="images/medals/medal_beta.png", biguv="0 0 1 1", bigsize="128x128",
			desc="This award is granted with appreciation to those who helped test in the Beta period of game development, from early in 2004 until launch in November of 2004.",
			category="special",
		},
	},
	{type="masterprospector",
		{
			name="Master Prospector",
			texture="images/medals/ribbons2.png", uv=UV8, size="96x32",
			bigtexture="images/medals/medal_prospecting.png", biguv="0 0 1 1", bigsize="128x128",
			desc="The Master Prospector award is given to those who have proven their ability to locate and identify a wide variety of mineral and ore types in locations across the galaxy.",
			category="mining",
		},
	},
	{type="hunteritani",
		{texture="images/medals/medal_botkills1.png", uv="0 0 1 1", name="Itani Bounty Hunter", desc="", category="combat",
			bigtexture="images/medals/medal_botkills1.png", biguv="0 0 1 1", bigsize="128x128", },
	},
	{type="hunterserco",
		{texture="images/medals/medal_botkills2.png", uv="0 0 1 1", name="Serco Bounty Hunter", desc="", category="combat",
			bigtexture="images/medals/medal_botkills2.png", biguv="0 0 1 1", bigsize="128x128", },
	},
	{type="hunteruit",
		{texture="images/medals/medal_botkills3.png", uv="0 0 1 1", name="UIT Bounty Hunter", desc="", category="combat",
			bigtexture="images/medals/medal_botkills3.png", biguv="0 0 1 1", bigsize="128x128", },
	},
	{type="pvpvet1",
		{
			name="PVP Veteran - 25 Kills",
			texture="images/medals/ribbons2.png", uv=UV5, size="96x32",
			bigtexture="images/medals/medal_10kills.png", biguv="0 0 1 1", bigsize="128x128",
			desc=pvpvetdesc,
			category="combat",
		},
	},
	{type="pvpvet2",
		nil,
		{
			name="PVP Veteran - 100 Kills",
			texture="images/medals/ribbons2.png", uv=UV6, size="96x32",
			bigtexture="images/medals/medal_100kills.png", biguv="0 0 1 1", bigsize="128x128",
			desc=pvpvetdesc,
			category="combat",
		},
	},
	{type="pvpvet3",
		nil,
		nil,
		pvpvet3_hack,
		pvpvet3_hack,
		pvpvet3_hack,
		pvpvet3_hack,
		pvpvet3_hack,
		pvpvet3_hack,
		pvpvet3_hack,
		pvpvet3_hack,
	},
	{type="pvpvet4",
		nil,
		nil,
		nil,
		{
			name="PVP Specialist I - 1000 Kills",
			texture="images/medals/ribbons4.png", uv=UV1, size="96x32",
			bigtexture="images/medals/medal_500kills.png", biguv="0 0 1 1", bigsize="128x128",
			desc="This person wishes to unlock their true combat potential."..pvpvetdesctail,
			category="combat",
		},
		{
			name="PVP Specialist II - 2000 Kills",
			texture="images/medals/ribbons4.png", uv=UV2, size="96x32",
			bigtexture="images/medals/medal_500kills.png", biguv="0 0 1 1", bigsize="128x128",
			desc="This person has seen the horrors of battle and wishes to see more."..pvpvetdesctail,
			category="combat",
		},
		{
			name="PVP Specialist III - 5000 Kills",
			texture="images/medals/ribbons4.png", uv=UV3, size="96x32",
			bigtexture="images/medals/medal_500kills.png", biguv="0 0 1 1", bigsize="128x128",
			desc="This person is either a one-man fighter squadron or takes the initiative to bring the bigger guns."..pvpvetdesctail,
			category="combat",
		},
		{
			name="PVP Expert I - 10000 Kills",
			texture="images/medals/ribbons4.png", uv=UV4, size="96x32",
			bigtexture="images/medals/medal_500kills.png", biguv="0 0 1 1", bigsize="128x128",
			desc="This person has proven themselves to be among the best in their preferred fighter craft."..pvpvetdesctail,
			category="combat",
		},
		{
			name="PVP Expert II - 20000 Kills",
			texture="images/medals/ribbons4.png", uv=UV5, size="96x32",
			bigtexture="images/medals/medal_500kills.png", biguv="0 0 1 1", bigsize="128x128",
			desc="This person seeks the annihilation of their enemy until they are no more."..pvpvetdesctail,
			category="combat",
		},
		{
			name="PVP Expert III - 50000 Kills",
			texture="images/medals/ribbons4.png", uv=UV6, size="96x32",
			bigtexture="images/medals/medal_500kills.png", biguv="0 0 1 1", bigsize="128x128",
			desc="This person is among the few top-guns."..pvpvetdesctail,
			category="combat",
		},
		{
			name="Gunslinger - 100000 Kills",
			texture="images/medals/ribbons4.png", uv=UV7, size="96x32",
			bigtexture="images/medals/medal_500kills.png", biguv="0 0 1 1", bigsize="128x128",
			desc="This person can kill with a thought."..pvpvetdesctail,
			category="combat",
		},
	},
	{type="mentor",
		{texture="images/medals/medal_mentor_bronze.png", uv="0 0 1 1", name="Mentor Level 1", desc="", category="special",
			bigtexture="images/medals/medal_mentor_bronze.png", biguv="0 0 1 1", bigsize="128x128", },
		{texture="images/medals/medal_mentor_silver.png", uv="0 0 1 1", name="Mentor Level 2", desc="", category="special",
			bigtexture="images/medals/medal_mentor_silver.png", biguv="0 0 1 1", bigsize="128x128", },
		{texture="images/medals/medal_mentor_gold.png", uv="0 0 1 1", name="Mentor Level 3", desc="", category="special",
			bigtexture="images/medals/medal_mentor_gold.png", biguv="0 0 1 1", bigsize="128x128", },
	},
	{type="trader",
		{texture="images/medals/medal_crescent.png", uv="0 0 1 1", name="Trader", desc="", category="trading",
			bigtexture="images/medals/medal_crescent.png", biguv="0 0 1 1", bigsize="128x128", },
	},
	{type="buskill",
		{
			name="Bus Hunter",
			texture="images/medals/ribbons2.png", uv=UV9, size="96x32",
			bigtexture="images/medals/medal_bus.png", biguv="0 0 1 1", bigsize="128x128",
			desc=bushunterdesc,
			category="combat",
		},
		{
			name="Bus Hunter II",
			texture="images/medals/ribbons2.png", uv=UV10, size="96x32",
			bigtexture="images/medals/medal_bus.png", biguv="0 0 1 1", bigsize="128x128",
			desc="",
			category="combat",
		},
		{
			name="Bus Hunter III",
			texture="images/medals/ribbons2.png", uv=UV11, size="96x32",
			bigtexture="images/medals/medal_bus.png", biguv="0 0 1 1", bigsize="128x128",
			desc="",
			category="combat",
		},
	},
	{type="queenkill",
		{
			name="Hive Queen Hunter I",
			title="Hive Queen Hunter I (10 kills)",
			texture="images/medals/ribbons.png", uv=UV1, size="96x32",
			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=hivequeenhunterdesc,
			category="combat",
		},
		{
			name="Hive Queen Hunter II",
			title="Hive Queen Hunter II (25 kills)",
			texture="images/medals/ribbons.png", uv=UV2, size="96x32",
			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=hivequeenhunterdesc,
			category="combat",
		},
		{
			name="Hive Queen Hunter III",
			title="Hive Queen Hunter III (100 kills)",
			texture="images/medals/ribbons.png", uv=UV3, size="96x32",
			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=hivequeenhunterdesc,
			category="combat",
		},
		{
			name="Master Hive Queen Hunter",
			title="Master Hive Queen Hunter (500 kills)",
			texture="images/medals/ribbons.png", uv=UV4, size="96x32",
			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=lasthivequeenhunterdesc,
			category="combat",
		},
	},
	{type="hive_leviathan",
		{
			name="Leviathan Hunter I",
			title="Leviathan Hunter I (1 kill)",
			texture="images/medals/ribbons.png", uv=UV5, size="96x32",
--			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=leviathanhunterdesc,
			category="combat",
		},
		{
			name="Leviathan Hunter II",
			title="Leviathan Hunter II (5 kills)",
			texture="images/medals/ribbons.png", uv=UV6, size="96x32",
--			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=leviathanhunterdesc,
			category="combat",
		},
		{
			name="Leviathan Hunter III",
			title="Leviathan Hunter III (50 kills)",
			texture="images/medals/ribbons.png", uv=UV7, size="96x32",
--			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=leviathanhunterdesc,
			category="combat",
		},
		{
			name="Master Leviathan Hunter",
			title="Master Leviathan Hunter (200 kills)",
			texture="images/medals/ribbons.png", uv=UV8, size="96x32",
--			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=lastleviathanhunterdesc,
			category="combat",
		},
	},
	{type="tradeprofit",
		{texture="images/medals/ribbons2.png", uv=UV1, size="96x32", name="Basic Trader I", title="Basic Trader I (5000c profit)", category="trading", desc=traderdesc,
			bigtexture="images/medals/medal_crescent.png", biguv="0 0 1 1", bigsize="128x128", },
		{texture="images/medals/ribbons2.png", uv=UV2, size="96x32", name="Basic Trader II", title="Basic Trader II (100kc profit)", category="trading", desc=traderdesc,
			bigtexture="images/medals/medal_crescent.png", biguv="0 0 1 1", bigsize="128x128", },
		{texture="images/medals/ribbons2.png", uv=UV3, size="96x32", name="Basic Trader III", title="Basic Trader III (1milc profit)", category="trading", desc=traderdesc,
			bigtexture="images/medals/medal_crescent.png", biguv="0 0 1 1", bigsize="128x128", },
		{texture="images/medals/ribbons2.png", uv=UV4, size="96x32", name="Basic Trader IV", title="Basic Trader IV (10milc profit)", category="trading", desc=traderdesc,
			bigtexture="images/medals/medal_crescent.png", biguv="0 0 1 1", bigsize="128x128", },

		{texture="images/medals/ribbons3.png", uv=UV1, size="96x32", name="Intermediate Trader I", title="Intermediate Trader I (20milc profit)", category="trading", desc="This person has proven their value as a talented intermediate trader."..traderdesctail,
			bigtexture="images/medals/medal_crescent.png", biguv="0 0 1 1", bigsize="128x128", },
		{texture="images/medals/ribbons3.png", uv=UV2, size="96x32", name="Intermediate Trader II", title="Intermediate Trader II (50milc profit)", category="trading", desc="This person seeks great riches above and beyond the requirements of their fellow pilots."..traderdesctail,
			bigtexture="images/medals/medal_crescent.png", biguv="0 0 1 1", bigsize="128x128", },
		{texture="images/medals/ribbons3.png", uv=UV3, size="96x32", name="Intermediate Trader III", title="Intermediate Trader III (100milc profit)", category="trading", desc="This person is forming themselves to be a well known trader throughout the galaxy."..traderdesctail,
			bigtexture="images/medals/medal_crescent.png", biguv="0 0 1 1", bigsize="128x128", },
		{texture="images/medals/ribbons3.png", uv=UV4, size="96x32", name="Intermediate Trader IV", title="Intermediate Trader IV (200milc profit)", category="trading", desc="This person is starting to understand the meaning of no boundaries."..traderdesctail,
			bigtexture="images/medals/medal_crescent.png", biguv="0 0 1 1", bigsize="128x128", },

		{texture="images/medals/ribbons3.png", uv=UV5, size="96x32", name="Trade Master I", title="Trade Master I (500milc profit)", category="trading", desc="This person is an enterprising individual with a clear goal in mind."..traderdesctail,
			bigtexture="images/medals/medal_crescent.png", biguv="0 0 1 1", bigsize="128x128", },
		{texture="images/medals/ribbons3.png", uv=UV6, size="96x32", name="Trade Master II", title="Trade Master II (1bilc profit)", category="trading", desc="This person is among the few tycoons brave enough to make it this far."..traderdesctail,
			bigtexture="images/medals/medal_crescent.png", biguv="0 0 1 1", bigsize="128x128", },
		{texture="images/medals/ribbons3.png", uv=UV7, size="96x32", name="Trade Master III", title="Trade Master III (2bilc profit)", category="trading", desc="This person seeks to be a true galactic player."..traderdesctail,
			bigtexture="images/medals/medal_crescent.png", biguv="0 0 1 1", bigsize="128x128", },
		{texture="images/medals/ribbons3.png", uv=UV8, size="96x32", name="Trade Master IV", title="Trade Master IV (5bilc profit)", category="trading", desc="This person is a true galactic player."..lasttraderdesctail,
			bigtexture="images/medals/medal_crescent.png", biguv="0 0 1 1", bigsize="128x128", },
	},
	{type="hivehunter",
		{texture="images/medals/ribbons.png", uv=UV9, size="96x32", name="Hive Hunter I", title="Hive Hunter I (10 kills)", category="combat", desc=hivehunterdesc},
		{texture="images/medals/ribbons.png", uv=UV10, size="96x32", name="Hive Hunter II", title="Hive Hunter II (50 kills)", category="combat", desc=hivehunterdesc},
		{texture="images/medals/ribbons.png", uv=UV11, size="96x32", name="Hive Hunter III", title="Hive Hunter III (100 kills)", category="combat", desc=hivehunterdesc},
		{texture="images/medals/ribbons.png", uv=UV12, size="96x32", name="Veteran Hive Hunter I", title="Veteran Hive Hunter I (500 kills)", category="combat", desc=hivehunterdesc},
		{texture="images/medals/ribbons.png", uv=UV13, size="96x32", name="Veteran Hive Hunter II", title="Veteran Hive Hunter II (1000 kills)", category="combat", desc=hivehunterdesc},
		{texture="images/medals/ribbons.png", uv=UV14, size="96x32", name="Veteran Hive Hunter III", title="Veteran Hive Hunter III (5000 kills)", category="combat", desc=hivehunterdesc},
		{texture="images/medals/ribbons.png", uv=UV15, size="96x32", name="Master Hive Hunter I", title="Master Hive Hunter I (10000 kills)", category="combat", desc=hivehunterdesc},
		{texture="images/medals/ribbons.png", uv=UV16, size="96x32", name="Master Hive Hunter II", title="Master Hive Hunter II (20000 kills)", category="combat", desc=hivehunterdesc},
		{texture="images/medals/ribbons4.png", uv=UV9, size="96x32", name="Master Hive Hunter III", title="Master Hive Hunter III (50000 kills)", category="combat", desc="This person seeks the utter destruction of the Hive."..hivehunterdesctail},
		{texture="images/medals/ribbons4.png", uv=UV10, size="96x32", name="Hive Dominator", title="Hive Dominator (100000 kills)", category="combat", desc="This person's skills are like that of a virus which causes Hive bots to explode randomly."..lasthivehunterdesctail},
	},
	{type="basicminer",
		{texture="images/medals/ribbons2.png", uv=UV12, size="96x32", name="Basic Miner I", title="Basic Miner I (500cu)", category="mining", desc=basicminerdesc},
		{texture="images/medals/ribbons2.png", uv=UV13, size="96x32", name="Basic Miner II", title="Basic Miner II (15000cu)", category="mining", desc=basicminerdesc},
		{texture="images/medals/ribbons2.png", uv=UV14, size="96x32", name="Basic Miner III", title="Basic Miner III (100000cu)", category="mining", desc=basicminerdesc},
		{texture="images/medals/ribbons2.png", uv=UV15, size="96x32", name="Basic Miner IV", title="Basic Miner IV (1milcu)", category="mining", desc=basicminerdesc},

		{texture="images/medals/ribbons3.png", uv=UV9, size="96x32", name="Advanced Miner I", title="Advanced Miner I (2milcu)", category="mining", desc="This person seeks be a captain of industry."..basicminerdesctail},
		{texture="images/medals/ribbons3.png", uv=UV10, size="96x32", name="Advanced Miner II", title="Advanced Miner II (5milcu)", category="mining", desc="This person is a captain of industry and wishes to become more."..basicminerdesctail},
		{texture="images/medals/ribbons3.png", uv=UV11, size="96x32", name="Advanced Miner III", title="Advanced Miner III (10milcu)", category="mining", desc="This person has a unusually large interest in mining and their ranks shows it."..basicminerdesctail},
		{texture="images/medals/ribbons3.png", uv=UV12, size="96x32", name="Advanced Miner IV", title="Advanced Miner IV (20vcu)", category="mining", desc="This person can single handily supply a small planet."..basicminerdesctail},

		{texture="images/medals/ribbons3.png", uv=UV13, size="96x32", name="Industrial Miner I", title="Industrial Miner I (50milcu)", category="mining", desc="This person has proven themselves capable to be a galactic supplier of fine materials."..basicminerdesctail},
		{texture="images/medals/ribbons3.png", uv=UV14, size="96x32", name="Industrial Miner II", title="Industrial Miner II (100milcu)", category="mining", desc="This person has surely overseen the depletion of entire resource sectors and then some."..basicminerdesctail},
		{texture="images/medals/ribbons3.png", uv=UV15, size="96x32", name="Industrial Miner III", title="Industrial Miner III (200milcu)", category="mining", desc="This person has the potential to make their own planet."..basicminerdesctail},
		{texture="images/medals/ribbons3.png", uv=UV16, size="96x32", name="Industrial Miner IV", title="Industrial Miner IV (500milcu)", category="mining", desc="This person has theoretically mined an entire system."..basicminerdesctail},

		{texture="images/medals/ribbons4.png", uv=UV8, size="96x32", name="Planet Cracker", title="Planet Cracker (1bilcu)", category="mining", desc="Planets quake in fear of this person's name and entire systems implode in their wake."..lastbasicminerdesctail},
	},
	{type="pentricminer",
		{
			name="Pentric Miner I",
			title="Pentric Miner I (50 cu)",
			texture="images/medals/ribbons_mining.png", uv=UV1, size="96x32",
--			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=pentricminerdesc,
			category="mining",
		},
		{
			name="Pentric Miner II",
			title="Pentric Miner II (500 cu)",
			texture="images/medals/ribbons_mining.png", uv=UV2, size="96x32",
--			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=pentricminerdesc,
			category="mining",
		},
		{
			name="Pentric Miner III",
			title="Pentric Miner III (5000 cu)",
			texture="images/medals/ribbons_mining.png", uv=UV3, size="96x32",
--			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=pentricminerdesc,
			category="mining",
		},
		{
			name="Pentric Miner IV",
			title="Pentric Miner IV (50000 cu)",
			texture="images/medals/ribbons_mining.png", uv=UV4, size="96x32",
--			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=lastpentricminerdesc,
			category="mining",
		},
	},
	{type="denicminer",
		{
			name="Denic Miner I",
			title="Denic Miner I (50 cu)",
			texture="images/medals/ribbons_mining.png", uv=UV5, size="96x32",
--			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=denicminerdesc,
			category="mining",
		},
		{
			name="Denic Miner II",
			title="Denic Miner II (500 cu)",
			texture="images/medals/ribbons_mining.png", uv=UV6, size="96x32",
--			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=denicminerdesc,
			category="mining",
		},
		{
			name="Denic Miner III",
			title="Denic Miner III (5000 cu)",
			texture="images/medals/ribbons_mining.png", uv=UV7, size="96x32",
--			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=denicminerdesc,
			category="mining",
		},
		{
			name="Denic Miner IV",
			title="Denic Miner IV (50000 cu)",
			texture="images/medals/ribbons_mining.png", uv=UV8, size="96x32",
--			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=lastdenicminerdesc,
			category="mining",
		},
	},
	{type="helioceneminer",
		{
			name="Heliocene Miner I",
			title="Heliocene Miner I (50 cu)",
			texture="images/medals/ribbons_mining.png", uv=UV9, size="96x32",
--			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=helioceneminerdesc,
			category="mining",
		},
		{
			name="Heliocene Miner II",
			title="Heliocene Miner II (500 cu)",
			texture="images/medals/ribbons_mining.png", uv=UV10, size="96x32",
--			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=helioceneminerdesc,
			category="mining",
		},
		{
			name="Heliocene Miner III",
			title="Heliocene Miner III (5000 cu)",
			texture="images/medals/ribbons_mining.png", uv=UV11, size="96x32",
--			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=helioceneminerdesc,
			category="mining",
		},
		{
			name="Heliocene Miner IV",
			title="Heliocene Miner IV (50000 cu)",
			texture="images/medals/ribbons_mining.png", uv=UV12, size="96x32",
--			bigtexture="images/medals/medal_sun.png", biguv="0 0 1 1", bigsize="128x128",
			desc=lasthelioceneminerdesc,
			category="mining",
		},
	},
	{type="duelvet",
	 	{
			name="Duellist",
			texture="images/medals/ribbons4.png", uv=UV11, size="96x32",
--			bigtexture="images/medals/.png", biguv="0 0 1 1", bigsize="128x128",
			desc="This individual achieved a duel score of 1600.",
			category="combat",
		},
	 	{
			name="Master Duellist",
			texture="images/medals/ribbons4.png", uv=UV12, size="96x32",
--			bigtexture="images/medals/.png", biguv="0 0 1 1", bigsize="128x128",
			desc="This individual achieved a duel score of 2000.",
			category="combat",
		},
	 	{
			name="Grandmaster Duellist",
			texture="images/medals/ribbons4.png", uv=UV13, size="96x32",
--			bigtexture="images/medals/.png", biguv="0 0 1 1", bigsize="128x128",
			desc="This individual achieved a duel score of 2400.",
			category="combat",
		},
	 	{
			name="Legendary Duellist",
			texture="images/medals/ribbons4.png", uv=UV14, size="96x32",
--			bigtexture="images/medals/.png", biguv="0 0 1 1", bigsize="128x128",
			desc="This individual achieved a duel score of 2800.",
			category="combat",
		},
	},
	{type="racewin",
	 	{
			name="Race Winner",
			texture="images/medals/ribbons4.png", uv=UV15, size="96x32",
--			bigtexture="images/medals/.png", biguv="0 0 1 1", bigsize="128x128",
			desc="This individual has had a monthly track record.",
			category=nil,  -- other
		},
	 	{
			name="Super Race Winner",
			texture="images/medals/ribbons4.png", uv=UV16, size="96x32",
--			bigtexture="images/medals/.png", biguv="0 0 1 1", bigsize="128x128",
			desc="This individual has had 10 monthly track records.",
			category=nil,  -- other
		},
	},
}


function GetAccomplishmentCategory(accomtype, accomlevel)
	accomtype = accomplishmentlist[accomtype]
	accomlevel = accomtype and accomtype[accomlevel]
	return accomlevel and accomlevel.category
end

function GetAccomplishmentName(accomtype, accomlevel)
	accomtype = accomplishmentlist[accomtype]
	accomlevel = accomtype and accomtype[accomlevel]
	return accomlevel and accomlevel.name
end

function GetAccomplishmentTitle(accomtype, accomlevel)
	accomtype = accomplishmentlist[accomtype]
	accomlevel = accomtype and accomtype[accomlevel]
	return accomlevel and (accomlevel.title or accomlevel.name)
end

function GetAccomplishmentDescription(accomtype, accomlevel)
	accomtype = accomplishmentlist[accomtype]
	accomlevel = accomtype and accomtype[accomlevel]
	return accomlevel and accomlevel.desc or ""
end

function GetAccomplishmentTexture(accomtype, accomlevel)
	accomtype = accomplishmentlist[accomtype]
	accomlevel = accomtype and accomtype[accomlevel]
	return accomlevel and accomlevel.texture
end

function GetAccomplishmentUV(accomtype, accomlevel)
	accomtype = accomplishmentlist[accomtype]
	accomlevel = accomtype and accomtype[accomlevel]
	return accomlevel and accomlevel.uv
end

function GetAccomplishmentSize(accomtype, accomlevel)
	accomtype = accomplishmentlist[accomtype]
	accomlevel = accomtype and accomtype[accomlevel]
	return accomlevel and accomlevel.size
end

function GetAccomplishmentBigTexture(accomtype, accomlevel)
	accomtype = accomplishmentlist[accomtype]
	accomlevel = accomtype and accomtype[accomlevel]
	return accomlevel and accomlevel.bigtexture
end

function GetAccomplishmentBigUV(accomtype, accomlevel)
	accomtype = accomplishmentlist[accomtype]
	accomlevel = accomtype and accomtype[accomlevel]
	return accomlevel and accomlevel.biguv
end

function GetAccomplishmentBigSize(accomtype, accomlevel)
	accomtype = accomplishmentlist[accomtype]
	accomlevel = accomtype and accomtype[accomlevel]
	return accomlevel and accomlevel.bigsize
end
