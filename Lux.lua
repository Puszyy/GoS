if myHero.charName ~= "Lux" then return end

require "OpenPredict"

local Kugel = {}

menu = MenuConfig("LUX", "Illuminati Lux by Puszyy")
        menu:SubMenu("combo", "Combo")
                menu.combo:Key("ckey", "Combo Key", 32)
                menu.combo:Boolean("useQ", "Use Q", true)
				menu.combo:Boolean("useE", "Use E", true)
				menu.combo:Boolean("useR", "Use R (KillSteal)", true)
        menu:SubMenu("pred", "Prediction")
                menu.pred:Slider("predQ", "Q Hitchance",61,0,100,1)
                menu.pred:Slider("predE", "E Hitchance",61,0,100,1)
                menu.pred:Slider("predR", "R Hitchance",61,0,100,1)

local qHitchance =  menu.pred.predQ:Value() * 0.01
local eHitchance =  menu.pred.predE:Value() * 0.01
local rHitchance =  menu.pred.predR:Value() * 0.01

local Q = {delay = 0.25, speed = 1200, width = 130, range = 1300}
local E = {range = 1100, delay = 0.25, speed = 1300, radius = 345, width = 345}
local R = {speed = math.huge, delay = 1, range = 3340, width = 250}

OnTick(function(myHero)
        qHitchance =  menu.pred.predQ:Value() * 0.01
        eHitchance =  menu.pred.predE:Value() * 0.01
        rHitchance =  menu.pred.predR:Value() * 0.01
		Combo()
		detE()
		KillSteal()
end)

OnCreateObj(function(Object)
	if GetObjectBaseName(Object) == "Lux_Base_E_tar_aoe_sound" then
		table.insert(Kugel, Object)
		DelayAction(function() table.remove(Kugel, 1) end, 4)
	end
end)
OnDeleteObj(function(Object)
	if GetObjectBaseName(Object) == "Lux_Base_E_tar_nova" then
		table.remove(Kugel,1)
	end
end)

OnDraw(function(myHero)
		DrawCircle(GetOrigin(myHero),1300,2,100,0xffff0000)
		--[[for _,luxE in pairs(Kugel) do
		local drawPos = WorldToScreen(1,GetOrigin(myHero))
			DrawText(GetDistance(GetOrigin(luxE), target),drawPos.x, drawPos.y, 80, 0xffff0000)
			local c = GetOrigin(luxE)
			DrawCircle(c.x,100,c.z, 345,0,0,0xffff0000)
		end]]-- E object to target distance
end)
function useQ(target)
local specQ = GetPrediction(target, Q)
	if specQ then
		if specQ.hitChance < qHitchance then return false end
			if not specQ:mCollision(2) then
			CastSkillShot(_Q, specQ.castPos)
			end
	end
end

function useE(target)
local specE = GetCircularAOEPrediction(target, E)
	if specE then
		if specE.hitChance < eHitchance then return false end
			CastSkillShot(_E, specE.castPos)
	end
end

function useR(target)
local specR = GetLinearAOEPrediction(target, R)
	if specR then
		if specR.hitChance < rHitchance then return false end
			CastSkillShot(_R, specR.castPos)
	end
end

function detE(target)
for _,target in pairs(GetEnemyHeroes()) do
	for _,luxE in pairs(Kugel) do
		if math.sqrt( (luxE.x-target.pos.x)^2 + (luxE.z-target.pos.z)^2 ) < 345 then
			CastSpell(_E)
		end
	end
end
end

function Combo()
target = GetCurrentTarget()
if menu.combo.ckey:Value() then
	if menu.combo.useQ:Value() and CanUseSpell(myHero,_Q) == READY and ValidTarget(target, 1250) then
		useQ(target)
	end
	if menu.combo.useE:Value() and CanUseSpell(myHero,_E) == READY and ValidTarget(target, 1100) then
		useE(target)
	end
end
end

function KillSteal()
for i,enemy in pairs(GetEnemyHeroes()) do
	if menu.combo.useR:Value() and CanUseSpell(myHero,_R) == READY and ValidTarget(enemy, 3210) then
		dmgR = CalcDamage(myHero, enemy, ((100*GetCastLevel(myHero,_R))+200) + (0.75*GetBonusAP(myHero)),0)
			if GetCurrentHP(enemy)+GetMagicShield(enemy)+GetHPRegen(enemy)*2 < dmgR then
				useR(enemy)
			end
	end
end
end

PrintChat("<font color='#FF0000'>Illuminati Lux - <font color='#00FF00'>Loaded.")
PrintChat("<font color='#FF0000'>by <font color='#FF0000'>Pu<font color='#FFFF00'>sz<font color='#0000FF'>yy")
PrintChat("<font color='#FF00FF'>BETA Ver. 0.1")
PrintChat("<font color='#FF0000'>This script is WIP and runs only basic combo for now!")