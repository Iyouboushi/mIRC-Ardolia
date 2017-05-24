;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; AI COMMANDS
;;;; Last updated: 05/24/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Is this person AI controlled?
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias aicheck { 
  unset %statusmessage.display | unset %action.bar | unset %song.name | unset %ai.item | unset %element | unset %status.type
  remini $char($1) renkei

  ; Determine if the current person in battle is a monster or not.  If so, they need to do a turn.  If not, return.
  if (($is_charmed($1) = true) || ($is_confused($1) = true)) { /.timerAIthink $+ $rand(a,z) $+ $rand(1,1000) 1 6 /ai_turn $1 | halt }

  ; Check to see if it's a defender type. If so, next turn it.  This is needed for surprise attacks on certain monsters..
  if ($readini($char($1), info, ai_type) = defender) {
    if ($readini($char($1), descriptions, DefenderAI) != $null) { $set_chr_name($1) | $display.message(4 $+ $readini($char($1), descriptions, DefenderAI), battle) }
    $next 
    halt
  }

  if (($readini($char($1), info, ai_type) = PayToAttack) && ($currency.amount($1, gil) <= 0)) {
    if ($readini($char($1), descriptions, Idle) != $null) { $set_chr_name($1) | $display.message(4 $+ %real.name  $+ $readini($char($1), descriptions, Idle), battle) }
    if ($readini($char($1), descriptions, Idle) = $null) { $set_chr_name($1) | $display.message(4 $+ %real.name watches the battle as $gender3($3) waits to be paid before getting involved., battle) }
    $next 
    halt
  }

  ; Now we check for the AI system to see if it's turned on or not.
  var %ai.system $readini(system.dat, system, aisystem)
  if ((%ai.system = $null) || (%ai.system = on)) { var %ai.wait.time 6
    if (%battle.type = ai) { inc %ai.wait.time 4 }

    if ($flag($1) != $null) {  /.timerAIthink $+ $rand(a,z) $+ $rand(1,1000) 1 %ai.wait.time /ai_turn $1 | halt }
    else { return }
  }
  else { return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; It's the AI's turn
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias ai_turn {
  ; Is it the AI's turn?  This is to prevent some bugs showing up..
  if (%who != $1) { return }

  ; If it's an AI's turn, give the AI 30 seconds to make an action.. in case it hangs up.
  /.timerBattleNext 1 30 /next

  ; Clear some old variables
  unset %ai.target | unset %ai.targetlist | unset %ai.ability | unset %ai.spell | unset %opponent.flag 
  unset %ai.type | unset %ai.action

  set %ai.type $readini($char($1), info, ai_type) 

  ; Get the type of opponent we need to search for
  if ($flag($1) = monster) { set %opponent.flag player }
  if ($flag($1) = npc) { set %opponent.flag monster }

  if ($status.check($1, charm) != $null) { 
    if ($flag($1) = monster) { set %opponent.flag monster } 
    else { set %opponent.flag player }
  }
  if ($status.check($1, charm) != $null) { 
    var %random.target $rand(1,2)
    if (%random.target = 1) { set %opponent.flag monster }
    if (%random.target = 2) { set %opponent.flag player }
  }

  if (%mode.pvp = on) { set %opponent.flag player }

  ; Now that we have the target type, we need to figure out what kind of action to do.
  $ai.buildactionbar($1)

  ; Choose something from the action bar
  set %total.actions $numtok(%action.bar, 46)
  set %random.action $rand(1,%total.actions)
  set %ai.action $gettok(%action.bar,%random.action,46)

  unset %total.actions |  unset %random.action 

  ; do an action

  if (%ai.action = $null) { set %ai.action attack | echo -a 4ERORR: AI ACTION WAS NULL!  }
  writeini $txtfile(battle2.txt) BattleInfo $1 $+ .lastactionbar %ai.action

  ; AI action is ability
  if (%ai.action = ability) { 
    $ai_gettarget($1)
    if (%ai.target = $null) { echo -a target null! | set %ai.action attack  }
    else { $ability_cmd($1, %ai.ability, %ai.target) | halt }
  } 

  ; AI action is spell
  if (%ai.action = spell) { 
    $ai_gettarget($1)
    if (%ai.target = $null) { echo -a target null! | set %ai.action attack  }
    else { $spell_cmd($1, %ai.spell, %ai.target) | halt }
  } 

  ; AI action is melee attack
  if (%ai.action = attack) { $ai_gettarget($1) 
    if (%ai.target = $null) { echo -a target null | set %ai.action flee }
    else { $attack_cmd($1, %ai.target) | halt }
  }

  ; AI action is fleeing the battle
  if (%ai.action = flee) { $ai.flee($1) | halt }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the AI action bar
; This determines what the
; AI will do in battle.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias ai.buildactionbar {
  ; This alias builds a list of actions the user is able to do.
  var %last.actionbar.action $readini($txtfile(battle2.txt), Battleinfo, $1 $+ .lastactionbar)

  set %action.bar attack

  ; If the monster is under amnesia, just attack.
  if ($status.check($1, amnesia) != $null) { return } 

  ; can the monster flee?
  if ($readini($char($1), info, CanFlee) = true) { 
    if ((no-flee isin %battleconditions) || (no-fleeing isin %battleconditions)) { return }
    if (%battle.type != ai) { %action.bar = %action.bar $+ .flee } 
  }

  ; can the monster use an ability?
  if ($ai_abilitycheck($1) = true) { 
    %action.bar = %action.bar $+ .ability
    if (%last.actionbar.action != ability) {  %action.bar = %action.bar $+ .ability }
  }

  ; can the monster use a spell?
  if ($ai_spellcheck($1) = true) { 
    %action.bar = %action.bar $+ .spell
    if (%last.actionbar.action != spell) {  %action.bar = %action.bar $+ .spell }
  }

  ; Adding attack on there once more for good measure if it wasn't the last action
  if (%last.actionbar.action != attack) {  %action.bar = %action.bar $+ .attack }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ability check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias ai_abilitycheck {
  unset %ai.ability | unset %ability.list | unset %abilities | unset %number.of.abilities
  if ((no-ability isin %battleconditions) || (no-abilities isin %battleconditions)) { 
    if ($readini($char($1), info, ai_type) != abilityonly) { return }
  }

  if ($status.check($1, amnesia) != $null) { return }

  var %number.of.abilities $ini($char($1), abilities, 0)
  if ((%number.of.abilities = 0) || (%number.of.abilities = $null)) { return }

  ; Look through the ability list and see if this monster can use this right now.
  var %current.ability.counter 1
  while (%current.ability.counter <= %number.of.abilities) {
    var %ability.name $ini($char($1), abilities, %current.ability.counter)
    var %ability.value $readini($char($1), abilities, %ability.name)

    if ((%ability.value != $null) && (%ability.value >= 1)) { 

      ; Does the monster have enough TP to use this?
      var %ability.tp $readini($dbfile(abilities.db), %ability.name, cost)
      if ($current.tp($1) >= %ability.tp)  {

        ; Is the monster high enough level for this?
        if ($get.level($1) >= $readini($dbfile(abilities.db), %ability.name, level)) { 

          ; Is the cooldown ready for this?
          var %cooldown.turns $readini($dbfile(abilities.db), %ability.name, cooldown)
          var %last.turn.used $readini($char($1), cooldowns, %ability.name)

          if (%last.turn.used = $null) { var %next.turn.can.use 0 }
          else { var %next.turn.can.use $calc(%last.turn.used + %cooldown.turns) }

          ; The monster has enough TP and the cooldown is ready, so let's add it so the monster can use it.
          if (%true.turn >= %next.turn.can.use) { %ability.list = $addtok(%ability.list, %ability.name, 46) }
        }
      }

    }

    inc %current.ability.counter
  }

  if ((%ability.list = $null) && (%ai.type = healer)) { 
    writeini $char($1) abilities FirstAid 10
    %ability.list = FirstAid
  }

  if (%ability.list = $null) { return false }


  ; Randomly picks an ability to use from the list
  set %total.abilities $numtok(%ability.list, 46)
  set %random.ability $rand(1,%total.abilities)
  set %ai.ability $gettok(%ability.list,%random.ability,46)

  unset %total.abilities
  unset %random.ability

  if (%ai.ability = $null) { return false }

  unset %random.ability | unset %total.abilities | unset %number.of.abilities

  return true
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spell check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias ai_spellcheck {
  unset %ai.spell | unset %spell.list | unset %spells | unset %number.of.spells
  if ((no-spell isin %battleconditions) || (no-spells isin %battleconditions)) { 
    if ($readini($char($1), info, ai_type) != spellonly) { return }
  }

  if ($status.check($1, amnesia) != $null) { return }
  if ($status.check($1, mute) != $null) { return }
  if ($status.check($1, silenced) != $null) { return }

  var %number.of.spells $ini($char($1), spells, 0)
  if ((%number.of.spells = 0) || (%number.of.spells = $null)) { return }

  ; Look through the spell list and see if this monster can use this right now.
  var %current.spell.counter 1
  while (%current.spell.counter <= %number.of.spells) {
    var %spell.name $ini($char($1), spells, %current.spell.counter)
    var %spell.value $readini($char($1), spells, %spell.name)

    if ((%spell.value != $null) && (%spell.value >= 1)) { 

      ; Does the monster have enough MP to use this?
      var %spell.mp $readini($dbfile(spells.db), %spell.name, cost)
      if ($current.mp($1) >= %spell.mp)  {

        ; Is the monster high enough level for this?
        if ($get.level($1) >= $readini($dbfile(spells.db), %spell.name, level)) { 

          ; Is the cooldown ready for this?
          var %cooldown.turns $readini($dbfile(spells.db), %spell.name, cooldown)
          var %last.turn.used $readini($char($1), cooldowns, %spell.name)

          if (%last.turn.used = $null) { var %next.turn.can.use 0 }
          else { var %next.turn.can.use $calc(%last.turn.used + %cooldown.turns) }

          ; The monster has enough MP and the cooldown is ready, so let's add it so the monster can use it.
          if (%true.turn >= %next.turn.can.use) { %spell.list = $addtok(%spell.list, %spell.name, 46) }
        }
      }

    }

    inc %current.spell.counter
  }

  if (%spell.list = $null) { return false }

  ; Randomly picks an spell to use from the list
  set %total.spells $numtok(%spell.list, 46)
  set %random.spell $rand(1,%total.spells)
  set %ai.spell $gettok(%spell.list,%random.spell,46)

  unset %total.spells
  unset %random.spell

  if (%ai.spell = $null) { return false }

  unset %random.spell | unset %total.spells | unset %number.of.spells

  return true
}



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Monster attempts to flee from
; battle.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias ai.flee {
  var %flee.chance $rand(1,100)
  if (%flee.chance <= 50) { $flee($1) | halt }
  if (%flee.chance > 60) {  

    $display.message($translate(CannotFleeBattle, $1), battle)

    /.timerCheckForDoubleTurnWait 1 1 /check_for_double_turn $1 | halt 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns a target for the AI
; to attack (via enmity)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias ai_gettarget {
  ; If the monster is using a healing spell or ability, target itself.
  if ((%ai.action = spell) && ($readini($dbfile(spells.db), %ai.spell, type) = heal)) { set %ai.target $1 | return }
  if ((%ai.action = ability) && ($readini($dbfile(abilities.db), %ai.ability, type) = heal)) { set %ai.target $1 | return }

  ; Is the enmity list blank?  If so, pick a target at random.
  var %number.of.enmity.targets $ini($txtfile(battle2.txt), enmity, 0)
  if ((%number.of.enmity.targets = 0) || (%number.of.enmity.targets = $null)) { $ai_gettarget.random($1) | return }

  ; Is this person an NPC? If so, let's use the old method as monsters do not generate enmity.
  if ($flag($1) != monster) { $ai_gettarget.random($1) | return }

  ; Look through the enmity list and find who has the largest enmity value
  var %current.enmity.counter 1 | var %current.enmity.amount 0
  while (%current.enmity.counter <= %number.of.enmity.targets) {

    var %current.enmity.name $ini($txtfile(battle2.txt), enmity, %current.enmity.counter)
    var %current.enmity.value $readini($txtfile(battle2.txt), np, enmity, %current.enmity.name)

    if (%current.enmity.value > %current.enmity.amount) {
      ; Is this person dead? if so, remove from the enmity list. If not, check to see if this person has more enmity than others
      if ($readini($char(%current.enmity.name), Battle, Status) = dead) { remini $txtfile(battle2.txt) enmity %current.enmity.name }
      else { var %current.enmity.amount %current.enmity.value | set %ai.target %current.enmity.name }
    }
    inc %current.enmity.counter
  }

  ; Check to make sure we have a target.  If not, randomly pick one
  if (%ai.target = $null) { $ai_gettarget.random($1) | return }

  ; We have a valid target. Let's decrease the amount of enmity that person has now.
  var %reduced.enmity.amount $calc($enmity(%ai.target, return) / 2)
  writeini $txtfile(battle2.txt) enmity %ai.target %reduced.enmity.amount

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns a target for the AI
; to attack (completely random)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias ai_gettarget.random {
  unset %ai.targetlist | unset %tech.type | unset %status.type

  if (%ai.action = ability) {  
    set %tech.type $readini($dbfile(abilities.db), %ai.ability, type)  
    var %status.type $readini($dbfile(abilities.db), %ai.ability, statusEffect)
  }

  if ((((%tech.type = heal) || (%tech.type = aoeheal) || (%tech.type = ClearStatusNegative) || (%tech.type = buff)))) {
    unset %provoke.target
    if (%opponent.flag = player) { set %opponent.flag monster | goto gettarget }
    if (%opponent.flag = monster) { set %opponent.flag player | goto gettarget }
  }
  else { goto gettarget }

  ; As much as I hate using the goto command, it's the only way I can think of to make the above flag change work right so that healing techs work right.

  :gettarget

  set %battletxt.lines $lines($txtfile(battle.txt)) | set %battletxt.current.line 1 | unset %tech.type

  if ((%opponent.flag = monster) && ($readini($char($1), info, flag) = npc)) {
    if ($is_confused($1) != true) {
      if (%ai.action = tech) { var %element $readini($dbfile(abilities.db), %ai.ability, Element) }
      if (%ai.action = attack) { var %element $readini($dbfile(weapons.db), $readini($char($1), Weapons, Equipped), Element) }

      if ((%element = none) || (%element = $null)) { unset %element }
    }
  }


  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle.ai $read -l $+ %battletxt.current.line $txtfile(battle.txt)

    if ($readini($char(%who.battle.ai), monster, type) != object) { 

      if (%ai.type = berserker) { 
        if (%who.battle.ai = $1) { 
          if (($is_confused($1) = true) || ($is_charmed($1) = true)) { $add_target }
        }
        if (%who.battle.ai != $1) { $add_target }   
      }

      if (%ai.type != berserker) { 

        ; The AI is targeting a player or npc.
        if (%opponent.flag = player) {

          if ($readini($char(%who.battle.ai), info, flag) != monster) {

            ; Get a target for clones
            if ($readini($char($1), info, clone) = yes) {
              if ($readini($char($1), info, cloneowner) = %who.battle.ai) {  
                if (($is_confused($1) = true) || ($is_charmed($1) = true)) { $add_target }
              }
              if (($readini($char($1), info, cloneowner) != %who.battle.ai) && (%who.battle.ai != $1)) { $add_target }
            }

            ; Get a target for non-clones
            if ($readini($char($1), info, clone) != yes) { 
              if (($readini($char($1), info, ai_type) = healer) && ($readini($char(%who.battle.ai), status, zombie) = no)) { $add_target }

              if ($readini($char($1), info, ai_type) != healer) { 
                if (%who.battle.ai = $1) { 
                  if (($is_confused($1) = true) || ($is_charmed($1) = true)) { $add_target }
                }
                if (%who.battle.ai != $1) { $add_target }   
              }
            }
          }
        }

        ; The AI is targeting a monster.
        if (%opponent.flag = monster) {

          ; Ensure that Allied NPCs don't attack monsters with attacks they absorb.
          if (%element != $null) {
            var %absorb.list $readini($char(%who.battle.ai), Modifiers, Heal)
            if ($istok(%absorb.list, %element, 46) = $true) { inc %battletxt.current.line | continue }
          }

          if (%status.type != $null) {
            var %current.target.status $readini($char(%who.battle.ai), status, %status.type) 
            if (((%current.target.status = true) || (%current.target.status = yes) || (%current.target.status = on))) {  inc %battletxt.current.line | continue }
          }

          if ($readini($char(%who.battle.ai), info, flag) = monster) {

            ; Get a target for clones
            if ($readini($char($1), info, clone) = yes) {
              if ($readini($char($1), info, cloneowner) = %who.battle.ai) {  
                if (($is_confused($1) = true) || ($is_charmed($1) = true)) { $add_target }
              }
              if (($readini($char($1), info, cloneowner) != %who.battle.ai) && (%who.battle.ai != $1)) { $add_target }
            }


            ; Get a target for non-clones
            if ($readini($char($1), info, clone) != yes) { 

              if ($readini($char($1), info, ai_type) = healer) {     
                if ((%who.battle.ai != demon_portal) && ($readini($char(%who.battle.ai), status, zombie) = no)) { $add_target }   
              }
              else { 
                if (%who.battle.ai = $1) { 
                  if (($is_confused($1) = true) || ($is_charmed($1) = true)) { $add_target }
                }
                if (%who.battle.ai != $1) { $add_target }   

              }
            }
          }
        }

      }
    }

    inc %battletxt.current.line 1
  }

  set %total.targets $numtok(%ai.targetlist, 46)
  set %random.target $rand(1,%total.targets)
  set %ai.target $gettok(%ai.targetlist,%random.target,46)

  if (%ai.target = $null) { 

    if ($readini($char($1), info, ai_type) = healer) { set %ai.target $1 }
    if ($readini($char($1), info, ai_type) != healer) { 
      ; Try a second time.
      set %total.targets $numtok(%ai.targetlist, 46)
      set %random.target $rand(1,%total.targets)
      set %ai.target $gettok(%ai.targetlist,%random.target,46)
    }

    if (%ai.target = $null) { 
      if ((%element = $null) && (%status.type = $null)) { echo -a 4NULL TARGET. SWITCHING TO BERSERK TYPE | set %ai.target $1 | writeini $char($1) info ai_type berserk }
    }

    unset %random.target | unset %total.targets | unset %taunt.action
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gets a monster target
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias ai_getmontarget {
  ; $1 = AI user

  unset %ai.targetlist

  set %battletxt.lines $lines($txtfile(battle.txt)) | set %battletxt.current.line 1

  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle.ai $read -l $+ %battletxt.current.line $txtfile(battle.txt)

    if (($readini($char(%who.battle.ai), battle, status) != runaway) && ($readini($char(%who.battle.ai), battle, hp) > 0)) {
      if (($readini($char(%who.battle.ai), info, flag) = monster) && (%who.battle.ai != $1)) {

        if ($isfile($boss(%who.battle.ai)) != $true) {  $add_target }
      }
    }

    inc %battletxt.current.line 
  } 
}

alias add_target {
  if (%who.battle.ai = $null) { return }

  var %current.status $readini($char(%who.battle.ai), battle, status)
  if ((%current.status = dead) || (%current.status = runaway)) { return }


  else { 
    %ai.targetlist = $addtok(%ai.targetlist, %who.battle.ai, 46)
  }
  return
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Lets a monster summon other
; monsters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias ai.monstersummon {
  if ($is_charmed($1) = true) { return }
  if ($readini($char($1), skills, monstersummon) >= 1) { 
    $portal.clear.monsters
    var %summon.chance $rand(1,100)
    if (%summon.chance <= $readini($char($1), skills, monstersummon.chance)) {

      if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) { 
        var %max.number.of.mons $readini(system.dat, system, MaxNumberOfMonsInBattle)
        if (%max.number.of.mons = $null) { var %max.number.of.mons 10 }
      }

      if ($readini(system.dat, system, botType) = DCCchat) { var %max.number.of.mons 50 }

      var %current.number.of.mons $readini($txtfile(battle2.txt), battleinfo, Monsters)
      var %number.of.monsters.to.spawn $readini($char($1), skills, monstersummon.numberspawn)
      inc %current.number.of.mons %number.of.monsters.to.spawn

      if (%current.number.of.mons <= %max.number.of.mons) { 
        var %monster.name $readini($char($1), skills, monstersummon.monster)
        if (%monster.name != $null) { $skill.monstersummon($1, %monster.name) }
      }
    }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; AI learning check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This really isn't used for Ardolia. Leaving it
; here just in case I decide to re-add it.
alias ai.learncheck {
  if ($readini($char($1), info, flag) = $null) { return }
  if ($readini($char($1), monster, abilitylearn) != true) { return }
  if ($readini($dbfile(abilities.db), $2, type) = $null) { return }
  writeini $char($1) modifiers $2 0
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for mechs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This really isn't used for this game
; at least not yet
alias ai_mechcheck {
  if (($readini($char($1), mech, HpMax) = $null) || ($readini($char($1), mech, HpMax) = 0)) {  return false }
  if (($readini($char($1), mech, EngineLevel) = $null) || ($readini($char($1), mech, EngineLevel) = 0)) {  return false }
  if ($readini($char($1), status, ignition.on) = on) { return false }
  if ($readini($char($1), status, boosted) = yes) { return false }
  if ($person_in_mech($1) = true) { return false }
  if ((no-mech isin %battleconditions) || (no-mechs isin %battleconditions)) { return false }

  var %base.energycost $round($calc($mech.baseenergycost($1) / 2),0)
  var %mech.currentenergy $readini($char($1), mech, energyCurrent)

  if (%base.energycost >= %mech.currentenergy) { return false }
  if ($readini($char($1), mech, hpCurrent) <= 0) { return false }

  return true
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Changes the battlefield
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This isn't used in Ardolia yet.
; Leaving it here in case I decide to add it.
alias ai.changebattlefield {
  var %change.chance $readini($char($1), skills, ChangeBattlefield.chance)
  if (%change.chance = $null) { var %change.chance 15 }

  var %random.chance $rand(1,100)

  if (%random.chance > %change.chance) { return }
  set %battlefields $readini($char($1), skills, ChangeBattlefield.battlefields)
  set %number.of.battlefields $numtok(%battlefields,46)

  if (%number.of.battlefields >= 1) {
    set %random.battlefield $rand(1,%number.of.battlefields)
    set %battlefield.tochange $gettok(%battlefields,%random.battlefield,46)

    if (%battlefield.tochange = %current.battlefield) { unset %battlefields | unset %number.of.battlefields | unset %random.battlefield | unset %battlefield.tochange | return }

    set %current.battlefield %battlefield.tochange

    $set_chr_name($1)
    var %skill.message $readini($char($1), Descriptions, ChangeBattlefield)
    if (%skill.message = $null) { var %skill.message channels a powerful energy to teleport everyone to a new battlefield. Everyone finds themselves now on the %current.battlefield battlefield. }
    $display.message(12 $+ %real.name  $+ %skill.message, battle)
  }

  unset %battlefields | unset %number.of.battlefields | unset %random.battlefield | unset %battlefield.tochange

}
