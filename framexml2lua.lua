#!/usr/bin/env lua
require("LuaXML")


local types, parse = {}

local function quote(str) return str and string.format("%q", str) end
local function rel(arg, parent)
	if arg then
		return arg:gsub("%$[pP][aA][rR][eE][nN][tT]", parent or "")
	else
		return parent
	end
end
local sentinel = {}
local function _attrfunc(req, n, f, ...)
	local t = {}
	if select('#', ...) > 0 then
		for i = 1, select('#', ...) do
			v = select(i, ...)
			v = tonumber(v) or v
			t[#t+1] = v and string.format("%s", v) or sentinel
		end
		for i = #t, 0, -1 do
			if t[i] == sentinel then table.remove(t, i) end
		end
	end
	if #t > 0 or req then
		io.write(n or "", n and ":" or "", f, "(")
		if #t > 0 then io.write(table.concat(t, ", ")) end
		print(")")
	end
end
local function attrfunc(...) _attrfunc(false, ...) end
local function reqattrfunc(...)	_attrfunc(true, ...) end


scriptargs = {
	["OnAnimFinished"] = "self",
	["OnArrowPressed"] = "self, key",
	["OnAttributeChanged"] = "self, name, value",
	["OnButtonUpdate"] = "self, action",
	["OnChar"] = "self, text",
	["OnCharComposition"] = "self, text",
	["OnClick"] = "self, button, down",
	["OnColorSelect"] = "self, r, g, b",
	["OnCooldownDone"] = "self",
	["OnCursorChanged"] = "self, x, y, width, height",
	["OnDisable"] = "self",
	["OnDoubleClick"] = "self, button",
	["OnDragStart"] = "self, button",
	["OnDragStop"] = "self",
	["OnEditFocusGained"] = "self",
	["OnEditFocusLost"] = "self",
	["OnEnable"] = "self",
	["OnEnter"] = "self, motion",
	["OnEnterPressed"] = "self",
	["OnError"] = "self, msg",
	["OnEscapePressed"] = "self",
	["OnEvent"] = "self, event, ...",
	["OnExternalLink"] = "self, url",
	["OnFinished"] = "self, requested",
	["OnHide"] = "self",
	["OnHorizontalScroll"] = "self, offset",
	["OnHyperlinkClick"] = "self, link, text, button",
	["OnHyperlinkEnter"] = "self, link, text",
	["OnHyperlinkLeave"] = "self, link, text",
	["OnInputLanguageChanged"] = "self, language",
	--[[ unknown args, not used in FrameXML
	["OnJoystickAxisMotion"]
	["OnJoystickButtonDown"]
	["OnJoystickButtonUp"]
	["OnJoystickHatMotion"]
	["OnJoystickStickMotion"]
	--]]
	["OnKeyDown"] = "self, key",
	["OnKeyUp"] = "self, key",
	["OnLeave"] = "self, motion",
	["OnLoad"] = "self",
	["OnLoop"] = "self, loopState",
	["OnMessageScrollChanged"] = "self",
	["OnMinMaxChanged"] = "self, min, max",
	["OnMouseDown"] = "self, button",
	["OnMouseUp"] = "self, button",
	["OnMouseWheel"] = "self, delta",
	["OnMovieFinished"] = "self",
	["OnMovieHideSubtitle"] = "self",
	["OnMovieShowSubtitle"] = "self, text",
	["OnPause"] = "self",
	["OnPlay"] = "self",
	["OnReceiveDrag"] = "self",
	["OnScrollRangeChanged"] = "self, xrange, yrange",
	["OnShow"] = "self",
	["OnSizeChanged"] = "self, w, h",
	["OnSpacePressed"] = "self",
	["OnStop"] = "self, requested",
	["OnTabPressed"] = "self",
	["OnTextChanged"] = "self, userInput",
	["OnTextSet"] = "self",
	["OnTooltipAddMoney"] = "self, cost, maxcost",
	["OnTooltipCleared"] = "self",
	["OnTooltipSetAchievement"] = "self",
	["OnTooltipSetEquipmentSet"] = "self",
	["OnTooltipSetDefaultAnchor"] = "self",
	["OnTooltipSetFrameStack"] = "self",
	["OnTooltipSetItem"] = "self",
	["OnTooltipSetQuest"] = "self",
	["OnTooltipSetSpell"] = "self",
	["OnTooltipSetUnit"] = "self",
	["OnUpdate"] = "self, elapsed",
	["OnUpdateModel"] = "self",
	["OnValueChanged"] = "self, value, userInput",
	["OnVerticalScroll"] = "self, offset",
	["PostClick"] = "self, button, down",
	["PreClick"] = "self, button, down",

}

types["AlphaType"] = function(obj, parent, grandparent)
		local ret = types["AnimationType"](obj, parent, grandparent)
		attrfunc(parent, 'SetChange', obj["change"])
		attrfunc(parent, 'SetFromAlpha', obj["fromAlpha"]) --invalid according to schema, but used in FrameXML
		attrfunc(parent, 'SetToAlpha', obj["toAlpha"]) --invalid according to schema, but used in FrameXML
		return ret
	end
types["Anchor"] = function(obj, parent, grandparent)
		local x, y = types["Dimension"](obj)
		reqattrfunc(parent, 'SetPoint', quote(obj["point"]),
			rel(obj["relativeKey"] or obj["relativekey"] or obj["relativeTo"], grandparent),
			quote(obj["relativePoint"] or obj["RelativePoint"] or obj["relativepoint"]), --"RelativePoint" and "relativepoint" invalid according to schema, but used in FrameXML
			x or 0, y or 0)
	end
types["AnimationGroupType"] = function(obj, parent, grandparent)
		io.write("local ", obj.nickname, " = ", obj.nickname, " or ")
		reqattrfunc(parent, "CreateAnimationGroup", quote(obj.name), quote(obj.inherits))
		attrfunc(obj.nickname, 'SetLooping', quote(obj["looping"]))
		if obj["parentKey"] and parent then print(parent.."["..quote(obj["parentKey"]).."] = "..obj.nickname) end
		attrfunc(obj.nickname, 'SetIgnoreFramerateThrottle', obj["ignoreFramerateThrottle"])
		if obj["setToFinalAlpha"] then reqattrfunc(obj.nickname, 'SetToFinalAlpha') end --invalid according to schema, but used in FrameXML
		return true
	end
types["AnimationType"] = function(obj, parent, grandparent)
		io.write("local ", obj.nickname, " = ", obj.nickname, " or ")
		reqattrfunc(parent, "CreateAnimation", quote(obj:tag()), quote(obj.name), quote(obj.inherits))
		attrfunc(obj.nickname, 'SetTarget', quote(obj["target"]))
		attrfunc(obj.nickname, 'SetTargetKey', quote(obj["targetKey"]))
		if obj["obj.nicknameKey"] then print(parent.."["..quote(obj["obj.nicknameKey"]).."] = ", obj.nickname) end
		attrfunc(obj.nickname, 'SetChildKey', quote(obj["childKey"])) --invalid according to schema, but used in FrameXML
		attrfunc(obj.nickname, 'SetStartDelay', obj["startDelay"])
		attrfunc(obj.nickname, 'SetEndDelay', obj["endDelay"])
		attrfunc(obj.nickname, 'SetDuration', obj["duration"])
		attrfunc(obj.nickname, 'SetOrder', obj["order"])
		attrfunc(obj.nickname, 'SetSmoothing', quote(obj["smoothing"]))
		return true
	end
types["AnimOriginType"] = function(obj, parent, grandparent)
		attrfunc(parent, 'SetOrigin', quote(obj["point"]) or "CENTER", types["Dimension"](obj))
	end
types["AttributeType"] = function(obj, parent, grandparent)
		attrfunc(parent, 'SetAttribute', quote(obj["name"]), (obj["type"] and obj["type"] ~= "string") and obj["value"] or quote(obj["value"]))
	end
types["BackdropType"] = function(obj, parent, grandparent)
		local str = {}
		str[#str+1] = "{"
		for i, v in ipairs(obj) do
			if v:tag() == "TileSize" then
				str[#str+1] = "tileSize = "..types["Value"](v)..","
			elseif v:tag() == "EdgeSize" then
				str[#str+1] = "edgeSize = "..types["Value"](v)..","
			elseif v:tag() == "Color" then
				attrfunc(parent, 'SetBackdropColor', types["ColorType"](v))
			elseif v:tag() == "BorderColor" then
				attrfunc(parent, 'SetBackdropBorderColor', types["ColorType"](v))
			elseif v:tag() == "BackgroundInsets" then
				local l, r, t, b = types["Inset"](v)
				str[#str+1] = "insets = {"
				str[#str+1] = "left = "..(l or 0)..","
				str[#str+1] = "right = "..(r or 0)..","
				str[#str+1] = "top = "..(t or 0)..","
				str[#str+1] = "bottom = "..(b or 0)..","
				str[#str+1] = "},"
			end
		end
		if obj["bgFile"] then str[#str+1] = "bgFile = "..quote(obj["bgFile"]).."," end
		if obj["edgeFile"] then str[#str+1] = "edgeFile = "..quote(obj["edgeFile"]).."," end
		if obj["tile"] then str[#str+1] = "tile = "..obj["tile"].."," end
		str[#str+1] = "}"
		attrfunc(parent, 'SetBackdrop', table.concat(str, "\n"))
		--attrfunc(parent, '', quote(obj["alphaMode"])) no Lua equivalent?
	end
types["BlobType"] = function(obj, parent, grandparent) --not defined in schema, virtual type used in C
		local ret = types["FrameType"](obj, parent, grandparent)
		attrfunc(parent, 'SetFillTexture', quote(obj["filltexture"]))
		attrfunc(parent, 'SetBorderTexture', quote(obj["bordertexture"]))
		return ret
	end
types["BrowserType"] = function(obj, parent, grandparent)
		return types["FrameType"](obj, parent, grandparent)
		--attrfunc(parent, '', quote(obj["imefont"])) no Lua equivalent, used in help frame
	end
types["ButtonStyleType"] = function(obj, parent, grandparent)
		return quote(obj["style"])
	end
types["ButtonType"] = function(obj, parent, grandparent)
		local ret = types["FrameType"](obj, parent, grandparent)
		attrfunc(obj.nickname, 'SetText', quote(obj["text"]))
		attrfunc(obj.nickname, 'SetEnabled', quote(obj["enabled"])) --invalid according to schema, but used in FrameXML
		attrfunc(obj.nickname, 'RegisterForClicks', obj["registerForClicks"] and obj["registerForClicks"]:gsub("([^,]+)", quote))
		attrfunc(obj.nickname, 'SetMotionScriptsWhileDisabled', obj["motionScriptsWhileDisabled"])
		return ret
	end
types["CheckButtonType"] = function(obj, parent, grandparent)
		local ret = types["ButtonType"](obj, parent, grandparent)
		attrfunc(obj.nickname, 'SetChecked', obj["checked"])
		return ret
	end
types["CinematicModelType"] = function(obj, parent, grandparent)
		local ret = types["ModelType"](obj, parent, grandparent)
		attrfunc(obj.nickname, 'SetFacingLeft', obj["facing"])
		attrfunc(obj.nickname, 'SetFacingLeft', obj["facingLeft"]) --invalid according to schema, but used in FrameXML
		return ret
	end
types["ColorSelectType"] = function(obj, parent, grandparent)
		return types["FrameType"](obj, parent, grandparent)
	end
types["ColorType"] = function(obj, parent, grandparent)
		return obj["r"], obj["g"], obj["b"], obj["a"]
	end
types["ControlPoint"] = function(obj, parent, grandparent)
		io.write("local ", obj.nickname, " = ", obj.nickname, " or ")
		reqattrfunc(parent, "CreateControlPoint", obj.name)
		attrfunc(obj.nickname, 'SetOffset', obj["offsetX"] or 0, obj["offsetY"] or 0)
		return true
	end
types["CooldownType"] = function(obj, parent, grandparent)
		local ret = types["FrameType"](obj, parent, grandparent)
		attrfunc(obj.nickname, 'SetReverse', obj["reverse"])
		attrfunc(obj.nickname, 'SetHideCountdownNumbers', obj["hideCountdownNumbers"]) --invalid according to schema, but used in FrameXML
		attrfunc(obj.nickname, 'SetDrawBling', obj["drawBling"]) --invalid according to schema, but used in FrameXML
		attrfunc(obj.nickname, 'SetDrawEdge', obj["drawEdge"]) --invalid according to schema, but used in FrameXML
		return ret
	end
types["Dimension"] = function(obj)
		local x, y
		for i, v in ipairs(obj) do
			x, y = types["Dimension"](v)
		end
		return tonumber(obj["x"]) or x, tonumber(obj["y"]) or y
	end
types["DressUpModelType"] = function(obj, parent, grandparent)
		return types["PlayerModelType"](obj, parent, grandparent)
	end
types["EditBoxType"] = function(obj, parent, grandparent)
		local ret = types["FrameType"](obj, parent, grandparent)
		for i, v in ipairs(obj) do
			if v:tag() == "TextInsets" then attrfunc(parent, 'SetTextInsets', types["Inset"](v)) end
		end
		attrfunc(obj.nickname, 'SetFontObject', quote(obj["font"]))
		attrfunc(obj.nickname, 'SetMaxLetters', obj["letters"])
		attrfunc(obj.nickname, 'SetBlinkSpeed', obj["blinkSpeed"])
		attrfunc(obj.nickname, 'SetNumeric', obj["numeric"])
		attrfunc(obj.nickname, 'SetPassword', obj["password"])
		attrfunc(obj.nickname, 'SetMultiLine', obj["multiLine"])
		attrfunc(obj.nickname, 'SetHistoryLines', obj["historyLines"])
		attrfunc(obj.nickname, 'SetAutoFocus', obj["autoFocus"])
		attrfunc(obj.nickname, 'SetAltArrowKeyMode', obj["ignoreArrows"])
		attrfunc(obj.nickname, 'SetCountInvisibleLetters', obj["countInvisibleLetters"])
		return ret
	end
--[[ no Lua equivalent
types["FontFamilyType"] = function(obj, parent, grandparent)
		reqattrfunc(parent, '', quote(obj["name"]))
	end
types["FontMemberType"] = function(obj, parent, grandparent)
	end
]]
types["FontStringType"] = function(obj, parent, grandparent)
		io.write("local ", obj.nickname, " = ", obj.nickname, " or ")
		reqattrfunc(parent, "CreateFontString", quote(obj.name), quote(obj.level) or "curLevel", quote(obj.inherits))
		types["LayoutFrameType"](obj, parent, grandparent)
		for i, v in ipairs(obj) do
			if v:tag() == "Color" then attrfunc(parent, 'SetTextColor', types["ColorType"](v)) end
		end
		attrfunc(obj.nickname, 'SetFontObject', quote(obj["font"]))
		--attrfunc(obj.nickname, '', obj["bytes"]) no Lua equivalent for FontStrings, used in chat frame and friends list
		attrfunc(obj.nickname, 'SetText', quote(obj["text"]))
		attrfunc(obj.nickname, 'SetSpacing', obj["spacing"])
		--attrfunc(obj.nickname, '', quote(obj["outline"])) no direct Lua equivalent, unused in FrameXML
		--attrfunc(obj.nickname, '', obj["monochrome"]) no direct Lua equivalent, unused in FrameXML
		attrfunc(obj.nickname, 'SetNonSpaceWrap', obj["nonspacewrap"])
		attrfunc(obj.nickname, 'SetWordWrap', obj["wordwrap"])
		attrfunc(obj.nickname, 'SetJustifyV', quote(obj["justifyV"]))
		attrfunc(obj.nickname, 'SetJustifyH', quote(obj["justifyH"] or obj["JustifyH"]))
		attrfunc(obj.nickname, 'SetMaxLines', obj["maxLines"])
		attrfunc(obj.nickname, 'SetIndentedWordWrap', obj["indented"])
		return true
	end
types["FontType"] = function(obj, parent, grandparent)
		io.write("local ", obj.nickname, " = ", obj.nickname, " or ")
		reqattrfunc(nil, "CreateFont")
		attrfunc(obj.nickname, 'SetFontObject', quote(obj["inherits"]))
		local flags = obj["outline"] and obj["monochrome"] and obj["outline"]..",".."MONOCHROME" or obj["outline"] or obj["monochrome"]
		attrfunc(obj.nickname, 'SetFont', quote(obj["font"]), obj["height"], quote(flags))
		attrfunc(obj.nickname, 'SetSpacing', obj["spacing"])
		attrfunc(obj.nickname, 'SetJustifyV', quote(obj["justifyV"]))
		attrfunc(obj.nickname, 'SetJustifyH', quote(obj["justifyH"]))
		return true
	end
types["FrameType"] = function(obj, parent, grandparent)
		io.write("local ", obj.nickname, " = ", obj.nickname, " or ")
		reqattrfunc(nil, "CreateFrame", quote(obj:tag()), obj.virtual == "true" and "name" or quote(obj.name), quote(obj.parent) or parent, quote(obj.inherits))
		types["LayoutFrameType"](obj, parent, grandparent)
		attrfunc(obj.nickname, 'SetAlpha', obj["alpha"])
		attrfunc(obj.nickname, 'SetToplevel', obj["toplevel"])
		attrfunc(obj.nickname, 'SetToplevel', obj["topLevel"]) --invalid according to schema, but used in FrameXML
		--attrfunc(obj.nickname, '', obj["useParentLevel"]) no Lua equivalent, used all over FramexML
		attrfunc(obj.nickname, 'SetMovable', obj["movable"])
		attrfunc(obj.nickname, 'SetResizable', obj["resizable"])
		attrfunc(obj.nickname, 'SetFrameStrata', quote(obj["frameStrata"]))
		attrfunc(obj.nickname, 'SetFrameLevel', obj["frameLevel"])
		attrfunc(obj.nickname, 'SetID', obj["id"])
		attrfunc(obj.nickname, 'EnableMouse', obj["enableMouse"])
		attrfunc(obj.nickname, 'EnableKeyboard', obj["enableKeyboard"])
		attrfunc(obj.nickname, 'SetClampedToScreen', obj["clampedToScreen"])
		--attrfunc(obj.nickname, '', obj["protected"]) no Lua equivalent for obvious reasons
		attrfunc(obj.nickname, 'SetDepth', obj["depth"])
		attrfunc(obj.nickname, 'SetDontSavePosition', obj["dontSavePosition"])
		attrfunc(obj.nickname, 'SetPropagateKeyboardInput', obj["propagateKeyboardInput"])
		--attrfunc(obj.nickname, '', obj["forceAlpha"]) no Lua equivalent, used in party frames
		return true
	end
types["GameTooltipType"] = function(obj, parent, grandparent)
		return types["FrameType"](obj, parent, grandparent)
	end
types["GradientType"] = function(obj, parent, grandparent)
		local minR, minG, minB, minA, maxR, maxG, maxB, maxA
		for i, v in ipairs(obj) do
			if v:tag() == "MinColor" then minR, minG, minB, minA = types["ColorType"](v)
			elseif v:tag() == "MaxColor" then maxR, maxG, maxB, maxA = types["ColorType"](v) end
		end
		if minA or maxA then
			attrfunc(parent, 'SetGradientAlpha', quote(obj["orientation"]) or "HORIZONTAL",
				minR, minG, minB, minA or "1.0",
				maxR, maxG, maxB, maxA or "1.0")
		else
			attrfunc(parent, 'SetGradient', quote(obj["orientation"]) or "HORIZONTAL",
				minR, minG, minB,
				maxR, maxG, maxB)
		end
	end
types["Inset"] = function(obj, parent, grandparent)
		local l, r, t, b
		for i, v in ipairs(obj) do
			l, r, t, b = types["Inset"](v)
		end
		return tonumber(obj["left"]) or l, tonumber(obj["right"]) or r, tonumber(obj["top"]) or t, tonumber(obj["bottom"]) or b
	end
--[[ no Lua equivalent
types["KeyValuesType"] = function(obj, parent, grandparent)
	end
types["KeyValueType"] = function(obj, parent, grandparent)
		reqattrfunc(parent, '', quote(obj["key"]))
		reqattrfunc(parent, '', quote(obj["value"]))
		attrfunc(parent, '', quote(obj["keyType"]) or "string")
		attrfunc(parent, '', quote(obj["type"]) or "string")
	end
--]]
types["LayoutFrameType"] = function(obj, parent, grandparent)
		if parent then
			if obj["parentKey"] then print(parent.."["..quote(obj["parentKey"]).."] = "..obj.nickname) end
			if obj["parentArray"] then
				print(parent.."["..quote(obj["parentArray"]).."] = ",parent.."["..quote(obj["parentArray"]).."] or {}")
				print("table.insert("..parent.."["..quote(obj["parentArray"]).."], "..obj.nickname..")")
			end
		end

		if obj["setAllPoints"] or obj["setallpoints"] or obj["SetAllPoints"] then reqattrfunc(obj.nickname, 'SetAllPoints') end
		if obj["hidden"] == "true" then reqattrfunc(obj.nickname, 'Hide') end
		if obj["mixin"] then
			obj["mixin"]:gsub("[^,]+", function(name)
				print("for k, v in pairs("..name..") do")
				print(obj.nickname.."[k] = v")
				print("end")
			end)
		end
	end
types["MessageFrameType"] = function(obj, parent, grandparent)
		local ret = types["FrameType"](obj, parent, grandparent)
		for i, v in ipairs(obj) do
			if v:tag() == "TextInsets" then attrfunc(obj.nickname, 'SetTextInsets', types["Inset"](v)) end
		end
		attrfunc(obj.nickname, 'SetFontObject', quote(obj["font"]))
		attrfunc(obj.nickname, 'SetFading', obj["fade"])
		attrfunc(obj.nickname, 'SetFadeDuration', obj["fadeDuration"])
		attrfunc(obj.nickname, 'SetTimeVisible', obj["displayDuration"])
		attrfunc(obj.nickname, 'SetInsertMode', quote(obj["insertMode"]))
		return ret
	end
types["MinimapType"] = function(obj, parent, grandparent)
		return types["FrameType"](obj, parent, grandparent)
		--attrfunc(parent, '', quote(obj["minimapArrowModel"]))
		--attrfunc(parent, '', quote(obj["minimapPlayerModel"]))
	end
types["ModelType"] = function(obj, parent, grandparent)
		local ret = types["FrameType"](obj, parent, grandparent)
		attrfunc(obj.nickname, 'SetModel', quote(obj["file"]))
		attrfunc(obj.nickname, 'SetModelScale', obj["scale"])
		attrfunc(obj.nickname, 'SetFogNear', obj["fogNear"])
		attrfunc(obj.nickname, 'SetFogFar', obj["fogFar"])
		attrfunc(obj.nickname, 'SetGlow', obj["glow"])
		--attrfunc(obj.nickname, '', quote(obj["drawLayer"])) no Lua equivalent, unused in FrameXML
		return ret
	end
types["MovieFrameType"] = function(obj, parent, grandparent)
		return types["FrameType"](obj, parent, grandparent)
	end
types["PathType"] = function(obj, parent, grandparent)
		local ret = types["AnimationType"](obj, parent, grandparent)
		attrfunc(obj.nickname, 'SetCurve', quote(obj["curve"]))
		return ret
	end
types["PlayerModelType"] = function(obj, parent, grandparent)
		return types["ModelType"](obj, parent, grandparent)
	end
types["QuestPOIFrameType"] = types["BlobType"]
types["RotationType"] = function(obj, parent, grandparent)
		local ret = types["AnimationType"](obj, parent, grandparent)
		attrfunc(obj.nickname, 'SetDegrees', obj["degrees"])
		attrfunc(obj.nickname, 'SetRadians', obj["radians"])
		return ret
	end
types["ScaleType"] = function(obj, parent, grandparent)
		local ret = types["AnimationType"](obj, parent, grandparent)
		attrfunc(obj.nickname, 'SetScale', obj["scaleX"] or 1, obj["scaleY"] or 1)
		attrfunc(obj.nickname, 'SetFromScale', obj["fromScaleX"], obj["fromScaleY"]) --invalid according to schema, but used in FrameXML
		attrfunc(obj.nickname, 'SetToScale', obj["toScaleX"], obj["toScaleY"]) --invalid according to schema, but used in FrameXML
		return ret
	end
types["ScenarioPOIFrameType"] = types["BlobType"]
types["ScriptType"] = function(obj, parent, grandparent)
		if obj["inherit"] then
			io.write("local s = ")
			attrfunc(obj.nickname, string.format('GetScript(%q)', obj:tag()))
		end
		if obj["function"] == '"' then obj["function"] = nil end --workaround for LuaXML bug
		local func = string.format("function(%s)\n\t%s%s%s\nend", scriptargs[obj:tag()],
			obj["inherit"] == "append" and string.format("s(self, %s)\n\t", scriptargs[obj:tag()]) or "",
			obj["function"] and obj["function"].."()" or (obj[1] and obj[1]:gsub("\r\n", "\n\t")) or "",
			obj["inherit"] == "prepend" and string.format("s(self, %s)\n\t", scriptargs[obj:tag()]) or "")
		attrfunc(parent, "SetScript", quote(obj:tag()), obj["inherit"] and func or obj["function"] or func)
	end
types["ScrollFrameType"] = function(obj, parent, grandparent)
		return types["FrameType"](obj, parent, grandparent)
	end
types["ScrollingMessageFrameType"] = function(obj, parent, grandparent)
		local ret = types["FrameType"](obj, parent, grandparent)
		for i, v in ipairs(obj) do
			if v:tag() == "TextInsets" then attrfunc(obj.nickname, 'SetTextInsets', types["Inset"](v)) end
		end
		attrfunc(obj.nickname, 'SetFontObject', quote(obj["font"]))
		attrfunc(obj.nickname, 'SetFading', obj["fade"])
		attrfunc(obj.nickname, 'SetFadeDuration', obj["fadeDuration"])
		attrfunc(obj.nickname, 'SetTimeVisible', obj["displayDuration"])
		attrfunc(obj.nickname, 'SetInsertMode', quote(obj["insertMode"]))
		attrfunc(obj.nickname, 'SetMaxLines', obj["maxLines"])
		return ret
	end
types["ShadowType"] = function(obj, parent, grandparent)
		for i, v in ipairs(obj) do
			if v:tag() == "Color" then attrfunc(parent, 'SetShadowColor', types["ColorType"](v))
			elseif v:tag() == "Offset" then attrfunc(parent, 'SetShadowOffset', types["Dimension"](v)) end
		end
	end
types["SimpleHTMLType"] = function(obj, parent, grandparent)
		local ret = types["FrameType"](obj, parent, grandparent)
		attrfunc(obj.nickname, 'SetFontObject', quote(obj["font"]))
		--attrfunc(obj.nickname, '', quote(obj["file"])) no Lua equivalent
		attrfunc(obj.nickname, 'SetHyperlinkFormat', quote(obj["hyperlinkFormat"]))
		return ret
	end
types["SliderType"] = function(obj, parent, grandparent)
		local ret = types["FrameType"](obj, parent, grandparent)
		--attrfunc(obj.nickname, '', quote(obj["drawLayer"])) no Lua equivalent, not used in FrameXML
		attrfunc(obj.nickname, 'SetMinMaxValues', obj["minValue"], obj["maxValue"])
		attrfunc(obj.nickname, 'SetValue', obj["defaultValue"])
		attrfunc(obj.nickname, 'SetValueStep', obj["valueStep"])
		attrfunc(obj.nickname, 'SetOrientation', quote(obj["orientation"]))
		attrfunc(obj.nickname, 'SetObeyStepOnDrag', obj["obeyStepOnDrag"]) --invalid according to schema, but used in FrameXML
		attrfunc(obj.nickname, 'SetStepsPerPage', obj["stepsPerPage"]) --invalid according to schema, but used in FrameXML
		return ret
	end
types["StatusBarType"] = function(obj, parent, grandparent)
		local ret = types["FrameType"](obj, parent, grandparent)
		--attrfunc(parent, '', quote(obj["drawLayer"])) no Lua equivalent, used all over FrameXML
		attrfunc(obj.nickname, 'SetMinMaxValues', obj["minValue"], obj["maxValue"])
		attrfunc(obj.nickname, 'SetValue', obj["defaultValue"])
		attrfunc(obj.nickname, 'SetOrientation', quote(obj["orientation"]))
		attrfunc(obj.nickname, 'SetRotatesTexture', obj["rotatesTexture"])
		attrfunc(obj.nickname, 'SetReverseFill', obj["reverseFill"])
		return ret
	end
types["TabardModelType"] = function(obj, parent, grandparent)
		return types["PlayerModelType"](obj, parent, grandparent)
	end
types["TaxiRouteFrameType"] = function(obj, parent, grandparent)
		return types["FrameType"](obj, parent, grandparent)
	end
types["TextureType"] = function(obj, parent, grandparent)
		io.write("local ", obj.nickname, " = ", obj.nickname, " or ")
		reqattrfunc(parent, "CreateTexture", quote(obj.name), quote(obj.level) or "curLevel", quote(obj.inherits), obj.textureSubLevel or "curSubLevel")
		types["LayoutFrameType"](obj, parent, grandparent)
		for i, v in ipairs(obj) do
			if v:tag() == "Color" then attrfunc(parent, 'SetVertexColor', types["ColorType"](v)) end
		end
		attrfunc(obj.nickname, 'SetTexture', quote(obj["file"]))
		attrfunc(obj.nickname, 'SetMask', quote(obj["mask"]))
		attrfunc(obj.nickname, 'SetBlendMode', quote(obj["alphaMode"]))
		attrfunc(obj.nickname, 'SetAlpha', obj["alpha"])
		-- attrfunc(obj.nickname, '', obj["forceAlpha"]) no Lua equivalent, used in compact raid frames
		attrfunc(obj.nickname, 'SetNonBlocking', obj["nonBlocking"])
		attrfunc(obj.nickname, 'SetHorizTile', obj["horizTile"])
		attrfunc(obj.nickname, 'SetVertTile', obj["vertTile"])
		attrfunc(obj.nickname, 'SetAtlas', quote(obj["atlas"]), obj["useAtlasSize"])
		return true
	end
types["TranslationType"] = function(obj, parent, grandparent)
		local ret = types["AnimationType"](obj, parent, grandparent)
		attrfunc(parent, 'SetOffset', obj["offsetX"] or 0, obj["offsetY"] or 0)
		return ret
	end
types["UnitButtonType"] = function(obj, parent, grandparent)
		return types["ButtonType"](obj, parent, grandparent)
	end
types["Value"] = function(obj, parent, grandparent)
		local val
		for i, v in ipairs(obj) do
			val = types["Value"](v)
		end
		return tonumber(obj["val"]) or val
	end
types["WorldFrameType"] = function(obj, parent, grandparent)
		return types["FrameType"](obj, parent, grandparent)
	end
tags = {
	["Include"] = function(obj, parent, grandparent)
		parse(package.loaded.xml.load(obj.file:gsub("\\", "/")))
	end,
	["Script"] = function(obj, parent, grandparent)
		if obj.file then
			local f = io.open(obj.file:gsub("\\", "/"), "r")
			if f then
				print(f:read("*all"))
				f:close()
			end
		else
			print(obj[1])
		end
	end,
	["Alpha"] = types["AlphaType"],
	["Anchor"] = types["Anchor"],
	["Animation"] = types["AnimationType"],
	["AnimationGroup"] = types["AnimationGroupType"],
	["ArchaeologyDigSiteFrame"] = types["BlobType"],
	["Attribute"] = types["AttributeType"],
	["Attributes"] = types["AttributesType"],
	["Backdrop"] = types["BackdropType"],
	["BackgroundInsets"] = types["Inset"],
	["BarColor"] = function(obj, parent, grandparent)
		attrfunc(parent, "SetStatusBarTexture", types["ColorType"](obj, parent, grandparent))
	end,
	["BarTexture"] = function(obj, parent, grandparent)
		local ret = types["TextureType"](obj, parent, grandparent)
		attrfunc(parent, "SetStatusBarTexture", obj.nickname)
		return ret
	end,
	["BorderColor"] = types["ColorType"],
	["Browser"] = types["BrowserType"],
	["Button"] = types["ButtonType"],
	["ButtonText"] = function(obj, parent, grandparent)
		local ret = types["FontStringType"](obj, parent, grandparent)
		attrfunc(parent, "SetFontString", obj.nickname)
		return ret
	end,
	["CheckButton"] = types["CheckButtonType"],
	["CheckedTexture"] = function(obj, parent, grandparent)
		local ret = types["TextureType"](obj, parent, grandparent)
		attrfunc(parent, "SetCheckedTexture", obj.nickname)
		return ret
	end,
	["CinematicModel"] = types["CinematicModelType"],
	["Color"] = types["ColorType"],
	["ColorSelect"] = types["ColorSelectType"],
	["ColorValueTexture"] = function(obj, parent, grandparent)
		local ret = types["TextureType"](obj, parent, grandparent)
		attrfunc(parent, "SetColorValueTexture", obj.nickname)
		return ret
	end,
	["ColorValueThumbTexture"] = function(obj, parent, grandparent)
		local ret = types["TextureType"](obj, parent, grandparent)
		attrfunc(parent, "SetColorValueThumbTexture", obj.nickname)
		return ret
	end,
	["ColorWheelTexture"] = function(obj, parent, grandparent)
		local ret = types["TextureType"](obj, parent, grandparent)
		attrfunc(parent, "SetColorWheelTexture", obj.nickname)
		return ret
	end,
	["ColorWheelThumbTexture"] = function(obj, parent, grandparent)
		local ret = types["TextureType"](obj, parent, grandparent)
		attrfunc(parent, "SetColorWheelThumbTexture", obj.nickname)
		return ret
	end,
	["ControlPoint"] = types["ControlPointType"],
	["ControlPoints"] = types["ControlPointsType"],
	["Cooldown"] = types["CooldownType"],
	["DisabledCheckedTexture"] = function(obj, parent, grandparent)
		local ret = types["TextureType"](obj, parent, grandparent)
		attrfunc(parent, "SetDisabledCheckedTexture", obj.nickname)
		return ret
	end,
	--["DisabledColor"] = types["ColorType"], no Lua equivalent, not used in FrameXML
	["DisabledFont"] = function(obj, parent, grandparent)
		attrfunc(parent, "SetDisabledFontObject", types["ButtonStyleType"](obj))
	end,
	["DisabledTexture"] = function(obj, parent, grandparent)
		local ret = types["TextureType"](obj, parent, grandparent)
		attrfunc(parent, "SetDisabledTexture", obj.nickname)
		return ret
	end,
	["DressUpModel"] = types["DressUpModelType"],
	["EdgeSize"] = types["Value"],
	["EditBox"] = types["EditBoxType"],
	["FogColor"] = function(obj, parent, grandparent)
		attrfunc(parent, "SetFogColor", types["ColorType"](obj, parent, grandparent))
	end,
	["Font"] = types["FontType"],
	--["FontFamily"] = types["FontFamilyType"], no Lua equivalent
	["FontHeight"] = function(obj, parent, grandparent)
		attrfunc(parent, "SetTextHeight", types["Value"](obj)) --not exact Lua equivalent, not used in FrameXML
	end,
	["FontString"] = types["FontStringType"],
	["FontStringHeader1"] = types["FontStringType"],
	["FontStringHeader2"] = types["FontStringType"],
	["FontStringHeader3"] = types["FontStringType"],
	["Frame"] = types["FrameType"],
	["GameTooltip"] = types["GameTooltipType"],
	["Gradient"] = types["GradientType"],
	--["HighlightColor"] = types["ColorType"], no Lua equivalent, not used in FrameXML
	["HighlightFont"] = function(obj, parent, grandparent)
		attrfunc(parent, "SetHighlightFontObject", types["ButtonStyleType"](obj))
	end,
	["HighlightTexture"] = function(obj, parent, grandparent)
		local ret = types["TextureType"](obj, parent, grandparent)
		attrfunc(parent, "SetHighlightTexture", obj.nickname)
		return ret
	end,
	["HitRectInsets"] = types["Inset"],
	--[[ no Lua equivalent
	["KeyValue"] = types["KeyValueType"],
	["KeyValues"] = types["KeyValuesType"],
	]]
	["Layer"] = function(obj, parent, grandparent)
		print("curLevel = ", quote(obj["level"]) or "ARTWORK")
		print("curSubLevel = ", obj["textureSubLevel"] or obj["textureSublevel"] or 0)
	end,
	["Layers"] = function(obj, parent, grandparent)
		print("local curLevel")
		print("local curSubLevel")
	end,
	["LayoutFrame"] = types["LayoutFrameType"],
	["MaxColor"] = types["ColorType"],
	["maxResize"] = function(obj, parent, grandparent)
		attrfunc(parent, "SetMaxResize", types["Dimension"](obj))
	end,
	--["Member"] = types["FontMemberType"], no Lua equivalent
	["MessageFrame"] = types["MessageFrameType"],
	["MinColor"] = types["ColorType"],
	["Minimap"] = types["MinimapType"],
	["minResize"] = function(obj, parent, grandparent)
		attrfunc(parent, "SetMinResize", types["Dimension"](obj))
	end,
	["Model"] = types["ModelType"],
	["ModelFFX"] = types["ModelType"],
	["MovieFrame"] = types["MovieFrameType"],
	--["NormalColor"] = types["ColorType"], no Lua equivalent, not used in FrameXML
	["NormalFont"] = function(obj, parent, grandparent)
		attrfunc(parent, "SetNormalFontObject", types["ButtonStyleType"](obj))
	end,
	["NormalTexture"] = function(obj, parent, grandparent)
		local ret = types["TextureType"](obj, parent, grandparent)
		attrfunc(parent, "SetNormalTexture", obj.nickname)
		return ret
	end,
	["OffScreenFrame"] = types["FrameType"],
	--["Offset"] = types["Dimension"],
	["Origin"] = types["AnimOriginType"],
	["Path"] = types["PathType"],
	["PlayerModel"] = types["PlayerModelType"],
	["PushedTextOffset"] = function(obj, parent, grandparent)
		attrfunc(parent, "SetPushedTextOffset", types["Dimension"](obj))
	end,
	["PushedTexture"] = function(obj, parent, grandparent)
		local ret = types["TextureType"](obj, parent, grandparent)
		attrfunc(parent, "SetPushedTexture", obj.nickname)
		return ret
	end,
	["QuestPOIFrame"] = types["BlobType"],
	["Rect"] = function(obj, parent, grandparent) --invalid according to schema, but used in FrameXML
		return obj["ULx"] or 0, obj["ULy"] or 0, obj["LLx"] or 0, obj["LLy"] or 0, obj["ULx"] or 0, obj["URy"] or 0, obj["LRx"] or 0, obj["LRy"] or 0
	end,
	["Rotation"] = types["RotationType"],
	["Scale"] = types["ScaleType"],
	["ScenarioPOIFrame"] = types["BlobType"],
	["Scripts"] = types["ScriptsType"],
	["ScrollChild"] = function(obj, parent, grandparent)
		attrfunc(parent, "SetScrollChild", obj.nickname)
	end,
	["ScrollFrame"] = types["ScrollFrameType"],
	["ScrollingMessageFrame"] = types["ScrollingMessageFrameType"],
	--["ScopedModifier"] = , invalid according to schema, no Lua equivalent for obvious reasons
	["Shadow"] = types["ShadowType"],
	["SimpleHTML"] = types["SimpleHTMLType"],
	["Size"] = function(obj, parent, grandparent)
		local x, y = types["Dimension"](obj)
		attrfunc(parent, "SetWidth", x)
		attrfunc(parent, "SetHeight", y)
	end,
	["Slider"] = types["SliderType"],
	["StatusBar"] = types["StatusBarType"],
	["SwipeTexture"] = function(obj, parent, grandparent) --invalid according to schema, but used in FrameXML
		local r, g, b, a
		for i, v in ipairs(obj) do
			r, g, b, a = types["ColorType"](v)
		end
		attrfunc(parent, "SetSwipeTexture", quote(obj["file"]), r, g, b, a)
	end,
	["TabardModel"] = types["TabardModelType"],
	["TaxiRouteFrame"] = types["TaxiRouteFrameType"],
	["TexCoords"] = function(obj, parent, grandparent)
		for i, v in ipairs(obj) do
			attrfunc(parent, 'SetTexCoord', types["Inset"](v)) --invalid according to schema, but used in FrameXML
		end
		reqattrfunc(parent, 'SetTexCoord', types["Inset"](obj))
	end,
	["TextInsets"] = types["Inset"],
	["Texture"] = types["TextureType"],
	["ThumbTexture"] =  function(obj, parent, grandparent)
		local ret = types["TextureType"](obj, parent, grandparent)
		attrfunc(parent, "SetThumbTexture", obj.nickname)
		return ret
	end,
	["TileSize"] = types["Value"],
	["TitleRegion"] = types["LayoutFrameType"],
	["Translation"] = types["TranslationType"],
	["WorldFrame"] = types["WorldFrameType"],
}


for k, v in pairs(scriptargs) do
	tags[k] = types["ScriptType"]
end

------------------------------------------------------

local virtuals = {}

function parse(tree, parent, parentname, grandparent)
	if type(tree) == "table" then
		tree.parentKey = tree.parentKey or tree.parentkey --invalid according to schema, but used in FrameXML
		tree.nickname = ((parentname or "")..tree:tag()..(tree.nickname or "")):gsub("[^%w_]","_")
		if tree.virtual == "true" and tree.name then
			tree.name = tree.name:gsub("[^%w_]","_")
			virtuals[tree.name] = true
			print(string.format("local function %s(name, parent)", tree.name))
			tree.nickname = "new"..tree.name
			parent = "parent"
		elseif tree.name then
			tree.name = rel(tree.name, parentname or "")
		end
		if tree.inherits and virtuals[tree.inherits] and tree.virtual ~= "true" then
			print(string.format("local %s = %s(%s, %s)", tree.nickname, tree.inherits, quote(tree.name) or "nil", parent or "UIParent"))
		end
		local new
		if tags[tree:tag()] then
			new = tags[tree:tag()](tree, parent, grandparent)
		end
		for i, v in ipairs(tree) do
			if type(v) == "table" then
				--if new then print("do") end --useful for very large files, to avoid reaching 200 local variable limit
				v.level = tree.level or v.level
				v.textureSubLevel = tree.textureSubLevel or v.textureSubLevel
				v.nickname = i
				parse(v, new and tree.nickname or parent, new and tree.name or parentname, new and parent or grandparent)
				--if new then print("end --do") end --useful for very large files
			end
		end
		if tree.virtual == "true" and tree.name then
			print("return new"..tree.name.."\nend --local function")
		end
	end
end

parse(package.loaded.xml.load(arg[1]), "UIParent", "UIParent")
