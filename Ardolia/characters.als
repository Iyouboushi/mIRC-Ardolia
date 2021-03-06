;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; characters.als
;;;; Last updated: 09/08/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; A flag for brand new characters who aren't set up yet
creatingcharacter { return $readini($char($1), info, CreatingCharacter) }

; Returns current stats [not final; this is placeholder]
current.hp { 
  if ($flag($1) = $null) { return $readini($char($1), battle, hp) }
  else { return $readini($char($1), Battle, HP) }
}
current.tp { return $round($readini($char($1), battle, tp),0) }
current.mp { 
  if ($flag($1) = $null) { return $readini($char($1), battle, mp) }
  else { return $readini($char($1), Battle, MP) }
}

current.str { 
  var %stat.str $readini($char($1), battle, str)

  ; Increase this by the bonus given by armor, weapon and food
  inc %stat.str $bonus.stats($1, str)

  ; Check for buffs that increase str
  inc %stat.str $buff.check($1, str, %stat.str)

  return %stat.str
}

current.dex { 
  var %stat.dex $readini($char($1), battle, dex)

  ; Increase this by the bonus given by armor, weapon and food
  inc %stat.dex $bonus.stats($1, dex)

  ; Check for buffs that increase dex
  inc %stat.dex $buff.check($1, dex, %stat.dex)

  return %stat.dex
}

current.vit { 
  var %stat.vit $readini($char($1), battle, vit)

  ; Increase this by the bonus given by armor, weapon and food
  inc %stat.vit $bonus.stats($1, vit)

  ; Check for buffs that increase vit
  inc %stat.vit $buff.check($1, vit, %stat.vit)

  return %stat.vit
}

current.int { 
  var %stat.int $readini($char($1), battle, int)

  ; Increase this by the bonus given by armor, weapon and food
  inc %stat.int $bonus.stats($1, int)

  ; Check for buffs that increase int
  inc %stat.int $buff.check($1, int, %stat.int)

  return %stat.int
}

current.mnd { 
  var %stat.mnd $readini($char($1), battle, mnd)

  ; Increase this by the bonus given by armor, wepaon and food
  inc %stat.mnd $bonus.stats($1, mnd)

  ; Check for buffs that increase mnd
  inc %stat.mnd $buff.check($1, mnd, %stat.mnd)

  return %stat.mnd
}

current.pie { 
  var %stat.pie $readini($char($1), battle, pie)

  ; Increase this by the bonus given by armor, weapon and food
  inc %stat.pie $bonus.stats($1, pie)

  ; Check for buffs that increase pie
  inc %stat.pie $buff.check($1, pie, %stat.pie)

  return %stat.pie
}

current.det { 
  var %stat.det $readini($char($1), battle, det)

  ; Increase this by the bonus given by armor, weapon and food
  inc %stat.det $bonus.stats($1, det)

  ; Check for buffs that increase det
  inc %stat.str $buff.check($1, det, %stat.det)

  return %stat.det
}

current.defense { 
  var %defense 0 
  if ($flag($1) = $null) { inc %defense $armor.def($1) }
  else { inc %defense $readini($char($1), Battle, Defense) }

  ; Check for buffs that increase defense
  inc %defense $buff.check($1, defense, %defense)
  return %defense
}

current.mdefense { 
  var %mdefense 0
  if ($flag($1) = $null) { inc %mdefense $armor.mdef($1) }
  else { inc %mdefense $readini($char($1), Battle, MagicDefense) }

  ; Check for buffs that increase magic defense
  inc %mdefense $buff.check($1, mdefense, %mdefense)

  return %mdefense
}

current.speed {
  if ($flag($1) != $null) {
    var %char.speed $readini($char($1), battle, spd)
    inc %char.speed $weapon.speed($1)

    ; Check for buffs that increase speed
    inc %char.speed $buff.check($1,speed, %char.speed)

    return %char.speed
  }
  else {
    var %char.speed $round($calc($readini($jobfile($current.job($1)), StatInfo, BaseSpeed) * ($get.level($1) / 10)),0)
    inc %char.speed $weapon.speed($1)

    ; Check for buffs that increase speed
    inc %char.speed $buff.check($1,speed, %char.speed)

    return %char.speed
  }
}




current.fame {
  var %current.fame $readini($char($1), Info, Fame)
  if (%current.fame = $null) { return 0 }
  else { return %current.fame }
}

current.freestatpoints {
  var %current.statpoints $readini($char($1), Info, UnallocatedStatPoints)
  if (%current.statpoints = $null) { return 0 }
  else { return %current.statpoints }
}

job.hp {
  ; How much HP does 1 vit equal on this job?
  return $readini($jobfile($current.job($1)), StatInfo, HPperVIT)
}

job.mp {
  ; How much MP does 1 pie equal on this job?
  return $readini($jobfile($current.job($1)), StatInfo, MPperPIE)
}

; Returns the resting stats (basestats)
resting.hp {
  if ($flag($1) = $null) { return $round($calc($resting.vit($1) * $job.hp($1)),0) }
  else { return $readini($char($1), BaseStats, HP) }
}
resting.mp { 
  if ($flag($1) = $null) { return $round($calc($resting.pie($1) * $job.mp($1)),0) }
  else { return $readini($char($1), BaseStats, MP) }
}

resting.str { 
  var %stat.str $readini($char($1), BaseStats, str)

  ; Increase this by the bonus given by armor and weapon
  inc %stat.str $bonus.stats($1, str)

  return %stat.str
}

resting.dex { 
  var %stat.dex $readini($char($1), BaseStats, dex)

  ; Increase this by the bonus given by armor and weapon
  inc %stat.dex $bonus.stats($1, dex)

  return %stat.dex
}

resting.vit { 
  var %stat.vit $readini($char($1), BaseStats, vit)

  ; Increase this by the bonus given by armor and weapon
  inc %stat.vit $bonus.stats($1, vit)

  ; Check for buffs that increase this
  inc %stat.vit $buff.check($1, max-vit, %stat.vit)

  return %stat.vit
}

resting.int { 
  var %stat.int $readini($char($1), BaseStats, int)

  ; Increase this by the bonus given by armor and weapon
  inc %stat.int $bonus.stats($1, int)

  return %stat.int
}

resting.mnd { 
  var %stat.mnd $readini($char($1), BaseStats, mnd)

  ; Increase this by the bonus given by armor and weapon
  inc %stat.mnd $bonus.stats($1, mnd)

  return %stat.mnd
}

resting.pie { 
  var %stat.pie $readini($char($1), BaseStats, pie)

  ; Increase this by the bonus given by armor and weapon
  inc %stat.pie $bonus.stats($1, pie)

  ; Check for buffs that increase this
  inc %stat.vit $buff.check($1, max-pie, %stat.pie)

  return %stat.pie
}

resting.det { 
  var %stat.det $readini($char($1), BaseStats, det)

  ; Increase this by the bonus given by armor and weapon
  inc %stat.det $bonus.stats($1, det)

  return %stat.det
}

armor.def { return $bonus.stats($1, PDefense) }
armor.mdef { return $bonus.stats($1, MDefense) }

weapon.speed { return $readini($dbfile(weapons.db), $return.equipped($1, weapon), speed) }
weapon.damage { return $readini($dbfile(weapons.db), $return.equipped($1, weapon), damage) }
weapon.stat { return $readini($dbfile(weapons.db), $return.equipped($1, weapon), stat) }

; Returns the level of a job a player has
job.level {
  var %job.level $readini($char($1), jobs, $2)
  if (%job.level = $null) { return 0 }
  else { return %job.level }
}

; Returns the maximum amount of TP everyone is allowed to accumulate
max.tp { return 1000 }

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

; Returns true if the person is in an adventure party
in.adventure { 
  var %party.list $readini($txtfile(adventure.txt), Info, PartyMembersList)
  if (%party.list = $null) { return false }

  $if($istok(%party.list, $1, 46) = $true) { return true }
  else { return false }
}

; Returns the current level
get.level { var %current.job.level $readini($char($1), jobs, $current.job($1)) 
  if (%current.job.level = $null) { return 1 }
  else { return %current.job.level }
}

; Returns the current xp
current.xp { 
  var %level.cap $return.systemsetting(PlayerLevelCap)
  if (%level.cap = null) { var %level.cap 60 }

  if ($get.level($1) >= %level.cap) { return 0 }
  else { return $readini($char($1), exp, $current.job($1))  }
}

; Returns the amount of xp needed to level
xp.to.level {

  var %level.cap $return.systemsetting(PlayerLevelCap)
  if (%level.cap = null) { var %level.cap 60 }

  if ($get.level($1) >= %level.cap) { return 0 }
  else {
    var %exponent 1.5

    if ($get.level($1) <= 5) { var %baseXP 100 }
    if ($get.level($1) > 5) { var %baseXP 300 }

    return $floor($calc(%baseXP * ($get.level($1) ^ %exponent)))
  }
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
  ; $2 = what we're checking (head, body, legs, etc)

  return $readini($char($1), equipment, $2)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Get the character's real
; name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set_chr_name {
  set %real.name $readini($char($1), Info, Name)
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
; removes an amount to a currency
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
currency.remove {
  ; $1 = the person 
  ; $2 = the currency name
  ; $3 = how much we're removing

  var %currency.amount $currency.amount($1, $2)
  dec %currency.amount $3
  writeini $char($1) currencies $2 %currency.amount
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the level of fame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
character.fame {
  ; $1 = the person we're checking

  var %famepoints $character.famepoints($1)

  if (%famepoints < 20) { return 1 }
  if ((%famepoints >= 20) && (%famepoints < 100)) { return 2 }
  if ((%famepoints >= 100) && (%famepoints < 300)) { return 3 }
  if ((%famepoints >= 400) && (%famepoints < 400)) { return 4 }
  if ((%famepoints >= 500) && (%famepoints < 500)) { return 5 }
  if ((%famepoints >= 500) && (%famepoints < 700)) { return 6 }
  if ((%famepoints >= 700) && (%famepoints < 900)) { return 7 }
  if ((%famepoints >= 900) && (%famepoints < 1000)) { return 8 }
  if ((%famepoints >= 1000) && (%famepoints < 1500)) { return 9 }
  if (%famepoints >= 1500)  { return 10 }

}

character.famepoints {
  var %fame $readini($char($1), Info, Fame)
  if (%fame = $null) { return 0 }
  else { return %fame }
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

  if ($2 = $null) { return }

  var %inventory.amount $inventory.amount($1, $2)
  inc %inventory.amount $3
  writeini $char($1) inventory $2 %inventory.amount
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; decreases an amount to the inventory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inventory.decrease {
  ; $1 = the person
  ; $2 = the item name
  ; $3 = the amount we're decreasing

  var %inventory.amount $inventory.amount($1, $2)
  dec %inventory.amount $3
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
  var %food.effect $readini($char($1), Battle, Food)
  if (%food.effect = $null) { return none }
  else { return %food.effect }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns true if the character
; has cleared a specific adventure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
character.adventure.clear.check {
  var %adventure.clear.check $readini($char($1), AdventuresCleared, $2) 
  if (%adventure.clear.check = $null) { return false }
  else { return %adventure.clear.check }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if we can level up
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
levelup.check {

  if (($current.level = 50) && ($return.systemsetting(GenkaiQuest) = true)) {
    ; Has the player cleared the genkai adventure?
    if ($character.adventure.clear.check($1, Genkai) = false) { 

      ; If not, message the player.
      $display.private.message2($1, $translate(NeedToDoGenkaiQuest))
      halt
    }
  }

  ; check for the level cap
  var %level.cap $return.systemsetting(PlayerLevelCap)
  if (%level.cap = null) { var %level.cap 60 }

  if (%current.level = %level.cap) { halt }

  if ($current.xp($1) >= $xp.to.level($1)) { $levelup($1) }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Let's level up!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
levelup {
  ; First things first, reduce the number of xp a person has by the amount needed to level
  var %current.xp $current.xp($1) |  var %needed.xp 

  var %level.cap $return.systemsetting(PlayerLevelCap)
  if (%level.cap = null) { var %level.cap 60 }

  while ((%current.xp >= $xp.to.level($1)) && ($get.level($1) < %level.cap)) {

    dec %current.xp $xp.to.level($1)
    if (%current.xp < 0) { var %current.xp 0 }

    writeini $char($1) exp $current.job($1) %current.xp

    ; Increase the level of the job
    var %current.level $calc(1 + $get.level($1) )
    writeini $char($1) jobs $current.job($1) %current.level

    ; Max HP and MP will automatically increase as the stats increase.

    ; Increase the player's stats
    var %stat.str $resting.str($1)
    inc %stat.str $readini($jobfile($current.job($1)), LevelUpInfo, Str)
    writeini $char($1) BaseStats Str %stat.str

    var %stat.dex $resting.dex($1)
    inc %stat.dex $readini($jobfile($current.job($1)), LevelUpInfo, Dex)
    writeini $char($1) BaseStats Dex %stat.dex

    var %stat.vit $resting.vit($1)
    inc %stat.vit $readini($jobfile($current.job($1)), LevelUpInfo, Vit)
    writeini $char($1) BaseStats Vit %stat.str

    var %stat.int $resting.int($1)
    inc %stat.int $readini($jobfile($current.job($1)), LevelUpInfo, Int)
    writeini $char($1) BaseStats Int %stat.int

    var %stat.mnd $resting.mnd($1)
    inc %stat.mnd $readini($jobfile($current.job($1)), LevelUpInfo, Mnd)
    writeini $char($1) BaseStats mnd %stat.int

    var %stat.pie $resting.pie($1)
    inc %stat.pie $readini($jobfile($current.job($1)), LevelUpInfo, Pie)
    writeini $char($1) BaseStats Pie %stat.pie

    var %stat.det $resting.det($1)
    inc %stat.det $readini($jobfile($current.job($1)), LevelUpInfo, Det)
    writeini $char($1) BaseStats Det %stat.det

    var %unallocated.statpoints $current.freestatpoints($1)
    inc %unallocated.statpoints 1
    writeini $char($1) Info UnallocatedStatPoints %unallocated.statpoints

    ; Tell the player all that he/she's won!
    $display.private.message2($1, $translate(leveledupreward, $1))
    $display.message($translate(leveledup, $1))

    writeini $char($1)  info NeedsFulls yes
    $fulls($1)
  }

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
; This is from armor/food
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bonus.stats {
  ; $1 = the person we're checking
  ; $2 = the stat we're checking

  var %bonus.stat 0

  ; First check for each armor part
  if ($return.equipped($1, head) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, head), $2) }
  if ($return.equipped($1, body) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, body), $2) }
  if ($return.equipped($1, legs) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, legs), $2) }
  if ($return.equipped($1, feet) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, feet), $2) }
  if ($return.equipped($1, hands) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, hands), $2) }
  if ($return.equipped($1, ears) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, ears), $2) } 
  if ($return.equipped($1, neck) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, neck), $2) }
  if ($return.equipped($1, wrists) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, wrists), $2) }
  if ($return.equipped($1, Ring) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, Ring), $2) }

  ; Let's check shield and weapon
  if ($return.equipped($1, shield) != nothing) { inc %bonus.stat $readini($dbfile(equipment.db), $return.equipped($1, shield), $2) }
  inc %bonus.stat $readini($dbfile(weapons.db), $return.equipped($1, weapon), $2)

  ; Finally let's check food
  if ($return.foodeffect($1) != none) { inc %bonus.stat $readini($dbfile(items.db), $return.foodeffect($1), $2) }

  return %bonus.stat
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates the iLevel you have
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
character.ilevel {
  ; $1 = the person we're checking

  var %iLevel 0

  ; First check for each armor part

  if ($return.equipped($1, head) != nothing) { inc %ilevel $readini($dbfile(equipment.db), $return.equipped($1, head), ItemLevel) }
  if ($return.equipped($1, body) != nothing) { inc %ilevel $readini($dbfile(equipment.db), $return.equipped($1, body), ItemLevel) }
  if ($return.equipped($1, legs) != nothing) { inc %ilevel $readini($dbfile(equipment.db), $return.equipped($1, legs), ItemLevel) }
  if ($return.equipped($1, feet) != nothing) { inc %ilevel $readini($dbfile(equipment.db), $return.equipped($1, feet), ItemLevel) }
  if ($return.equipped($1, hands) != nothing) { inc %ilevel $readini($dbfile(equipment.db), $return.equipped($1, hands), ItemLevel) }
  if ($return.equipped($1, ears) != nothing) { inc %ilevel $readini($dbfile(equipment.db), $return.equipped($1, ears), ItemLevel) } 
  if ($return.equipped($1, neck) != nothing) { inc %ilevel $readini($dbfile(equipment.db), $return.equipped($1, neck), ItemLevel) }
  if ($return.equipped($1, wrists) != nothing) { inc %ilevel $readini($dbfile(equipment.db), $return.equipped($1, wrists), ItemLevel) }
  if ($return.equipped($1, Ring) != nothing) { inc %ilevel $readini($dbfile(equipment.db), $return.equipped($1, RingRight), ItemLevel) }

  ;Paladins check shields, otherwise it multiplies the weapon twice.
  if ($current.job($1) = PLD) { 
    if ($return.equipped($1, shield) != nothing) { inc %ilevel $readini($dbfile(equipment.db), $return.equipped($1, shield), ItemLevel) }
    inc %ilevel $readini($dbfile(weapons.db), $return.equipped($1, weapon), ItemLevel)
  }
  else { inc %ilevel $calc($readini($dbfile(weapons.db), $return.equipped($1, weapon), ItemLevel) *2) }

  var %iLevel $round($calc(%ilevel / 11),0)

  if (%iLevel <= 0) {  return 1 }
  else { return %iLevel }
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
; Wield a weapon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
character.wieldweapon {
  writeini $char($1) equipment weapon $2
  $display.message($translate(EquipWeaponPlayer, $1, $2),private)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Wear Armor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wear.armor {
  ; $1 = the person
  ; $2 = the armor we're going to equip
  ; $3 = ignore if you want to ignore the equip message

  if (%adventureis = on) { $display.message($translate(CanOnlySwitchOutsideAdventure), private) | halt }

  ; Does the player own that the armor?
  if ($inventory.amount($1, $2) <= 0) { $display.message($translate(DoesNotHaveThatItem, $1), private) | halt }

  ; Armor equip
  var %item.location $readini($dbfile(equipment.db), $2, EquipLocation)
  if (%item.location = $null) { $display.message($translate(ItemIsNotArmor), private) | halt }

  ; Can the job wear the armor?
  var %jobs.list $readini($dbfile(equipment.db), $2, jobs)

  if (($istok(%jobs.list, $current.job($1), 46) = $false) && (%jobs.list != all))  { $display.message($translate(WrongJobToWear, $1) , private) | halt }

  ; Are we high enough level?
  var %armor.level.requirement $readini($dbfile(equipment.db), $2, level)
  if ($get.level($1) < %armor.level.requirement) { $display.message($translate(ArmorLevelHigher, $1), private) | halt }

  ; Equip the armor and tell the world
  writeini $char($1) equipment %item.location $2
  if ($3 != ignore) { $display.message($translate(EquippedArmor, $1, $2), global) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Remove Armor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
remove.armor {
  ; $1 = the person
  ; $2 = the armor being removed

  if ((%adventureis = on) && ($adventure.alreadyinparty.check($1) = true)) { $display.message($translate(CanOnlySwitchOutsideAdventure), private) | halt }

  ; Does the player own that the armor or accessory?
  if ($inventory.amount($1, $2) <= 0) { $display.message($translate(DoesNotHaveThatItem, $1), private) | halt }

  ; Armor unequip
  var %item.location $readini($dbfile(equipment.db), $2, EquipLocation)
  var %worn.item $return.equipped($1, %item.location)

  if (%worn.item != $2) { $display.message($translate(NotWearingThatArmor), private) | halt }

  writeini $char($1) equipment %item.location nothing
  $display.message($translate(RemovedArmor, $1, $2), global)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Looking at a character
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lookat {
  $set_chr_name($1)

  var %equipped.weapon $return.equipped($1, weapon)
  var %equipped.shield $return.equipped($1, shield)
  var %equipped.armor.head $return.equipped($1, head)
  var %equipped.armor.body $return.equipped($1, body)
  var %equipped.armor.legs $return.equipped($1, legs)
  var %equipped.armor.feet $return.equipped($1, feet)
  var %equipped.armor.hands $return.equipped($1, hands)
  var %equipped.armor.ears $return.equipped($1, ears)
  var %equipped.armor.neck $return.equipped($1, neck)
  var %equipped.armor.wrists $return.equipped($1, wrists)
  var %equipped.armor.ring $return.equipped($1, ring)

  var %equipped.weapon $rarity.color.check(%equipped.weapon, weapon) $+ %equipped.weapon $+ 3
  if (%equipped.shield != nothing) { var %equipped.shield $rarity.color.check(%equipped.shield, armor) $+ %equipped.shield $+ 3 }
  var %equipped.armor.head $rarity.color.check(%equipped.armor.head, armor) $+ %equipped.armor.head $+ 3
  var %equipped.armor.body $rarity.color.check(%equipped.armor.body, armor) $+ %equipped.armor.body $+ 3
  var %equipped.armor.legs $rarity.color.check(%equipped.armor.legs, armor) $+ %equipped.armor.legs $+ 3
  var %equipped.armor.feet $rarity.color.check(%equipped.armor.feet,armor) $+ %equipped.armor.feet $+ 3 
  var %equipped.armor.hands $rarity.color.check(%equipped.armor.hands, armor) $+ %equipped.armor.hands $+ 3
  var %equipped.armor.ears $rarity.color.check(%equipped.armor.ears,armor) $+ %equipped.armor.ears $+ 3 
  var %equipped.armor.neck $rarity.color.check(%equipped.armor.neck,armor) $+ %equipped.armor.neck $+ 3 
  var %equipped.armor.wrists $rarity.color.check(%equipped.armor.wrists,armor) $+ %equipped.armor.wrists $+ 3 
  var %equipped.armor.ring $rarity.color.check(%equipped.armor.ring,armor) $+ %equipped.armor.ring $+ 3 

  if ($readini($char($1), info, CustomTitle) != $null) { var %custom.title " $+ $readini($char($1), info, CustomTitle) $+ " }

  if ($readini(system.dat, system, botType) = IRC) { 
    if ($2 = channel) {  $display.message(3 $+ %real.name %custom.title is wearing %equipped.armor.head on $gender($1) head; %equipped.armor.body on $gender($1) body; %equipped.armor.legs on $gender($1) legs; %equipped.armor.feet on $gender($1) feet; %equipped.armor.hands on $gender($1) hands; %equipped.armor.ears on $gender($1) ears; %equipped.armor.neck on $gender($1) neck; %equipped.armor.wrists on $gender($1) wrists and  %equipped.armor.ring on $gender($1) ring finger. %real.name is currently using the %equipped.weapon weapon $iif(%equipped.shield != nothing, and %equipped.shield shield), private) }
    if ($2 != channel) {  $display.private.message(3 $+ %real.name %custom.title is wearing %equipped.armor.head on $gender($1) head; %equipped.armor.body on $gender($1) body; %equipped.armor.legs on $gender($1) legs; %equipped.armor.feet on $gender($1) feet; %equipped.armor.hands on $gender($1) hands; %equipped.armor.ears on $gender($1) ears; %equipped.armor.neck on $gender($1) neck; %equipped.armor.wrists on $gender($1) wrists and  %equipped.armor.ring on $gender($1) ring finger. %real.name is currently using the %equipped.weapon weapon $iif(%equipped.shield != nothing, and %equipped.shield shield)) }

  }

  unset %real.name
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's abilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readabilities {
  ; $1 = the person who's checking
  ; $2 = channel, private, dcc

  if (%abilities.list = $null) { 
    if ($2 = channel) { $display.message($translate(HasNoabilities, $1),private) | halt }
    if ($2 = private) { $display.private.message($translate(HasNoabilities, $1)) | halt }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(HasNoabilities, $1)) | halt }
  }

  if ($2 = channel) { $display.message($translate(ViewAbilities, $1, $3), private) }
  if ($2 = private) { $display.private.message($translate(ViewAbilities, $1, $3)) }
  if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewAbilities, $1, $3)) } 

  if (%abilities.list2 != $null) { $display.message(%abilities.list2, global) }
  if (%abilities.list3 != $null) { $display.message(%abilities.list3, global) }
  if (%abilities.list4 != $null) { $display.message(%abilities.list4, global) }

  unset %abilities.list*
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's spells
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readspells {
  ; $1 = the person who's checking
  ; $2 = channel, private, dcc

  if (%spells.list = $null) { 
    if ($2 = channel) { $display.message($translate(HasNospells, $1),private) | halt }
    if ($2 = private) { $display.private.message($translate(HasNospells, $1)) | halt }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(HasNospells, $1)) | halt }
  }

  if ($2 = channel) { $display.message($translate(ViewSpells, $1, $3), private) }
  if ($2 = private) { $display.private.message($translate(ViewSpells, $1, $3)) }
  if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewSpells, $1, $3)) } 

  if (%spells.list2 != $null) { $display.message(%spells.list2, global) }
  if (%spells.list3 != $null) { $display.message(%spells.list3, global) }
  if (%spells.list4 != $null) { $display.message(%spells.list4, global) }

  unset %spells.list*
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's armor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readarmor {
  ; $1 = the person who's checking
  ; $2 = channel, private, dcc
  ; $3 = the armor type we're searching for (head, body, legs, feet, hands, ears, neck, wrists, ring, shield)

  if (%armor.list = $null) { 
    if ($2 = channel) { $display.message($translate(HasNoArmor, $1, $3),private) | halt }
    if ($2 = private) { $display.private.message($translate(HasNoArmor, $1, $3)) | halt }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(HasNoArmor, $1, $3)) | halt }
  }

  if ($2 = channel) { $display.message($translate(ViewArmor, $1, $3), private) }
  if ($2 = private) { $display.private.message($translate(ViewArmor, $1, $3)) }
  if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewArmor, $1, $3)) } 

  if (%armor.list2 != $null) { $display.message(%armor.list2, global) }
  if (%armor.list3 != $null) { $display.message(%armor.list3, global) }
  if (%armor.list4 != $null) { $display.message(%armor.list4, global) }
  if (%armor.list5 != $null) { $display.message(%armor.list5, global) }
  if (%armor.list6 != $null) { $display.message(%armor.list6, global) }

  unset %armor.list*
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's weapons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readweapons {
  ; $1 = the person who's checking
  ; $2 = channel, private, dcc
  ; $3 = the wepaon type we're searching for (HandToHand, Sword, etc)

  if (%weapons.list = $null) { 
    if ($2 = channel) { $display.message($translate(HasNoweapons, $1, $3),private) | halt }
    if ($2 = private) { $display.private.message($translate(HasNoweapons, $1, $3)) | halt }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(HasNoweapons, $1, $3)) | halt }
  }

  if ($2 = channel) { $display.message($translate(Viewweapons, $1, $3), private) }
  if ($2 = private) { $display.private.message($translate(Viewweapons, $1, $3)) }
  if ($2 = dcc) { $dcc.private.message($nick, $translate(Viewweapons, $1, $3)) } 

  if (%weapons.list2 != $null) { $display.message(%weapons.list2, global) }
  if (%weapons.list3 != $null) { $display.message(%weapons.list3, global) }
  if (%weapons.list4 != $null) { $display.message(%weapons.list4, global) }
  if (%weapons.list5 != $null) { $display.message(%weapons.list5, global) }
  if (%weapons.list6 != $null) { $display.message(%weapons.list6, global) }

  unset %weapons.list*
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's items
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readitems { 
  if (%items.list != $null) { 
    if ($2 = channel) { $display.message($translate(ViewItems, $1),private) }
    if ($2 = private) { $display.private.message($translate(ViewItems, $1)) }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewItems, $1)) }
  }
  if (%items.list2 != $null) { 
    if ($2 = channel) { $display.message( $+ %items.list2,private) }
    if ($2 = private) { $display.private.message( $+ %items.list2) }
    if ($2 = dcc) { $dcc.private.message($nick,  $+ %items.list2) }
  }

  if (%crystal.items.list != $null) { 
    if ($2 = channel) { $display.message($translate(ViewCrystalItems, $1),private) }
    if ($2 = private) {  $display.private.message($translate(ViewCrystalItems, $1)) }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewCrystalItems, $1)) }
  }

  if (((%items.list = $null) && (%crystal.items.list = $null) && (%misc.items.list = $null))) { 
    var %items.empty true 

    if ($2 = channel) { $display.message($translate(HasNoItems, $1),private) }
    if ($2 = private) {  $display.private.message($translate(HasNoItems, $1)) }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(HasNoItems, $1)) }
  }    

  ; Display commands for other inventory items
  if (%items.empty != true) { 
    if ($2 = channel) { $display.message(3Other item commands:5 !spoils $+ 3 $+ $chr(44) 10!food,private) }
    if ($2 = private) {  $display.private.message(3Other item commands:5 !spoils $+ 3 $+ $chr(44) 10!food) }
    if ($2 = dcc) { $dcc.private.message($nick, 3Other item commands:5 !spoils $+ 3 $+ $chr(44) 10!food) }
  }

  unset %*.items.lis* | unset %items.lis*
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's food items
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readfood {

  if (%items.list != $null) { 
    if ($2 = channel) { $display.message($translate(ViewFoodItems, $1),private) }
    if ($2 = private) {  $display.private.message($translate(ViewFoodItems, $1)) }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewFoodItems, $1)) }
  }

  if (%items.list2 != $null) { 
    if ($2 = channel) { $display.message(10 $+ %items.list2,private) }
    if ($2 = private) { $display.private.message(10 $+ %items.list2) }
    if ($2 = dcc) { $dcc.private.message($nick,10  $+ %items.list2) }
  }

  if (%items.list = $null) { 
    if ($2 = channel) { $display.message($translate(HasNoFoodItems, $1),private) }
    if ($2 = private) { $display.private.message($translate(HasNoFoodItems, $1)) }
    if ($2 = dcc) {  $dcc.private.message($nick, $translate(HasNoFoodItems, $1)) }
  }    

  unset %*.items.lis* | unset %items.lis* 

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a char's misc items
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readspoils {
  if (%spoils.items.list != $null) {
    if ($2 = channel) { $display.message($translate(ViewSpoils, $1),private) 
      if (%spoils.items.list2 != $null) { $display.message( $+ %spoils.items.list2,private) } 
      if (%spoils.items.list3 != $null) { $display.message( $+ %spoils.items.list3,private) } 
      if (%spoils.items.list4 != $null) { $display.message( $+ %spoils.items.list4,private) }  
      if (%spoils.items.list5 != $null) { $display.message( $+ %spoils.items.list5,private) }    
      if (%spoils.items.list6 != $null) { $display.message( $+ %spoils.items.list6,private) }  
    }
    if ($2 = private) { $display.private.message($translate(ViewSpoils, $1)) 
      if (%spoils.items.list2 != $null) { $display.private.message(5 $+ %spoils.items.list2) } 
      if (%spoils.items.list3 != $null) { $display.private.message( $+ %spoils.items.list3) } 
      if (%spoils.items.list4 != $null) { $display.private.message( $+ %spoils.items.list4) } 
      if (%spoils.items.list5 != $null) { $display.private.message( $+ %spoils.items.list5) } 
      if (%spoils.items.list6 != $null) { $display.private.message( $+ %spoils.items.list6) } 
    }
    if ($2 = dcc) { $dcc.private.message($nick, $translate(ViewSpoils, $1)) 
      if (%spoils.items.list2 != $null) {  $dcc.private.message($nick,  $+ %spoils.items.list2) } 
      if (%spoils.items.list3 != $null) { $dcc.private.message($nick,  $+ %spoils.items.list3) } 
      if (%spoils.items.list4 != $null) { $dcc.private.message($nick,  $+ %spoils.items.list4) } 
      if (%spoils.items.list5 != $null) { $dcc.private.message($nick,  $+ %spoils.items.list5) } 
      if (%spoils.items.list6 != $null) { $dcc.private.message($nick,  $+ %spoils.items.list6) } 
    }
  }

  if (%spoils.items.list = $null) { 
    if ($2 = channel) { $display.message($translate(HasNoSpoils, $1),private) }
    if ($2 = private) { $display.private.message($translate(HasNoSpoils, $1)) }
    if ($2 = dcc) {  $dcc.private.message($nick, $translate(HasNoSpoils, $1)) }
  }    

  unset %*.items.lis* | unset %items.lis* 
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Revives a dead player
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
character.revive {
  ; $1 = player to revive
  ; $2 = revive amount (20% if missing)

  var %character.revive.percent $2 
  if (%character.revive.percent = $null) { var %character.revive.percent .20 }

  var %max.hp $resting.hp($1) 
  set %revive.current.hp $round($calc(%max.hp * %character.revive.percent),0)
  if (%revive.current.hp <= 0) { set %revive.current.hp 1 }
  writeini $char($1) battle hp %revive.current.hp
  writeini $char($1) battle status normal
  writeini $char($1) status revive no
  unset %revive.current.hp
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for buffs that enhance stats/defenses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
buff.check {
  ; $1 = the person we're checking
  ; $2 = the stat/defense we're checking
  ; $3 = the current stat/defense amount

  var %buff.increase 0

  if ($2 = max-vit) { 
    if ($status.check($1, ThrillOfBattle) != $null) { inc %buff.increase $floor($return_percentofvalue($3, 40)) }
  }

  if ($2 = max-pie) { 
  }

  if ($2 = str) { 
    if ($status.check($1, berserk) != $null) { inc %buff.increase $floor($return_percentofvalue($3, 25)) }
  }

  if ($2 = dex) { 
    ; abilities/spells that enhance dex go here
  }

  if ($2 = vit) { 
    ; abilities/spells that enhance dex go here
  }

  if ($2 = int) { 
    if ($status.check($1, attunement) != $null) { inc %buff.increase $floor($return_percentofvalue($3, 15)) }
  }

  if ($2 = mnd) { 
    if ($status.check($1, attunement) != $null) { inc %buff.increase $floor($return_percentofvalue($3, 15)) }
  }

  if ($2 = pie) { 
    ; abilities/spells that enhance piety go here
  }

  if ($2 = det) { 
    ; abilities/spells that enhance determination go here
  }

  if ($2 = defense) { 
    if ($status.check($1, protect) != $null) { inc %buff.increase $floor($return_percentofvalue($3, 15)) }
  }

  if ($2 = mdefense) { 
    if ($status.check($1, shell) != $null) { inc %buff.increase $floor($return_percentofvalue($3, 15)) }
  }

  if ($2 = reduceDmg) {
    if ($status.check($1, foresight) != $null) { inc %buff.increase $floor($return_percentofvalue($3, 25)) } 
  }

  if ($2 = speed) {
    if ($status.check($1, haste) != $null) { inc %buff.increase $floor($return_percentofvalue($3, 20)) }
    if ($status.check($1, swiftsong) != $null) { inc %buff.increase $floor($return_percentofvalue($3, 10)) }
  }

  if ($2 = CurePotency) {
    if ($status.check($1, DivineSeal) != $null) { inc %buff.increase $floor($return_percentofvalue($3, 30)) }
  }

  ; Status effects that decrease the enmity multiplier
  if ($2 = DecreaseEnmity) {
    if ($status.check($1, QuellingStrikes) != $null) { inc %buff.increase .5 }
  }

  ; Status effects that increase the enmity multiplier
  if ($2 = IncreaseEnmity) {
  }

  if ($2 = IncreaseMeleeDmg) {
    if ($status.check($1, Deliverance) != $null) { inc %buff.increase $floor($return_percentofvalue($3, 35)) }
  }

  if ($2 = IncreaseAbilityDmg) {
  }

  if ($2 = IncreaseRangedDmg) {
  }

  return %buff.increase
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the current status 
; effect amount if it's on
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
status.check { return $readini($char($1), StatusEffects, $2) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cycles through status effects
; and displays them
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
character.showstatus {
  ; Cycle through the Status Effects and add them to the list
  var %number.of.statuseffects $ini($char($1), StatusEffects, 0) | var %current.status.effect 1
  while (%current.status.effect <= %number.of.statuseffects) { 
    var %current.statuseffect.name $ini($char($1), StatusEffects, %current.status.effect)

    var %effect.type $readini($dbfile(statuseffects.db), %current.statuseffect.name, type)
    if (%effect.type = buff) { %status.buffs = $addtok(%status.buffs, $translate(%current.statuseffect.name), 46) } 
    if (%effect.type = effect) { %status.effects = $addtok(%status.effects, $translate(%current.statuseffect.name), 46) } 

    inc %current.status.effect
  }

  if (%status.effects = $null) && (%status.buffs = $null) { $display.message($translate(StatusNormal, $1)) | halt }

  if (%status.buffs != $null) { %status.buffs = $clean.list(%status.buffs) | $display.message.delay($translate(TurnStatusBuffs, $1), battle, 1) | unset %status.buffs }
  if (%status.effects != $null) { %status.effects = $clean.list(%status.effects) | $display.message.delay($translate(TurnStatusEffects, $1), battle, 1) | unset %status.effects }

  unset %status.effects
  unset %status.buffs

}
