local myHero = GetMyHero()
if GetObjectName(myHero) ~= "Irelia" then return end
require('Inspired')
local mainMenu = Menu("Quick Irelia by Puszyy")
-- Combo
mainMenu:Menu("Combo", "Combo")
mainMenu.Combo:Boolean("useQ", "Use Q If Marked(Q reset)", true)
mainMenu.Combo:Boolean("useR", "Use R on X enemies", true)
mainMenu.Combo:Key("fkey", "Press Key to Ult on target:", string.byte("U"))
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
mainMenu.KillSteal:Boolean("useR", "Use R", true)
mainMenu.KillSteal:Boolean("block", "Block R KS during Combo", true)
-- Drawings
mainMenu:Menu("Drawings", "Drawings")
mainMenu.Drawings:Boolean('DrawQ', 'Draw Q Range', true)
mainMenu.Drawings:Boolean('DrawQC', 'Draw Q Killable', true)
mainMenu.Drawings:Boolean('DrawW', 'Draw W Range', false)
mainMenu.Drawings:Boolean('DrawE', 'Draw E Range', true)
mainMenu.Drawings:Boolean('DrawR', 'Draw R Range', true)
-- Misc
mainMenu:Menu("Misc", "Misc")
mainMenu.Misc:Boolean('Items', 'Use Items', true)
mainMenu.Misc:Boolean('LvlUp', 'Auto Level Up', true)
mainMenu.Misc:DropDown('AutoLvlUp', 'Level Table', 2, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})

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
if mainMenu.Drawings.DrawQ:Value() then DrawCircle(pos,625,2,25,0xffffff00) end
if mainMenu.Drawings.DrawW:Value() then DrawCircle(pos,825,1,25,0xff0000ff) end
if mainMenu.Drawings.DrawE:Value() then DrawCircle(pos,900,2,25,0xFFFF0000) end
if mainMenu.Drawings.DrawR:Value() then DrawCircle(pos,1000,1,25,0xffff0000) end
for _, minion in pairs(minionManager.objects) do
local tarC = GetOrigin(minion)
if CanUseSpell(myHero,_Q) == READY and ValidTarget(minion, 1200) then
local qDrawc = ((20*GetCastLevel(myHero,_Q)-10)+(0.7*GetBaseDamage(myHero)))
if GetCurrentHP(minion)+GetDmgShield(minion) < qDrawc then
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
Combo()
KillSteal()
LaneClear()
Farm()
Rkey()
	end)

function useQ(target)
CastTargetSpell(target, _Q)
end

function useR(target)
CastSkillShot(_R, GetOrigin(target))
end

function Combo()
if Mode() == "Combo" then
if mainMenu.Combo.useQ:Value() then
if GotBuff(target, "ireliamark") > 0 and CanUseSpell(myHero, _Q) and ValidTarget(target, 625) then
useQ(target)
end
end
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

function Rkey()
if mainMenu.Combo.fkey:Value() and CanUseSpell(myHero,_R) == READY and ValidTarget(target, 975) then
useR(target)
end
end

function Farm()
if Mode() == "Harass" then
for _, minion in pairs(minionManager.objects) do
if GetTeam(minion) == MINION_ENEMY then
if mainMenu.Farm.useQ:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > mainMenu.Farm.FMP:Value() and CanUseSpell(myHero,_Q) == READY and ValidTarget(minion, 625) then
local qDMG1 = ((20*GetCastLevel(myHero,_Q)-10)+(0.7*GetBaseDamage(myHero)))
if GetCurrentHP(minion)+GetDmgShield(minion) < qDMG1 then
CastTargetSpell(minion, _Q)
end
end
end
end
end
if Mode() == "LastHit" then
for _, minion in pairs(minionManager.objects) do
if GetTeam(minion) == MINION_ENEMY then
if mainMenu.Farm.useQ:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > mainMenu.Farm.FMP:Value() and CanUseSpell(myHero,_Q) == READY and ValidTarget(minion, 625) then
local qDMG1 = ((20*GetCastLevel(myHero,_Q)-10)+(0.7*GetBaseDamage(myHero)))
if GetCurrentHP(minion)+GetDmgShield(minion) < qDMG1 then
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
if mainMenu.LaneClear.useQ:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > mainMenu.LaneClear.LMP:Value() and CanUseSpell(myHero,_Q) == READY and ValidTarget(minion, 625) then
local qDMG2 = ((20*GetCastLevel(myHero,_Q)-10)+(0.7*GetBaseDamage(myHero)))
if GetCurrentHP(minion)+GetDmgShield(minion) < qDMG2 then
CastTargetSpell(minion, _Q)
end
end
end
end
end
end

function KillSteal()
for i,enemy in pairs(GetEnemyHeroes()) do
if mainMenu.KillSteal.useQ:Value() and CanUseSpell(myHero,_Q) == READY and ValidTarget(enemy, 625) then
local qDMG3 = CalcDamage(myHero, enemy, ((20*GetCastLevel(myHero,_Q)-10)+(0.7*GetBaseDamage(myHero))),0)
if GetCurrentHP(enemy)+GetHPRegen(enemy)*2 < qDMG3 then
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
PrintChat("<font color='#FF00FF'>Ver. 0.2")
