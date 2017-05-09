;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; spells.mrc
;;;; Last updated: 05/09/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This file is seriously unfinished
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spell Commands and code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 3:ACTION:casts * on *:#:{ 
  $no.turn.check($nick) |  $set_chr_name($nick)
  $partial.name.match($nick, $5)
  $spell_cmd($nick , $3 , %attack.target, $7) | halt 
} 
ON 3:TEXT:!cast * on *:#:{ 
  $no.turn.check($nick) |  $set_chr_name($nick)
  $partial.name.match($nick, $4)
  $spell_cmd($nick , $2 , %attack.target, $5) | halt 
} 
ON 3:TEXT:!magic * on *:#:{ 
  $no.turn.check($nick) |  $set_chr_name($nick)
  $partial.name.match($nick, $4)
  $spell_cmd($nick , $2 , %attack.target, $5) | halt 
} 
ON 50:TEXT:*casts * on *:*:{ 
  if ($1 = uses) { halt }
  if ($3 = item) { halt }
  if ($5 != on) { halt }

  $partial.name.match($1, $6)
  $spell_cmd($1 , $4,  %attack.target) 
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

    ; Are we in battle?
    $check_for_battle($1) 

    $no.turn.check($1,admin)
  }


  var %spell.type $readini($dbfile(spells.db), $2, Type) | $amnesia.check($1, spell) 

  if ($flag($1) != monster) {

    if ((no-spell isin %battleconditions) || (no-spells isin %battleconditions)) { 
      if (($readini($char($1), info, ai_type) != healer) && ($readini($char($1), info, ai_type) != spellonly)) { 
        $set_chr_name($1) | $display.message($translate(NotAllowedBattleCondition),private) | halt 
      }
    }

    if ($readini($char($1), Battle, Status) = dead) { $set_chr_name($1) | $display.message($translate(CanNotAttackWhileUnconcious, $1),private)  | unset %real.name | halt }
    if ($readini($char($2), Battle, Status) = dead) { $set_chr_name($1) | $display.message($translate(CanNotAttackSomeoneWhoIsDead, $1, $2),private) | unset %real.name | halt }
    if ($readini($char($2), Battle, Status) = RunAway) { $set_chr_name($1) | $display.message($translate(CanNotAttackSomeoneWhoFled, $1, $2),private) | unset %real.name | halt } 

    $person_in_battle($3) | $checkchar($3) 

    ; Can this job use this ability?
    var %jobs.list $readini($dbfile(abilities.db), $2, jobs)
    if (($istok(%jobs.list, $current.job($1), 46) = $false) && (%jobs.list != all))  { $display.message($translate(WrongJobToUseSpell, $1, $2) , private) | halt }
  }

  ; Are we high enough level to use this spell?
  var %spell.level $readini($dbfile(spells.db), $2, level)
  if ($get.level($1) < %spell.level) { $display.message($translate(NotRightLevelForSpell, $1, $2),private) | halt }

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

  if ((%user.flag != monster) && (%target.flag != monster)) { $set_chr_name($1) | $display.message($translate(CanOnlyAttackMonsters, $1),private)  | halt }

  ; Decrease the MP used
  dec %mp.have %mp.needed
  writeini $char($1) Battle MP %mp.have

  ; Check for a prescript
  if ($readini($dbfile(spells.db), n, $2, PreScript) != $null) { $readini($dbfile(spells.db), p, $2, PreScript) }

  ; Write to the file that we just used this spell
  writeini $char($1) cooldowns $2 %true.turn

  ; Write that we used this as the last action
  writeini $txtfile(battle2.txt) Actions $1 $2 


  ; to-do: add the code for the actual spell types


  ; Check for a postcript
  if ($readini($dbfile(spells.db), n, $2, PostScript) != $null) { $readini($dbfile(spells.db), p, $2, PostScript) }

  ; Time to go to the next turn
  if (%battleis = on)  {  $check_for_double_turn($1) | halt }

}
