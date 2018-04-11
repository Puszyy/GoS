local myHero = GetMyHero()
if GetObjectName(myHero) ~= "Irelia" then return end
require('Inspired')
require "OpenPredict"
local mainMenu = Menu("Quick Irelia by Puszyy")
-- Auto
mainMenu:Menu("Auto", "Auto")
mainMenu.Auto:Boolean("useE", "SEMI Use E", true)
mainMenu.Auto:Info("info","You must use first cast manually!")
mainMenu.Auto:Info("info2","Second blade will be auto casted")
mainMenu.Auto:Boolean("useW", "Auto W Cast at MAX DMG", true)
mainMenu.Auto:Info("info3","On QuickCast u need to hold key")
-- Combo
mainMenu:Menu("Combo", "Combo")
mainMenu.Combo:Boolean("useQ", "Use Q If Marked(Q reset)", true)
mainMenu.Combo:Boolean("useQA", "Use Q on ALL Marked Enms", false)
mainMenu.Combo:Slider("HP", "My %HP to use ^up", 10, 0, 100, 5)
mainMenu.Combo:Boolean("useQS", "Q near targets(Q reset)", true)
mainMenu.Combo:Slider("QMP","Mana-Manager", 10, 0, 100, 5)
mainMenu.Combo:Boolean("useR", "Use R on X enemies", true)
mainMenu.Combo:Key("fkey", "Press Key to Ult on target:", string.byte("U"))
-- Harass
mainMenu:Menu("Harass", "Harass")
mainMenu.Harass:Boolean("useW", "Use W", true)
mainMenu.Harass:Slider("HMP", "Mana-manager", 40, 0, 100, 5)
-- R Configuration
mainMenu:Menu("Rconfig", "R Configuration")
mainMenu.Rconfig:Slider('X','Minimum Enemies R', 1, 0, 5, 1)
mainMenu.Rconfig:Slider('HP','Enemy HP Manager R', 50, 0, 100, 5)
-- Farm
mainMenu:Menu("Farm", "Farm")
mainMenu.Farm:Boolean('useQ', 'Use Q', true)
mainMenu.Farm:Slider("FMP","Mana-Manager", 30, 0, 100, 5)
-- LaneClear
mainMenu:Menu("LaneClear", "LaneClear")
mainMenu.LaneClear:Boolean('useQ', 'Use Q', true)
mainMenu.LaneClear:Slider("LMP","Mana-Manager", 40, 0, 100, 5)
-- Killsteal
mainMenu:Menu("KillSteal", "KillSteal")
mainMenu.KillSteal:Boolean("useQ", "Use Q", true)
mainMenu.KillSteal:Boolean("useW", "Use W", true)
mainMenu.KillSteal:Boolean("useR", "Use R", true)
mainMenu.KillSteal:Boolean("block", "Block R KS during Combo", true)
-- Drawings
mainMenu:Menu("Drawings", "Drawings")
mainMenu.Drawings:Boolean('DrawQ', 'Draw Q Range', true)
mainMenu.Drawings:Boolean('DrawQC', 'Draw Q Killable', true)
mainMenu.Drawings:Boolean('DrawW', 'Draw W Range', true)
mainMenu.Drawings:Boolean('DrawE', 'Draw E Range', true)
mainMenu.Drawings:Boolean('DrawR', 'Draw R Range', true)
-- Misc
mainMenu:Menu("Misc", "Misc")
mainMenu.Misc:Boolean('Items', 'Use Items', true)
mainMenu.Misc:Boolean('LvlUp', 'Auto Level Up', true)
mainMenu.Misc:DropDown('AutoLvlUp', 'Level Table', 1, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})
mainMenu.Misc:Slider("predE", "E Hitchance",95,0,100,1)

local Duet = {}
local wObj = {}
local E = {range = math.huge, delay = 0.25, speed = math.huge, width = 100, radius = 50}
local eHitchance =  mainMenu.Misc.predE:Value() * 0.01

function Mode()
if _G.IOW_Loaded and IOW:Mode() then
return IOW:Mode()
elseif GoSWalkLoaded and GoSWalk.CurrentMode then
return ({"Combo", "Harass", "LaneClear", "LastHit"})[GoSWalk.CurrentMode+1]
end
end  --basename Irelia_Base_W_FullPower

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
	if GetObjectType(Object) == "AIMinionClient" and GetObjectBaseName(Object) == "Blade" and GetObjectName(Object) == "TestCubeRender10Vision" then
		table.insert(Duet, Object)
		DelayAction(function() table.remove(Duet, 1) end, 4)
	end
		if GetObjectBaseName(Object) == "Irelia_Base_W_FullPower" then
		table.insert(wObj, Object)
		DelayAction(function() table.remove(wObj, 1) end, 4)
	end
end)
OnDeleteObj(function(Object)
	if GetObjectType(Object) == "AIMinionClient" and GetObjectBaseName(Object) == "BreathBeamVision" and GetObjectName(Object) == "TestCubeRender10Vision" then
		table.remove(Duet,1)
	end
	if GetObjectBaseName(Object) == "Irelia_Base_W_Swipe_Empowered" then
		table.remove(wObj,1)
	end
end)

OnDraw(function(myHero)
		for _,Beam in pairs(Duet) do
			local c = GetOrigin(Beam)
			DrawCircle(c.x,c.y,c.z, 100,2,0,0xffff0000)
		end
		for _,chargeW in pairs(wObj) do
			local ce = GetOrigin(chargeW)
			DrawCircle(ce.x,ce.y,ce.z, 100,2,0,0xffff0000)
		end
local pos = GetOrigin(myHero)
if mainMenu.Drawings.DrawQ:Value() then DrawCircle(pos,650,2,25,0xffffff00) end
if mainMenu.Drawings.DrawW:Value() then DrawCircle(pos,825,1,25,0xff0000ff) end
if mainMenu.Drawings.DrawE:Value() then DrawCircle(pos,900,2,25,0xFFFF0000) end
if mainMenu.Drawings.DrawR:Value() then DrawCircle(pos,1000,1,25,0xffff0000) end
for _, minion in pairs(minionManager.objects) do
local tarC = GetOrigin(minion)
if CanUseSpell(myHero,_Q) == READY and ValidTarget(minion, 1200) then
local qDrawc0 = ((20*GetCastLevel(myHero,_Q)-10)+(0.7*(GetBaseDamage(myHero)+GetBonusDmg(myHero))))
local qDrawc = qDrawc0 + (qDrawc0*0.6)
local qDrawT = qDrawc + 2*GetBaseDamage(myHero)
local qDrawG = qDrawc + GetBaseDamage(myHero)
if GetItemSlot(myHero, 3078) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3078)) == READY then -- Trinity Force
if GetCurrentHP(minion)+GetDmgShield(minion) < qDrawT then
if mainMenu.Drawings.DrawQC:Value() then DrawCircle(tarC,100,2,25,0xFFFF0000)  DrawCircle(tarC,80,2,25,0xffffff00) end
end
elseif GetItemSlot(myHero, 3025) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3025)) == READY then
if GetCurrentHP(minion)+GetDmgShield(minion) < qDrawG then
if mainMenu.Drawings.DrawQC:Value() then DrawCircle(tarC,100,2,25,0xFFFF0000)  DrawCircle(tarC,80,2,25,0xffffff00) end
end
elseif GetItemSlot(myHero, 3057) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3057)) == READY then
if GetCurrentHP(minion)+GetDmgShield(minion) < qDrawG then
if mainMenu.Drawings.DrawQC:Value() then DrawCircle(tarC,100,2,25,0xFFFF0000)  DrawCircle(tarC,80,2,25,0xffffff00) end
end
elseif GetCurrentHP(minion)+GetDmgShield(minion) < qDrawc then
if mainMenu.Drawings.DrawQC:Value() then DrawCircle(tarC,100,2,25,0xFFFF0000)  DrawCircle(tarC,80,2,25,0xffffff00) end
end
end
end
for _, enemy in pairs(GetEnemyHeroes()) do
local tarC2 = GetOrigin(enemy)
if CanUseSpell(myHero,_Q) == READY and ValidTarget(enemy, 1200) then
local qDrawc2 = CalcDamage(myHero, enemy, ((20*GetCastLevel(myHero,_Q)-10)+(0.7*GetBaseDamage(myHero))),0)
if GetCurrentHP(enemy)+GetHPRegen(enemy)*2 < qDrawc2 then
if mainMenu.Drawings.DrawQC:Value() then DrawCircle(tarC2,100,2,25,0xFFFF0000)  DrawCircle(tarC2,80,2,25,0xffffff00)end
end
end
end
end)

OnTick(function(myHero)
target = GetCurrentTarget()
eHitchance =  mainMenu.Misc.predE:Value() * 0.01 
Combo()
KillSteal()
Farm()
Harass()
LaneClear()
Rkey()
	end)

function useW(target)
	if ValidTarget(target, 825) then
		if GotBuff(myHero, "ireliawdefense") > 0 then
			if mainMenu.Auto.useW:Value() then
						for _,chargeW in pairs(wObj) do
						--DelayAction(function() CastSkillShot2(_W,enemy) end, 0.75)
						CastSkillShot2(_W,target)
						end
			end
		end
	end
end	

function useWKS(target)
	if ValidTarget(target, 825) then
		if GotBuff(myHero, "ireliawdefense") > 0 then
			if mainMenu.KillSteal.useW:Value() then
						for _,chargeW in pairs(wObj) do
						--DelayAction(function() CastSkillShot2(_W,enemy) end, 0.75)
						CastSkillShot2(_W,target)
						end
			end
		end
	end
end	
	
function useWH(target)
	if ValidTarget(target, 825) then
		if GotBuff(myHero, "ireliawdefense") > 0 then
			if mainMenu.Harass.useW:Value() then
						for _,chargeW in pairs(wObj) do
						--DelayAction(function() CastSkillShot2(_W,enemy) end, 0.75)
						CastSkillShot2(_W,target)
						end
			end
		end
	end
end	
	
function Combo()
useW(target)
useWKS(target)
useWH(target)
if Mode() == "Combo" then
if mainMenu.Combo.useQ:Value() then
if GotBuff(target, "ireliamark") > 0 and CanUseSpell(myHero, _Q) and ValidTarget(target, 650) then
useQ(target)
end
end
for i,enemy in pairs(GetEnemyHeroes()) do
if mainMenu.Combo.useQA:Value() and 100*GetCurrentHP(myHero)/GetMaxHP(myHero) <= mainMenu.Combo.HP:Value() and GotBuff(enemy, "ireliamark") > 0 and CanUseSpell(myHero, _Q) and ValidTarget(enemy, 650) then
CastTargetSpell(enemy, _Q)
end
end
if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > mainMenu.Combo.QMP:Value() then
useQS()
end
end
if mainMenu.Auto.useE:Value() and CanUseSpell(myHero, _E) and ValidTarget(target, 900) then
useE(target)
end

if mainMenu.Combo.useR:Value() then
if CanUseSpell(myHero,_R) == READY then
if ValidTarget(target, 975) then
if 100*GetCurrentHP(target)/GetMaxHP(target) < mainMenu.Rconfig.HP:Value() then
if EnemiesAround(myHero, 975) >= mainMenu.Rconfig.X:Value() then
useR(target)
end
end
end
end
end
end

function Harass()
if Mode() == "Harass" then
if mainMenu.Harass.useW:Value() and CanUseSpell(myHero, _W) and ValidTarget(target, 650) and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > mainMenu.Harass.HMP:Value() then
CastSkillShot(_W, GetMousePos())
end
end
end
	
function useQ(target)
CastTargetSpell(target, _Q)
end

function useQS()
for _, enemy in pairs(GetEnemyHeroes()) do
if mainMenu.Combo.useQS:Value() and CanUseSpell(myHero, _Q) and ValidTarget(enemy, 250) and GotBuff(enemy, "ireliamark") > 0 then
CastTargetSpell(enemy, _Q)
end
end
for _, minion in pairs(minionManager.objects) do
if mainMenu.Combo.useQS:Value() and CanUseSpell(myHero, _Q) and ValidTarget(minion, 250) and EnemiesAround(myHero, 250) >= 1 then
local qsDMG0 = ((20*GetCastLevel(myHero,_Q)-10)+(0.7*(GetBaseDamage(myHero)+GetBonusDmg(myHero))))
local qsDMG = qsDMG0 + (qsDMG0*0.6)
local qsDMGT = qsDMG + 2*GetBaseDamage(myHero)
local qsDMGG = qsDMG + GetBaseDamage(myHero)
DelayAction(function()
if GetItemSlot(myHero, 3078) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3078)) == READY then
if GetCurrentHP(minion)+GetDmgShield(minion) < qsDMGT then
CastTargetSpell(minion, _Q)
end
end
if GetItemSlot(myHero, 3025) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3025)) == READY then
if GetCurrentHP(minion)+GetDmgShield(minion) < qsDMGG then
CastTargetSpell(minion, _Q)
end
end
if GetItemSlot(myHero, 3057) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3057)) == READY then
if GetCurrentHP(minion)+GetDmgShield(minion) < qsDMGG then
CastTargetSpell(minion, _Q)
end
end
 end, 0.25)
if GetCurrentHP(minion)+GetDmgShield(minion) < qsDMG then
CastTargetSpell(minion, _Q)
end
end
end
end

function useE(target)
for _,Beam in pairs(Duet) do
local beamPos = GetOrigin(Beam)
local specE = GetLinearAOEPrediction(target, E, beamPos)
	if specE then
		if specE.hitChance < eHitchance then return false end
			CastSkillShot(_E, specE.castPos.x, specE.castPos.y,specE.castPos.z)
			end
	end
end

function useR(target)
CastSkillShot(_R, GetOrigin(target))
end



function Rkey()
if mainMenu.Combo.fkey:Value() and CanUseSpell(myHero,_R) == READY and ValidTarget(target, 975) then
useR(target)
end
end

function Farm()
if Mode() == "Harass" then
for _, minion in pairs(minionManager.objects) do
if GetTeam(minion) == MINION_ENEMY then
if mainMenu.Farm.useQ:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > mainMenu.Farm.FMP:Value() and CanUseSpell(myHero,_Q) == READY and ValidTarget(minion, 650) then
local qhDMG0 = ((20*GetCastLevel(myHero,_Q)-10)+(0.7*(GetBaseDamage(myHero)+GetBonusDmg(myHero))))
local qhDMG = qhDMG0 + (qhDMG0*0.6)
local qhDMGT = qhDMG + 2*GetBaseDamage(myHero)
local qhDMGG = qhDMG + GetBaseDamage(myHero)
DelayAction(function()
if GetItemSlot(myHero, 3078) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3078)) == READY then
if GetCurrentHP(minion)+GetDmgShield(minion) < qhDMGT then
CastTargetSpell(minion, _Q)
end
end
if GetItemSlot(myHero, 3025) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3025)) == READY then
if GetCurrentHP(minion)+GetDmgShield(minion) < qhDMGG then
CastTargetSpell(minion, _Q)
end
end
if GetItemSlot(myHero, 3057) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3057)) == READY then
if GetCurrentHP(minion)+GetDmgShield(minion) < qhDMGG then
CastTargetSpell(minion, _Q)
end
end
 end, 0.25)
if GetCurrentHP(minion)+GetDmgShield(minion) < qhDMG then
CastTargetSpell(minion, _Q)
end
end
end
end
end

if Mode() == "LastHit" then
for _, minion in pairs(minionManager.objects) do
if GetTeam(minion) == MINION_ENEMY then
if mainMenu.Farm.useQ:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > mainMenu.Farm.FMP:Value() and CanUseSpell(myHero,_Q) == READY and ValidTarget(minion, 650) then
local qlDMG0 = ((20*GetCastLevel(myHero,_Q)-10)+(0.7*(GetBaseDamage(myHero)+GetBonusDmg(myHero))))
local qlDMG = qlDMG0 + (qlDMG0*0.6)
local qlDMGT = qlDMG + 2*GetBaseDamage(myHero)
local qlDMGG = qlDMG + GetBaseDamage(myHero)
DelayAction(function()
if GetItemSlot(myHero, 3078) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3078)) == READY then
if GetCurrentHP(minion)+GetDmgShield(minion) < qlDMGT then
CastTargetSpell(minion, _Q)
end
end
if GetItemSlot(myHero, 3025) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3025)) == READY then
if GetCurrentHP(minion)+GetDmgShield(minion) < qlDMGG then
CastTargetSpell(minion, _Q)
end
end
if GetItemSlot(myHero, 3057) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3057)) == READY then
if GetCurrentHP(minion)+GetDmgShield(minion) < qlDMGG then
CastTargetSpell(minion, _Q)
end
end
 end, 0.25)
if GetCurrentHP(minion)+GetDmgShield(minion) < qlDMG then
CastTargetSpell(minion, _Q)
end
end
end
end
end
end


function LaneClear()
if Mode() == "LaneClear" then
for _, minion in pairs(minionManager.objects) do
if GetTeam(minion) == MINION_ENEMY then
if mainMenu.LaneClear.useQ:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > mainMenu.LaneClear.LMP:Value() and CanUseSpell(myHero,_Q) == READY and ValidTarget(minion, 650) then
local qlcDMG0 = ((20*GetCastLevel(myHero,_Q)-10)+(0.7*(GetBaseDamage(myHero)+GetBonusDmg(myHero))))
local qlcDMG = qlcDMG0 + (qlcDMG0*0.6)
local qlcDMGT = qlcDMG + 2*GetBaseDamage(myHero)
local qlcDMGG = qlcDMG + GetBaseDamage(myHero)
DelayAction(function()
if GetItemSlot(myHero, 3078) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3078)) == READY then
if GetCurrentHP(minion)+GetDmgShield(minion) < qlcDMGT then
CastTargetSpell(minion, _Q)
end
end
if GetItemSlot(myHero, 3025) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3025)) == READY then
if GetCurrentHP(minion)+GetDmgShield(minion) < qlcDMGG then
CastTargetSpell(minion, _Q)
end
end
if GetItemSlot(myHero, 3057) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3057)) == READY then
if GetCurrentHP(minion)+GetDmgShield(minion) < qlcDMGG then
CastTargetSpell(minion, _Q)
end
end
 end, 0.25)
if GetCurrentHP(minion)+GetDmgShield(minion) < qlcDMG then
CastTargetSpell(minion, _Q)
end
end
end
end
end
end

function KillSteal()
for i,enemy in pairs(GetEnemyHeroes()) do
if mainMenu.KillSteal.useQ:Value() and CanUseSpell(myHero,_Q) == READY and ValidTarget(enemy, 650) then
local qksDMG = CalcDamage(myHero, enemy, ((20*GetCastLevel(myHero,_Q)-10)+(0.7*(GetBaseDamage(myHero)+GetBonusDmg(myHero)))),0)
local qksDMGT = qksDMG + CalcDamage(myHero, enemy, (2*GetBaseDamage(myHero)),0)
local qksDMGG = qksDMG + CalcDamage(myHero, enemy, (GetBaseDamage(myHero)),0)
if GetItemSlot(myHero, 3078) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3078)) == READY then
if GetCurrentHP(enemy)+GetHPRegen(enemy)*2 < qksDMGT then
useQ(enemy)
end
end
if GetItemSlot(myHero, 3025) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3025)) == READY then
if GetCurrentHP(enemy)+GetHPRegen(enemy)*2 < qksDMGG then
useQ(enemy)
end
end
if GetItemSlot(myHero, 3057) >= 1 and CanUseSpell(myHero, GetItemSlot(myHero, 3057)) == READY then
if GetCurrentHP(enemy)+GetHPRegen(enemy)*2 < qksDMGG then
useQ(enemy)
end
end
if GetCurrentHP(enemy)+GetHPRegen(enemy)*2 < qksDMG then
useQ(enemy)
end
end
if not mainMenu.KillSteal.block:Value() then
if mainMenu.KillSteal.useR:Value() and CanUseSpell(myHero,_R) == READY and ValidTarget(enemy, 975) then
local rDMG = CalcDamage(myHero, enemy, ((125*GetCastLevel(myHero,_R)+25)+(0.7*GetBonusAP(myHero))),0)
if GetCurrentHP(enemy)+GetHPRegen(enemy)*2 < rDMG then
useR(enemy)
end
end
end
if mainMenu.KillSteal.useW:Value() and CanUseSpell(myHero, _W) and ValidTarget(target, 650) then
local wDMG = CalcDamage(myHero, enemy, ((40*GetCastLevel(myHero, _W)-20) + (1.2*(GetBaseDamage(myHero)+GetBonusDmg(myHero))) + (0.8*GetBonusAP(myHero))),0)
if GetCurrentHP(enemy)+GetHPRegen(enemy)*2 < wDMG then
CastSkillShot(_W, GetMousePos())
end
end
end
end

OnTick(function(myHero)
if Mode() == "Combo" then
if mainMenu.Misc.Items:Value() then
if GetItemSlot(myHero, 3074) >= 1 and ValidTarget(target, 400) then
if CanUseSpell(myHero, GetItemSlot(myHero, 3074)) == READY then
CastSpell(GetItemSlot(myHero, 3074))
end
end
if GetItemSlot(myHero, 3077) >= 1 and ValidTarget(target, 400) then
if CanUseSpell(myHero, GetItemSlot(myHero, 3077)) == READY then
CastSpell(GetItemSlot(myHero, 3077))
end
end
if GetItemSlot(myHero, 3144) >= 1 and ValidTarget(target, 550) then
if (GetCurrentHP(target) / GetMaxHP(target)) <= 0.5 then
if CanUseSpell(myHero, GetItemSlot(myHero, 3144)) == READY then
CastTargetSpell(target, GetItemSlot(myHero, 3144))
end
end
end
if GetItemSlot(myHero, 3146) >= 1 and ValidTarget(target, 700) then
if (GetCurrentHP(target) / GetMaxHP(target)) <= 0.5 then
if CanUseSpell(myHero, GetItemSlot(myHero, 3146)) == READY then
CastTargetSpell(target, GetItemSlot(myHero, 3146))
end
end
end
if GetItemSlot(myHero, 3153) >= 1 and ValidTarget(target, 550) then
if (GetCurrentHP(target) / GetMaxHP(target)) <= 0.5 then
if CanUseSpell(myHero, GetItemSlot(myHero, 3153)) == READY then
CastTargetSpell(target, GetItemSlot(myHero, 3153))
end
end
end
if GetItemSlot(myHero, 3748) >= 1 and ValidTarget(target, 300) then
if (GetCurrentHP(target) / GetMaxHP(target)) <= 0.5 then
if CanUseSpell(myHero,GetItemSlot(myHero, 3748)) == READY then
CastSpell(GetItemSlot(myHero, 3748))
end
end
end
end
end
end)

OnTick(function(myHero)
if mainMenu.Misc.LvlUp:Value() then
if mainMenu.Misc.AutoLvlUp:Value() == 1 then
leveltable = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
if GetLevelPoints(myHero) > 0 then
DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
end
elseif mainMenu.Misc.AutoLvlUp:Value() == 2 then
leveltable = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
if GetLevelPoints(myHero) > 0 then
DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
end
elseif mainMenu.Misc.AutoLvlUp:Value() == 3 then
leveltable = {_W, _Q, _E, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
if GetLevelPoints(myHero) > 0 then
DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
end
elseif mainMenu.Misc.AutoLvlUp:Value() == 4 then
leveltable = {_W, _E, _Q, _W, _W, _R, _W, _E, _W, _E, _R, _E, _E, _Q, _Q, _R, _Q, _Q}
if GetLevelPoints(myHero) > 0 then
DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
end
elseif mainMenu.Misc.AutoLvlUp:Value() == 5 then
leveltable = {_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}
if GetLevelPoints(myHero) > 0 then
DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
end
elseif mainMenu.Misc.AutoLvlUp:Value() == 6 then
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

PrintChat("<font color='#FF0000'>Quick Irelia - <font color='#00FF00'>Loaded.")
PrintChat("<font color='#FF0000'>by <font color='#FF0000'>Pu<font color='#FFFF00'>sz<font color='#0000FF'>yy")
PrintChat("<font color='#FF00FF'>Ver. 1.1")
