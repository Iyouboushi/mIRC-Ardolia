;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; battleformulas.als
;;;; Last updated: 05/29/17
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

  $modifer_adjust($3, $return.equipped($1, weapon))

  ;;;;;;;;;;;;;; Melee checks: weapon element and weapon type
  if ($4 = melee) { 

    var %weapon.element $readini($dbfile(weapons.db), $2, element)
    if ((%weapon.element != $null) && (%weapon.element != none)) {  $modifer_adjust($3, %weapon.element)  }

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

  return %evasion
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates accuracy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate.accuracy {
  ; $1 = the person we need the accuracy for
  ; $2 = the target

  ; For players the max accuracy is 95%, lowest accuracy is 5%
  var %accuracy 90

  ; Monsters have a higher max accuracy
  if ($flag($1) = monster) { var %accuracy 175 }
  else { 

    ; If the attacker level is equal or higher than the target's then accuracy is 95% for players
    if ($get.level($1) >= $get.level($2)) { var %accuracy 95 }
  }

  ; Otherwise, accuracy decreases.
  if ($get.level($1) < $get.level($2)) { 
    dec %accuracy $calc($get.level($2) - $get.level($1))
  }

  ; check for status effects that lower accuracy
  if ($status.check($1, blind) != $null) { dec %accuracy $calc(%accuracy * .5) }

  ; check for status effects that raise accuracy
  if ($status.check($1, Hawk'sEye) != $null) { inc %accuracy 25 }


  ; We never want accuracy to be below 5%
  if (%accuracy < 5) { var %accuracy 5 }

  ; And we never want accuracy above 95 for players
  if ((%accuracy > 95) && ($flag($1) != monster)) { var %accuracy 95 }

  ; Roll the dice!
  var %hit.chance $roll(1d100)

  ; Check to see if the player has hit the target
  if (%hit.chance <= %accuracy) { return }
  else { 

    set %guard.message $translate(NormalDodge, $2) 

    ; Increase the total number of times this target has dodged
    $miscstats($2, add, TimesDodged, 1)

  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates weapon power
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate.wpn.damage {
  ; $1 = the person we're checking

  var %weapon.damage $weapon.damage($1)
  var %weapon.speed $weapon.speed($1)
  var %stat.needed $weapon.stat($1, $2)

  if (%stat.needed = str) { var %current.stat $current.str($1) } 
  if (%stat.needed = dex) { var %current.stat $current.dex($1) } 
  if (%stat.needed = vit) { var %current.stat $current.vit($1) } 
  if (%stat.needed = int) { var %current.stat $current.int($1) } 
  if (%stat.needed = mnd) { var %current.stat $current.mnd($1) } 
  if (%stat.needed = pie) { var %current.stat $current.pie($1) } 

  var %current.det $current.det($1)

  var %base.melee.damage $abs($calc((%weapon.damage * .2714745 + %current.stat * .1006032 + (%current.det -202) * .0241327 + %weapon.damage * %current.stat * .0036167 + %weapon.damage * (%weapon.det - 202) * .0022597 - 1) * (%weapon.speed / 3)))
  inc %base.melee.damage $rand(1,2)

  return $round(%base.melee.damage,0)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates ability damage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate.ability.damage {
  ; $1 = the person we're checking
  ; $2 = ability name

  var %weapon.damage $weapon.damage($1)
  var %stat.needed $readini($dbfile(abilities.db), $2, stat)
  var %potency $readini($dbfile(abilities.db), $2, potency)
  if (%potency = $null) { var %potency 100 }

  if (%stat.needed = str) { var %current.stat $current.str($1) } 
  if (%stat.needed = dex) { var %current.stat $current.dex($1) } 
  if (%stat.needed = vit) { var %current.stat $current.vit($1) } 
  if (%stat.needed = int) { var %current.stat $current.int($1) } 
  if (%stat.needed = mnd) { var %current.stat $current.mnd($1) } 
  if (%stat.needed = pie) { var %current.stat $current.pie($1) } 

  var %current.det $current.det($1)

  var %det.calculation $calc(%current.det - 202)
  var %base.ability.damage $abs($calc((%weapon.damage *.2714745 + %current.stat * .1006032 + %det.calculation * .0241327 + %weapon.damage * %current.stat * .0036167 + %weapon.damage * %det.calculation *.0022597 - 1)))
  var %base.ability.damage $abs($calc((%potency / 100) * %base.ability.damage))

  inc %base.ability.damage $roll(1d3)

  return $round(%base.ability.damage,0)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates spell damage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate.spell.damage {
  ; $1 = the person we're checking
  ; $2 = ability name

  var %weapon.damage $weapon.damage($1)
  var %stat.needed $readini($dbfile(spells.db), $2, stat)
  var %potency $readini($dbfile(spells.db), $2, potency)

  if (%potency = $null) { var %potency 100 }
  if (%stat.needed = $null) { var %stat.needed int }

  if (%stat.needed = str) { var %current.stat $current.str($1) } 
  if (%stat.needed = dex) { var %current.stat $current.dex($1) } 
  if (%stat.needed = vit) { var %current.stat $current.vit($1) } 
  if (%stat.needed = int) { var %current.stat $current.int($1) } 
  if (%stat.needed = mnd) { var %current.stat $current.mnd($1) } 
  if (%stat.needed = pie) { var %current.stat $current.pie($1) } 

  var %current.det $current.det($1)
  var %base.spell.damage $calc(%weapon.damage * (0.01156 * %weapon.damage + 0.001314 * %current.det + 0.3736) + (0.2229 * %current.stat) + (0.06071 * %current.det) + 1.7786))
  var %base.spell.damage $abs($calc((%potency / 100) * %base.spell.damage)) 
  inc %base.spell.damage $rand(1,2)
  return $round(%base.spell.damage,0)

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates defense
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calculate.defense {
  ; $1 = the person
  ; $2 = physical or magical

  var %defense.percent 100

  if ($2 = physical) { var %defense $current.defense($1) }
  if (($2 = spell) || ($2 = magical)) { var %defense $current.mdefense($1) }

  var %defense.percent $abs($calc(1 - (0.044 * %defense)))
  if (%defense.percent = 1) { return 1 }
  else { 

    var %defense.percent $calc((100-%defense.percent)/100)


    return %defense.percent
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Melee Formula for Players
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.melee.player {
  ; $1 = %user
  ; $2 = weapon equipped
  ; $3 = target / %enemy 

  set %attack.damage $calculate.wpn.damage($1, $2)
  var %damage.defense.percent $calculate.defense($3, physical)

  set %attack.damage $floor($calc(%attack.damage * %damage.defense.percent))
  if (%attack.damage <= 0) { set %attack.damage 1 }

  ; Check for modifiers
  set %starting.damage %attack.damage
  $damage.color.check
  ; to be added
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Melee Formula for Monsters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.melee.monster {
  ; $1 = %user
  ; $2 = weapon equipped
  ; $3 = target / %enemy 

  set %attack.damage $calculate.wpn.damage($1)
  var %damage.defense.percent $calculate.defense($3, physical)

  set %attack.damage $floor($calc(%attack.damage * %damage.defense.percent))
  if (%attack.damage <= 0) { set %attack.damage 1 }

  ; Check for modifiers
  set %starting.damage %attack.damage
  $damage.color.check
  ; to be added

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Attack Ability Formula
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formula.ability {
  ; $1 = the person we're checking
  ; $2 = the ability name
  ; $3 = the target

  set %attack.damage $calculate.ability.damage($1, $2)
  var %damage.defense.percent $calculate.defense($3, physical)

  set %attack.damage $floor($calc(%attack.damage * %damage.defense.percent))
  if (%attack.damage <= 0) { set %attack.damage 1 }
}
