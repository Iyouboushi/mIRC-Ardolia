;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; abilities.mrc
;;;; Last updated: 10/04/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ability Commands and code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 2:ACTION:uses * *:#:{ 
  $no.turn.check($nick)

  ; Are we in battle?
  $check_for_battle($nick) 

  $set_chr_name($nick)
  if ($4 != on) { 
    if ($readini($dbfile(abilities.db), $3, type) = buff) { $partial.name.match($nick, $nick) }
    else { halt }
  }

  if (%attack.target = $null) { $partial.name.match($nick, $5) }
  $ability_cmd($nick , $3 , %attack.target, $7) | halt 
} 

ON 2:TEXT:!ability *:#:{ 
  $no.turn.check($nick) 

  ; Are we in battle?
  $check_for_battle($nick) 

  $set_chr_name($nick)

  if ($3 != on) { 
    if ($readini($dbfile(abilities.db), $2, type) = buff) { $partial.name.match($nick, $nick) }
    else { halt }
  }

  if (%attack.target = $null) { $partial.name.match($nick, $4) }
  $ability_cmd($nick , $2 , %attack.target, $5) | halt 
} 

ON 2:TEXT:!tech *:#:{ 
  $no.turn.check($nick) 

  ; Are we in battle?
  $check_for_battle($nick) 

  $set_chr_name($nick)

  if ($3 != on) { 
    if ($readini($dbfile(abilities.db), $2, type) = buff) { $partial.name.match($nick, $nick) }
    else { halt }
  }

  if (%attack.target = $null) { $partial.name.match($nick, $4) }
  $ability_cmd($nick , $2 , %attack.target, $5) | halt 
} 

ON 50:TEXT:*uses * * on *:*:{ 
  if ($1 = uses) { halt }
  if ($3 = item) { halt }
  if ($5 != on) { halt }

  $no.turn.check($1,admin)

  ; Are we in battle?
  $check_for_battle($1) 

  if ($6 = $null) { $partial.name.match($1, $1) }
  else { $partial.name.match($1, $6) } 

  $ability_cmd($1 , $4,  %attack.target) 
  halt 
}

;=================
; The Ability command
;=================
alias ability_cmd {
  ; $1 = user
  ; $2 = Ability used
  ; $3 = target

  ; Make sure some old attack variables are cleared.
  unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged 
  unset %abilityincrease.check | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
  unset %multihit.message.on  | unset %lastaction.nerf

  ; Are we in an adventure?
  if (%adventureis = off) { halt }

  ; Can this ability be used outside of battle?
  if ($readini($dbfile(abilities.db), $2, CanUseOutsideBattle) != true) {  
    $check_for_battle($1) 
    $no.turn.check($1,admin)
  }

  if (%attack.target = $null) { set %attack.target $3 } 

  var %ability.type $readini($dbfile(abilities.db), $2, Type) | $amnesia.check($1, ability) 

  if ($flag($1) != monster) {

    if ((no-ability isin %battleconditions) || (no-abilities isin %battleconditions)) { 
      if (($readini($char($1), info, ai_type) != healer) && ($readini($char($1), info, ai_type) != abilityonly)) { 
        $set_chr_name($1) | $display.message($translate(NotAllowedBattleCondition),private) | unset %attack.target | halt 
      }
    }

    if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message($translate(CanNotAttackWhileUnconcious, $1),private)  | unset %attack.target | unset %real.name | halt }
    if ($readini($char($3), Battle, Status) = dead) { $set_chr_name($1) | $display.message($translate(CanNotAttackSomeoneWhoIsDead, $1, $3),private) | unset %attack.target | unset %real.name | halt }
    if ($readini($char($3), Battle, Status) = RunAway) { $set_chr_name($1) | $display.message($translate(CanNotAttackSomeoneWhoFled, $1, $3),private) | unset %attack.target | unset %real.name | halt } 

    ; Can this ability be used outside of battle?
    if ($readini($dbfile(abilities.db), $2, CanUseOutsideBattle) != true) {  
      if (%battleis != on) { $display.message($translate(NoBattleCurrently), private) | halt }

      echo -a here :: %ability.type

      ; Check for a specific buff message
      if (($istok($readini($txtfile(battle2.txt), Battle, List),$1,46) = $false) && (%ability.type = buff)) { echo -a false | $display.message($translate(UseBuffOnYourself, $1, $2),private) | unset %real.name | unset %attack.target | halt }

      $person_in_battle($3)
      $no.turn.check($1,admin)
    }

    if ($flag($1) != monster) { 
      ; does this ability exist?
      if ($readini($dbfile(abilities.db), $2, job) = $null) { $display.message($translate(NoSuchAbility, $1, $2) , private) | halt }

      ; Can this job use this ability?
      var %jobs.list $readini($dbfile(abilities.db), $2, job)
      if (($istok(%jobs.list, $current.job($1), 46) = $false) && (%jobs.list != all))  { $display.message($translate(WrongJobToUseAbility, $1, $2) , private) | halt }
    }

    ; Are we high enough level to use this ability?
    var %ability.level $readini($dbfile(abilities.db), $2, level)
    if ($get.level($1) < %ability.level) { $display.message($translate(NotRightLevelForAbility, $1, $2),private) | halt }
  }

  ; Can we use this ability again so soon?
  $cooldown.check($1, $2, ability)

  ; Make sure the user has enough TP to use this in battle..
  var %tp.needed $readini($dbfile(abilities.db), $2, Cost) | var %tp.have $current.tp($1)
  if (%tp.needed > %tp.have) { $display.message($translate(NotEnoughTPForAbility, $1, $2),private) | halt }

  if (%mode.pvp != on) {
    if ($3 = $1) {
      if (($is_confused($1) = false) && ($is_charmed($1) = false))  { 
        if (%ability.type !isin heal.heal-AOE.buff.ClearStatusNegative.ClearStatusPositive) { $set_chr_name($1) | $display.message($translate(Can'tAttackYourself, $1),private) | unset %real.name | halt  }
      }
    }
  }

  var %user.flag $readini($char($1), info, flag) | var %target.flag $readini($char($3), info, flag)
  var %ai.type $readini($char($1), info, ai_type)

  if ($is_charmed($1) = true) { var %user.flag monster }
  if ($is_confused($1) = true) { var %user.flag monster } 
  if (%ability.type = heal) { var %user.flag monster }
  if (%ability.type = heal-aoe) { var %user.flag monster }
  if (%mode.pvp = on) { var %user.flag monster }
  if (%ai.type = berserker) { var %user.flag monster }
  if (%covering.someone = on) { var %user.flag monster }

  if ((%ability.type != buff) && (%ability.type != heal))  {
    if ((%user.flag != monster) && (%target.flag != monster)) { $set_chr_name($1) | $display.message($translate(CanOnlyAttackMonsters, $1),private)  | unset %attack.target | halt }
  }

  ; Decrease the TP used
  dec %tp.have %tp.needed
  writeini $char($1) Battle TP %tp.have

  ; Check for a prescript
  if ($readini($dbfile(abilities.db), n, $2, PreScript) != $null) { $readini($dbfile(abilities.db), p, $2, PreScript) }

  ; Write to the file that we just used this ability
  writeini $char($1) cooldowns $2 %true.turn

  ; Display the action message
  $display.message(3 $+ $get_chr_name($1)  $+ $readini($dbfile(abilities.db), $2, Description), global)

  if (%ability.type = attack) {  $ability.attack($1, $2, %attack.target, %tp.have )  }
  if (%ability.type = heal) { $ability.heal($1, $2, $3, %tp.have) }
  if (%ability.type = buff) { $ability.buff($1, $2, $3) }
  if (%ability.type = suicide) { 

    $display.message($translate(SuicideUseAllHP, $1), battle)
    $ability.attack($1, $2, %attack.target, suicide) 
    writeini $char($1) Battle HP 0
    writeini $char($1) Battle Status dead 
    $add.monster.xp($1, $1)
  }

  ; Write that we used this as the last action
  writeini $txtfile(battle2.txt) Actions $1 $2 

  ; Check for a postcript
  if ($readini($dbfile(abilities.db), n, $2, PostScript) != $null) { $readini($dbfile(abilities.db), p, $2, PostScript) }

  ; Increase the total number of times this player has used an ability
  $miscstats($1, add, AbilitiesUsed, 1)

  ; Unset the attack target
  unset %attack.target

  ; Time to go to the next turn
  if ($readini($dbfile(abilities.db), $2, Instant) != true) {   
    if (%battleis = on)  {  $check_for_double_turn($1) | halt }
  }
  else {
    ; Reset the Next timer.
    var %nextTimer $readini(system.dat, system, BattleIdleTime)
    if (%nextTimer = $null) { var %nextTimer 180 }
    /.timerBattleNext 1 %nextTimer /next ForcedTurn

    $display.message($translate(AnotherActionThisTurn, $1), battle)
  }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs a regular tech/ws
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias ability.attack {
  ; $1 = user
  ; $2 = ability name
  ; $3 = target

  ; Decrease the action points
  $action.points($1, remove, 4)

  if ($readini($dbfile(abilities.db), $2, absorb) = yes) { set %absorb absorb }
  else { set %absorb none }

  ; Single target ability
  if ($readini($dbfile(abilities.db), $2, AOE) != true) {
    $calculate_damage_ability($1, $2, $3, $4)
    $deal_damage($1, $3, $2, %absorb, ability)
    $inflict.status($1, $3, $2, ability)
    $display_damage($1, $3, ability, $2, %absorb)
  }

  ; AOE ability
  else {
    var %user.flag $flag($1)
    if (%user.flag = npc) { unset %user.flag }

    if ($is_confused($1) = true) { 
      var %random.target.chance $rand(1,2)
      if (%random.target.chance = 1) { var %user.flag monster }
      if (%random.target.chance = 2) { unset %user.flag }
    }

    ; cycle through the battle list and hit the targets that are opposite of the user's flag.
    var %battle.party $readini($txtfile(battle2.txt), Battle, List) | var %current.battle.member 1 | var %targets.hit 0
    while (%current.battle.member <= $numtok(%battle.party, 46)) {
      var %battle.member.name $gettok(%battle.party, %current.battle.member, 46)

      ; We don't want to hit ourselves..
      if (%battle.member.name != $1) {
        ; Is this target alive?
        if ($current.hp(%battle.member.name) > 0) { 
          ; Check the corresponding flags
          if ((%user.flag = monster) && ($flag(%battle.member.name) = $null)) {
            inc %targets.hit 1
            $calculate_damage_ability($1, $2, %battle.member.name, $4)
            $deal_damage($1, %battle.member.name, $2, %absorb, ability)
            $inflict.status($1, %battle.member.name, $2, ability)
            $display_aoedamage($1, %battle.member.name, $2)
          }
          if ((%user.flag = $null) && ($flag(%battle.member.name) = monster)) { 
            inc %targets.hit 1
            $calculate_damage_ability($1, $2, %battle.member.name, $4)
            $deal_damage($1, %battle.member.name, $2, %absorb, ability)
            $inflict.status($1, %battle.member.name, $2, ability)
            $display_aoedamage($1, %battle.member.name, $2)
          }
        }
      }

      inc %current.battle.member
    }

  }

  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calculates Ability Damage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias calculate_damage_ability {
  ; $1 = user
  ; $2 = ability used
  ; $3 = target
  ; $4 = optional flag ("heal" or "aoe" or "suicide")

  $calculate.accuracy($1, $3)
  if (%guard.message != $null) { set %attack.damage 0 | return }

  if ($flag($1) = monster) { $formula.ability($1, $2, $3, $4) }
  else { $formula.ability($1, $2, $3, $4) }

  unset %enemy.defense | set %multihit.message.on on
  unset %attacker.level | unset %defender.level 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs a buff ability
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias ability.buff {
  ; $1 = user
  ; $2 = ability name

  ; Decrease the action points
  $action.points($1, remove, 4)

  ; Which buff is being applied?
  var %buff.name $readini($dbfile(abilities.db), $2, StatusEffect)
  var %buff.length $readini($dbfile(statuseffects.db), %buff.name, Length)

  ; Is this buff a single or AOE target?  If single, just apply it and move on.  Else, cycle through

  if ($readini($dbfile(abilities.db), $2, AOE) = false) { writeini $char($1) StatusEffects %buff.name %buff.length  }
  else { 

    if ($flag($1) = monster) {
      var %battle.party $readini($txtfile(battle2.txt), Battle, List) | var %current.battle.member 1 
      while (%current.battle.member <= $numtok(%battle.party, 46)) {
        var %battle.member.name $gettok(%battle.party, %current.battle.member, 46)
        if (($current.hp(%battle.member.name) > 0) && ($flag(%battle.member.name) = monster)) { writeini $char(%battle.member.name) StatusEffects %buff.name %buff.length }
        inc %current.battle.member
      }
      return 
    }

    else {   
      var %adventure.party $readini($txtfile(adventure.txt), Info, partymembersList) | var %current.party.member 1 
      while (%current.party.member <= $adventure.party.count) { 
        var %party.member.name $gettok(%adventure.party, %current.party.member, 46)
        if ($current.hp(%party.member.name) > 0) { writeini $char(%party.member.name) StatusEffects %buff.name %buff.length }
        inc %current.party.member    
      }
    }
  }

  ; Increase enmity
  if (%battleis = on) { 
    var %base.enmity 10
    var  %enmity.multiplier $readini($dbfile(abilities.db), $2, EnmityMultiplier)
    if (%enmity.multiplier = $null) { var %enmity.multiplier 1 }
    $enmity($1, add, $calc(%base.enmity * %enmity.multiplier))
  }

  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs a healing ability
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias ability.heal {
  ; $1 = the user
  ; $2 = the ability
  ; $3 = the target

  ; Get the heal amount
  set %heal.amount $calculate.ability.damage($1, $2)

  ; Is this spell an AOE?  If so, apply it to everyone
  if ($readini($dbfile(abilities.db), $2, AOE) = true) {   

    var %user.flag $flag($1)
    if (%user.flag = npc) { unset %user.flag }

    if ($is_confused($1) = true) { 
      var %random.target.chance $rand(1,2)
      if (%random.target.chance = 1) { var %user.flag monster }
      if (%random.target.chance = 2) { unset %user.flag }
    }

    ; cycle through the battle list and hit the targets that are opposite of the user's flag.
    var %battle.party $readini($txtfile(battle2.txt), Battle, List) | var %current.battle.member 1 | var %targets.hit 0
    while (%current.battle.member <= $numtok(%battle.party, 46)) {
      var %battle.member.name $gettok(%battle.party, %current.battle.member, 46)

      ; Is this target alive?
      if ($current.hp(%battle.member.name) > 0) { 
        ; Check the corresponding flags

        if ((%user.flag = monster) && ($flag(%battle.member.name) = monster)) {
          set %attack.damage %heal.amount

          ; Deal and display the damage done
          $heal_damage($1, %battle.member.name, $2, spell)
          $display_heal($1, %battle.member.name, spell, $2, spell)
        }
        if ((%user.flag = $null) && ($flag(%battle.member.name) = $null)) { 
          set %attack.damage %heal.amount

          ; Get the heal amount
          set %attack.damage $calculate.ability.damage($1, $2)

          ; Deal and display the damage done
          $heal_damage($1, %battle.member.name, $2, spell)
          $display_heal($1, %battle.member.name, spell, $2, spell)
        }
      }

      inc %current.battle.member
    }
  }
  else {
    ; Not an AOE

    ; Get the heal amount
    set %attack.damage $calculate.ability.damage($1, $2)

    ; Deal and display the damage done
    $heal_damage($1, $3, $2, %absorb, ability)
    $display_heal($1, $3, ability, $2, %absorb)
  }

  unset %heal.amount

  return
}
