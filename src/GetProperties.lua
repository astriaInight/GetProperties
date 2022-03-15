-- Written by @AstrialNight 3/14/22
-- Please note that this module may take a few seconds to start up on the first run.
-- This is due to the fact that it has to import the whole API dump first.

local APIDump = require(script.APIDump)

local API = APIDump.GetLatest()

local function HasProperty(Obj, PropName)
	local s, _ = pcall(function()
		local _ = Obj[PropName]
	end)
	
	return s
end

local function GetClass(ClassName)
	for _, c in pairs(API.Classes) do
		if c.Name ~= ClassName then continue end
		
		return c
	end
end

local function GetRelevantClasses(ClassName)
	local RelClasses = {}
	
	local CurClassName = ClassName
	
	while true do
		local Class = GetClass(CurClassName)
		local SuperClass = Class.Superclass
		
		table.insert(RelClasses, Class)
		
		CurClassName = SuperClass
		
		if SuperClass == "<<<ROOT>>>" then break end
	end
	
	return RelClasses
end

local function MemberHasTags(Member, TargetTags)
	if not Member.Tags then return false end

	for _, Tag in pairs(Member.Tags) do
		for _, TargetTag in pairs(TargetTags) do
			if Tag ~= TargetTag then continue end
			
			return true
		end
	end

	return false
end

local function GetClassProperties(ClassName)
	local Props = {}
	
	local ClassData = GetClass(ClassName)
	local Members = ClassData.Members
	
	for _, m in pairs(Members) do
		if m.MemberType ~= "Property" then continue end
		
		-- Excludes deprecated & read only properties
		if MemberHasTags(m, { "Deprecated", "ReadOnly" }) then continue end
		
		table.insert(Props, m.Name)
	end
	
	return Props
end

local function GetAllClassProperties(ClassName)
	local RelClasses = GetRelevantClasses(ClassName)
	
	local Props = {}
	
	for _, c in pairs(RelClasses) do
		for _, p in pairs(GetClassProperties(c.Name)) do
			table.insert(Props, p)
		end
	end
	
	return Props
end

-- This function excludes properties that are set to their defaults
local function GetInstanceProperties(Obj)
	local InsProps = {}
	
	local AllProps = GetAllClassProperties(Obj.ClassName)
	
	local TempObj = Instance.new(Obj.ClassName)
	
	for _, p in pairs(AllProps) do
		-- Prevents stray errors
		if not HasProperty(Obj, p) then continue end
		
		-- Exclude defaults
		if Obj[p] == TempObj[p] then continue end
		
		InsProps[p] = Obj[p]
	end
	
	TempObj:Destroy()
	
	return InsProps
end

return {
	GetClass = GetClass,
	GetRelevantClasses = GetRelevantClasses,
	GetClassProperties = GetClassProperties,
	GetAllClassProperties = GetAllClassProperties,
	GetInstanceProperties = GetInstanceProperties
}