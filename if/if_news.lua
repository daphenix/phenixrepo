local function htmlcodeLUT(x)
	x = tonumber(x)
	if x <= 126 then
		x = string.char(x)
	else
		x = ""
	end
	
	return x
end

function CreateNewsMenu()
	local dlg
	local header, body, closebutton

	header = iup.label{title="",font=Font.H1,expand="HORIZONTAL",alignment="ACENTER", wordwrap="YES"}
	body = iup.stationhighopacitysubmultiline{
		readonly="YES",
		expand="YES",
	}
	closebutton = iup.stationbutton{title="Back to headlines",
		action=function(self)
			HideDialog(dlg)
		end,
	}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.vbox{
						iup.stationhighopacityframebg{
							header,
						},
						body,
						iup.stationhighopacityframebg{
							iup.hbox{iup.fill{},closebutton,iup.fill{}},
						},
					},
					size = "%75x%75",
					expand="NO",
				},
				iup.fill{},
			},
			iup.fill{},
		},
		show_cb=function(self)
			body.value = "Retrieving article..."
		end,
		SetHeader=function(self, text)
			header.title = text
		end,
		fullscreen = "YES",
		bgcolor="0 0 0 128 *",
		defaultesc = closebutton,
		defaultenter = closebutton,
	}
	function dlg:map_cb()
		RegisterEvent(self, "UPDATE_NEWS")
	end
	function dlg:OnEvent(eventname, ...)
		local arg1, arg2, arg3 = ...
		header.title = arg2
		body.value = ""
		arg3 = string.gsub(arg3, "<.->", "")
		arg3 = string.gsub(arg3, "&quot;", "\"")
		arg3 = string.gsub(arg3, "&lt;", "<")
		arg3 = string.gsub(arg3, "&gt;", ">")
		arg3 = string.gsub(arg3, "&#(%d+);", htmlcodeLUT)
		arg3 = string.gsub(arg3, "&amp;", "&")
		body.append = arg3
	end

	return dlg
end


NewsDialog = CreateNewsMenu()
NewsDialog:map()
