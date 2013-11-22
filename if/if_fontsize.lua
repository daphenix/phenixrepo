local scaleY = gkinterface.GetYResolution() / 600

if UseFontScaling then
	scaleY = scaleY * FontScale
end

iup.SetDefaultFontSize(math.floor(16*scaleY))
radar.SetNavpointFontHeight(math.floor(18*scaleY))

Font = {
	Default = math.floor(16*scaleY),
	Tiny = 12,
	Big = math.floor(32*scaleY),
	Huge = math.floor(44*scaleY),
	Tab = math.floor(24*scaleY),
	HUDNotification = math.floor(24*scaleY),
	H1 = math.floor(22*scaleY),
	H2 = math.floor(20*scaleY),
	H3 = math.floor(18*scaleY),
	H4 = math.floor(16*scaleY),
	H5 = math.floor(14*scaleY),
	H6 = math.floor(12*scaleY),
}

Font1 = {
	Default = 16,
	Tiny = 12,
	Big = 32,
	Huge = 44,
	Tab = 24,
	HUDNotification = 24,
	H1 = 22,
	H2 = 20,
	H3 = 18,
	H4 = 16,
	H5 = 14,
}

Font2 = {
	Default = 32,
	Tiny = 12,
	Big = 64,
	Huge = 88,
	Tab = 48,
	HUDNotification = 48,
	H1 = 44,
	H2 = 40,
	H3 = 36,
	H4 = 32,
	H5 = 28,
}