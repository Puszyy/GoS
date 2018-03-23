local myHero = GetMyHero()
if GetObjectName(myHero) ~= "XinZhao" then return end
require('Inspired')
local mainMenu = Menu("Winged Hussar Xin Zhao")
-- Combo
mainMenu:Menu("Combo", "Combo")
mainMenu.Combo:Boolean("useE", "Use E", true)
mainMenu.Combo:Boolean("useR", "Use R on X enemies", true)
-- R Configuration
mainMenu:Menu("Rconfig", "R Configuration")
mainMenu.Rconfig:Slider('X','Minimum Enemies R', 1, 0, 5, 1)
mainMenu.Rconfig:Slider('HP','Enemy HP Manager R', 50, 0, 100, 5)
-- Harass
mainMenu:Menu("Harass", "Harass")
mainMenu.Harass:Boolean('useQ', 'Use Q', true)
mainMenu.Harass:Boolean('useW', 'Use W', true)
mainMenu.Harass:Slider("MP","Mana-Manager", 50, 0, 100, 5)
-- Killsteal
mainMenu:Menu("KillSteal", "KillSteal")
mainMenu.KillSteal:Boolean("useW", "Use W", true)
mainMenu.KillSteal:Boolean("useE", "Use E", false)
mainMenu.KillSteal:Boolean("useR", "Use R", false)
mainMenu.KillSteal:Boolean("block", "Block R KS during Combo", true)
-- LaneClear
mainMenu:Menu("LaneClear", "LaneClear")
mainMenu.LaneClear:Boolean('useQ', 'Use Q', false)
mainMenu.LaneClear:Boolean('useW', 'Use W', true)
mainMenu.LaneClear:Boolean('useE', 'Use E', false)
mainMenu.LaneClear:Slider("MP","Mana-Manager", 50, 0, 100, 5)
-- JungleClear
mainMenu:Menu("JungleClear", "JungleClear")
mainMenu.JungleClear:Boolean('useQ', 'Use Q', true)
mainMenu.JungleClear:Boolean('useW', 'Use W', true)
mainMenu.JungleClear:Boolean('useE', 'Use E', true)
mainMenu.JungleClear:Slider("MP","Mana-Manager", 50, 0, 100, 5)
-- JungleSteal
mainMenu:Menu("JungleSteal", "JungleSteal")
mainMenu.JungleSteal:Boolean('useW', 'Use W', true)
mainMenu.JungleSteal:Boolean('useE', 'Use E', false)
-- Drawings
mainMenu:Menu("Drawings", "Drawings")
mainMenu.Drawings:Boolean('DrawW', 'Draw W Range', true)
mainMenu.Drawings:Boolean('DrawE', 'Draw E Range', true)
mainMenu.Drawings:Boolean('DrawR', 'Draw R Range', true)
-- Misc
mainMenu:Menu("Misc", "Misc")
mainMenu.Misc:Boolean('Items', 'Use Items', true)
mainMenu.Misc:Boolean('LvlUp', 'Auto Level Up', true)
mainMenu.Misc:DropDown('AutoLvlUp', 'Level Table', 6, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})

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

OnDraw(function(myHero)
local pos = GetOrigin(myHero)
if mainMenu.Drawings.DrawW:Value() then DrawCircle(pos,900,1,25,0xff0000ff) end
if mainMenu.Drawings.DrawE:Value() then DrawCircle(pos,650,1,25,0xffffff00) end
if mainMenu.Drawings.DrawR:Value() then DrawCircle(pos,500,1,25,0xffff0000) end
end)

OnTick(function(myHero)
target = GetCurrentTarget() 
Combo()
Harass()
KillSteal()
LaneClear()
JungleClear()
JungleSteal()
	end)
	
function useE(target)
CastTargetSpell(target, _E)
end	

function useW(target)
CastSkillShot(_W,GetOrigin(target))
end

function useQ(target)
CastSpell(_Q)
end

function useR(target)
CastSpell(_R)
end

function Combo()
if Mode() == "Combo" then
if mainMenu.Combo.useE:Value() and CanUseSpell(myHero,_E) == READY and ValidTarget(target, 650) then
useE(target)
IOW:ResetAA()
end
if CanUseSpell(myHero,_W) == READY and CanUseSpell(myHero,_E) == ONCOOLDOWN and ValidTarget(target, 850) then
useW(target)
end
if CanUseSpell(myHero,_Q) == READY and CanUseSpell(myHero,_E) == ONCOOLDOWN and CanUseSpell(myHero,_W) == ONCOOLDOWN and ValidTarget(target, 650) then
useQ(target)
IOW:ResetAA()
end
if mainMenu.Combo.useR:Value() then
if CanUseSpell(myHero,_R) == READY then
if ValidTarget(target, 500) then
if 100*GetCurrentHP(target)/GetMaxHP(target) < mainMenu.Combo.HP:Value() then
if EnemiesAround(myHero, 500) >= mainMenu.Combo.X:Value() then
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
if mainMenu.Harass.useW:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > mainMenu.Harass.MP:Value() and CanUseSpell(myHero,_W) == READY and ValidTarget(target, 850) then
useW(target)
end
if mainMenu.Harass.useQ:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > mainMenu.Harass.MP:Value() and CanUseSpell(myHero,_Q) == READY and ValidTarget(target, 175) then
useQ(target)
end
end
end

function KillSteal()
for i,enemy in pairs(GetEnemyHeroes()) do
if mainMenu.KillSteal.useW:Value() and CanUseSpell(myHero,_W) == READY and ValidTarget(enemy, 175) then
local dmgWS = ((({[1]=30,[2]=65,[3]=100,[4]=135,[5]=170})[GetCastLevel(myHero,_W)])+(0.75*GetBaseDamage(myHero))) + ((10*GetCastLevel(myHero,_W)+20)+(0.3*GetBaseDamage(myHero)))
if GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*2 < dmgWS then
useW(enemy)
end
end
if mainMenu.KillSteal.useW:Value() and CanUseSpell(myHero,_W) == READY and ValidTarget(enemy, 850) then
local dmgW = (({[1]=30,[2]=65,[3]=100,[4]=135,[5]=170})[GetCastLevel(myHero,_W)])+(0.75*GetBaseDamage(myHero))
if GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*2 < dmgW then
useW(enemy)
end
end
if mainMenu.KillSteal.useE:Value() and CanUseSpell(myHero,_E) == READY and ValidTarget(enemy, 650) then
local dmgE = (25*GetCastLevel(myHero,_E)+25)+(0.6*GetBonusAP(myHero))
if GetCurrentHP(enemy)+GetMagicResist(enemy)+GetMagicShield(enemy)+GetHPRegen(enemy)*2 < dmgE then
useE(enemy)
end
if not mainMenu.KillSteal.block:Value() then
if mainMenu.KillSteal.useR:Value() and CanUseSpell(myHero,_R) == READY and ValidTarget(enemy, 500) then
local dmgR = ((({[1]=75,[2]=175,[3]=275})[GetCastLevel(myHero,_R)])+ GetBonusDmg(myHero)) + (GetCurrentHP(enemy)*0.15)
if GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*2 < dmgR then
CastSpell(_R)
end
end
end
end
end
end

function LaneClear()
if Mode() == "LaneClear" then
for _,minion in pairs(minionManager.objects) do
if GetTeam(minion) == MINION_ENEMY then
if mainMenu.LaneClear.useW:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > mainMenu.LaneClear.MP:Value() and CanUseSpell(myHero,_W) == READY and ValidTarget(minion, 850) then
useW(minion)
end
if mainMenu.LaneClear.useQ:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > mainMenu.LaneClear.MP:Value() and CanUseSpell(myHero,_Q) == READY and ValidTarget(minion, 175) then
useQ(minion)
end
if mainMenu.LaneClear.useE:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > mainMenu.LaneClear.MP:Value() and CanUseSpell(myHero,_E) == READY and ValidTarget(minion, 650) then
useE(minion)
end
end
end
end
end

function JungleClear()
if Mode() == "LaneClear" then
for _,mob in pairs(minionManager.objects) do
if GetTeam(mob) == 300 then
if mainMenu.JungleClear.useW:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > mainMenu.JungleClear.MP:Value() and CanUseSpell(myHero,_W) == READY and ValidTarget(mob, 850) then
useW(mob)
end
if mainMenu.JungleClear.useQ:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > mainMenu.JungleClear.MP:Value() and CanUseSpell(myHero,_Q) == READY and ValidTarget(mob, 175) then
useQ(mob)
end
if mainMenu.JungleClear.useE:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > mainMenu.JungleClear.MP:Value() and CanUseSpell(myHero,_E) == READY and ValidTarget(mob, 650) then
useE(mob)
end
end
end
end
end

function JungleSteal()
for _,mob in pairs(minionManager.objects) do
if GetTeam(mob) == 300 then
if mainMenu.JungleSteal.useW:Value() and CanUseSpell(myHero,_W) == READY and ValidTarget(mob, 175) then
local dmgWSJ = ((({[1]=30,[2]=65,[3]=100,[4]=135,[5]=170})[GetCastLevel(myHero,_W)])+(0.75*GetBaseDamage(myHero))) + ((10*GetCastLevel(myHero,_W)+20)+(0.3*GetBaseDamage(myHero)))
if GetCurrentHP(mob)+GetArmor(mob) < dmgWSJ then
useW(mob)
end
end
if mainMenu.JungleSteal.useW:Value() and CanUseSpell(myHero,_W) == READY and ValidTarget(mob, 850) then
local dmgWJ = (({[1]=30,[2]=65,[3]=100,[4]=135,[5]=170})[GetCastLevel(myHero,_W)])+(0.75*GetBaseDamage(myHero))
if GetCurrentHP(mob)+GetArmor(mob) < dmgWJ then
useW(mob)
end
end
if mainMenu.JungleSteal.useE:Value() and CanUseSpell(myHero,_E) == READY and ValidTarget(mob, 650) then
local dmgEJ = (25*GetCastLevel(myHero,_E)+25)+(0.6*GetBonusAP(myHero))
if GetCurrentHP(mob)+GetMagicResist(mob) < dmgEJ then
useE(mob)
end
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
if GotBuff(myHero, "XinZhaoQ") == 0 then

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
end
end)

PrintChat("<font color='#FF0000'>Winged Hussar Xin Zhao - <font color='#00FF00'>Loaded.")
PrintChat("<font color='#FF0000'>by <font color='#FF0000'>Pu<font color='#FFFF00'>sz<font color='#0000FF'>yy")
PrintChat("<font color='#FF00FF'>Ver. 1.0")
