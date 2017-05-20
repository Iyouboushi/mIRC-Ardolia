;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; abilities.mrc
;;;; Last updated: 05/20/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TO-DO: status effects

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ability Commands and code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 3:ACTION:uses * * on *:#:{ 
  $no.turn.check($nick) |  $set_chr_name($nick)
  $partial.name.match($nick, $5)
  $ability_cmd($nick , $3 , %attack.target, $7) | halt 
} 

ON 3:TEXT:!ability * on *:#:{ 
  $no.turn.check($nick) |  $set_chr_name($nick)
  $partial.name.match($nick, $4)
  $ability_cmd($nick , $2 , %attack.target, $5) | halt 
} 

ON 3:TEXT:!tech * on *:#:{ 
  $no.turn.check($nick) |  $set_chr_name($nick)
  $partial.name.match($nick, $4)
  $ability_cmd($nick , $2 , %attack.target, $5) | halt 
} 

ON 50:TEXT:*uses * * on *:*:{ 
  if ($1 = uses) { halt }
  if ($3 = item) { halt }
  if ($5 != on) { halt }

  $no.turn.check($1,admin)

  $partial.name.match($1, $6)

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

  var %ability.type $readini($dbfile(abilities.db), $2, Type) | $amnesia.check($1, ability) 

  if ($flag($1) != monster) {

    if ((no-ability isin %battleconditions) || (no-abilities isin %battleconditions)) { 
      if (($readini($char($1), info, ai_type) != healer) && ($readini($char($1), info, ai_type) != abilityonly)) { 
        $set_chr_name($1) | $display.message($translate(NotAllowedBattleCondition),private) | halt 
      }
    }

    if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message($translate(CanNotAttackWhileUnconcious, $1),private)  | unset %real.name | halt }
    if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | $display.message($translate(CanNotAttackSomeoneWhoIsDead, $1, $2),private) | unset %real.name | halt }
    if ($readini($char($2), Battle, Status) = RunAway) { $set_chr_name($1) | $display.message($translate(CanNotAttackSomeoneWhoFled, $1, $2),private) | unset %real.name | halt } 

    ; Can this spell be cast outside of battle?
    if ($readini($dbfile(abilities.db), $2, CanUseOutsideBattle) != true) {  
      if (%battleis != on) { $display.message($translate(NoBattleCurrently), private) | halt }

      ; Are we in battle?
      $check_for_battle($1) 

      $person_in_battle($3)
      $no.turn.check($1,admin)
    }

    ; Can this job use this ability?
    var %jobs.list $readini($dbfile(abilities.db), $2, job)
    if (($istok(%jobs.list, $current.job($1), 46) = $false) && (%jobs.list != all))  { $display.message($translate(WrongJobToUseAbility, $1, $2) , private) | halt }
  }

  ; Are we high enough level to use this ability?
  var %ability.level $readini($dbfile(abilities.db), $2, level)
  if ($get.level($1) < %ability.level) { $display.message($translate(NotRightLevelForAbility, $1, $2),private) | halt }

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
    if ((%user.flag != monster) && (%target.flag != monster)) { $set_chr_name($1) | $display.message($translate(CanOnlyAttackMonsters, $1),private)  | halt }
  }

  ; Decrease the TP used
  dec %tp.have %tp.needed
  writeini $char($1) Battle TP %tp.have

  ; Check for a prescript
  if ($readini($dbfile(abilities.db), n, $2, PreScript) != $null) { $readini($dbfile(abilities.db), p, $2, PreScript) }

  ; Write to the file that we just used this ability
  writeini $char($1) cooldowns $2 %true.turn

  ; Write that we used this as the last action
  writeini $txtfile(battle2.txt) Actions $1 $2 

  ; Display the action message
  $display.message(3 $+ $get_chr_name($1)  $+ $readini($dbfile(abilities.db), $2, Description), global)

  if (%ability.type = attack) {  $ability.attack($1, $2, %attack.target, %tp.have )  }
  if (%ability.type = heal) { $ability.heal($1, $2, $3, %tp.have) }
  if (%ability.type = buff) { $ability.buff($1, $2, $3) }
  if (%ability.type = suicide) { $ability.suicide($1, $2, %attack.target, %tp.have )  }

  ; Check for a postcript
  if ($readini($dbfile(abilities.db), n, $2, PostScript) != $null) { $readini($dbfile(abilities.db), p, $2, PostScript) }

  ; Time to go to the next turn
  if (%battleis = on)  {  $check_for_double_turn($1) | halt }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs a regular tech/ws
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias ability.attack {
  ; $1 = user
  ; $2 = tech name
  ; $3 = target

  ; Decrease the action points
  $action.points($1, remove, 4)

  var %tech.element $readini($dbfile(abilities.db), $2, element)

  if ($readini($dbfile(abilities.db), $2, absorb) = yes) { set %absorb absorb }
  else { set %absorb none }


  ; Single target ability
  if ($readini($dbfile(abilities.db), $2, AOE) != true) {
    $calculate_damage_ability($1, $2, $3, $4)
    $deal_damage($1, $3, $2, %absorb, ability)
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
            $display_aoedamage($1, %battle.member.name, $2)
          }
          if ((%user.flag = $null) && ($flag(%battle.member.name) = monster)) { 
            inc %targets.hit 1
            $calculate_damage_ability($1, $2, %battle.member.name, $4)
            $deal_damage($1, %battle.member.name, $2, %absorb, ability)
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
  ; $4 = optional flag ("heal" or "aoe")
  ; $5 = the tp value at the time of use

  if ($flag($1) = monster) { $formula.ability.monster($1, $2, $3, $4, $5) }
  else { $formula.ability.player($1, $2, $3, $4, $5) }

  unset %tech.howmany.hits |  unset %enemy.defense | set %multihit.message.on on
  unset %attacker.level | unset %defender.level | unset %tech.count | unset %tech.power | unset %base.weapon
  unset %capamount
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
  var %buff.length $readini($dbfile(abilities.db), $2, BuffLength)

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
