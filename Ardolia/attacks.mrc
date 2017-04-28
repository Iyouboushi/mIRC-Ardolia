;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ATTACKS COMMAND
;;;; Last updated: 04/28/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON 3:ACTION:attacks *:#:{ 
  $no.turn.check($nick)
  $set_chr_name($nick) 
  $partial.name.match($nick, $2)
  $covercheck(%attack.target)
  $attack_cmd($nick , %attack.target) 
} 
on 3:TEXT:!attack *:#:{ 
  $no.turn.check($nick)
  $set_chr_name($nick)
  $partial.name.match($nick, $2)
  $covercheck(%attack.target)
  $attack_cmd($nick , %attack.target) 
} 

ON 50:TEXT:*attacks *:*:{ 
  if ($2 != attacks) { halt } 
  else { 
    $no.turn.check($1,admin)
    if ($readini($char($1), Battle, HP) = $null) { halt }
    $set_chr_name($1) 
    $partial.name.match($1, $3)
    $covercheck(%attack.target)
    $attack_cmd($1 , %attack.target) 
  }
}

alias attack_cmd { 
  $check_for_battle($1) | $person_in_battle($2) | $checkchar($2) | var %user.flag $flag($1) | var %target.flag $flag($2) 
  var %ai.type $readini($char($1), info, ai_type)

  if ((%ai.type != berserker) && (%covering.someone != on)) {
    if (%mode.pvp != on) {
      if ($2 = $1) {
        if (($is_confused($1) = false) && ($is_charmed($1) = false))  { $display.message($translate(Can'tAttackYourself, $1), private) | unset %real.name | halt  }
      }
    }
  }

  if ($is_charmed($1) = true) { var %user.flag monster }
  if ($is_confused($1) = true) { var %user.flag monster } 
  if (%tech.type = heal) { var %user.flag monster }
  if (%tech.type = heal-aoe) { var %user.flag monster }
  if (%mode.pvp = on) { var %user.flag monster }
  if (%ai.type = berserker) { var %user.flag monster }
  if (%covering.someone = on) { var %user.flag monster }

  if ((%user.flag != monster) && (%target.flag != monster)) { $set_chr_name($1) | $display.message($translate(CanOnlyAttackMonsters, $1),private)  | halt }
  if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message($translate(CanNotAttackWhileUnconcious, $1),private)  | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | $display.message($translate(CanNotAttackSomeoneWhoIsDead, $1, $2),private) | unset %real.name | halt }
  if ($readini($char($2), Battle, Status) = RunAway) { $set_chr_name($1) | $display.message($translate(CanNotAttackSomeoneWhoFled, $1, $2),private) | unset %real.name | halt } 

  ; Make sure the old attack damages have been cleared, and clear a few variables.
  unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %target.flag | unset %trickster.dodged | unset %covering.someone
  unset %techincrease.check |  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
  unset %multihit.message.on | unset %critical.hit.chance | unset %drainsamba.on | unset %absorb | unset %counterattack
  unset %shield.block.line | unset %inflict.meleewpn

  ; Get the weapon equipped
  $weapon_equipped($1) 

  ; Does the weapon require ammo to swing?  If so, check to see if we have enough ammo (this only applies for players)
  var %weapon.ammo $readini($dbfile(weapons.db), %weapon.equipped, AmmoRequired)
  if ((%weapon.ammo != $null) && (%user.flag != monster)) {
    var %weapon.ammo.amount $readini($dbffile(weapons.db), %weapon.equipped, AmmoAmountNeeded)
    if (%weapon.ammo.amount = $null) { var %weapon.ammo.amount 1 }

    var %player.ammo.amount $readini($char($1), item_amount, %weapon.ammo)
    if (%player.ammo.amount = $null) { var %player.ammo.amount 0 }

    if (%player.ammo.amount < %weapon.ammo.amount) { $display.message($translate(NeedAmmoToDoThis), private) | unset %weapon.equipped | halt }
    dec %player.ammo.amount %weapon.ammo.amount
    writeini $char($1) item_amount %weapon.ammo %player.ammo.amount
  }

  var %action.points.to.decrease $round($log($readini($dbfile(weapons.db), %weapon.equipped, basepower)),0)
  if (%action.points.to.decrease <= 0) { inc %action.points.to.decrease 1 }

  ; Decrease the action point cost
  $action.points($1, remove, %action.points.to.decrease)

  ; Stop the battlenext timer til this action is finished
  /.timerBattleNext off

  ; If it's an AOE attack, perform that here.  Else, do a single hit.

  if ($readini($dbfile(weapons.db), %weapon.equipped, target) != aoe) {

    ; Calculate, deal, and display the damage..
    $calculate_damage_weapon($1, %weapon.equipped, $2)

    ; Deal the damage done
    $deal_damage($1, $2, %weapon.equipped, melee)

    ; Display the damage done
    $display_damage($1, $2, weapon, %weapon.equipped)

    unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
    unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged | unset %covering.someone
    unset %techincrease.check |  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
    unset %multihit.message.on | unset %critical.hit.chance

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }

  if ($readini($dbfile(weapons.db), %weapon.equipped, target) = aoe) {

    if ($is_charmed($1) = true) { 
      var %current.flag $readini($char($1), info, flag)
      if ((%current.flag = $null) || (%current.flag = npc)) { $melee.aoe($1, %weapon.equipped, $2, player) | halt }
      if (%current.flag = monster) { $melee.aoe($1, %weapon.equipped, $2, monster) | halt }
    }
    else {
      ; check for confuse.
      if ($is_confused($1) = true) { 
        var %random.target.chance $rand(1,2)
        if (%random.target.chance = 1) { var %user.flag monster }
        if (%random.target.chance = 2) { unset %user.flag }
      }

      ; Determine if it's players or monsters
      if (%user.flag = monster) { $melee.aoe($1, %weapon.equipped, $2, player) | halt }
      if ((%user.flag = $null) || (%user.flag = npc)) { $melee.aoe($1, %weapon.equipped, $2,monster) | halt }
    }

  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates Melee Damage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Although it's being worked on, this isn't finished
alias calculate_damage_weapon {
  ; $1 = %user
  ; $2 = weapon equipped
  ; $3 = target / %enemy 

  echo -a step 1: Determine if we hit or not

  var %attacker.acc $calculate.accuracy($1, $3, melee)
  var %defender.evasion $calculate.evasion($1, $3)

  var %to.hit.chance 50
  inc %to.hit.chance %attacker.acc
  dec %to.hit.chance %defender.evasion

  echo -a accuracy: %attacker.acc :: evasion: %defender.evasion :: to hit chance: %to.hit.chance

  if (%to.hit.chance >= 100) { var %to.hit.chance 90 }
  if (%to.hit.chance < 10) { var %to.hit.chance 10 }

  var %hit.chance $roll(1d100)
  echo -a hit chance: %hit.chance

  var %hit.chance 1

  ; Check to see if the target dodged it
  ;  if (%attacker.acc < %defender.evasion) { set %guard.message $readini(translation.dat, battle, NormalDodge) }
  if (%hit.chance > %to.hit.chance) { set %guard.message $readini(translation.dat, battle, NormalDodge) }

  ; Check for third eye dodge here in the future

  if (%guard.message != $null) { set %attack.damage 0 | return }

  if ($flag($1) = monster) { $formula.melee.monster($1, $2, $3, $4) }
  else { $formula.melee.player($1, $2, $3, $4) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs a melee AOE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This code is largely unchanged from BattleArena and needs to be worked
alias melee.aoe {
  ; $1 = user
  ; $2 = weapon name
  ; $3 = target
  ; $4 = type, either player or monster 

  set %wait.your.turn on

  unset %who.battle | set %number.of.hits 0
  unset %absorb  | unset %element.desc

  ; Display the weapon type description
  $set_chr_name($1) | set %user %real.name
  if ($person_in_mech($1) = true) { set %user %real.name $+ 's $readini($char($1), mech, name) } 

  var %enemy all targets

  var %weapon.type $readini($dbfile(weapons.db), $2, type) |  var %attack.file $txtfile(attack_ $+ %weapon.type $+ .txt) 

  $display.message(3 $+ %user $+  $read %attack.file  $+ 3., battle)
  set %showed.melee.desc true

  if ($readini($dbfile(weapons.db), $2, absorb) = yes) { set %absorb absorb }

  var %melee.element $readini($dbfile(weapons.db), $2, element)

  ; If it's player, search out remaining players that are alive and deal damage and display damage
  if ($4 = player) {
    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }
      else { 

        if (($readini($char($1), status, confuse) != yes) && ($1 = %who.battle)) { inc %battletxt.current.line 1 }

        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
        else { 

          if ($readini($char($1), battle, hp) > 0) {
            inc %number.of.hits 1
            var %target.element.heal $readini($char(%who.battle), modifiers, heal)
            if ((%melee.element != none) && (%melee.element != $null)) {
              if ($istok(%target.element.heal,%melee.element,46) = $true) { 
                $heal_damage($1, %who.battle, %weapon.equipped)
                inc %battletxt.current.line 1 
              }
            }

            if (($istok(%target.element.heal,%melee.element,46) = $false) || (%melee.element = none)) { 

              $covercheck(%who.battle, $2, AOE)

              $calculate_damage_weapon($1, %weapon.equipped, %who.battle)
              $deal_damage($1, %who.battle, %weapon.equipped, melee)

              $display_aoedamage($1, %who.battle, $2, %absorb, melee)
              unset %attack.damage

            }
          }

          unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
          unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged | unset %covering.someone
          unset %techincrease.check |  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
          unset %multihit.message.on | unset %critical.hit.chance

          inc %battletxt.current.line 1 | inc %aoe.turn 1
        } 
      }
    }
  }


  ; If it's monster, search out remaining monsters that are alive and deal damage and display damage.
  if ($4 = monster) { 
    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 | set %aoe.turn 1
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      if ($readini($char(%who.battle), info, flag) != monster) { inc %battletxt.current.line }
      else { 
        inc %number.of.hits 1
        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { inc %battletxt.current.line 1 }
        else { 
          if ($readini($char($1), battle, hp) > 0) {

            var %target.element.heal $readini($char(%who.battle), modifiers, heal)
            if ((%melee.element != none) && (%melee.element != $null)) {
              if ($istok(%target.element.heal,%melee.element,46) = $true) { 
                $heal_damage($1, %who.battle, %weapon.equipped)
              }
            }

            if (($istok(%target.element.heal,%melee.element,46) = $false) || (%melee.element = none)) { 
              $covercheck(%who.battle, $2, AOE)


              $calculate_damage_weapon($1, %weapon.equipped, %who.battle)
              $deal_damage($1, %who.battle, %weapon.equipped, melee)
              $display_aoedamage($1, %who.battle, $2, %absorb, melee)

            }
          }

          unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
          unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged | unset %covering.someone
          unset %techincrease.check |  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
          unset %multihit.message.on | unset %critical.hit.chance

          inc %battletxt.current.line 1 | inc %aoe.turn 1 | unset %attack.damage
        } 
      }
    }
  }

  unset %element.desc | unset %showed.melee.desc | unset %aoe.turn
  set %timer.time $calc(%number.of.hits * 1.1) 

  if ($readini($dbfile(weapons.db), $2, magic) = yes) {
    ; Clear elemental seal
    if ($readini($char($1), skills, elementalseal.on) = on) { 
      writeini $char($1) skills elementalseal.on off 
    }
  }

  unset %statusmessage.display
  if ($readini($char($1), battle, hp) > 0) {
    set %inflict.user $1 | set %inflict.meleewpn $2 
    $self.inflict_status(%inflict.user, %inflict.meleewpn, melee)
    if (%statusmessage.display != $null) { $display.message(%statusmessage.display, battle) | unset %statusmessage.display }
  }


  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  if (%timer.time > 20) { %timer.time = 20 }

  unset %melee.element | $formless_strike_check($1)

  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 %timer.time /check_for_double_turn $1
  halt
}
