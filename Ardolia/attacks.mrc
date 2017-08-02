;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ATTACKS COMMAND
;;;; Last updated: 08/01/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Melee Commands and code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

  ; Write that we used this as the last action
  writeini $txtfile(battle2.txt) Actions $1 melee 

  ; Stop the battlenext timer til this action is finished
  /.timerBattleNext off

  ; If it's an AOE attack, perform that here.  Else, do a single hit.

  if ($readini($dbfile(weapons.db), %weapon.equipped, target) != aoe) {

    ; Calculate, deal, and display the damage..
    $calculate_damage_weapon($1, %weapon.equipped, $2)
    $buff.check($1, IncreaseMeleeDmg, %attack.damage)

    ; Deal the damage done
    $deal_damage($1, $2, %weapon.equipped, melee)

    ; Display the damage done
    $display_damage($1, $2, weapon, %weapon.equipped)

    ; Increase the total number of times this player has done a melee hit
    $miscstats($1, add, MeleeHits, 1)

    unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
    unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged | unset %covering.someone
    unset %techincrease.check |  unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
    unset %multihit.message.on | unset %critical.hit.chance

    ; Time to go to the next turn
    if (%battleis = on)  { $check_for_double_turn($1) | halt }
  }


  ; Melee AOEs are unfinished at the moment. This is code left over from BattleArena.
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

  $calculate.accuracy($1, $3)
  if (%guard.message != $null) { set %attack.damage 0 | return }

  if ($flag($1) = monster) { $formula.melee.monster($1, $2, $3, $4) }
  else { $formula.melee.player($1, $2, $3, $4) }
}
