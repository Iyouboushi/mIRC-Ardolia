;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; spells.mrc
;;;; Last updated: 09/25/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spell Commands and code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 2:ACTION:casts *:#:{ 
  $no.turn.check($nick) |  $set_chr_name($nick)

  if ($3 != on) { 
    if (($readini($dbfile(spells.db), $2, type) = buff) || ($readini($dbfile(spells.db), $2, type) = heal)) { $partial.name.match($nick, $nick) }
    else { halt }
  }

  if (%attack.target = $null) { $partial.name.match($nick, $4) }
  $spell_cmd($nick , $2 , %attack.target, $5) | halt 
} 

ON 2:TEXT:!cast * on *:#:{ 
  $no.turn.check($nick) |  $set_chr_name($nick)
  $partial.name.match($nick, $4)
  $spell_cmd($nick , $2 , %attack.target, $5) | halt 
} 
ON 2:TEXT:!magic * on *:#:{ 
  $no.turn.check($nick) |  $set_chr_name($nick)
  $partial.name.match($nick, $4)
  $spell_cmd($nick , $2 , %attack.target, $5) | halt 
} 
ON 50:TEXT:*casts * on *:*:{ 
  if ($1 = uses) { halt }
  if ($3 = item) { halt }
  if ($5 != on) { halt }

  $partial.name.match($1, $5)
  $spell_cmd($1 , $3,  %attack.target) 
  halt 
}


alias spell_cmd {
  ; $1 = user
  ; $2 = Spell cast
  ; $3 = target

  ; Make sure some old attack variables are cleared.
  unset %attack.damage |  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %attack.damage.total
  unset %drainsamba.on | unset %absorb |  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged 
  unset %abilityincrease.check | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack
  unset %multihit.message.on  | unset %lastaction.nerf

  ; Are we in an adventure?
  if (%adventureis = off) { halt }

  ; Can this spell be cast outside of battle?
  if ($readini($dbfile(spells.db), $2, CanUseOutsideBattle) != true) {  
    if (%battleis != on) { $display.message($translate(NoBattleCurrently), private) | halt }

    ; Are we in battle?
    $check_for_battle($1) 
    $person_in_battle($3)
    $no.turn.check($1,admin)
  }

  if (%attack.target = $null) { set %attack.target $3 } 

  var %spell.type $readini($dbfile(spells.db), $2, Type) | $amnesia.check($1, spell) 

  if ($flag($1) != monster) {

    if ((no-spell isin %battleconditions) || (no-spells isin %battleconditions)) { 
      if (($readini($char($1), info, ai_type) != healer) && ($readini($char($1), info, ai_type) != spellonly)) { 
        $set_chr_name($1) | $display.message($translate(NotAllowedBattleCondition),private) | halt 
      }
    }

    if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message($translate(CanNotAttackWhileUnconcious, $1),private)  | unset %real.name | halt }
    if ($readini($char($3), Battle, Status) = dead) { $set_chr_name($1) | $display.message($translate(CanNotAttackSomeoneWhoIsDead, $1, $3),private) | unset %real.name | halt }
    if ($readini($char($3), Battle, Status) = RunAway) { $set_chr_name($1) | $display.message($translate(CanNotAttackSomeoneWhoFled, $1, $3),private) | unset %real.name | halt } 

    if ($flag($1) != monster) { 
      ; does this spell exist?
      if ($readini($dbfile(spells.db), $2, jobs) = $null) { $display.message($translate(NoSuchSpell, $1, $2) , private) | halt }

      ; Can this job use this spell?
      var %jobs.list $readini($dbfile(spells.db), $2, jobs)
      if (($istok(%jobs.list, $current.job($1), 46) = $false) && (%jobs.list != all))  { $display.message($translate(WrongJobToUseSpell, $1, $2) , private) | halt }
    }

    ; Are we high enough level to use this spell?
    var %spell.level $readini($dbfile(spells.db), $2, level)
    if ($get.level($1) < %spell.level) { $display.message($translate(NotRightLevelForSpell, $1, $2),private) | halt }
  }

  ; Can we use this spell again so soon?
  $cooldown.check($1, $2, spell)

  ; Make sure the user has enough MP to use this in battle..
  var %mp.needed $readini($dbfile(spells.db), $2, Cost) | var %mp.have $current.mp($1)
  if (%mp.needed > %mp.have) { $display.message($translate(NotEnoughMPForSpell, $1, $2),private) | halt }


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


  if ((%spell.type != buff) && (%spell.type != heal)) { 
    if ((%user.flag != monster) && (%target.flag != monster)) { $set_chr_name($1) | $display.message($translate(CanOnlyAttackMonsters, $1),private)  | halt }
  }

  ; Decrease the MP used
  dec %mp.have %mp.needed
  writeini $char($1) Battle MP %mp.have

  ; Check for a prescript
  if ($readini($dbfile(spells.db), n, $2, PreScript) != $null) { $readini($dbfile(spells.db), p, $2, PreScript) }

  ; Write to the file that we just used this spell
  writeini $char($1) cooldowns $2 %true.turn

  ; Show the casting description
  $display.message(3 $+ $get_chr_name($1)  $+ $readini($dbfile(spells.db), $2, Description), global)

  ; Perform the spell
  if (%spell.type = attack) { $spell.attack($1, $2, $3) } 
  if (%spell.type = buff) { $spell.buff($1, $2, $3) }
  if (%spell.type = heal) { $spell.heal($1, $2, $3) }

  ; Write that we used this as the last action
  writeini $txtfile(battle2.txt) Actions $1 $2 

  ; Check for a postcript
  if ($readini($dbfile(spells.db), n, $2, PostScript) != $null) { $readini($dbfile(spells.db), p, $2, PostScript) }

  ; Increase the total number of times this player has cast a spell
  $miscstats($1, add, SpellsCast, 1)

  ; Time to go to the next turn
  if (%battleis = on)  {  $check_for_double_turn($1) | halt }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Attack spell type
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias spell.attack {
  ; $1 = the caster
  ; $2 = the spell name 
  ; $3 = the target

  ; Is this spell an AOE?  If so, apply it to everyone
  if ($readini($dbfile(spells.db), $2, AOE) = true) {   

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

            ; Get the attack damage
            set %attack.damage $calculate.spell.damage($1, $2)

            ; Get the defense for the current
            var %damage.defense.percent $calculate.defense(%battle.member.name, magical)
            set %attack.damage $floor($calc(%attack.damage * %damage.defense.percent))
            if (%attack.damage <= 0) { set %attack.damage 1 }

            ; Deal and display the damage
            $deal_damage($1, %battle.member.name, $2, %absorb, spell)
            $inflict.status($1, %battle.member.name, $2, spell)
            $display_aoedamage($1, %battle.member.name, $2)
          }
          if ((%user.flag = $null) && ($flag(%battle.member.name) = monster)) { 
            inc %targets.hit 1

            ; Get the attack damage
            $calculate.accuracy($1, $3)
            if (%guard.message != $null) { set %attack.damage 0 }
            else {    
              set %attack.damage $calculate.spell.damage($1, $2)

              ; Get the defense for the current
              var %damage.defense.percent $calculate.defense(%battle.member.name, magical)
              set %attack.damage $floor($calc(%attack.damage * %damage.defense.percent))
              if (%attack.damage <= 0) { set %attack.damage 1 }
            }

            ; Deal and display the damage
            $deal_damage($1, %battle.member.name, $2, %absorb, spell)
            $inflict.status($1, %battle.member.name, $2, spell)
            $display_aoedamage($1, %battle.member.name, $2)
          }
        }
      }

      inc %current.battle.member
    }
  }
  else {
    ; Not an AOE

    ; Get the attack amount
    $calculate.accuracy($1, $3)
    if (%guard.message != $null) { set %attack.damage 0 }
    else {    
      set %attack.damage $calculate.spell.damage($1, $2)

      ; Get the defense for one person    
      var %damage.defense.percent $calculate.defense($3, magical)
      set %attack.damage $floor($calc(%attack.damage * %damage.defense.percent))
      if (%attack.damage <= 0) { set %attack.damage 1 }
    }

    ; Deal and display the damage done
    $deal_damage($1, $3, $2, %absorb, spell)
    $inflict.status($1, $3, $2, spell)
    $display_damage($1, $3, spell, $2, %absorb)
  }

  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Healing spell type
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias spell.heal {
  ; $1 = the caster
  ; $2 = the spell name 
  ; $3 = the target

  set %heal.amount $calculate.spell.damage($1, $2)
  inc %heal.amount $buff.check($1, CurePotency, %heal.amount)

  ; Is this spell an AOE?  If so, apply it to everyone
  if ($readini($dbfile(spells.db), $2, AOE) = true) {   

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

          ; Get the heal amount
          set %attack.damage %heal.amount

          ; Deal and display the damage done
          $heal_damage($1, %battle.member.name, $2, spell)
          $display_heal($1, %battle.member.name, spell, $2, spell)
        }
        if ((%user.flag = $null) && ($flag(%battle.member.name) = $null)) { 

          ; Get the heal amount
          set %attack.damage %heal.amount

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
    set %attack.damage $calculate.spell.damage($1, $2)

    ; Deal and display the damage done
    $heal_damage($1, $3, $2, %absorb, spell)
    $display_heal($1, $3, spell, $2, %absorb)
  }

  unset %heal.amount

  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Performs a buff spell
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias spell.buff {
  ; $1 = the caster
  ; $2 = the spell name
  ; $3 = the target

  ; Decrease the action points
  $action.points($1, remove, 4)

  ; Which buff is being applied?
  var %buff.name $readini($dbfile(spells.db), $2, StatusEffect)
  var %buff.length $readini($dbfile(statuseffects.db), %buff.name, Length)

  ; Is this buff a single or AOE target?  If single, just apply it and move on.  Else, cycle through

  if ($readini($dbfile(spells.db), $2, AOE) = false) { writeini $char($3) StatusEffects %buff.name %buff.length  }
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
    var  %enmity.multiplier $readini($dbfile(spells.db), $2, EnmityMultiplier)
    if (%enmity.multiplier = $null) { var %enmity.multiplier 1 }
    $enmity($1, add, $calc(%base.enmity * %enmity.multiplier))
  }

  return
}
