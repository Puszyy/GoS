if myHero.charName ~= "Lux" then return end

require "OpenPredict"

local Kugel = {}

menu = MenuConfig("LUX", "Illuminati Lux by Puszyy")
        menu:SubMenu("combo", "Combo")
                menu.combo:Boolean("useQ", "Use Q", true)
				menu.combo:Boolean("useE", "Use E", true)
				menu.combo:Boolean("useR", "Use R (KillSteal)", true)
				menu.combo:Boolean("useRR", "Use R Configuration", false)
				menu.combo:Key("rkey", "Key to use R", string.byte("U"))
		menu:SubMenu("rconfig", "R Configuration")
				menu.rconfig:Slider('X','Minimum Enemies R', 2, 0, 5, 1)
				menu.rconfig:Slider('HP','Enemy HP Manager R', 50, 0, 100, 5)
        menu:SubMenu("pred", "Prediction")
                menu.pred:Slider("predQ", "Q Hitchance",90,0,100,1)
                menu.pred:Slider("predE", "E Hitchance",90,0,100,1)
                menu.pred:Slider("predR", "R Hitchance",45,0,100,1)
		menu:SubMenu("harass", "Harass")
		        menu.harass:Boolean("useQ", "Use Q", true)
				menu.harass:Boolean("useE", "Use E", true)
		menu:SubMenu("Misc", "Misc")
				menu.Misc:Boolean('Items', 'Use Items', true)
				menu.Misc:Boolean('LvlUp', 'Auto Level Up', true)
				menu.Misc:DropDown('AutoLvlUp', 'Level Table', 5, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})

local qHitchance =  menu.pred.predQ:Value() * 0.01
local eHitchance =  menu.pred.predE:Value() * 0.01
local rHitchance =  menu.pred.predR:Value() * 0.01

local Q = {delay = 0.25, speed = 1200, width = 70, range = 1300}
local E = {range = 1100, delay = 0.25, speed = 1300, radius = 115}
local R = {speed = math.huge, delay = 1, range = 3340, width = 200}

OnTick(function(myHero)
		KillSteal()
        qHitchance =  menu.pred.predQ:Value() * 0.01
        eHitchance =  menu.pred.predE:Value() * 0.01
        rHitchance =  menu.pred.predR:Value() * 0.01
		Combo()
		detE()
		Harass()
		Rkey()
end)

function Mode()
if _G.IOW_Loaded and IOW:Mode() then
return IOW:Mode()
elseif GoSWalkLoaded and GoSWalk.CurrentMode then
return ({"Combo", "Harass", "LaneClear", "LastHit"})[GoSWalk.CurrentMode+1]
end
end

OnProcessSpell(function(unit, spell)
if unit == myHero then
if spell.name:lower():find("attack") then
DelayAction(function()
AA = true
end, GetWindUp(myHero)+0.01)
else
AA = false
end
end
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
		DrawCircle(GetOrigin(myHero),1220,2,100,0xffff0000)
		for _,luxE in pairs(Kugel) do
		local drawPos = WorldToScreen(1,GetOrigin(myHero))
			local c = GetOrigin(luxE)
			DrawCircle(c.x,c.y-100,c.z, 345,2,0,0xffff0000)
		end
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

function Rkey()
if menu.combo.rkey:Value() and CanUseSpell(myHero,_R) == READY and ValidTarget(target, 3210) then
useR(target)
end
end

function Combo()
target = GetCurrentTarget()
if Mode() == "Combo" then
	if menu.combo.useQ:Value() and CanUseSpell(myHero,_Q) == READY and ValidTarget(target, 1220) then
		useQ(target)
	end
	if menu.combo.useE:Value() and CanUseSpell(myHero,_E) == READY and ValidTarget(target, 1100) then
		useE(target)
	end
	if menu.combo.useRR:Value() then
		if CanUseSpell(myHero,_R) == READY then
			if ValidTarget(target, 3210) then
				if 100*GetCurrentHP(target)/GetMaxHP(target) < menu.rconfig.HP:Value() then
					if EnemiesAround(myHero, 500) >= menu.rconfig.X:Value() then
					useR(target)
end
end
end
end
end
end
end

function Harass()
if Mode() == "Harass" then
for i,enemy in pairs(GetEnemyHeroes()) do
	if menu.harass.useE:Value() and CanUseSpell(myHero,_E) == READY and ValidTarget(enemy, 1100) then
	useE(target)
	end
	if menu.harass.useQ:Value() and CanUseSpell(myHero,_Q) == READY and ValidTarget(enemy, 1220) then
	useQ(target)
	end
	end
	end
end


function KillSteal()
for i,enemy in pairs(GetEnemyHeroes()) do
	if menu.combo.useR:Value() and CanUseSpell(myHero,_R) == READY and ValidTarget(enemy, 3210) and GotBuff(enemy, "LuxIlluminatingFraulein") > 0 then
		local dmgRP = CalcDamage(myHero, enemy, (((100*GetCastLevel(myHero,_R))+200) + (0.75*GetBonusAP(myHero)))+(10*(GetLevel(myHero)+10)+(0.20*(GetBonusAP(myHero)))),0)
			if GetCurrentHP(enemy)+GetMagicShield(enemy)+GetHPRegen(enemy)*2 < dmgRP then
				useR(enemy)
			end
	end
	if menu.combo.useR:Value() and CanUseSpell(myHero,_R) == READY and ValidTarget(enemy, 3210) then
		local dmgR = CalcDamage(myHero, enemy, ((100*GetCastLevel(myHero,_R))+200) + (0.75*GetBonusAP(myHero)),0)
			if GetCurrentHP(enemy)+GetMagicShield(enemy)+GetHPRegen(enemy)*2 < dmgR then
				useR(enemy)
			end
end
end
end

OnTick(function(myHero)
if menu.Misc.LvlUp:Value() then
if menu.Misc.AutoLvlUp:Value() == 1 then
leveltable = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
if GetLevelPoints(myHero) > 0 then
DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
end
elseif menu.Misc.AutoLvlUp:Value() == 2 then
leveltable = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
if GetLevelPoints(myHero) > 0 then
DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
end
elseif menu.Misc.AutoLvlUp:Value() == 3 then
leveltable = {_W, _Q, _E, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
if GetLevelPoints(myHero) > 0 then
DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
end
elseif menu.Misc.AutoLvlUp:Value() == 4 then
leveltable = {_W, _E, _Q, _W, _W, _R, _W, _E, _W, _E, _R, _E, _E, _Q, _Q, _R, _Q, _Q}
if GetLevelPoints(myHero) > 0 then
DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
end
elseif menu.Misc.AutoLvlUp:Value() == 5 then
leveltable = {_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}
if GetLevelPoints(myHero) > 0 then
DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
end
elseif menu.Misc.AutoLvlUp:Value() == 6 then
leveltable = {_E, _W, _Q, _E, _E, _R, _E, _W, _E, _W, _R, _W, _W, _Q, _Q, _R, _Q, _Q}
if GetLevelPoints(myHero) > 0 then
DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
end
end
end
end)

local lastaa = 0
local aawind = 0
local aaanim = 0
local lastmove = 0
local lastkillsteal = 0
local aarange = myHero.range + myHero.boundingRadius

OnProcessSpellAttack(function(unit, aa)
if unit.isMe then
lastaa = GetTickCount()
aawind = ( aa.windUpTime * 1000 ) - 30
aaanim = ( aa.animationTime * 1000 ) - 125
end
end)


function GetTarget(range, addBB)
local t = nil
local num = 10000000
for i, enemy in pairs(GetEnemyHeroes()) do
local r = addBB and range + enemy.boundingRadius or range
if ValidTarget(enemy, r) then
local mr = GetMagicResist(enemy) - GetMagicPenFlat(myHero)
mr = mr > 0 and GetMagicPenPercent(myHero) * mr or mr
local hp  = GetCurrentHP(enemy) + ( 2 * mr ) - ( 1.5*(GetBaseDamage(enemy) + GetBonusDmg(enemy)) ) - ( 1.5 * GetBonusAP(enemy) )
if hp < num then
num = hp
t = enemy
end
end
end
return t
end


OnTick(function(myHero)  
if Mode() == "Combo" then

BlockF7OrbWalk(true)

local checkT = GetTickCount()
local canMove = checkT > lastaa + aawind and checkT > lastmove + 125
local canAttack = checkT > lastaa + aaanim

local t = GetTarget(aarange, true)
if t ~= nil and canAttack then
AttackUnit(t)
elseif canMove then
lastmove = GetTickCount()
MoveToXYZ(GetMousePos())
end

else

BlockF7OrbWalk(false)

end
end)

PrintChat("<font color='#FF0000'>Illuminati Lux - <font color='#00FF00'>Loaded.")
PrintChat("<font color='#FF0000'>by <font color='#FF0000'>Pu<font color='#FFFF00'>sz<font color='#0000FF'>yy")
PrintChat("<font color='#FF00FF'>BETA Ver. 0.3")