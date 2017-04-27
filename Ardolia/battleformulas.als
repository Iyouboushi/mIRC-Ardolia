;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; battleformulas.als
;;;; Last updated: 04/27/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determines the damage
; display color
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
damage.color.check {
  if (%starting.damage > %attack.damage) { set %damage.display.color 6 }
  if (%starting.damage < %attack.damage) { set %damage.display.color 7 }
  if (%starting.damage = %attack.damage) { set %damage.display.color 4 }

  unset %starting.damage
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Goes through the modifiers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
damage.modifiers.check {
  ; $1 = the user
  ; $2 = the weapon or tech name
  ; $3 = the target
  ; $4 = melee or tech

  ;;;;;;;;;;;;;; All attacks check the weapon itself

  ; Check to see if the target is resistant/weak to the weapon itself

  $modifer_adjust($3, $readini($char($1), weapons, equipped))

  ; Check for Left-Hand weapon, if applicable
  if ($readini($char($1), equipped, weapon2) != nothing) { 
    var %weapon.type2 $readini($dbfile(weapons.db), $readini($char($1), equipment, weapon2), type)
    if (%weapon.type2 != shield) { $modifer_adjust($3, $readini($char($1), equipment, weapon2))  }
  }


  ;;;;;;;;;;;;;; Melee checks: weapon element and weapon type
  if ($4 = melee) { 

    var %weapon.element $readini($dbfile(weapons.db), $2, element)
    if ((%weapon.element != $null) && (%weapon.element != none)) {  $modifer_adjust($3, %weapon.element)  }

    ; Check for Left-Hand weapon element, if applicable
    if ((%weapon.type2 != $null) && (%weapon.type2 != shield)) { 
      var %weapon.element2 $readini($dbfile(weapons.db), $readini($char($1), weapons, EquippedLeft), Element )
      $modifer_adjust($3, %weapon.element2) 
    }

    ; Check for weapon type weaknesses.
    var %weapon.type $readini($dbfile(weapons.db), $2, type)
    $modifer_adjust($3, %weapon.type)

    ; Elementals are strong to melee
    if ($readini($char($3), monster, type) = elemental) { %attack.damage = $round($calc(%attack.damage - (%attack.damage * .30)),0) } 
  }

  ;;;;;;;;;;;;;; Techs check: tech name, tech element
  if ($4 = tech) { 

    ; Check for the tech name
    ; if $2 = element, use +techname, else use techname
    var %elements fire.earth.wind.water.ice.lightning.light.dark
    if ($istok(%elements, $2, 46) = $true) { $modifer_adjust($3, $chr(43) $+ $2) }
    else { $modifer_adjust($3, $2) }

    ; Check for the tech element
    var %tech.element $readini($dbfile(techniques.db), $2, element)

    if ((%tech.element != $null) && (%tech.element != none)) {
      if ($numtok(%tech.element,46) = 1) { $modifer_adjust($3, %tech.element) }
      if ($numtok(%tech.element,46) > 1) { 
        var %element.number 1 
        while (%element.number <= $numtok(%tech.element,46)) {
          var %current.tech.element $gettok(%tech.element, %element.number, 46)
          $modifer_adjust($3, %current.tech.element)
          inc %element.number 
        }
      } 
    }
  }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Modifier Checks for
; elements and weapon types
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
modifer_adjust {
  ; $1 = target
  ; $2 = element or weapon type

  if (%guard.message != $null) { return }

  ; Let's get the adjust value.
  var %modifier.adjust.value $readini($char($1), modifiers, $2)
  if (%modifier.adjust.value = $null) { var %modifier.adjust.value 100 }

  ; Check for accessories that cut elemental damage down.
  set %elements earth.fire.wind.water.ice.lightning.light.dark
  if ($istok(%elements,$2,46) = $true) {   
    if ($accessory.check($1, ElementalDefense) = true) {
      if (%accessory.amount = 0) { var %accessory.amount .50 }
      %modifier.adjust.value = $round($calc(%modifier.adjust.value * %accessory.amount),0)
      unset %accessory.amount
    }

    ; Check for augment to cut elemental damage down
    if ($augment.check($1, EnhanceElementalDefense) = true) { dec %modifier.adjust.value $calc(%augment.strength * 10) } 

    unset %current.accessory | unset %current.accessory.type | unset %accessory.amount
  }
  unset %elements

  ; Turn it into a deciminal
  var %modifier.adjust.value $calc(%modifier.adjust.value / 100) 

  if (($readini($char($1), info, flag) != $null) && ($readini($char($1), info, clone) != yes)) {
    ; If it's over 1, then it means the target is weak to the element/weapon so we can adjust the target's def a little as an extra bonus.
    if (%modifier.adjust.value > 1) {
      var %mon.temp.def $readini($char($1), battle, def)
      var %mon.temp.def = $round($calc(%mon.temp.def - (%mon.temp.def * .05)),0)
      if (%mon.temp.def < 0) { var %mon.temp.def 0 }
      writeini $char($1) battle def %mon.temp.def
      set %damage.display.color 7
    }

    ; If it's under 1, it means the target is resistant to the element/weapon.  Let's make the monster stronger for using something it's resistant to.

    if (%modifier.adjust.value < 1) {
      var %mon.temp.str $readini($char($1), battle, str)
      var %mon.temp.str = $round($calc(%mon.temp.str + (%mon.temp.str * .05)),0)
      if (%mon.temp.str < 0) { var %mon.temp.str 0 }
      writeini $char($1) battle str %mon.temp.str
      set %damage.display.color 6
    }
  }

  ; Adjust the attack damage.
  set %attack.damage $round($calc(%attack.damage * %modifier.adjust.value),0)
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates the evasion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate.evasion { 
  ; $1 = the person we need the evasion for
  ; $2 = the target 

  var %evasion 0

  var %evasion $roll(2d6)

  if ($get.level($1) < $get.level($2)) { var %evasion $roll(1d6) }

  inc %evasion $current.dex($2)

  if ($flag($2) = $null) { inc %evasion $readini($jobfile($current.job($1)), BasicInfo, Evasion) }
  else { inc %evasion $readini($char($2), BaseStats, Evasion) }

  return %evasion
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates accuracy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate.accuracy {
  ; $1 = the person we need the accuracy for
  ; $2 = the target
  ; $3 = melee or spell

  var %accuracy $roll(2d6)

  if ($get.level($1) < $get.level($2)) { var %accuracy $roll(1d6) }

  if ($3 = melee) {
    inc %accuracy $round($calc($current.dex($1) /2),0)
    if ($flag($2) = $null) { inc %accuracy $readini($jobfile($current.job($1)), BasicInfo, Accuracy) }
    else { inc %accuracy $readini($char($2), BaseStats, accuracy) }
  }

  if ($3 = spell) { 
    inc %accuracy $current.mag($1)
    if ($flag($2) = $null) {  inc %accuracy $readini($jobfile($current.job($1)), BasicInfo, MAccuracy)  }
    else { inc %accuracy $readini($char($2), BaseStats, MAccuracy) }
  }

  return %accuracy
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates weapon power
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate.wpn.damage {
  ; $1 = the person we're checking
  ; $2 = the weapon

  var %weapon.power 0

  ; Increase # of hits
  inc %number.of.hits $readini($dbfile(weapons.db), $2, Hits)

  ; Get the stat multiplier for the weapon  
  var %stat.multiplier $readini($dbfile(weapons.db), $2, Multiplier)
  if (%stat.multiplier = $null) { var %stat.multiplier 1 }

  ; Get the base weapon damage done
  var %weapon.power $roll($readini($dbfile(weapons.db), $2, Damage))

  ; Add in the stat to the damage
  if ($readini($dbfile(weapons.db), $2, Ranged) = true) { 
    var %stat.power $current.agi($1) | inc %stat.power $bonus.stat($1, agi) 
    inc %weapon.power $calc(%stat.power * %stat.multiplier)  
  }
  else { 
    var %stat.power $current.str($1) | inc %stat.power $bonus.stat($1, str) 
    inc %weapon.power $calc(%stat.power * %stat.multiplier)  
  }

  echo -a attack damage: %weapon.power

  return %weapon.power
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates defense
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate.defense {
  ; $1 = the person
  ; $2 = melee or spell

  var %defense 0

  if ($2 = melee) {

    if ($flag($1) = monster) { inc %defense $readini($char($1), BaseStats, Defense) }
    else {   
      if ($return.equipped($1, head) != nothing) { inc %defense $readini($dbfile(equipment.db), $return.equipped($1, head), Defense) }
      if ($return.equipped($1, body) != nothing) { inc %defense $readini($dbfile(equipment.db), $return.equipped($1, body), Defense) }
      if ($return.equipped($1, legs) != nothing) { inc %defense $readini($dbfile(equipment.db), $return.equipped($1, legs), Defense) }
      if ($return.equipped($1, feet) != nothing) { inc %defense $readini($dbfile(equipment.db), $return.equipped($1, feet), Defense) }
      if ($return.equipped($1, hands) != nothing) { inc %defense $readini($dbfile(equipment.db), $return.equipped($1, hands), Defense) }
    }


    var %stat.bonus $current.def($1)
    inc %stat.bonus $bonus.stat($1, def)

    var %stat.bonus $round($calc(%stat.bonus / 4),0)

    inc %defense %stat.bonus

  }

  if ($2 = spell) {
    if ($flag($1) = monster) { inc %defense $readini($char($1), BaseStats, MDefense) }
    else {
      if ($return.equipped($1, head) != nothing) { inc %defense $readini($dbfile(equipment.db), $return.equipped($1, head), MDefense) }
      if ($return.equipped($1, body) != nothing) { inc %defense $readini($dbfile(equipment.db), $return.equipped($1, body), MDefense) }
      if ($return.equipped($1, legs) != nothing) { inc %defense $readini($dbfile(equipment.db), $return.equipped($1, legs), MDefense) }
      if ($return.equipped($1, feet) != nothing) { inc %defense $readini($dbfile(equipment.db), $return.equipped($1, feet), MDefense) }
      if ($return.equipped($1, hands) != nothing) { inc %defense $readini($dbfile(equipment.db), $return.equipped($1, hands), MDefense) }
    }

    var %stat.bonus $current.mag($1)
    inc %stat.bonus $bonus.stat($1, mag)

    var %stat.bonus $round($calc(%stat.bonus / 4),0)

    inc %defense %stat.bonus
  }

  return %defense
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Melee Formula for Players
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.melee.player {
  ; $1 = %user
  ; $2 = weapon equipped
  ; $3 = target / %enemy 

  set %number.of.hits 0

  ; None of this is correct right now.  This is just a block of dummy code just for testing the bot.
  ; This file will not be done until a battle system has been decided upon.

  set %attack.damage 1

  ; Check for modifiers
  set %starting.damage %attack.damage
  ; $damage.modifiers.check($1, %weapon.equipped.right, $3, melee)
  $damage.color.check
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Melee Formula for Monsters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.melee.monster {
  ; $1 = %user
  ; $2 = weapon equipped
  ; $3 = target / %enemy 

  set %number.of.hits 0

  ; STEP 1: Calculate weapon damage
  set %attack.damage $calculate.wpn.damage($1, %weapon.equipped.right)

  if ((%weapon.equipped.left != nothing) && ($readini($dbfile(weapons.db), %weapon.equipped.left, type) != shield)) { 
    inc %attack.damage $round($calc($calculate.wpn.damage($1, %weapon.equipped.left) / 2),0)
  }

  ; Check for critical hit
  var %critical.hit.roll $roll(1d100)
  if (%critical.hit.roll <= 10) { inc %attack.damage %attack.damage | $display.message($readini(translation.dat, battle, LandsACriticalHit),battle) }

  ; STEP 2: Calculate target's defense
  var %target.defense $calculate.defense($3, melee)

  ; STEP 3: Calculate actual damage
  dec %attack.damage %target.defense
  %attack.damage = $round($calc(%attack.damage * (1 + ($get.level($1) / 10))),0)

  ; Check for modifiers
  set %starting.damage %attack.damage
  $damage.modifiers.check($1, %weapon.equipped.right, $3, melee)
  $damage.color.check

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Tech Formula for Players
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.tech.player {

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WpnSkill Formula for Monsterss
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.tech.monster {

}
