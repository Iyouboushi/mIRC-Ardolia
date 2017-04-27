;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; battlecontrol.mrc
;;;; Last updated: 04/27/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This file contains code for the battles
; including the NEXT command, generating battle order
; and checking to see if it's over or not

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Battle Generate
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias battle.generate { 

  ; Let's move on by determining how many monsters we need to generate.
  var %monsters.needed $readini($zonefile(adventure), %current.room, monsters.needed)
  if (%monsters.needed <= 0) { inc %monsters.needed 1 }

  ; Get the list of monsters
  var %monsters.list $readini($zonefile(adventure), %current.room, monsters)

  ; No monsters to meet the players, end the adventure without any rewards.
  if (%monsters.list = $null) {  $display.message($translate(NoMonsAvailable), private) | $battle.end(defeat) | halt }

  ; Else we need to pick a monster.
  var %monsters.added 0

  while (%monsters.added < %monsters.needed) {
    $battle.generatemonster(%monsters.list)
    inc %monsters.added 1
  }

  ; Copy the party members over into the battle.txt
  var %partymember.list $readini($txtfile(adventure.txt), Info, PartyMembersList)
  var %number.of.partymembers $numtok(%partymember.list, 46) | var %current.partymember 1

  while (%current.partymember <= %number.of.partymembers) { 

    var %partymember.name $gettok(%partymember.list, %current.partymember, 46)

    write $txtfile(battle.txt) %partymember.name  
    set %battlelist.toadd $readini($txtfile(battle2.txt), Battle, List) | %battlelist.toadd = $addtok(%battlelist.toadd,%partymember.name,46) | writeini $txtfile(battle2.txt) Battle List %battlelist.toadd | unset %battlelist.toadd
    var %battleplayers $return_playersinbattle | inc %battleplayers 1 | writeini $txtfile(battle2.txt) BattleInfo Players %battleplayers

    inc %current.partymember 1
  }

  ; Set the turns
  set %current.turn 0 | inc %current.battle.number 1

  ; The battle may now start
  $battle.start
}

alias battle.generate.manual {
  ; Are there any monsters in battle?
  if (($return_monstersinbattle = $null) || ($return_monstersinbattle = 0)) { $translate(NoMonstersInBattle),battle) | $battle.end(defeat) | halt }

  ; Set the turns
  set %true.turn 0 | set %current.turn 0

  ; The battle may start
  $battle.start
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Picks a monster
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias battle.generatemonster {
  ; $1 = the list of monsters to choose from

  ; Picks a monster at random from the list
  var %number.of.monsters $numtok($1, 46)
  var %monster.name $gettok($1, $rand(1, %number.of.monsters), 46)

  $battle.addmonster(%monster.name) 

  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; adds the monster to the battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias battle.addmonster {
  ; Copies the file to the \characters\ folder.

  var %isboss $isfile($boss($1))
  var %ismonster $isfile($mon($1))

  if ((%isboss != $true) && (%ismonster != $true)) { $display.message(4 $+ $1 is not found in the monsters or bosses folder. The battle will end now.,battle) | $battle.end(defeat) | halt }

  set %found.monster true 
  var %current.monster.to.spawn.name $1
  var %multiple.monster.counter 2

  ; If the monster with the same name exists, let's add a counter to it so it can spawn
  while ($isfile($char(%current.monster.to.spawn.name)) = $true) { 
    var %current.monster.to.spawn.name $1 $+ %multiple.monster.counter 
    inc %multiple.monster.counter 1 | var %multiple.monster.found true
  }

  if ($isfile($boss($1)) = $true) { .copy -o $boss($1) $char(%current.monster.to.spawn.name)  }
  if ($isfile($mon($1)) = $true) {  .copy -o $mon($1) $char(%current.monster.to.spawn.name)  }

  if (%multiple.monster.found = true) {  
    var %real.name.spawn $get_chr_name($1) $calc(%multiple.monster.counter - 1)
    writeini $char(%current.monster.to.spawn.name) info name %real.name.spawn
    unset %real.name
  }

  ; increase the total # of monsters
  set %battlelist.toadd $readini($txtfile(battle2.txt), Battle, List) | %battlelist.toadd = $addtok(%battlelist.toadd,%current.monster.to.spawn.name,46) | writeini $txtfile(battle2.txt) Battle List %battlelist.toadd | unset %battlelist.toadd
  write $txtfile(battle.txt) %current.monster.to.spawn.name
  var %battlemonsters $return_monstersinbattle | inc %battlemonsters 1 | writeini $txtfile(battle2.txt) BattleInfo Monsters %battlemonsters

  ; display the description of the spawned monster
  $set_chr_name(%current.monster.to.spawn.name) 
  $display.message($readini(translation.dat, battle, MonsterEnteredTheBattle), battle)
  $display.message(12 $+ $get_chr_name(%current.monster.to.spawn.name)  $+ $readini($char(%current.monster.to.spawn.name), Descriptions, Char),battle)

  var %bossquote $readini($char(%current.monster.to.spawn.name), descriptions, bossquote)
  if (%bossquote != $null) { 
    var %bossquote 2 $+ %real.name looks at the heroes and says " $+ $readini($char(%current.monster.to.spawn), descriptions, BossQuote) $+ "
    $display.message(%bossquote, battle) 
  }

  unset %real.name
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The battle may now start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias battle.start {
  ; Now that we have everything and everyone in battle we need to roll initative.
  $battle.rollinitiative

  ; Display the battle information to the channel
  $battle.list

  ; turn the battle on
  set %battleis on

  ; advance the battle info to the first person
  set %line 0 |  $next
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rolls Iniative and determines the battle order
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias battle.rollinitiative {

  ; Is the battle over? Let's find out.
  $battle.check.for.end

  ; get rid of the Battle Table and the now un-needed file
  if ($isfile(BattleTable.file) = $true) { 
    hfree BattleTable
    .remove BattleTable.file
  }

  ; make the Battle List table
  hmake BattleTable

  ; load them from the file.   the initial list will be generated from the !enter commands.  
  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)

    var %battle.speed $roll(1d10)
    inc %battle.speed $current.spd(%who.battle)

    ; check for statuses and abilities that would lower that    
    if ($readini($char(%who.battle), status, slow) = yes) { %battle.speed = $calc(%battle.speed / 2) } 
    if ($readini($char(%who.battle), skills, Retaliation.on) = on) { %battle.speed = -1000 }

    ; check for statuses and abilities that would increase that

    ; increase action points
    var %action.points $action.points(%who.battle, check)

    if (%clearactionpoints = true) { var %action.points 0 }

    inc %action.points 1
    if (%battle.speed >= 1) { inc %action.points $round($log(%battle.speed),0) }
    if ($flag(%who.battle) = monster) { inc %action.points 1 }
    if ($readini($char(%who.battle), info, ai_type) = defender) { var %action.points 0 } 
    var %max.action.points $round($log(%battle.speed),0)
    inc %max.action.points 1

    if (%action.points > %max.action.points) { var %action.points %max.action.points }
    writeini $txtfile(battle2.txt) ActionPoints %who.battle %action.points

    if (%surpriseattack = on) {
      var %ai.type $readini($char(%who.battle), info, ai_type)
      if ((%ai.type != defender) && ($readini($char(%who.battle), monster, type) != object)) { 
        if ($readini($char(%who.battle), info, flag) = monster) { inc %battle.speed 9999999999 }
      }
    }

    if (%playersgofirst = on) {
      if ($flag(%who.battle) = $null) { inc %battle.speed 9999999999 }
    }

    if (%battle.speed <= 0) { var %battle.speed 1 }

    if ($readini($char(%who.battle), battle, status) = inactive) {  inc %battle.speed -9999999999 }
    if ($readini($char(%who.battle), monster, type) = object) { inc %battle.speed -99999999999 }
    if ($readini($char(%who.battle), info, ai_type) = defender) { inc %battle.speed -999999999999 }
    if ($readini($char(%who.battle), battle, status) = dead) { %battle.speed = -9999999999999 } 

    ; Write the person to the table and increase the counter
    hadd BattleTable %who.battle %battle.speed
    inc %battletxt.current.line
  }

  unset %clearactionpoints

  ; save the BattleTable hashtable to a file
  hsave BattleTable BattleTable.file

  ; load the BattleTable hashtable (as a temporary table)
  hmake BattleTable_Temp
  hload BattleTable_Temp BattleTable.file

  ; sort the Battle Table
  hmake BattleTable_Sorted
  var %battletableitem, %battletabledata, %battletableindex, %battletablecount = $hget(BattleTable_Temp,0).item
  while (%battletablecount > 0) {
    ; step 1: get the lowest item
    %battletableitem = $hget(BattleTable_Temp,%battletablecount).item
    %battletabledata = $hget(BattleTable_Temp,%battletablecount).data
    %battletableindex = 1
    while (%battletableindex < %battletablecount) {
      if ($hget(BattleTable_Temp,%battletableindex).data < %battletabledata) {
        %battletableitem = $hget(BattleTable_Temp,%battletableindex).item
        %battletabledata = $hget(BattleTable_Temp,%battletableindex).data
      }
      inc %battletableindex
    }

    ; step 2: remove the item from the temp list
    hdel BattleTable_Temp %battletableitem

    ; step 3: add the item to the sorted list
    %battletableindex = sorted_ $+ $hget(BattleTable_Sorted,0).item
    hadd BattleTable_Sorted %battletableindex %battletableitem

    ; step 4: back to the beginning
    dec %battletablecount
  }

  ; get rid of the temp table
  hfree BattleTable_Temp

  ; Erase the old battle.txt and replace it with the new one.
  .remove $txtfile(battle.txt)

  var %index = $hget(BattleTable_Sorted,0).item
  while (%index > 0) {
    dec %index
    var %tmp = $hget(BattleTable_Sorted,sorted_ $+ %index)
    write $txtfile(battle.txt) %tmp
  }

  ; get rid of the sorted table
  hfree BattleTable_Sorted

  ; get rid of the Battle Table and the now un-needed file
  hfree BattleTable
  .remove BattleTable.file

  ; unset the battle.speed
  unset %battle.speed

  ; increase the current turn.
  if (%battle.type != defendoutpost) { inc %current.turn 1 | inc %true.turn 1 }

  ; Count the total number of monsters in battle
  $count.monsters

  unset %surpriseattack | unset %playersgofirst

  if (%current.turn > 1) { 
    if ($rand(1,10) <= 4) {  $random.weather.pick(inbattle) }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ends the current battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias battle.end {
  ; $1 = victory, defeat, draw

  ; Clear the old monsters and variables
  $battle.clear

  ; if the players are all dead, the adventure is over
  if (($1 = defeat) || ($1 = draw)) { 
    ; display message saying the party is dead 
    $adventure.end($1) 
    halt  
  }

  ; Restore some MP and HP to players -- revive dead players, remove players who fled
  $battle.revivedeadplayers

  ; Display the endbattle message and set the room as cleared
  $display.message(7*2 $+ $readini($zonefile(adventure), %current.room, CombatEndDesc), global)
  writeini $zonefile(adventure) %current.room Clear true
  unset %battleis

  ; Is this the final boss/combat room of the dungeon?  If so, we won! Let's end the adventure with victory
  if (($1 = victory) && (%current.room = $readini($zonefile(adventure), Info, ClearRoom))) { $adventure.end(victory)   }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clears the battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias battle.clear { 
  ; Turn off the next timer
  /.timerbattlenext off

  ; Clear out the char folder of monsters
  .echo -q $findfile( $char_path , *.char, 0 , 0, clear_monsters $1-)

  ; Erase files that we no longer need
  .remove $txtfile(battle.txt) |  .remove $txtfile(battle2.txt) 

  ; Unset some variables
  unset %name | unset %found.monster | unset %multiple.monster.counter
  unset %current.turn | unset %current.battle.number | unset %monsters.in.battle
  unset %true.turn | unset %line | unset %next.person | unset %who | unset %status
  unset %wait.your.turn | unset %hp.percent | unset %hstats | unset %weapon.*
  unset %battletxt.* | unset %ai.* | unset %who.battle.ai 
  unset %status.message | unset %ai.type | unset %opponent.flag | unset %action.bar
  unset %techs | unset %damage.display.color
}

; ==========================
; The $next command.
; ==========================
alias next {
  unset %skip.ai | unset %file.to.read.lines | unset %user.gets.second.turn

  ; Reset the Next timer.
  var %nextTimer $readini(system.dat, system, TimeForIdle)
  if (%nextTimer = $null) { var %nextTimer 180 }
  /.timerBattleNext 1 %nextTimer /next ForcedTurn

  if ($1 = ForcedTurn) { 
    var %forced.turns $readini($char(%who), info, SkippedTurns)
    inc %forced.turns 1

    var %max.idle.turns $return.systemsetting(MaxIdleTurns)
    if (%max.idle.turns = null) { var %max.idle.turns 2 | writeini system.dat system MaxIdleTurns 2 }

    if ((%forced.turns >= %max.idle.turns) && ($readini($char(%who), info, flag) = $null)) { $display.message($readini(translation.dat, battle, DroppedOutofBattle), battle) |  writeini $char(%who) battle status runaway }
    writeini $char(%who) info SkippedTurns %forced.turns
  }

  if (%adventureis = off) { $clear_adventure | halt }

  if ($readini($char(%who), info, ai_type) = PayToAttack) { writeini $char(%who) currencies gil 0 }

  inc %line 1
  set %next.person $read -l $+ %line $txtfile(battle.txt)

  if (%next.person = $null) { set %line 1 | $battle.rollinitiative  } 
  set %who $read -l $+ %line $txtfile(battle.txt)
  $turn(%who)
}


; ==========================
; Displays battle information
; to the channel
; ==========================
on 3:TEXT:!batlist*:#:battle.list
on 3:TEXT:!bat list*:#:battle.list
on 3:TEXT:!bat info*:#:battle.list

alias battle.list {
  if (%battleis = off) { $display.message($translate(NoBattleCurrently), private) | halt }

  unset %battle.list | set %lines $lines($txtfile(battle.txt)) | set %l 1
  while (%l <= %lines) { 
    var %who.battle $read -l [ $+ [ %l ] ] $txtfile(battle.txt) | var %status.battle $readini($char(%who.battle), Battle, Status)
    if (%status.battle = $null) { inc %l 1 }
    else { 
      if ((%status.battle = dead) || (%status.battle = runaway)) { 
        var %token.to.add 4 $+ $get_chr_name(%who.battle)
        %battle.list = $addtok(%battle.list,%token.to.add,46) | inc %l 1 
      } 
      else { 
        if ($flag(%who.battle) = monster) { 
          unset %action.points

          if (($return.systemsetting(TurnType) = action) && ($readini($char(%who.battle), info, ai_type) != defender)) { var %action.points $chr(91) $+ $action.points(%who.battle, check) $+ $chr(93) }

          var %token.to.add 5 $+ $get_chr_name(%who.battle) $+ %action.points
          if ($readini($char(%who.battle), monster, type) = object) { var %token.to.add 14 $+ $get_chr_name(%who.battle) }
          if (($readini($boss(%who.battle), basestats, hp) != $null) || ($readini($char(%who.battle), monster, boss) = true)) { 

            if ($return.systemsetting(TurnType) = action) { var %action.points $chr(91) $+ $action.points(%who.battle, check) $+ $chr(93) }
            var %token.to.add 6 $+ $get_chr_name(%who.battle) $+ %action.points
          }
        }
        if ($flag(%who.battle) = npc) { 
          if ($return.systemsetting(TurnType) = action) { var %action.points $chr(91) $+ $action.points(%who.battle, check) $+ $chr(93) }
          var %token.to.add 12 $+ $get_chr_name(%who.battle) $+ %action.points
        }
        if ($flag(%who.battle) = $null) { 
          if ($return.systemsetting(TurnType) = action) { var %action.points $chr(91) $+ $action.points(%who.battle, check) $+ $chr(93) }
          var %token.to.add 3 $+ $get_chr_name(%who.battle) $+ %action.points
        }
        if ($current.hp(%who.battle) > 0) { var %token.to.add $replace(%token.to.add, $get_chr_name(%who.battle),  $+ $get_chr_name(%who.battle) $+ ) }

        %battle.list = $addtok(%battle.list,%token.to.add,46) | inc %l 1 
      }
    } 
  }

  unset %lines | unset %l 
  $battlelist.cleanlist

  if (%current.turn = $null) { var %current.turn 0 }
  if (%battleconditions != $null) { var %batlist.battleconditions [Conditions:12 $replace(%battleconditions, $chr(046), $chr(044) $chr(032)) $+ 4] } 

  $display.message($translate(BatListTitleMessage), private)
  $display.message(4[Turn #:12 %current.turn $+ 4] [Battlefield:12 $readini($zonefile(adventure), %current.room, Name) $+ 4] %batlist.battleconditions, private)

  if ((%darkness.turns != $null) && (%battle.type != ai)) { 
    var %darkness.countdown $calc(%darkness.turns - %current.turn) 
    if (%battle.type != defendoutpost)  {
      if (%darkness.countdown > 0) { $display.message(4[Darkness will occur in:12 %darkness.countdown 4turns], private) }
      if (%darkness.countdown <= 0) { $display.message(4[Darkness12 has overcome 4the battlefield], private) }
    }
  }

  if (%battle.type != ai) { 
    $display.message(4[Battle Order: %battle.list $+ 4], private) 
  }

  unset %battle.list | unset %who.battle
}

alias battlelist.cleanlist {
  ; CLEAN UP THE LIST
  if ($chr(046) isin %battle.list) { var %replacechar $chr(044) $chr(032)
    %battle.list = $replace(%battle.list, $chr(046), %replacechar)
  }
}

; ==========================
; Controls the turn
; ==========================
alias turn {
  unset %all_status | unset %status.message
  unset %attack.damage | unset %attack.damage1 | unset %attack.damage2 | unset %attack.damage3 | unset %attack.damage4 | unset %attack.damage5 | unset %attack.damage6 | unset %attack.damage7 | unset %attack.damage8 | unset %drainsamba.on | unset %absorb
  unset %element.desc | unset %spell.element | unset %real.name  |  unset %user.flag | unset %target.flag | unset %trickster.dodged | unset %covering.someone | unset %double.attack 
  unset %damage.display.color

  set %status $readini($char($1), Battle, Status)
  if ((%status = dead) || (%status = runaway)) { unset %status | $next | halt }

  if ($readini($char($1), info, ai_type) = defender) {
    if ($readini($char($1), descriptions, DefenderAI) != $null) { $set_chr_name($1) | $display.message(4 $+ $readini($char($1), descriptions, DefenderAI), battle) | unset %real.name  }
    $next 
    halt
  }

  if ($readini($char($1), battle, status) = inactive) {  $next  |  halt  }

  if ($readini($char($1), info, FirstTurn) = true) { writeini $char($1) info FirstTurn false | $next | halt }

  ; Is the battle over? Let's find out.
  $battle.check.for.end

  set %wait.your.turn on

  $turn.statuscheck($1) 

  $hp_status($1) | $set_chr_name($1)

  ; Does the person have any action points this round?
  if ($return.systemsetting(TurnType) = action) {
    if ($action.points($1, check) <= 0) { set %skip.ai on |  set %status.message $translate(NoActionPoints) }
    else { set %status.message $translate(TurnMessage) }
  }
  else { set %status.message $translate(TurnMessage, $1) }

  $display.message.delay(%status.message, battle, 1)

  if (($lines($txtfile(temp_status.txt)) != $null) && ($lines($txtfile(temp_status.txt)) > 0)) { 
    /.timerThrottle $+ $rand(a,z) $+ $rand(1,1000) $+ $rand(a,z) 1 1 /display.statusmessages $1 
  } 

  if ($lines($txtfile(temp_status.txt)) != $null) { 
    set %file.to.read.lines $lines($txtfile(temp_status.txt))
    inc %file.to.read.lines 2
  }


  ; Turn off certain status effects
  ; TO BE ADDED

  ; Check for status effects that cause someone to miss a turn
  ; to be added

  if (($return.systemsetting(TurnType) = action) && ($action.points($1, check) <= 0)) { /.timerThrottle $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z) 1 %file.to.read.lines /next | halt }

  unset %real.name

  if (%skip.ai != on) {
    ; Check for AI
    if (%file.to.read.lines > 0) { 
      /.timerSlowYouDown $+ $rand(a,z) $+ $rand(1,100) 1 %file.to.read.lines /set %wait.your.turn off 
      /.timerSlowYouDown2 $+ $rand(a,z) $+ $rand(1,100) 1 %file.to.read.lines /aicheck $1 | halt
    }
    else { set %wait.your.turn off | $aicheck($1) | halt }
  }
}



; ==========================
; Checks to see if anyone won yet
; ==========================
alias battle.check.for.end {

  ; Count the total number of monsters in battle
  $count.monsters

  var %battle.player.death $battle.player.death.check
  var %battle.monster.death $battle.monster.death.check

  if ((%battle.monster.death = true) && (%battle.player.death = true)) {  /.timerbattle.end $+ $rand(a,z) 1 4 /battle.end draw | halt } 

  if (%battle.type != dungeon) { 
    if ((%battle.monster.death = true) && (%battle.player.death = false)) { 
      .timerbattle.end $+ $rand(a,z) 1 4 /battle.end victory | halt 
    } 
    if ((%battle.monster.death = false) && (%battle.player.death = true)) { 
      /.timerbattle.end $+ $rand(a,z) 1 4 /battle.end defeat | halt
    } 
    if ((%battle.monster.death = $null) && (%battle.player.death = true)) {  /.timerbattle.end $+ $rand(a,z) 1 4 /battle.end victory | halt } 
  }

  unset %battle.player.death | unset %battle.monster.death
}

; ==========================
; See if all the players are dead.
; ==========================
alias battle.player.death.check {

  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  var %death.count 0
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %flag $flag(%who.battle)  | var %summon.flag $readini($char(%who.battle), info, summon)
    if (%flag = monster) { inc %battletxt.current.line }
    else {
      if ((%flag = npc) && (%battle.type != ai)) { inc %battletxt.current.line }
      else if (%summon.flag = yes) { inc %battletxt.current.line }
      else { 
        var %current.status $readini($char(%who.battle), battle, status)
        if ((%current.status = dead) || (%current.status = runaway)) { inc %death.count 1 | inc %battletxt.current.line 1 }
        else { inc %battletxt.current.line 1 } 
      }
    }
  }

  if (%mode.pvp != on) {
    if (%death.count = $readini($txtfile(battle2.txt), BattleInfo, Players)) { return true } 
    else { return false }
  }
  if (%mode.pvp = on) {
    if (%death.count = $calc($readini($txtfile(battle2.txt), BattleInfo, Players) - 1)) { return true }
    else { return false }
  }
}

; ==========================
; See if all the monsters are dead
; ==========================
alias battle.monster.death.check {

  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  var %death.count 0
  while (%battletxt.current.line <= %battletxt.lines) { 
    var %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    var %summon.flag $readini($char(%who.battle), info, summon)
    var %clone.flag $readini($char(%who.battle), info, clone)
    var %doppel.flag $readini($char(%who.battle), info, Doppelganger)
    var %object.flag $readini($char(%who.battle), monster, type)

    if ($flag(%who.battle) != monster) { inc %battletxt.current.line }
    else {
      var %increase.count yes

      if ((%clone.flag = yes) && (%doppel.flag != yes)) { var %increase.count no }
      if (%summon.flag = yes) { var %increase.count no }
      if (%object.flag = object) { var %increase.count no } 

      if (%increase.count = yes) { 
        var %current.status $readini($char(%who.battle), battle, status)
        if (((%current.status = dead) || (%current.status = runaway) || (%current.status = inactive))) { inc %death.count 1 }
      }

      inc %battletxt.current.line
    }
  }

  if (%death.count >= $return_monstersinbattle) { return true } 
  else { return false }
}
