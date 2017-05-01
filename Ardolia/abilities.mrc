;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; abilities.mrc
;;;; Last updated: 04/30/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This file is horribly unfinished


ON 3:ACTION:uses * * on *:#:{ 
  $no.turn.check($nick) |  $set_chr_name($nick)
  $partial.name.match($nick, $5)
  $ability_cmd($nick , $3 , %attack.target, $7) | halt 
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
; This alias checks
; to see if a ability can
; be used again
;=================
alias ability.turncheck {
  ; $1 = the person using the ability
  ; $2 = ability name (in db file)

  if ($flag($1) != $null) { return }

  var %ability.turns $readini($dbfile(abilities.db), $2, cooldown)
  var %last.turn.used $readini($char($1), cooldowns, $2)

  if (%last.turn.used = $null) { var %next.turn.can.use 0 }
  else { var %next.turn.can.use $calc(%last.turn.used + %ability.turns) }

  if (%true.turn >= %next.turn.can.use) { return }
  else { $set_chr_name($1) | $display.message($translate(UnableToUseAbilityAgainSoSoon, $1, $2),private)  | $display.private.message(3You still have $calc(%next.turn.can.use - %true.turn) turns before you can use $2 again) | halt }
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

  $check_for_battle($1) 


  ; Can this spell be cast outside of battle?
  if ($readini($dbfile(abilities.db), $2, CanUseOutsideBattle) != true) {  
    $no.turn.check($1,admin)
  }

  ; Are we in an adventure?
  if (%adventureis = off) { halt }

  set %ability.type $readini($dbfile(abilities.db), $2, Type) | $amnesia.check($1, ability) 

  if ($flag($1) != monster) {

    if ((no-ability isin %battleconditions) || (no-abilities isin %battleconditions)) { 
      if (($readini($char($1), info, ai_type) != healer) && ($readini($char($1), info, ai_type) != abilityonly)) { 
        $set_chr_name($1) | $display.message($readini(translation.dat, battle, NotAllowedBattleCondition),private) | halt 
      }
    }

    if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message($translate(CanNotAttackWhileUnconcious, $1),private)  | unset %real.name | halt }
    if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | $display.message($translate(CanNotAttackSomeoneWhoIsDead, $1, $2),private) | unset %real.name | halt }
    if ($readini($char($2), Battle, Status) = RunAway) { $set_chr_name($1) | $display.message($translate(CanNotAttackSomeoneWhoFled, $1, $2),private) | unset %real.name | halt } 

    $person_in_battle($3) | $checkchar($3) 



    ; Are we high enough level to use this ability?
    var %ability.level $readini($dbfile(abilities.db), $2, level)
    if ($get.level($1) < %ability.level) { $display.message($translate(NotRightLevelForAbility, $1, $2),private) | halt }

    ; Can this job use this ability?
    var %jobs.list $readini($dbfile(abilities.db), $2, jobs)
    if (($istok(%jobs.list, $current.job($1), 46) = $false) && (%jobs.list != all))  { $display.message($translate(WrongJobToUseAbility, $1, $2) , private) | halt }
  }

  ; Can we use this ability again so soon?
  $ability.turncheck($1, $2)

  ; Make sure the user has enough TP to use this in battle..
  var %tp.needed $readini($dbfile(abilities.db), $2, TpNeeded) | var %tp.have $current.tp($1)
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

  if ((%user.flag != monster) && (%target.flag != monster)) { $set_chr_name($1) | $display.message($translate(CanOnlyAttackMonsters, $1),private)  | halt }

  ; Decrease the TP used
  dec %tp.have %tp.needed
  writeini $char($1) Battle TP %tp.have

  ; Check for a prescript
  if ($readini($dbfile(abilities.db), n, $2, PreScript) != $null) { $readini($dbfile(abilities.db), p, $2, PreScript) }

  ; Write to the file that we just used this ability
  writeini $char($1) cooldowns $2 %true.turn

  if (%ability.type = buff) { $ability.buff($1, $2, $3) }

  if (%ability.type = heal) { $ability.heal($1, $2, $3, %tp.have) }
  if (%ability.type = heal-aoe) { $ability.aoeheal($1, $2, $3, %tp.have) }
  if (%ability.type = single) {  $ability.single($1, $2, %attack.target, %tp.have )  }
  if (%ability.type = suicide) { $ability.suicide($1, $2, %attack.target, %tp.have )  }

  if (%ability.type = suicide-AOE) { 
    if ($is_charmed($1) = true) { 
      var %current.flag $readini($char($1), info, flag)
      if ((%current.flag = $null) || (%current.flag = npc)) { $ability.aoe($1, $2, $3, player, suicide, %tp.have) | halt }
      if (%current.flag = monster) { $ability.aoe($1, $2, $3 , monster, suicide, %tp.have) | halt }
    }
    else {
      ; Determine if it's players or monsters
      if (%user.flag = monster) { $ability.aoe($1, $2, $3, player, suicide, %tp.have) | halt }
      if ((%user.flag = $null) || (%user.flag = npc)) { $ability.aoe($1, $2, $3, monster, suicide, %tp.have) | halt }
    }
  }

  if (%ability.type = status) { $ability.single($1, $2, %attack.target, %tp.have ) } 


  if (%ability.type = AOE) { 

    if ($is_charmed($1) = true) { 
      var %current.flag $readini($char($1), info, flag)
      if ((%current.flag = $null) || (%current.flag = npc)) { $ability.aoe($1, $2, $3, player, %tp.have) | halt }
      if (%current.flag = monster) { $ability.aoe($1, $2, $3, monster, %tp.have) | halt }
    }
    else {
      ; check for confuse.
      if ($is_confused($1) = true) { 
        var %random.target.chance $rand(1,2)
        if (%random.target.chance = 1) { var %user.flag monster }
        if (%random.target.chance = 2) { unset %user.flag }
      }

      ; Determine if it's players or monsters
      if (%user.flag = monster) { $ability.aoe($1, $2, $3, player, %tp.have) | halt }
      if ((%user.flag = $null) || (%user.flag = npc)) { $ability.aoe($1, $2, $3, monster, %tp.have) | halt }
    }
  }

  ; Check for a postcript
  if ($readini($dbfile(abilities.db), n, $2, PostScript) != $null) { $readini($dbfile(abilities.db), p, $2, PostScript) }

  ; Time to go to the next turn
  if (%battleis = on)  {  $check_for_double_turn($1) | halt }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs a regular tech/ws
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias ability.single {
  ; $1 = user
  ; $2 = tech name
  ; $3 = target

  ; Decrease the action points
  $action.points($1, remove, 4)

  var %tech.element $readini($dbfile(abilities.db), $2, element)

  if ($readini($dbfile(abilities.db), $2, absorb) = yes) { set %absorb absorb }
  else { set %absorb none }

  $calculate_damage_ability($1, $2, $3, $4)
  $deal_damage($1, $3, $2, %absorb, ability)
  $display_damage($1, $3, ability, $2, %absorb)
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
; Performs an AOE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This file isn't fully done being converted over from the other bot
alias ability.aoe {
  ; $1 = user
  ; $2 = tech
  ; $3 = target
  ; $4 = type, either player or monster 

  set %wait.your.turn on

  unset %who.battle | set %number.of.hits 0
  unset %absorb  | unset %element.desc

  ; Decrease the action points
  $action.points($1, remove, 6)

  if ($5 = suicide) {
    $set_chr_name($1)
    $display.message($translate(SuicideUseAllHP, $1), battle)
  }

  ; Display the tech description
  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  var %enemy all targets

  $display.message(3 $+ %user  $+ $readini($dbfile(ability.db), $2, desc), battle)
  set %showed.tech.desc true

  if ($readini($dbfile(abilities.db), $2, absorb) = yes) { set %absorb absorb }

  var %ability.element $readini($dbfile(abilities.db), $2, element)

  ; If it's player, search out remaining players that are alive and deal damage and display damage
  if ($4 = player) {
    var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
    while (%battletxt.current.line <= %battletxt.lines) { 
      set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
      if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }
      else { 

        if ((%mode.pvp = on) && ($1 = %who.battle)) { var %can.hit no }
        if (($readini($char($1), status, confuse) != yes) && ($1 = %who.battle)) { var %can.hit no }

        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { var %can.hit no }

        if (%can.hit != no) { 
          if ($readini($char($1), battle, hp) > 0) {
            inc %number.of.hits 1
            var %target.element.heal $readini($char(%who.battle), modifiers, heal)
            if ((%tech.element != none) && (%tech.element != $null)) {
              if ($istok(%target.element.heal,%tech.element,46) = $true) { 
                $tech.heal($1, $2, %who.battle, %absorb)
                inc %battletxt.current.line 1 
              }
            }

            if (($istok(%target.element.heal,%tech.element,46) = $false) || (%tech.element = none)) { 

              $covercheck(%who.battle, $2, AOE)

              if (($readini($char(%who.battle), status, reflect) = yes) && ($readini($dbfile(techniques.db), $2, magic) = yes)) {
                $calculate_damage_techs($1, $2, $1, aoe)
                if (%attack.damage >= 5000) { set %attack.damage $rand(4000,5000) }
                unset %absorb
                $deal_damage($1, $1, $2, %absorb, tech)
              }
              else {
                $calculate_damage_techs($1, $2, %who.battle, aoe)
                $deal_damage($1, %who.battle, $2, %absorb, tech)
              }

              $display_aoedamage($1, %who.battle, $2, %absorb)
              unset %attack.damage

            }
          }
        } 
        unset %can.hit
        inc %battletxt.current.line 1 
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
            if ((%tech.element != none) && (%tech.element != $null)) {
              if ($istok(%target.element.heal,%tech.element,46) = $true) { 
                $tech.heal($1, $2, %who.battle, %absorb)
              }
            }

            if (($istok(%target.element.heal,%tech.element,46) = $false) || (%tech.element = none)) { 
              $covercheck(%who.battle, $2, AOE)

              ; Check for Reflect
              if (($readini($char(%who.battle), status, reflect) = yes) && ($readini($dbfile(techniques.db), $2, magic) = yes)) {
                $calculate_damage_techs($1, $2, $1, aoe)
                if (%attack.damage >= 5000) { set %attack.damage $rand(4000,5000) }
                unset %absorb
                $deal_damage($1, $1, $2, %absorb)
                $display_aoedamage($1, %who.battle, $2, %absorb, tech)
              }

              else {
                $calculate_damage_techs($1, $2, %who.battle, aoe)
                $deal_damage($1, %who.battle, $2, %absorb, tech)
                $display_aoedamage($1, %who.battle, $2, %absorb)
              }
            }
          }

          inc %battletxt.current.line 1 | inc %aoe.turn 1 | unset %attack.damage
        } 
      }
    }
  }

  unset %element.desc | unset %showed.tech.desc | unset %aoe.turn
  set %timer.time $calc(%number.of.hits * 1.1) 

  if ($readini($dbfile(techniques.db), $2, magic) = yes) {
    ; Clear elemental seal
    if ($readini($char($1), skills, elementalseal.on) = on) { 
      writeini $char($1) skills elementalseal.on off 
    }
  }

  unset %statusmessage.display
  if ($readini($char($1), battle, hp) > 0) {
    set %inflict.user $1 | set %inflict.techwpn $2 
    $self.inflict_status(%inflict.user, %inflict.techwpn, tech)
    if (%statusmessage.display != $null) { $display.message(%statusmessage.display, battle) | unset %statusmessage.display }
  }

  if ($5 = suicide) {   writeini $char($1) battle hp 0 | writeini $char($1) battle status dead | $set_chr_name($1) |  $increase.death.tally($1)  }

  ; Turn off the True Strike skill
  writeini $char($1) skills truestrike.on off

  if (%timer.time > 20) { %timer.time = 20 }

  ; Check for a postcript
  if ($readini($dbfile(techniques.db), n, $2, PostScript) != $null) { $readini($dbfile(techniques.db), p, $2, PostScript) }

  /.timerCheckForDoubleSleep $+ $rand(a,z) $+ $rand(1,1000) 1 %timer.time /check_for_double_turn $1
  halt
}
