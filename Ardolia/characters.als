;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; characters.als
;;;; Last updated: 04/27/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; A flag for brand new characters who aren't set up yet
creatingcharacter { return $readini($char($1), info, CreatingCharacter) }

; Returns current stats [not final; this is placeholder]
current.hp { return $readini($char($1), battle, hp) }
current.tp { return $round($readini($char($1), battle, tp),0) }
current.mp { return $readini($char($1), battle, mp) }
current.str { return $readini($char($1), battle, str) }
current.vit { return $readini($char($1), battle, vit) }
current.agi { return $readini($char($1), battle, agi) }
current.mag { return $readini($char($1), battle, mag) }
current.spd { return $readini($char($1), battle, spd) }
current.chr { return $readini($char($1), battle, chr) }

current.dex {  
  var %dex $calc($current.agi($1) + $current.spd($1)) 
  inc %dex $bonus.stat($1, agi)
  inc %dex $bonus.stat($1, spd)
  return %dex
}

; Returns the resting stats (basestats)
resting.hp { return $readini($char($1), basestats, hp) }
resting.mp { return $readini($char($1), basestats, mp) }
resting.str { return $readini($char($1), basestats, str) }
resting.vit { return $readini($char($1), basestats, vit) }
resting.agi { return $readini($char($1), basestats, agi) }
resting.mag { return $readini($char($1), basestats, mag) }
resting.spd { return $readini($char($1), basestats, spd) }
resting.chr { return $readini($char($1), basestats, chr) }

; Returns the race maximum stats
race.str { return $readini($racefile($1), StatMax, Str) }
race.agi { return $readini($racefile($1), StatMax, Agi) }
race.vit { return $readini($racefile($1), StatMax, Vit) }
race.mag { return $readini($racefile($1), StatMax, Mag) }
race.chr { return $readini($racefile($1), StatMax, Chr) }
race.spd { return $readini($racefile($1), StatMax, Spd) }

; Returns the job max stat bonuses
job.str { return $readini($jobfile($1), StatBonuses, Str) }
job.agi { return $readini($jobfile($1), StatBonuses, Agi) }
job.vit { return $readini($jobfile($1), StatBonuses, Vit) }
job.mag { return $readini($jobfile($1), StatBonuses, Mag) }
job.chr { return $readini($jobfile($1), StatBonuses, Chr) }
job.spd { return $readini($jobfile($1), StatBonuses, Spd) }

; Returns the level of a job a player has
job.level {
  var %job.level $readini($char($1), jobs, $2)
  if (%job.level = $null) { return 0 }
  else { return %job.level }
}

; Returns the maximum amount of TP everyone is allowed to accumulate
max.tp { return 300 }

; Returns the number of stat points the player has to spend
statpoints { return $readini($char($1), info, StatPoints) }

; Returns current job and race
current.job { return $readini($char($1), jobs, currentjob) }
race { return $readini($char($1), info, race) }

; Returns a flag (monster, npc, null)
flag { return $readini($char($1), info, flag) } 

; Returns true if the monster is a boss
isboss { var %isboss $readini($char($1), info, boss) 
  if (%isboss = $null) { return false }
  else { return %isboss }
}

; Returns true if the person is in the battle
in.battle { return $readini($char($1), battle, inbattle) }

; Returns the current level
get.level { var %current.job.level $readini($char($1), jobs, $current.job($1)) 
  if (%current.job.level = $null) { return 1 }
  else { return %current.job.level }
}

; Returns the current xp
current.xp { 
  if ($get.level($1) >= 75) { 
    ; get capacity points instead of xp
    var %capacity.points $readini($char($1), exp, capacitypoints)
    if (%capacity.points = $null) { return 0 }
    else { return %capacity.points }
  }
  else { return $readini($char($1), exp, $current.job($1))  }
}

; Returns the amount of xp or capacity points needed to level
xp.to.level {
  if ($get.level($1) >= 75) { return 10000 }
  else { return $calc(500 * ($get.level($1) - 1) + (500 * $get.level($1))) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the # of Enhancement Points
; that a character has
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
current.enhancementpoints {
  var %enhancement.points $readini($char($1), enhancementpoints, EnhancementPoints)
  if (%enhancement.points = $null) { writeini $char($1) EnhancementPoints EnhancementPoints 0 | return 0 }
  else { return %enhancement.points }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the # of Enhancement Points
; that a character has spent on the
; current job
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
current.enhancementpoints.spent {
  var %enhancement.points $readini($char($1), enhancementpoints, $current.job($1))
  if (%enhancement.points = $null) { writeini $char($1) EnhancementPoints $current.job($1) 0 | return 0 }
  else { return %enhancement.points }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns gender info
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gender { return $readini($char($1), Info, Gender) }
gender2 {
  if ($gender($1) = her) { return her }
  if ($gender($1) = its) { return it }
  else { return him }
}
gender3 {
  if ($gender($1) = her) { return she }
  if ($gender($1) = its) { return it }
  else { return he }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns what is equipped in the slot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return.equipped {
  ; $1 = person
  ; $2 = what we're checking (head, body, accessory1, accessory2, etc)

  return $readini($char($1), equipment, $2)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get the character's real
; name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set_chr_name {
  set %real.name $readini($char($1), BaseStats, Name)
  if (%real.name = $null) { set %real.name $1 | return }
  else { return }
}

get_chr_name {
  var %tmp.real.name $readini($char($1), Info, Name)
  if (%tmp.real.name = $null) { return $1 }
  else { return %tmp.real.name }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; returns the amount of a
; currency someone has
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
currency.amount {
  ; $1 = the person we're checking
  ; $2 = the currency name

  var %current.amount $readini($char($1), currencies, $2)
  if (%current.amount = $null) { return 0 }
  else { return %current.amount }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; adds an amount to a currency
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
currency.add {
  ; $1 = the person 
  ; $2 = the currency name
  ; $3 = how much we're adding

  var %currency.amount $currency.amount($1, $2)
  inc %currency.amount $3
  writeini $char($1) currencies $2 %currency.amount
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; returns the amount of an
; item someone has
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inventory.amount {
  ; $1 = the person we're checking
  ; $2 = the item name

  var %inventory.amount $readini($char($1), inventory, $2)
  if (%inventory.amount = $null) { return 0 }
  else { return %inventory.amount }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; adds an amount to the inventory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inventory.add {
  ; $1 = the person
  ; $2 = the item name
  ; $3 = the amount we're adding

  var %inventory.amount $inventory.amount($1, $2)
  inc %inventory.amount $3
  writeini $char($1) inventory $2 %inventory.amount
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Allows chars to add/remove
; access to his/her characters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
character.access {
  if ($2 = add) { 
    $checkchar($3)
    var %player.access.list $readini($char($1), access, list)
    if (%player.access.list = $null) { writeini $char($1) access list $nick | var %player.access.list $nick }
    if ($istok(%player.access.list,$3,46) = $true) {  $display.private.message2($1, $readini(translation.dat, errors, AccessCommandAlreadyHasAccess)) | halt }
    var %player.access.list $addtok(%player.access.list, $3,46) | writeini $char($1) access list %player.access.list | $display.private.message2($1, $translate(AccessCommandAdd)) | halt 
  }

  if ($2 = remove) { 
    var %player.access.list $readini($char($1), access, list)
    if (%player.access.list = $null) { writeini $char($1) access list $nick | var %player.access.list $nick }
    if ($istok(%player.access.list,$3,46) = $true) {   
      if ($3 != $1) { var %player.access.list $remtok(%player.access.list, $3,46) | writeini $char($1) access list %player.access.list | $display.private.message2($1, $translate(AccessCommandRemove)) | halt }
      if ($3 = $1) { $display.private.message2($1, $readini(translation.dat, errors, AccessCommandCan'tRemoveSelf)) }
    }
  }

  if ($2 = list) {
    var %player.access.list $readini($char($1), access, list)
    if (%player.access.list = $null) { writeini $char($1) access list $nick | var %player.access.list $nick }
    set %replacechar $chr(044) $chr(032)
    %player.access.list = $replace(%player.access.list, $chr(046), %replacechar)  
    unset %replacechar
    $display.private.message2($1, $translate(AccessCommandList)) 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the character's
; current food effect
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return.foodeffect {
  var %food.effect $readini($char($1), statuseffects, foodeffect)
  if (%food.effect = $null) { return none }
  else { return %food.effect }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Let's level up!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
levelup {
  ; First things first, reduce the number of xp a person has by the amount needed to level
  var %current.xp $current.xp($1) |  var %needed.xp $xp.to.level($1)
  dec %current.xp %needed.xp
  if (%current.xp < 0) { var %current.xp 0 }

  if ($get.level($1) >= 75) { 
    ; Players that are level 75+ use capacity points and enhancement points upon leveling up
    writeini $char($1) exp capacitypoints %current.xp 
    writeini $char($1) enhancementpoints EnhancementPoints $calc($current.enhancementpoints($1) + 1)
    $display.message($translate(leveledupEnhancementPoints))
  }
  else { 
    ; players under 75 get normal xp and get hp/mp and a stat point upon leveling up
    writeini $char($1) exp $current.job($1) %current.xp

    ; Increase the level of the job
    var %current.level $calc(1 + $get.level($1) )
    writeini $char($1) jobs $current.job($1) %current.level

    ; Increase the player's HP
    var %job.bonus.hp.dice $readini($jobfile($current.job($1)), LevelUpInfo, HP)
    var %new.hp $roll(%job.bonus.hp.dice)
    var %vit.bonus $round($calc($resting.vit($1) / 2),0)
    inc %new.hp %vit.bonus
    var %bonus.hp %new.hp
    inc %new.hp $resting.hp($1)
    writeini $char($1) BaseStats HP %new.hp

    ; Increase the player's MP
    var %bonus.mp 0
    var %job.bonus.mp.dice $readini($jobfile($current.job($1)), LevelUpInfo, MP)
    var %new.mp $roll(%job.bonus.mp.dice)
    inc %bonus.mp %new.mp

    ; Only certain jobs can actually gain MP. 
    if (%new.mp != 0) { 
      var %mag.bonus $round($calc($resting.mag($1) / 2),0)
      inc %new.mp %mag.bonus
      inc %new.mp $resting.mp($1)
      inc %bonus.mp %mag.bonus
    }
    writeini $char($1) BaseStats MP %new.mp

    ; Add a bonus stat point to the player
    writeini $char($1) info StatPoints $calc($statpoints($1) + 1)

    ; Tell the player all that he/she's won!
    $display.private.message2($1, $translate(leveledupreward))
    $display.message($translate(leveledup))

  }

  ; Restore the player's battle hp and mp to their resting hp/mp
  writeini $char($1) Battle HP $resting.hp($1)
  writeini $char($1) Battle MP $resting.mp($1)

  ; Check to see if we've unlocked any advanced jobs
  $advancedjobs.unlockcheck($1)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Let's check for advanced job unlocks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
advancedjobs.unlockcheck {
  ; $1 = the player we're checking

  ; If we meet the requirements, tell the world what we've unlocked and go to the next job

  ; Get the list of advanced jobs and cycle through them, one by one
  var %value 1 | var %ajobs.lines $lines($lstfile(jobs_advanced.lst))

  while (%value <= %ajobs.lines) {
    var %job.name $read -l $+ %value $lstfile(jobs_advanced.lst)

    ; Does the player already have this job unlocked? If not, let's check
    if ($job.level($1, %job.name) = 0) { 
      echo -a for job: %job.name
      ; Cycle through the job requirements and check against what the player has

      set %requirements.unlocked 0
      var %number.of.requirements $ini($jobfile(%job.name), Requirements, 0) | var %current.requirement.num 1
      while (%current.requirement.num <= %number.of.requirements) { 

        ; get the job requirement
        var %current.requirement $ini($jobfile(%job.name), Requirements, %current.requirement.num)
        var %requirement.level $readini($jobfile(%job.name), Requirements, %current.requirement)

        ; Does the player match the requirement?
        if ($job.level($1, %current.requirement) >= %requirement.level) {  inc %requirements.unlocked }

        inc %current.requirement.num
      }

      if (%requirements.unlocked = %number.of.requirements) { 
        writeini $char($1) jobs %job.name 1 | writeini $char($1) exp %job.name 0
        $display.message($translate(UnlockedJob),private)
      }
    }

    inc %value 1 
  }

  unset %requirements.unlocked
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the HP status of a char
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return.hpstatus { 
  var %hp.percent $calc(($current.hp($1) / $resting.hp($1)) *100)
  if (%hp.percent > 100) { return $translate(beyondperfect)  | return }
  if (%hp.percent = 100) { return $translate(perfect)  | return }
  if ((%hp.percent < 100) && (%hp.percent >= 90)) { return $translate(great) | return }
  if ((%hp.percent < 90) && (%hp.percent >= 80)) { return $translate(good) | return }
  if ((%hp.percent < 80) && (%hp.percent >= 70)) { return $translate(decent) | return }
  if ((%hp.percent < 70) && (%hp.percent >= 60)) { return $translate(scratched)  | return }
  if ((%hp.percent < 60) && (%hp.percent >= 50)) { return $translate(bruised) | return }
  if ((%hp.percent < 50) && (%hp.percent >= 40)) { return $translate(hurt) | return }
  if ((%hp.percent < 40) && (%hp.percent >= 30)) { return $translate(injured) | return }
  if ((%hp.percent < 30) && (%hp.percent >= 15)) { return $translate(injuredbadly) | return } 
  if ((%hp.percent < 15) && (%hp.percent > 2)) { return $translate(critical) | return }
  if ((%hp.percent <= 2) && (%hp.percent > 0)) { return $translate(AliveHairBredth) | return }
  if (%hp.percent <= 0) { return $translate(Dead)  | return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates maximum stat amount
; Adds the player's race maximum to their job maximum
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $1 = player

max.str { 
  var %race.max $race.str($race($1))
  if (%race.max = $null) { var %race.max 1 }

  if ($current.job($1) = none) { var %job.max 0 }
  else { var %job.max $job.str($current.job($1)) }
  if (%job.max = $null) { var %job.max 1 }

  return $calc(%race.max + %job.max)
}
max.agi { 
  var %race.max $race.agi($race($1))
  if (%race.max = $null) { var %race.max 1 }

  if ($current.job($1) = none) { var %job.max 0 }
  else { var %job.max $job.agi($current.job($1)) }
  if (%job.max = $null) { var %job.max 1 }

  return $calc(%race.max + %job.max)
}
max.vit { 
  var %race.max $race.vit($race($1))
  if (%race.max = $null) { var %race.max 1 }

  if ($current.job($1) = none) { var %job.max 0 }
  else { var %job.max $job.vit($current.job($1)) }
  if (%job.max = $null) { var %job.max 1 }

  return $calc(%race.max + %job.max)
}

max.mag { 
  var %race.max $race.mag($race($1))
  if (%race.max = $null) { var %race.max 1 }

  if ($current.job($1) = none) { var %job.max 0 }
  else { var %job.max $job.mag($current.job($1)) }
  if (%job.max = $null) { var %job.max 1 }

  return $calc(%race.max + %job.max)
}

max.chr { 
  var %race.max $race.chr($race($1))
  if (%race.max = $null) { var %race.max 1 }

  if ($current.job($1) = none) { var %job.max 0 }
  else { var %job.max $job.chr($current.job($1)) }
  if (%job.max = $null) { var %job.max 1 }

  return $calc(%race.max + %job.max)
}

max.spd { 
  var %race.max $race.spd($race($1))
  if (%race.max = $null) { var %race.max 1 }

  if ($current.job($1) = none) { var %job.max 0 }
  else { var %job.max $job.spd($current.job($1)) }
  if (%job.max = $null) { var %job.max 1 }

  return $calc(%race.max + %job.max)
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates the bonus stats
; This is from armor/weapons/food
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bonus.stat {
  ; $1 = the person we're checking
  ; $2 = the stat we're checking

  var %bonus.stat 0

  ; First check for each armor part
  if ($return.equipped($1, head) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, head), $2) }
  if ($return.equipped($1, body) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, body), $2) }
  if ($return.equipped($1, legs) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, legs), $2) }
  if ($return.equipped($1, feet) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, feet), $2) }
  if ($return.equipped($1, hands) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, hands), $2) }

  ; Now check for the two accessories
  if ($return.equipped($1, accessory1) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, accessory1), $2) }
  if ($return.equipped($1, accessory2) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, accessory2), $2) }

  ; Let's also check the weapon slots and see if there's a bonus
  if ($return.equipped($1, RightHand) != nothing) { inc %bonus.stat $readini($dbfile(weapons.db), $return.equipped($1, RightHand), $2) }
  if ($return.equipped($1, LeftHand) != nothing) { inc %bonus.stat $readini($dbfile(weapons.db), $return.equipped($1, LeftHand), $2) }

  ; Finally let's check food
  if ($return.foodeffect($1) != none) { inc %bonus.stat $readini($dbfile(items.db), $return.foodeffect($1), $2) }

  return %bonus.stat
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the abilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
character.abilities {
  ; $1 = person
  ; $2 = active or passive

  unset %ability.list 

  var %value 1 | var %abilities.lines $lines($lstfile(abilities_ $+ $current.job($1) $+ .lst))

  while (%value <= %abilities.lines) {
    var %ability.name $read -l $+ %value $lstfile(abilities_ $+ $current.job($1) $+ .lst)
    var %ability.type $readini($dbfile(abilities.db), %ability.name, Type)
    var %ability.level $readini($dbfile(abilities.db), %ability.name, Level)

    if ((%ability.type = $2) && ($get.level($1) >= %ability.level)) {  var %ability.list $addtok(%ability.list, 3 $+ %ability.name $+ , 46)  }

    inc %value 1 
  }

  var %replacechar $chr(044) $chr(032)
  var %ability.list = $replace(%ability.list, $chr(046), %replacechar)

  return %ability.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns true/false based on
; if a passive ability is on or not
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return.passive.on {
  ; $1 = person
  ; $2 = the passive ability we're checking

  var %passive.on false |  var %passive.level $readini($dbfile(abilities.db), $2, level) | var %passive.jobs $readini($dbfile(abilities.db), $2, job)

  if (($get.level($1) >= %passive.level) && ($istok(%passive.jobs, $current.job($1), 46) = $true)) { return true }
  else { return false }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the spell list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
character.spells {
  ; $1 = person
  ; $2 = spell type (blue, ninja, white, black, etc)

  unset %spell.list 

  var %value 1 | var %spells.lines $lines($lstfile(spells_ $+ $2 $+ .lst))

  while (%value <= %spells.lines) {
    var %spell.name $read -l $+ %value $lstfile(spells_ $+ $2 $+ .lst)
    var %spell.type $readini($dbfile(spells.db), %spell.name, Type)
    var %spell.level $readini($dbfile(spells.db), %spell.name, Level)
    var %spell.mp.cost $readini($dbfile(spells.db), %spell.name, mp)
    var %spell.jobs $readini($dbfile(spells.db), %spell.name, job)

    if ((%spell.type = $2) && ($get.level($1) >= %spell.level)) {  
      if ($istok(%spell.jobs, $current.job($1), 46) = $true)  {
        if ($current.mp($1) >= %spell.mp.cost) {  var %spell.list $addtok(%spell.list, 3 $+ %spell.name $+ , 46) }
        else {  var %spell.list $addtok(%spell.list, 5 $+ %spell.name $+ 3, 46) }

      }
    }

    inc %value 1 
  }

  var %replacechar $chr(044) $chr(032)
  var %spell.list = $replace(%spell.list, $chr(046), %replacechar)

  return %spell.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's weapon list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display_weapon_lists {  $set_chr_name($1) 

  set %replacechar $chr(044) $chr(032) 
  %weapon.list1 = $replace(%weapon.list1, $chr(046), %replacechar)

  if ($2 = channel) { 
    $display.message($translate(ViewWeaponList),private)

    var %weapon.counter 2
    while ($weapons.returnlist(%weapon.counter) != $null) {
      set %display.weaponlist $weapons.returnlist(%weapon.counter)
      %display.weaponlist = $replace(%display.weaponlist, $chr(046), %replacechar)

      $display.message(3 $+ %display.weaponlist)
      $weapons.unsetlist(%weapon.counter) | unset %display.weaponlist
      inc %weapon.counter
      if (%weapon.counter > 100) { echo -a breaking to prevent a flood | break }
    }
  }
  if ($2 = private) {
    $display.private.message2($3,$translate(ViewWeaponList))

    var %weapon.counter 2
    while ($weapons.returnlist(%weapon.counter) != $null) {
      set %display.weaponlist $weapons.returnlist(%weapon.counter)
      %display.weaponlist = $replace(%display.weaponlist, $chr(046), %replacechar)

      $display.private.message2($3,3 $+ %display.weaponlist)
      $weapons.unsetlist(%weapon.counter) | unset %display.weaponlist
      inc %weapon.counter
      if (%weapon.counter > 100) { echo -a breaking to prevent a flood | break }
    }
  }
  unset %wpn.lst.target | unset %base.weapon.list | unset %weapons
  unset %weapon.list1 | unset %weapon.counter | unset %replacechar
  unset %weaponlist.counter | unset %*.wpn.list | unset %weapon.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Wield a weapon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
character.wieldweapon {
  if ($2 = right) { writeini $char($1) equipment RightHand $3 }
  if ($2 = left) { writeini $char($1) equipment LeftHand $3 }
  if ($2 = both) { writeini $char($1) equipment RightHand $3 | writeini $char($1) equipment LeftHand nothing }

  $set_chr_name($1) | $display.message($translate(EquipWeaponPlayer),private)

  writeini $char($1) battle TP 0

  unset %weapon.equipped.right | unset %weapon.equipped.left | unset %weapon.equipped | unset %real.name
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Wear Armor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wear.armor {
  ; $1 = the person
  ; $2 = the armor we're going to equip
  ; $3 = accessory slot for accessories (1 by default)

  if ((%adventureis = on) && ($in.battle($1) = true)) { $display.message($readini(translation.dat, errors, CanOnlySwitchArmorOutsideBattle), private) | halt }


  ; Does the player own that the armor or accessory?
  if ($inventory.amount($1, $2) <= 0) { $display.message($readini(translation.dat, errors, DoesNotHaveThatItem), private) | halt }

  if ($3 != $null) { 
    ; Accessory equip

    if ($readini($dbfile(equipment.db), $2, type) = $null) { $display.message($readini(translation.dat, errors, ItemIsNotAccessory), private) | halt }

    var %item.location accessory $+ $3

    ; Can the job wear the armor?
    var %jobs.list $readini($dbfile(equipment.db), $2, jobs)
    if (($istok(%jobs.list, $current.job($1), 46) = $false) && (%jobs.list != all))  { $display.message($readini(translation.dat, errors, WrongJobToWear) , private) | halt }

    ; Are we high enough level?
    var %armor.level.requirement $readini($dbfile(equipment.db), $2, level)
    if ($get.level($1) < %armor.level.requirement) { $display.message($readini(translation.dat, errors, AccessoryLevelHigher), private) | halt }

    ; Equip the armor and tell the world
    writeini $char($1) equipment %item.location $2
    if ($3 = 1) { $display.message($readini(translation.dat, system,EquippedAccessory), global) }
    if ($3 = 2) { $display.message($readini(translation.dat, system,EquippedAccessory2), global) }
  }

  else {
    ; Armor equip
    var %item.location $readini($dbfile(equipment.db), $2, EquipLocation)
    if (%item.location = $null) { $display.message($readini(translation.dat, errors, ItemIsNotArmor), private) | halt }

    ; Can the job wear the armor?
    var %jobs.list $readini($dbfile(equipment.db), $2, jobs)
    if (($istok(%jobs.list, $current.job($1), 46) = $false) && (%jobs.list != all))  { $display.message($readini(translation.dat, errors, WrongJobToWear) , private) | halt }

    ; Are we high enough level?
    var %armor.level.requirement $readini($dbfile(equipment.db), $2, level)
    if ($get.level($1) < %armor.level.requirement) { $display.message($readini(translation.dat, errors, ArmorLevelHigher), private) | halt }

    ; Equip the armor and tell the world
    writeini $char($1) equipment %item.location $2
    $display.message($translate(EquippedArmor), global)
  }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Remove Armor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
remove.armor {
  ; $1 = the person
  ; $2 = the armor/accessory being removed
  ; $3 = the accessory slot (1 by default)

  if ((%adventureis = on) && ($in.battle($1) = true)) { $display.message($readini(translation.dat, errors, CanOnlySwitchArmorOutsideBattle), private) | halt }

  ; Does the player own that the armor or accessory?
  if ($inventory.amount($1, $2) <= 0) { $display.message($readini(translation.dat, errors, DoesNotHaveThatItem), private) | halt }

  if ($3 != $null) { 
    ; Accessory unequip

    if ($3 = 1) {  var %equipped.accessory $return.equipped($1, accessory1) }
    else { var %equipped.accessory $return.equipped($1, accessory2) }

    if ($2 != %equipped.accessory) { $display.message($translate(NotWearingThatAccessory), private)  | halt }

    writeini $char($1) equipment accessory $+ $3 nothing
    if ($3 = 1) { $display.message($translate(RemovedAccessory), global) }
    if ($3 = 2) { $display.message($translate(RemovedAccessory2), global) }
  }

  else {
    ; Armor unequip
    var %item.location $readini($dbfile(equipment.db), $2, EquipLocation)
    var %worn.item $return.equipped($1, %item.location)

    if (%worn.item != $2) {  $display.message($translate(NotWearingThatArmor), private) | halt }

    writeini $char($1) equipment %item.location nothing
    $display.message($translate(RemovedArmor), global)
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Looking at a character
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lookat {
  $weapon_equipped($1) | $set_chr_name($1)
  var %equipped.accessory $return.equipped($1, accessory1)

  var %equipped.armor.head $return.equipped($1, head)
  var %equipped.armor.body $return.equipped($1, body)
  var %equipped.armor.legs $return.equipped($1, legs)
  var %equipped.armor.feet $return.equipped($1, feet)
  var %equipped.armor.hands $return.equipped($1, hands)

  var %equipped.accessory $equipment.color(%equipped.accessory) $+  $+ %equipped.accessory $+ 3

  if ($readini($char($1), equipment, accessory2) != $null) { 
    var %equipped.accessory2 $equipment.color($readini($char($1), equipment, accessory2)) $+ $readini($char($1), equipment, accessory2)
    var %equipped.accessory %equipped.accessory 3and %equipped.accessory2 $+ 3
  }

  var %equipped.armor.head $equipment.color(%equipped.armor.head) $+ %equipped.armor.head $+ 3
  var %equipped.armor.body $equipment.color(%equipped.armor.body) $+ %equipped.armor.body $+ 3
  var %equipped.armor.legs $equipment.color(%equipped.armor.legs) $+ %equipped.armor.legs $+ 3
  var %equipped.armor.feet $equipment.color(%equipped.armor.feet) $+ %equipped.armor.feet $+ 3 
  var %equipped.armor.hands $equipment.color(%equipped.armor.hands) $+ %equipped.armor.hands $+ 3

  var %weapon.equipped $equipment.color(%weapon.equipped) $+ %weapon.equipped

  if ($readini($char($1), info, CustomTitle) != $null) { var %custom.title " $+ $readini($char($1), info, CustomTitle) $+ " }

  if ($readini(system.dat, system, botType) = IRC) { 
    if ($2 = channel) {  $display.message(3 $+ %real.name %custom.title is wearing %equipped.armor.head on $gender($1) head; %equipped.armor.body on $gender($1) body; %equipped.armor.legs on $gender($1) legs; %equipped.armor.feet on $gender($1) feet; %equipped.armor.hands on $gender($1) hands. %real.name also has %equipped.accessory equipped $iif(%equipped.accessory2 = $null, as an accessory, as accessories) and is currently using the %weapon.equipped $iif(%weapon.equipped.left != nothing, 3and $equipment.color(%weapon.equipped.left) $+ %weapon.equipped.left 3weapons, 3weapon),private) }
    if ($2 != channel) { $display.private.message(3 $+ %real.name %custom.title is wearing %equipped.armor.head on $gender($1) head; %equipped.armor.body on $gender($1) body; %equipped.armor.legs on $gender($1) legs; %equipped.armor.feet on $gender($1) feet; %equipped.armor.hands on $gender($1) hands. %real.name also has %equipped.accessory $iif(%equipped.accessory2 = $null, as an accessory, as accessories) and is currently using the %weapon.equipped $iif(%weapon.equipped.left != nothing, 3and $equipment.color(%weapon.equipped.left) $+ %weapon.equipped.left 3weapons, 3weapon)) }
  }

  unset %real.name
  unset %weapon.equipped*
}



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's accessories
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readaccessories {
  ; Display the list of accessories the player has
  if (%accessories.list != $null) { 
    if ($2 = channel) { $display.message($translate(ViewAccessories),private) }
    if ($2 = private) {  $display.private.message($translate(ViewAccessories)) }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewAccessories)) }

    if (%accessories.list2 != $null) { 
      if ($2 = channel) {  $display.message(3 $+ %accessories.list2,private) }
      if ($2 = private) { $display.private.message(3 $+ %accessories.list2) }
      if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %accessories.list2) }
    }

    if (%accessories.list3 != $null) { 
      if ($2 = channel) {  $display.message(3 $+ %accessories.list3,private) }
      if ($2 = private) { $display.private.message(3 $+ %accessories.list3) }
      if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %accessories.list3) }
    }
  }
  else { 
    if ($2 = channel) { $display.message($translate(HasNoAccessories),private) }
    if ($2 = private) {  $display.private.message($translate(HasNoAccessories)) }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(HasNoAccessories)) } 
  }

  unset %accessories.* | unset %accessory*
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's armor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readarmor {
  if (%armor.head != $null) { 
    if ($2 = channel) { $display.message($translate(ViewArmorHead),private) }
    if ($2 = private) { $display.private.message($translate(ViewArmorHead)) }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewArmorHead)) }
  }
  if (%armor.head2 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.head2,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.head2) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.head2) }
  }
  if (%armor.head3 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.head3,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.head3) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.head3) }
  }
  if (%armor.head4 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.head4,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.head4) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.head4) }
  }

  if (%armor.body != $null) { 
    if ($2 = channel) { $display.message($translate(ViewArmorBody),private) }
    if ($2 = private) { $display.private.message($translate(ViewArmorBody)) }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewArmorBody)) }
  }
  if (%armor.body2 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.body2,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.body2) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.body2) }
  }
  if (%armor.body3 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.body3,private) }
    if ($2 = private) {  $display.private.message(3 $+ %armor.body3) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.body3) }
  }
  if (%armor.body4 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.body4,private) }
    if ($2 = private) {  $display.private.message(3 $+ %armor.body4) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.body4) }
  }

  if (%armor.legs != $null) { 
    if ($2 = channel) { $display.message($translate(ViewArmorLegs),private) }
    if ($2 = private) {  $display.private.message($translate(ViewArmorLegs)) }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewArmorLegs)) }
  }
  if (%armor.legs2 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.legs2,private) }
    if ($2 = private) {  $display.private.message(3 $+ %armor.legs2) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.legs2) }
  }
  if (%armor.legs3 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.legs3,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.legs3) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.legs3) }
  }
  if (%armor.legs4 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.legs4,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.legs4) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.legs4) }
  }

  if (%armor.feet != $null) { 
    if ($2 = channel) { $display.message($translate(ViewArmorFeet),private) }
    if ($2 = private) {  $display.private.message($translate(ViewArmorFeet)) }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewArmorFeet)) }
  }
  if (%armor.feet2 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.feet2,private) }
    if ($2 = private) {  $display.private.message(3 $+ %armor.feet2) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.feet2) }
  }
  if (%armor.feet3 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.feet3,private) }
    if ($2 = private) {  $display.private.message(3 $+ %armor.feet3) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.feet3) }
  }
  if (%armor.feet4 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.feet4,private) }
    if ($2 = private) {  $display.private.message(3 $+ %armor.feet4) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.feet4) }
  }

  if (%armor.hands != $null) {
    if ($2 = channel) {  $display.message($translate(ViewArmorHands),private) }
    if ($2 = private) { $display.private.message($translate(ViewArmorHands)) }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewArmorHands)) }
  }
  if (%armor.hands2 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.hands2,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.hands2) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.hands2) }
  }
  if (%armor.hands3 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.hands3,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.hands3) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.hands3) }
  }
  if (%armor.hands4 != $null) { 
    if ($2 = channel) { $display.message(3 $+ %armor.hands4,private) }
    if ($2 = private) { $display.private.message(3 $+ %armor.hands4) }
    if ($2 = dcc) { $dcc.private.message($nick, 3 $+ %armor.hands4) }
  }

  if (((((%armor.head = $null) && (%armor.body = $null) && (%armor.legs = $null) && (%armor.feet = $null) && (%armor.hands = $null))))) { 
    if ($2 = channel) { $display.message($translate(HasNoArmor),private) }
    if ($2 = private) { $display.private.message($translate(HasNoArmor)) }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(HasNoArmor)) }
  }    

  unset %armor.head | unset %armor.body | unset %armor.legs | unset %armor.feet | unset %armor.hands | unset %armor.head2 | unset %armor.body2 | unset %armor.legs2 | unset %armor.feet2 | unset %armor.hands2
  unset %armor.head3 | unset %armor.body3 | unset %armor.legs3 | unset %armor.feet3 | unset %armor.hands3
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's items
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readitems { 
  if (%items.list != $null) { 
    if ($2 = channel) { $display.message($translate(ViewItems),private) }
    if ($2 = private) { $display.private.message($translate(ViewItems)) }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewItems)) }
  }
  if (%items.list2 != $null) { 
    if ($2 = channel) { $display.message( $+ %items.list2,private) }
    if ($2 = private) { $display.private.message( $+ %items.list2) }
    if ($2 = dcc) { $dcc.private.message($nick,  $+ %items.list2) }
  }

  if (%crystal.items.list != $null) { 
    if ($2 = channel) { $display.message($translate(ViewCrystalItems),private) }
    if ($2 = private) {  $display.private.message($translate(ViewCrystalItems)) }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewCrystalItems)) }
  }

  if (%food.items.list != $null) { 
    if ($2 = channel) { $display.message($translate(ViewFoodItems),private) }
    if ($2 = private) {  $display.private.message($translate(ViewFoodItems)) }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewFoodItems)) }
  }

  if ((((%items.list = $null) && (%food.items.list = $null) && (%crystal.items.list = $null) && (%misc.items.list = $null)))) { 
    var %items.empty true 

    if ($2 = channel) { $display.message($translate(HasNoItems),private) }
    if ($2 = private) {  $display.private.message($translate(HasNoItems)) }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(HasNoItems)) }
  }    

  ; Display commands for other inventory items
  if (%items.empty != true) { 
    if ($2 = channel) { $display.message(3Other item commands:5 !misc items,private) }
    if ($2 = private) {  $display.private.message(3Other item commands:5 !misc items) }
    if ($2 = dcc) { $dcc.private.message($nick, 3Other item commands:5 !misc items) }
  }

  unset %*.items.lis* | unset %items.lis*
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's misc items
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readmiscitems {
  if (%misc.items.list != $null) {
    if ($2 = channel) { $display.message($translate(ViewMiscItems),private) | if (%misc.items.list2 != $null) { $display.message( $+ %misc.items.list2,private) } |  if (%misc.items.list3 != $null) { $display.message( $+ %misc.items.list3,private) } | if (%misc.items.list4 != $null) { $display.message( $+ %misc.items.list4,private) }  }
    if ($2 = private) { $display.private.message($translate(ViewMiscItems)) | if (%misc.items.list2 != $null) { $display.private.message(5 $+ %misc.items.list2) } | if (%misc.items.list3 != $null) { $display.private.message( $+ %misc.items.list3) } | if (%misc.items.list4 != $null) { $display.private.message( $+ %misc.items.list4) } }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewMiscItems)) | if (%misc.items.list2 != $null) {  $dcc.private.message($nick,  $+ %misc.items.list2) } | if (%misc.items.list3 != $null) { $dcc.private.message($nick,  $+ %misc.items.list3) } | if (%misc.items.list4 != $null) { $dcc.private.message($nick,  $+ %misc.items.list4) } }
  }

  if (%misc.items.list = $null) { 
    if ($2 = channel) { $display.message($translate(HasNoMiscItems),private) }
    if ($2 = private) { $display.private.message($translate(HasNoMiscItems)) }
    if ($2 = dcc) {  $dcc.private.message($nick, $translate(HasNoMiscItems)) }
  }    

  unset %miscitems.items.*
}



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns/adds/removes 
; Misc Stats info
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
miscstats {
  ; $1 = person
  ; $2 = add/remove/read
  ; $3 = the misc stat we're using
  ; $4 = the amount for add/remove

  if ($2 = read) {
    var %misc.stat $readini($char($1), MiscStats, $3)
    if (%misc.stat = $null) { return 0 }
    else { return %misc.stat }
  }

  if ($2 = add) {
    var %misc.stat $readini($char($1), MiscStats, $3)
    if (%misc.stat = $null) { var %misc.stat 0 }
    inc %misc.stat $4 
    writeini $char($1) MiscStats $3 %misc.stat
  }

  if ($2 = remove) {
    var %misc.stat $readini($char($1), MiscStats, $3)
    if (%misc.stat = $null) { var %misc.stat 0 }
    dec %misc.stat $4 
    writeini $char($1) MiscStats $3 %misc.stat
  }
}
