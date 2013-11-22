local credits = 
[[Created By

Guild Software, Inc

*  *  *

- Managing Director -

John Bergman

- Programming -

Ray Ratelis
Andy Sloane
Michael Warnock

- Additional Programming -

Waylon Brinck
Kalle Anderson

- Artwork -

Waylon Brinck
Phil Bedard
John Bergman
Luis Zardo

- Additional Artwork -

Francis Bernier
Paul Burgermeister

- Music -

Philippe Charron
Jeremy Schmitz
John Bergman

- Sound -

John Bergman
Andy Sloane

- Core Game Design -

John Bergman

- Additional Game Design -

Waylon Brinck

*  *  *

- Many thanks to our Guides -

Whistler
Obsidian
Relayer
FiReMaGe
ctishman
Suicidal Lemming
Asp
Eldrad

*  *  *

- Special thanks to our amazing userbase -

Without your support and enthusiasm, 
this game would not exist. We made this
for you, we hope you like it.

*  *  *

Much love and gratitude to our
supportive families, spouses and close friends, who
helped us achieve the incredible goal of
creating this game.

*  *  *

- Our friends in the industry -

Keith Galocy - Nvidia
Mike Smith - ATI
Jeff Royle - ATI
Jonathan Zarge - ATI
Mike Drummelsmith - Matrox
Omar Yehia - Matrox
Rich Hernandez - Apple
Wallace Poulter - Apple
Jeremy Gaffney - NCsoft
Ritche Corpus - Logitech

*  *  *

- Everyone Else -

Alec Ellsworth
Bill Sella
Paul Bragiel
Antonios Proios
Nic Harteau
Ravi Pina
Nate Ferch
Neil Biondich
Randy Berdan
Ali Lomonaco
Sam Etler
Peter Clark

Everyone from #guild
Everyone from #vendetta

*  *  *

Vendetta Online makes
use of the following open
source libraries:

Lua Copyright (c) 1994-2005 Lua.org, PUC-Rio
libpng Copyright (c) 1998-2001 Greg Roelofs.  All rights reserved.
OGG/Vorbis Copyright (c) 2002-2004, Xiph.Org Foundation
IUP is Copyright (c) 1994-2005 Tecgraf / PUC-Rio and PETROBRAS S/A.
This software is based in part on the work of the Independent JPEG Group]]

function CreateCreditsDialog(logindialog)

local closebutton, creditlist
local dlg

closebutton = iup.stationbutton{title="Close",
	action=function()
		HideDialog(dlg)
		ShowDialog(logindialog)
	end}
creditlist = iup.stationhighopacitysubmultiline{
	value = credits,
	expand="YES",
	readonly="YES",
	alignment="ACENTER",
}

dlg = iup.dialog{
	iup.vbox{
		margin="20x20",
		iup.stationhighopacityframe{
			iup.vbox{
				font=Font.H1,
				iup.stationhighopacityframebg{
					iup.hbox{
						iup.fill{},
						iup.label{title="",image="images/new/vendetta_logo.png", size="256x128",expand="NO"},
						iup.fill{},
					},
				},
				creditlist,
				iup.stationhighopacityframebg{
					iup.vbox{
						iup.hbox{iup.label{title="",image="images/new/guild_logo.png", size="256x64",expand="NO"},iup.fill{},iup.label{title="Build "..Game.GetClientVersion()},alignment="ABOTTOM"},
						iup.hbox{iup.fill{},closebutton,iup.fill{}}
					}
				},
			},
		},
	},
	fullscreen="YES",
	startfocus = closebutton,
	defaultesc = closebutton,
	defaultenter = closebutton,
	bgcolor = "0 0 0 0 *",
}

return dlg
end
