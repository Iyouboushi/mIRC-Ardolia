;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; battle.als
;;;; Last updated: 04/27/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Attempts to match a partial
; target name to someone in
; the battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
partial.name.match {
  ; $1 = person using the command
  ; $2 = person they're trying to attack

  if ((($2 = me) || ($2 = himself) || ($2 = herself))) { set %attack.target $1 | return }

  if ($istok($return_peopleinbattle, $2, 46) = $true) { set %attack.target $2 }
  else { 
    set %attack.target $matchtok($return_peopleinbattle, $2, 1, 46)
    if (%attack.target = $null) { set %attack.target $2 }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns highest player level
; in the battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_playerlevelhighest {
  var %highest.level $readini($txtfile(adventure.txt), BattleInfo, HighestLevel)
  if (%highest.level = $null) { return 0 }
  return %highest.level
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns average player level
; in the battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_playerlevelaverage {
  var %average.level $readini($txtfile(adventure.txt), BattleInfo, AverageLevel)
  if (%average.level = $null) { return 0 }
  return %average.level
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns # of players in battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_playersinbattle {
  var %total.playersinbattle $readini($txtfile(battle2.txt), BattleInfo, Players)
  if (%total.playersinbattle = $null) { return 0 }

  var %total.npcsinbattle $readini($txtfile(battle2.txt), BattleInfo, NPCs) 
  if (%total.npcsinbattle != $null) { inc %total.playersinbattle %total.npcsinbattle }

  return %total.playersinbattle
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns list of battle participants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_peopleinbattle {
  var %temp.peopleinbattle $readini($txtfile(battle2.txt), battle, list)
  if (%temp.peopleinbattle = $null) { return null }
  else { return %temp.peopleinbattle }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns # of monsters in battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_monstersinbattle {
  var %total.monsinbattle $readini($txtfile(battle2.txt), BattleInfo, Monsters)
  if (%total.monsinbattle = $null) { return 0 }
  else { return %total.monsinbattle }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns max # of monsters in battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_maxmonstersinbattle {
  if ($return.systemsetting(botType) = DCCchat) { return 50 }

  var %max.monsters.allowed $return.systemsetting(MaxNumberOfMonsInBattle)
  if (%max.monsters.allowed = null) { return 10 }
  else { return %max.monsters.allowed }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This alias just counts how
; many monsters are in
; the battle. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
count.monsters {
  set %monsters.in.battle 0 

  var %count.battletxt.lines $lines($txtfile(battle.txt)) | var %count.battletxt.current.line 1 
  while (%count.battletxt.current.line <= %count.battletxt.lines) { 
    var %count.who.battle $read -l $+ %count.battletxt.current.line $txtfile(battle.txt)
    if (%count.who.battle = $null) { write -d $+ %count.battletxt.current.line $txtfile(battle.txt) | inc %count.battletxt.current.line }

    else { 
      var %count.flag $flag(%count.who.battle)

      if (%count.flag = monster) { 
        var %summon.flag $readini($char(%count.who.battle), info, summon)
        var %clone.flag $readini($char(%count.who.battle), info, clone)
        var %doppel.flag $readini($char(%count.who.battle), info, Doppelganger)
        var %object.flag $readini($char(%count.who.battle), monster, type)

        if (((%summon.flag != yes) && (%object.flag != object) && (%clone.flag != yes))) {  inc %monsters.in.battle 1 }
        if (%doppel.flag = yes) { inc %monsters.in.battle 1 }
      }

      inc %count.battletxt.current.line 1
    }
  }
  writeini $txtfile(battle2.txt) battleinfo monsters %monsters.in.battle
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Enmity
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
enmity {
  ; $1 = person
  ; $2 = add/remove/return
  ; $3 = amount for add/remove

  if ($2 = add) { 
    var %current.enmity $readini($txtfile(battle2.txt), Enmity, $1)
    if (%current.enmity = $null) { var %current.enmity 0 }

    inc %current.enmity $3
    writeini $txtfile(battle2.txt) Enmity $1 %current.enmity
  }

  if ($2 = remove) { 
    var %current.enmity $readini($txtfile(battle2.txt), Enmity, $1)
    if (%current.enmity = $null) { var %current.enmity 0 }

    dec %current.enmity $3
    if (%current.enmity < 0) { var %current.enmity 0 }
    writeini $txtfile(battle2.txt) Enmity $1 %current.enmity
  }

  if ($2 = return) { 
    var %current.enmity $readini($txtfile(battle2.txt), Enmity, $1)
    if (%current.enmity = $null) { return 0 }
    else { return %current.enmity }
  }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if it's a
; person's turn or not.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_for_battle { 
  if (%wait.your.turn = on) { $display.message($translate(WaitYourTurn, %who), private) | halt }
  if ((%battleis = on) && (%who = $1)) { return }
  if ((%battleis = on) && (%who != $1)) { $display.message($translate(WaitYourTurn, %who), private) | halt }
  else { return  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if someone
; is in the battle or not.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
person_in_battle {
  set %temp.battle.list $readini($txtfile(battle2.txt), Battle, List)
  if ($istok(%temp.battle.list,$1,46) = $false) {  unset %temp.battle.list | $set_chr_name($1) 
    $display.message($translate(NotInbattle, $1),private) 
    unset %real.name | halt 
  }
  else { return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for things that would
; stop a person from having
; a turn.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
no.turn.check {
  if ((%battleis = off) && ($2 != return)) { halt }
  if ($resting.hp($1) = $null) { halt }
  if ($flag($1) = monster) { return }
  if ($flag($1) = npc) { return }

  if ($is_charmed($1) = true) { $display.message($translate(CurrentlyCharmed), private) | halt }
  if ($is_confused($1) = true) { $display.message($translate(CurrentlyConfused),private) | halt }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for a chance at
; a double turn
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_for_double_turn {
  ; for now, this just moves the battle along
  ; Later I'll add a small chance
  $next
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function actually deals
; the damage to the target.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
deal_damage {
  ; $1 = person dealing damage
  ; $2 = target
  ; $3 = action that was done (tech name, item, etc)
  ; $4 = absorb or none

  $set_chr_name($1) | set %user %real.name
  $set_chr_name($2) | set %enemy %real.name

  set %attack.damage $round(%attack.damage, 0)

  if (%guard.message != $null) { set %attack.damage 0 }

  ; Is the target a TRUE metal defense target? If so, this will always be 1 damage max.
  if ((%attack.damage > 0) && ($readini($char($2), info, TrueMetalDefense) = true)) { 
    unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
    set %attack.damage 1 
  }

  ; Do we need to wake up a sleeping target?
  if ((%attack.damage > 0) && ($readini($char($2), Status, Sleep) = yes)) { 
    $display.message($translate(WakesUp), battle) 
    writeini $char($2) status sleep no
  }

  unset %absorb.message


  ; Check for natural armor.

  if (%attack.damage > 0) {

    var %naturalArmorCurrent $readini($char($2), NaturalArmor, Current)

    if ((%naturalArmorCurrent != $null) && (%naturalArmorCurrent > 0)) {
      set %naturalArmorName $readini($char($2), NaturalArmor, Name) 
      set %difference $calc(%attack.damage - %naturalArmorCurrent)
      dec %naturalArmorCurrent %attack.damage | writeini $char($2) NaturalArmor Current %naturalArmorCurrent

      if (%naturalArmorCurrent <= 0) { set %attack.damage %difference | writeini $char($2) naturalarmor current 0
        if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) {  $display.message($readini(translation.dat, battle, NaturalArmorBroken),battle) }
        if ($readini(system.dat, system, botType) = DCCchat) { $dcc.battle.message($readini(translation.dat, battle, NaturalArmorBroken)) }
        unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
      }
      if (%naturalArmorCurrent > 0) { set %guard.message $readini(translation.dat, battle, NaturalArmorAbsorb) | set %attack.damage 0 }

      unset %difference
    }

  }

  if ($readini($char($2), info, IgnoreDrain) = true) { unset %absorb | unset %drainsamba.on | unset %absorb.amount }

  ; decrease the target's life
  var %life.target $current.hp($2)
  dec %life.target %attack.damage
  writeini $char($2) battle hp %life.target

  ; If it's an Absorb HP type, we need to add the hp to the person.
  if ($person_in_mech($2) = false) { 
    if (($4 = absorb) || (%absorb = absorb)) { 

      if ($readini($char($2), info, IgnoreDrain) != true) {

        if (%guard.message = $null) {
          if ($readini($char($2), monster, type) != undead) {
            var %absorb.amount $round($calc(%attack.damage / 3),0)
            if (%bloodmoon = on) {  var %absorb.amount $round($calc(%attack.damage / 1.4),0) }

            if ($accessory.check($1, CurseAddDrain) = true) {
              var %absorb.amount $round($calc(%attack.damage / 1.7),0)
              unset %accessory.amount
            }

            unset %current.accessory | unset %current.accessory.type

            if ((%battle.type = torment)  || (%battle.type = dungeon)) { 
              if (($readini($char($1), info, flag) = $null) || ($readini($char($1), info, flag) = npc)) {
                if (%absorb.amount > 1500) { var %absorb.amount 1500 }
              }
            }

            set %life.target $readini($char($1), Battle, HP) | set %life.max $resting.hp($1)
            inc %life.target %absorb.amount
            if (%life.target >= %life.max) { set %life.target %life.max }
            writeini $char($1) battle hp %life.target
          }
          if ($readini($char($2), monster, type) = undead) { unset %absorb | unset %absorb.amount }
        }

      }
      if (%guard.message != $null) { unset %absorb | unset %absorb.amount }
    }

    if (($augment.check($1, AbsorbTP) = true) && (%guard.message = $null)) {
      var %tp.absorb.amount $calc(%augment.strength * 10)
      set %tp.target $readini($char($2), battle, tp) 

      if (%tp.target > 0) {
        set %tp.user $readini($char($1), battle, tp) | set %tp.max $readini($char($1), basestats, tp) 
        inc %tp.user %tp.absorb.amount
        if (%tp.user >= %tp.max) { writeini $char($1) battle tp %tp.max }
        if (%tp.user < %tp.max) { writeini $char($1) battle tp %tp.user }

        $set_chr_name($1) | set %absorb.message 3 $+ %real.name absorbs %tp.absorb.amount TP from $set_chr_name($2) %real.name $+ !
        set %tp.max $readini($char($2), basestats, tp) 
        dec %tp.target %tp.absorb.amount
        if (%tp.target <= 0) { writeini $char($2) battle tp 0 }
        if (%tp.target > 0) { writeini $char($2) battle tp %tp.target }
      }
      unset %tp.user | unset %tp.target | unset %tp.max
    } 

    if (($augment.check($1, AbsorbIG) = true) && (%guard.message = $null)) {
      if ((%aoe.turn <= 1) || (%aoe.turn = $null)) {
        var %ig.absorb.amount $calc(%augment.strength * 5)
        if ($readini($char($1), info, flag) = monster) { var %ig.absorb.amount $calc(%augment.strength * 10) }

        set %ig.target $readini($char($2), battle, IgnitionGauge)
        if (%ig.target < %ig.absorb.amount) { var %ig.absorb.amount %ig.target }

        if (%ig.target > 0) { 
          set %ig.user $readini($char($1), battle, IgnitionGauge)
          set %ig.max $readini($char($1), basestats, IgnitionGauge) 
          inc %ig.user %ig.absorb.amount
          if (%ig.user >= %ig.max) { writeini $char($1) battle IgnitionGauge %ig.max }
          if (%ig.user < %ig.max) { writeini $char($1) battle IgnitionGauge %ig.user }

          $set_chr_name($1) | set %absorb.message 3 $+ %real.name absorbs %ig.absorb.amount Ignition Gauge from $set_chr_name($2) %real.name $+ !

          set %ig.max $readini($char($2), basestats, IgnitionGauge) 
          dec %ig.target %ig.absorb.amount
          if (%ig.target <= 0) { writeini $char($2) battle IgnitionGauge 0 }
          if (%ig.target > 0) { writeini $char($2) battle IgnitionGauge %ig.target }
        }
        unset %ig.user | unset %ig.target | unset %ig.max
      }
    }
  }


  if ($readini($char($2), battle, HP) <= 0) { 

    writeini $char($2) battle status dead 
    writeini $char($2) battle hp 0

    if ((%battle.type = assault) && ($readini($char($2), info, flag) = monster)) { 
      if ($isfile($boss($2)) = $true) { $monster.outpost(remove, $rand(2,3)) }
      if ($isfile($mon($2)) = $true) { $monster.outpost(remove, 1) }
    }

    ; Add the XP and gil drops to the pool

    ; check for an item drop
    $add.monster.drop($1, $2)
    $add.monster.xp($1, $2)

    ; if the attacker isn't a monster we need to increase the total # of kills
    if (($readini($char($1), info, flag) != monster) && ($readini($char($1), battle, hp) > 0)) {
      $inc_monster_kills($1)
    }
  }

  $ai.learncheck($2, $3)

  if (%guard.message = $null) { $renkei.calculate($1, $2, $3) }

  ; Increase total damage that we're keeping track of
  if ((($4 = tech) || ($4 = melee) || ($5 = tech))) {
    if (($person_in_mech($1) = false) && (%guard.message = $null)) {
      if (($4 = tech) || ($5 = tech)) { var %totalstat tech }
      else { var %totalstat melee }

      var %current.totaldamage $readini($char($1), MiscStats, totalDmg. $+ %totalstat) 
      var %current.totalhits $readini($char($1), MiscStats, %totalstat $+ Hits)
      if (%current.totaldamage = $null) { var %current.damage 0 }
      if (%current.totalhits = $null) { var %current.totalhits 0 }
      inc %current.totalhits 1
      inc %current.totaldamage %attack.damage

      writeini $char($1) MiscStats totalDmg. $+ %totalstat %current.totaldamage
      writeini $char($1) MiscStats %totalstat $+ Hits %current.totalhits
    } 
  }

  ; Increase enmity
  if ($flag($1) != monster) { $enmity($1, add, %attack.damage) }

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function is for healing
; damage done to a target
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
heal_damage {
  ; $1 = person heal damage
  ; $2 = target
  ; $3 = action that was done (tech name, item, etc)

  ; Increase enmity
  if ($flag($1) != monster) { $enmity($1, add, $calc(%attack.damage * 2)) }

  $restore_hp($2, %attack.damage)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function actually shows
; the damage to the channel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display_damage {
  ; $1 = person attacking
  ; $2 = person defending
  ; $3 = type of display needs to be done
  ; $4 = weapon/tech/item name

  ; A valid command was done, so let's turn the next timer off before we do this
  /.timerBattleNext off

  ; Begin displaying the damage
  unset %overkill |  unset %style.rating | unset %target | unset %attacker 

  set %user $get_chr_name($1)
  set %enemy $get_chr_name($2)


  if (%damage.display.color = $null) { var %damage.display.color 4 }

  ; Show a random attack description
  if ($3 = weapon) { 

    if (%counterattack != shield) {

      set %attacker $1 | set %target $2 
      var %weapon.type $readini($dbfile(weapons.db), $4, type) |  var %attack.file $txtfile(attack_ $+ %weapon.type $+ .txt) 

      echo -a attacker: $1
      echo -a target: $2
      echo -a weapn type; %weapon.type
      echo -a attack file: %attack.file

    $display.message(3 $+ %user $+  $read %attack.file  $+ 3., battle)  }
  }

  if (%counterattack = shield) {
    var %weapon.equipped $readini($char($1), weapons, equipped)
    set  %weapon.type $readini($dbfile(weapons.db), %weapon.equipped, type)
    var %attack.file $txtfile(attack_ $+ %weapon.type $+ .txt)

    $display.message(3 $+ %user $+  $read %attack.file  $+ 3., battle)  

    $display.message($readini(translation.dat, battle, ShieldCountered), battle)
    $set_chr_name($1) | set %enemy %real.name | set %target $1 | set %attacker $2 | $set_chr_name($2) | set %user %real.name 
  }

  if (%shield.block.line != $null) { 
    if (%counterattack != on) { $display.message(%shield.block.line, battle) | unset %shield.block.line }
  }

  if ($3 = item) {  $display.message(3 $+ %user $+  $readini($dbfile(items.db), $4, desc), battle) }


  ; Show the damage
  if (%number.of.hits > 1) { $display.message($readini(translation.dat, battle, PerformsAMultiHitAttack)) }

  if ($3 != aoeheal) {
    if (%guard.message = $null) {  $display.message(The attack did $+ %damage.display.color $+  $bytes(%attack.damage,b) damage to %enemy, battle)  }
    if (%guard.message != $null) { $display.message(%guard.message,battle)   }
    if (%element.desc != $null) {  $display.message(%element.desc, battle) 
      unset %element.desc 
    }
  }
  if ($3 = aoeheal) { 
    if (%guard.message = $null) {  $display.message(The attack did $+ %damage.display.color $+  $bytes(%attack.damage,b) damage to %enemy, battle)    }
    if (%guard.message != $null) { $display.message(%guard.message,battle)  }
    if (%element.desc != $null) {  $display.message(%element.desc,battle) 
      unset %element.desc 
    }
  }


  if (%element.desc != $null) {  $display.message(%element.desc, battle) }

  if (%target = $null) { set %target $2 }
  if (%attacker = $null) { set %attacker $1 }

  if (%statusmessage.display != $null) { 
    if ($readini($char(%target), battle, hp) > 0) { $display.message(%statusmessage.display,battle) 
      unset %statusmessage.display 
    }
  }

  if (%absorb = absorb) {
    if (%guard.message = $null) {
      ; Show how much the person absorbed back.
      var %absorb.amount $round($calc(%attack.damage / 3),0)
      if (%bloodmoon = on) {  var %absorb.amount $round($calc(%attack.damage / 1.5),0) }

      if ((%battle.type = torment)  || (%battle.type = dungeon)) { 
        if (($readini($char($1), info, flag) = $null) || ($readini($char($1), info, flag) = npc)) {
          if (%absorb.amount > 1500) { var %absorb.amount 1500 }
        }
      }

      $display.message(3 $+ %user absorbs $bytes(%absorb.amount,b) HP back from the damage.,battle) 
      unset %absorb
    }
  }

  if (%drainsamba.on = on) {
    if (%guard.message = $null) {
      if (($readini($char(%target), monster, type) != undead) && ($readini($char(%target), monster, type) != zombie)) { 
        var %absorb.amount $round($calc(%attack.damage / 3),0)
        if (%bloodmoon = on) {  var %absorb.amount $round($calc(%attack.damage / 1.5),0) }
        if (%absorb.amount <= 0) { var %absorb.amount 1 }

        if ((%battle.type = torment)  || (%battle.type = dungeon)) { 
          if (($readini($char($1), info, flag) = $null) || ($readini($char($1), info, flag) = npc)) {
            if (%absorb.amount > 1500) { var %absorb.amount 1500 }
          }
        }

        $display.message(3 $+ %user absorbs $bytes(%absorb.amount,b) HP back from the damage.,battle) 
        set %life.target $readini($char($1), Battle, HP) | set %life.max $resting.hp($1)
        inc %life.target %absorb.amount
        if (%life.target >= %life.max) { set %life.target %life.max }
        writeini $char($1) battle hp %life.target
        unset %life.target | unset %life.target | unset %absorb.amount 
      }
    }
  }
  if (%absorb.message != $null) { 
    if (%guard.message = $null) { $display.message(%absorb.message,battle) 
      unset %absorb.message
    }
  }

  unset %guard.message


  ; Check for inactive..
  if ($readini($char(%target), battle, status) = inactive) {
    if ($readini($char(%target), battle, hp) > 0) { 
      if ($readini($char($1), info, flag) != monster) { 
        writeini $char(%target) battle status alive

        if ($readini($char(%target), descriptions, Awaken) != $null) { $display.message(4 $+ %enemy  $+ $readini($char(%target), descriptions, Awaken), battle) }
        if ($readini($char(%target), descriptions, Awaken) = $null) { $display.message($readini(translation.dat, battle, inactivealive),battle)    }
        $next 
      }
    }
  }

  ; Did the person die?  If so, show the death message.
  if ($readini($char(%target), battle, HP) <= 0) { 

    $increase_death_tally(%target)

    if (%attack.damage > $resting.hp($1)) { set %overkill 7<<OVERKILL>> }

    $display.message($translate(EnemyDefeated), battle)
    unset %overkill

    ; check to see if a clone or summon needs to die with the target
    $check.clone.death(%target)

    if ($readini($char($1), info, flag) = $null) {
      ; increase the death tally of the target
      if ($readini($char(%target), battle, status) = dead) {  $increase.death.tally(%target)  }
    }

    $spawn_after_death(%target)
    remini $char(%target) Renkei

    unset %number.of.hits
  }


  if ($readini($char(%target), battle, HP) > 0) {
    if ($3 = tech) { unset %attack.damage | $renkei.check($1, %target) }
  }


  unset %target | unset %attacker | unset %user | unset %enemy | unset %counterattack |  unset %statusmessage.display

  if ($3 = weapon) {
    if ($readini($char($1), battle, hp) > 0) {
      set %inflict.user $1 | set %inflict.techwpn $4
      $self.inflict_status(%inflict.user, %inflict.techwpn ,weapon)
      if (%statusmessage.display != $null) { $display.message(%statusmessage.display, battle) | unset %statusmessage.display }
    }
  }  

  unset %hp.percent |  unset %attack.target |  unset %weapon.equipped*
  unset %inflict.user  |  unset %inflict.techwpn | unset %status.message
  unset %hstats | unset %status

  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays AOE damage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display_aoedamage {
  ; $1 = user
  ; $2 = target
  ; $3 = tech name
  ; $4 = flag for if it's a melee


  if (%damage.display.color = $null) { var %damage.display.color 4 }

  unset %overkill | unset %target |  unset %style.rating
  $set_chr_name($1) | set %user %real.name
  if ($person_in_mech($1) = true) { set %user %real.name $+ 's $readini($char($1), mech, name) } 

  $set_chr_name($2) | set %enemy %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }

  ; Show the damage
  if ($person_in_mech($2) = false) { 
    if ($4 = $null) { 
      if (($readini($char($2), status, reflect) = yes) && ($readini($dbfile(techniques.db), $3, magic) = yes)) { $display.message($readini(translation.dat, skill, MagicReflected), battle) | $set_chr_name($1) | set %enemy %real.name | set %target $1 | writeini $char($2) status reflect no | writeini $char($2) status reflect.timer 1  }
    }
  }

  if ($3 != battlefield) {
    if (($readini($char($1), info, flag) != monster) && (%target != $1)) { $calculate.stylepoints($1) }
  }

  if (%guard.message = $null) { $display.message($readini(translation.dat, tech, DisplayAOEDamage), battle)  }
  if (%guard.message != $null) { $display.message(%guard.message, battle) | unset %guard.message }

  if (%target = $null) { set %target $2 }

  if ($4 = absorb) { 
    ; Show how much the person absorbed back.
    var %absorb.amount $round($calc(%attack.damage / 2),0)
    $display.message($readini(translation.dat, tech, AbsorbHPBack), battle)
  }

  if (%absorb.message != $null) { 
    if (%guard.message = $null) { 
      $display.message(%absorb.message,battle) 
      unset %absorb.message
    }
  }

  set %target.hp $readini($char(%target), battle, hp)

  if ((%target.hp > 0) && ($person_in_mech(%target) = false)) {

    ; Check for inactive..
    if ($readini($char(%target), battle, status) = inactive) {
      if ($readini($char($1), info, flag) != monster) { 
        writeini $char(%target) battle status alive
        if ($readini($char(%target), descriptions, Awaken) != $null) { $display.message(4 $+ %enemy  $+ $readini($char(%target), descriptions, Awaken), battle) }
        if ($readini($char(%target), descriptions, Awaken) = $null) { $display.message($readini(translation.dat, battle, inactivealive),battle)    }
      }
    }

    if (%battle.type = orbfountain) { 
      if (($readini($char(%target), battle, status) != dead) && ($return_winningstreak >= 50)) { 
        if ($rand(1,100) < 30) {
          if (($1 != battlefield) && (%target = orb_fountain)) { 
            $display.message($translate(MonstersDefendOrbFountain), battle)
            $portal.clear.monsters
            $generate_monster(monster)
          }
        }
      }
    }

    ; Check to see if the monster can be staggered..  
    var %stagger.check $readini($char(%target), info, CanStagger)
    if ((%stagger.check = $null) || (%stagger.check = no)) { return }

    ; Do the stagger if the damage is above the threshold.
    var %stagger.amount.needed $readini($char(%target), info, StaggerAmount)
    dec %stagger.amount.needed %attack.damage | writeini $char(%target) info staggeramount %stagger.amount.needed
    if (%stagger.amount.needed <= 0) { writeini $char(%target) status staggered yes |  writeini $char(%target) info CanStagger no
      $display.message($translate(StaggerHappens), battle)
    }



  }


  ; Did the person die?  If so, show the death message.

  if ((%target.hp  <= 0) && ($person_in_mech($2) = false)) { 
    writeini $char(%target) battle status dead 
    writeini $char(%target) battle hp 0
    $check.clone.death(%target)
    $increase_death_tally(%target)
    $achievement_check(%target, SirDiesALot)
    if (%attack.damage > $resting.hp(%target)) { set %overkill 7<<OVERKILL>> }
    $display.message($readini(translation.dat, battle, EnemyDefeated), battle)

    if ($readini($dbfile(techniques.db), $3, magic) = yes) {  $goldorb_check(%target, magic)  }
    if ($readini($dbfile(techniques.db), $3, magic) != yes) { $goldorb_check(%target, tech) }

    if ($readini($char($1), info, flag) = $null) {
      ; increase the death tally of the target
      if ($readini($char(%target), battle, status) = dead) {  $increase.death.tally(%target)  }
    }

    $spawn_after_death(%target)
    $achievement_check($1, FillYourDarkSoulWithLight)
  }

  if ($person_in_mech($2) = true) { 
    ; Is the mech destroyed?
    if ($readini($char($2), mech, HpCurrent) <= 0) {  var %mech.name $readini($char($2), mech, name)
      $display.message($readini(translation.dat, battle, DisabledMech), battle)
      writeini $char($2) mech inuse false
    }
  }



  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %double.attack | unset %triple.attack | unset %fourhit.attack | unset %fivehit.attack | unset %sixhit.attack | unset %sevenhit.attack | unset %eighthit.attack 
  unset %attack.damage | unset %target
  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This function displays the
; healing to the channel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display_heal {
  unset %style.rating
  $set_chr_name($1) | set %user %real.name
  if ($person_in_mech($1) = true) { set %user %real.name $+ 's $readini($char($1), mech, name) } 

  $set_chr_name($2) | set %enemy %real.name
  if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }

  if (%user = %enemy ) { set %enemy $gender2($1) $+ self }

  if ($3 = tech) {
    if (%showed.tech.desc != true) {
      $set_chr_name($1)
      $display.message(3 $+ %real.name $+  $readini($dbfile(techniques.db), $4, desc),battle) 
    }
  }

  if ($3 = item) {
    $display.message(3 $+ %user $+  $readini($dbfile(items.db), $4, desc),battle) 
  }

  if ($3 = weapon) { 
    var %weapon.type $readini($dbfile(weapons.db), $4, type) | var %attack.file $txtfile(attack_ $+ %weapon.type $+ .txt)
    $display.message(3 $+ %user $+  $read %attack.file  $+ 3.,battle) 
  }

  ; Show the damage healed
  if (%guard.message = $null) {  $set_chr_name($2) |  $set_chr_name($2)
    $set_chr_name($2) | set %enemy %real.name
    if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }
    $display.message(3 $+ %enemy has been healed for $bytes(%attack.damage,b) health!, battle) 
  }
  if (%guard.message != $null) { 
    $set_chr_name($2) | set %enemy %real.name
    if ($person_in_mech($2) = true) { set %enemy %real.name $+ 's $readini($char($2), mech, name) }
    $display.message(%guard.message,battle) 
    unset %guard.message
  }

  ; Did the person die?  If so, show the death message.
  if ($readini($char($2), battle, HP) <= 0) { 
    $set_chr_name($2) 
    $display.message(4 $+ %enemy has been defeated by %user $+ !  %overkill,battle) 
    $achievement_check($1, FillYourDarkSoulWithLight)
  }

  unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %drainsamba.on | unset %absorb
  unset %element.desc | unset %spell.element | unset %real.name  |  unset %trickster.dodged | unset %covering.someone

  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Adds a monster's drop to
; the pool
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
add.monster.drop {
  ; $1 = the person who killed
  ; $2 = the monster

  if ($flag($2) != monster) { return }

  ; Determine gil
  var %gil.reward $roll(1d5)

  var %total.gil.amount $readini($txtfile(adventure.txt), Rewards, Gil)
  if (%total.gil.amount = $null) { var %total.gil.amount 0 }
  inc %total.gil.amount %gil.reward


  writeini $txtfile(adventure.txt) Rewards Gil %total.gil.amount


  ; Determine spoil
  var %drop.chance $readini($char($2), Info, DropChance)
  if (%drop.chance = $null) { var %drop.chance 10 }

  ; Is there an item for this monster?

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Adds xp to the pool
; to be given out at the
; end of battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
add.monster.xp {
  ; $1 = the person who killed
  ; $2 = the monster

  if ($flag($2) != monster) { return }

  ; Get the XP value from the monster
  var %xp.amount $readini($char($2), info, xpvalue) 
  if (%xp.amount = $null) { var %xp.amount 1 }

  var %total.xp.amount $readini($txtfile(adventure.txt), Rewards, XP)
  if (%total.xp.amount = $null) { var %total.xp.amount 0 }
  inc %total.xp.amount %xp.amount

  writeini $txtfile(adventure.txt) Rewards XP %total.xp.amount
}




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Action Point alias
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Not really used in this game
; but keeping it in case I change
; my mind later
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
action.points {
  ; $1 = person
  ; $2 = check, add, remove or initialize
  ; $3 = amount to add or remove

  if ($2 = check) {
    var %current.actionpoints $readini($txtfile(battle2.txt), ActionPoints, $1)
    if (%current.actionpoints = $null) { writeini $txtfile(battle2.txt) ActionPoints $1 0 | return 0 }
    else { return %current.actionpoints }
  }

  if ($2 = add) { 
    var %current.actionpoints $readini($txtfile(battle2.txt), ActionPoints, $1)
    if (%current.actionpoints = $null) { var %current.actionpoints 0 }
    inc %current.actionpoints $3
    writeini $txtfile(battle2.txt) ActionPoints $1 %current.actionpoints
  }

  if ($2 = remove) {
    var %current.actionpoints $readini($txtfile(battle2.txt), ActionPoints, $1)
    if (%current.actionpoints = $null) { var %current.actionpoints 0 }
    dec %current.actionpoints $3
    writeini $txtfile(battle2.txt) ActionPoints $1 %current.actionpoints
  }

  if ($2 = initialize) {
    var %battle.speed $readini($char($1), battle, speed)
    var %action.points $action.points($1, check)
    var %max.action.points $round($log(%battle.speed),0)
    inc %max.action.points 1

    inc %action.points 1
    if (%battle.speed >= 1) { inc %action.points $round($log(%battle.speed),0) }
    if ($readini($char($1), info, flag) = monster) { 
      if (%portal.bonus = true) { inc %action.points 1 | inc %max.action.points 1 }
      if (%battle.type = dungeon) { inc %action.points 1 | inc %max.action.points 1 }
      inc %action.points 1 | inc %max.action.points 1
    }
    if ($readini($char($1), info, ai_type) = defender) { var %action.points 0 } 

    ; If the person gains more action ponits than they have, cap it to their max
    if (%action.points > %max.action.points) { var %action.points %max.action.points }

    writeini $txtfile(battle2.txt) ActionPoints $1 %action.points
  }
}
