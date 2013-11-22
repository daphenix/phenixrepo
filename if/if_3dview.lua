function SetViewObject(viewcontrol, meshname, meshfile, colorindex)
	if meshname then
		viewcontrol.value = meshfile..":"..meshname
		local fgcolor = ShipPalette[colorindex+1]
		viewcontrol.fgcolor = string.format("%d %d %d",
			fgcolor:x()*255,
			fgcolor:y()*255,
			fgcolor:z()*255)
	else
		viewcontrol.value = ""
	end
end

function CreateBig3DViewMenu()
	local dlg
	local viewport, closebutton
	local previousdlg

	viewport = iup.modelview{value="", expand="YES"}
	closebutton = iup.stationbutton{
		title="Close",
		action=function()
			HideDialog(dlg)
			ShowDialog(previousdlg)
		end
	}

	dlg = iup.dialog{
		iup.stationmainframe{
			iup.hbox{
				iup.stationsubhollowframe{
					iup.hbox{
						iup.stationsubframe{
							iup.vbox{viewport, closebutton, alignment="ACENTER"},
						},
					},
				},
			},
		},
		defaultesc=closebutton,
		fullscreen="YES",
		bgcolor="0 0 0 0 +",
	}
	
	function dlg:SetShip(meshname, meshfile, shipcolorindex)  -- invitem type
		SetViewObject(viewport, meshname, meshfile, shipcolorindex)
	end

	function dlg:SetOwner(prevdlg)
		previousdlg = prevdlg
	end

	return dlg
end

Big3DViewDialog = CreateBig3DViewMenu()
Big3DViewDialog:map()