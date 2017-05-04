;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; system.als
;;;; Last updated: 05/04/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Version of the bot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
game.version {  
  if ($readini(version.ver, versions, Bot) = $null) { echo -a 4ERROR: version.ver is either missing or corrupted! | return 1.0 }
  else { return $readini(version.ver, versions, Bot) } 
} 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Version of the system.dat file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
system.dat.version { 
  if ($readini(version.ver, versions, systemdat) = $null) { echo -a 4ERROR: version.ver is either missing or corrupted! | return 0 }
  else { return $readini(version.ver, versions, systemdat) } 
} 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Version of the character file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
charfile.version {  
  if ($readini(version.ver, versions, Character) = $null) { echo -a 4ERROR: version.ver is either missing or corrupted! | return 1.0 }
  else { return $readini(version.ver, versions, Character) } 
} 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The bot's quit message
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
quitmsg { return Battle Arena version $game.version written by James  "Iyouboushi" }


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Paths
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
char { return " $+ $mircdir $+ %player_folder $+ $1 $+ .char" }
boss { return " $+ $mircdir $+ %boss_folder $+ $1 $+ .char" } 
mon { return " $+ $mircdir $+ %monster_folder $+ $1 $+ .char" }
npc { return " $+ $mircdir $+ %npc_folder $+ $1 $+ .char" }
summon { return " $+ $mircdir $+ %summon_folder $+ $1 $+ .char" } 
zapped { return " $+ $mircdir $+ %player_folder $+ zapped $+ \ $+ $1 $+ .char" }
lstfile { return " $+ $mircdir $+ lsts\ $+ $1" }
txtfile {  return " $+ $mircdir $+ txts\ $+ $1" }
dbfile { return " $+ $mircdir $+ dbs\ $+ $1" }
zonefile { return " $+ $mircdir $+ zones\ $+ $1 $+ .zone $+ " }
jobfile { return " $+ $mircdir $+ jobs\ $+ $1 $+ .job $+ " }
racefile { return " $+ $mircdir $+ races\ $+ $1 $+ .race $+ " }
job_path { return " $+ $mircdir $+ jobs $+ " }
zone_path { return " $+ $mircdir $+ zones $+ " }
char_path { return " $+ $mircdir $+ %player_folder $+ " }
mon_path { return " $+ $mircdir $+ %monster_folder $+ " }
boss_path { return " $+ $mircdir $+ %boss_folder $+ " }
npc_path { return " $+ $mircdir $+ %npc_folder $+ " }
zap_path { return " $+ $mircdir $+ %player_folder $+ %zapped_folder $+ " }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for all system defaults
; and adds any that are missing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
system_defaults_check {
  if (%player_folder = $null) { set %player_folder characters\ }
  if (%boss_folder = $null) { set %boss_folder bosses\ }
  if (%monster_folder = $null) { set %monster_folder monsters\ }
  if (%zapped_folder = $null) { set %zapped_folder zapped\ }
  if (%npc_folder = $null) { set %npc_folder npcs\ }
  if (%help_folder = $null) { set %help_folder help-files\ }
  if (%adventureis = $null) { set %adventureis off }
  if (%adventureisopen = $null) { set %adventureisopen off }

  var %last.system.dat.version $readini(system.dat, version, SystemDatVersion)
  if (%last.system.dat.version != $system.dat.version) { 
    if ($readini(system.dat, system, botType) = $null) { writeini system.dat system botType IRC }
    if ($readini(system.dat, system, AllowColors) = $null) { writeini system.dat system AllowColors true }
    if ($readini(system.dat, system, AllowBold) = $null) { writeini system.dat system AllowBold true }
    if ($readini(system.dat, system, aisystem) = $null) { writeini system.dat system aisystem on } 
    if ($readini(system.dat, system, TimeForIdle) = $null) { writeini system.dat system TimeForIdle 180 }
    if ($readini(system.dat, system, TimeToEnter) = $null) { writeini system.dat system TimeToEnter 120 }
    if ($readini(system.dat, system, MaxNumberOfMonsInBattle) = $null) { writeini system.dat system MaxNumberOfMonsInBattle 10 }
    if ($readini(system.dat, system, TwitchDelayTime) = $null) { writeini system.dat system TwitchDelayTime 2 }
    if ($readini(system.dat, system, ShowDeleteEcho) = $null) { writeini system.dat system ShowDeleteEcho false }
    if ($readini(system.dat, system, currency) = $null) { writeini system.dat system currency Gil }
    if ($readini(system.dat, system, RPGMode) = $null) { writeini system.dat system RPGMode false }
    if ($readini(system.dat, system, GenkaiQuest) = $null) { writeini system.dat system GenkaiQuest true }
    if ($readini(system.dat, system, PlayerLevelCap) = $null) { writeini system.dat system PlayerLevelCap 60 }

    ; Certain battle/adventure settings
    if ($readini(adventure.dat, AdventureStats, TotalAdventures) = $null) { writeini adventure.dat TotalAdventures 0 }
    if ($readini(adventure.dat, AdventureStats, TotalAdventuresCleared) = $null) { writeini adventure.dat TotalAdventuresCleared 0 }
    if ($readini(adventure.dat, AdventureStats, TotalAdventuresFailed) = $null) { writeini adventure.dat TotalAdventuresFailed 0 }

    if ($readini(adventure.dat, BattleStats, TotalBattles) = $null) { writeini adventure.dat TotalBattles 0 }
    if ($readini(adventure.dat, BattleStats, BattlesWon) = $null) { writeini adventure.dat BattlesWon 0 }
    if ($readini(adventure.dat, BattleStats, BattlesLost) = $null) { writeini adventure.dat BattlesLost 0 }

    writeini system.dat version SystemDatVersion $system.dat.version
  }

  ; Check to see if all the remotes are loaded (except setup.mrc as that causes an infinite loop)
  /.load -rs admin.mrc
  /.load -rs characters.mrc 
  /.load -rs adventurecontrol.mrc
  /.load -rs battlecontrol.mrc
  /.load -rs attacks.mrc
  /.load -rs abilities.mrc 
  /.load -rs spells.mrc
  /.load -rs ai.mrc
  /.load -rs achivements.mrc
  /.load -rs help.mrc

  ; these files will eventually be loaded when they're finished
  ;  /.load -rs items.mrc
  ;  /.load -rs shop.mrc

  ; Check to see if the aliases are loaded (except this one as it'd cause a loop)
  /.load -a characters.als
  /.load -a adventure.als
  /.load -a battle.als
  /.load -a battleformulas.als

  ; Remove files that are no longer needed.

  ; Remove settings no longer needed

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns a translation message
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
translate { return $readini(translation.dat, translation, $1) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns a system setting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return.systemsetting {
  var %system.setting.temp $readini(system.dat, system, $1) 
  if (%system.setting.temp = $null) { return null }
  else { return %system.setting.temp }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rolls the dice
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
roll {
  ; $1 should be #d#(+#)
  var %diceroll $dll(dicelib.dll,roll,$strip($1))
  if (%diceroll = $null) { return 0 }
  else { return %diceroll }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Identifies to nickserv
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
identifytonickserv {
  var %bot.pass $readini(system.dat, botinfo, botpass)
  if (%bot.pass != $null) { /.msg nickserv identify %bot.pass }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copies an ini 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
copyini {
  ; $1 = person
  ; $2 = name of the ini section we're copying
  ; $3 = the new name of the ini section we're copying to
  ; For example: $copyini(Iyouboushi, BaseStats, Stats-WAR)

  var %number.of.ini.items $ini($char($1), $2, 0) | var %current.ini.item.num 1
  while (%current.ini.item.num <= %number.of.ini.items) { 

    ; get ini item
    var %current.ini.item $ini($char($1), $2, %current.ini.item.num)
    var %current.ini.value $readini($char($1), np, $2, %current.ini.item)

    ; Copy the ini item
    writeini $char($1) $3 %current.ini.item %current.ini.value

    inc %current.ini.item.num
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays some messages
; for people who are logging 
; in
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
system.intromessage {
  var %player.loginpoints $readini($char($1), stuff, loginpoints)
  if (%player.loginpoints = $null) { var %player.loginpoints 0 }

  var %player.money $currency.amount($1, money)
  if (%player.money = $null) { var %player.money 0 }

  $display.private.message(2Welcome back4 $get_chr_name($1) $+ . 2The current local bot time is4 $asctime(hh:nn tt) 2on4  $asctime(mmm dd yyyy) 2and this is bot version5 $game.version )
  $display.private.message(2You currently have:7 $bytes(%player.money,b) 2 $+ $readini(system.dat, system, currency) $+ $chr(44) 7 $+ $bytes($currency.amount($1, CraftingPoints),b) 2Crafting Points $+ $chr(44) 7 $+ $bytes($currency.amount($1, GuildPoints),b) 2Guild Points $+ $chr(44) and 7 $+ $bytes($currency.amount($1, LoginPoints),b) 2Login Points)  

  if ($isfile($txtfile(motd.txt)) = $true) { $display.private.message(4Current Admin Message2: $read($txtfile(motd.txt))) }
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns a percent of the #
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_percentofvalue {
  ; $1 = the original value
  ; $2 = the %

  var %percent $round($calc($2 / 100),2)
  return $round($calc($1 * %percent),0)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the difference of 2 #s
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return_differenceof {  return $calc($1 - $2) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cleans the main bot folder.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clean_mainfolder { 
  if ($2 = $null) {  .remove $1 }
  if ($2 != $null) { 
    set %clean.file $nopath($1-) 
    .remove %clean.file
    unset %clean.file
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Writes Hostname to file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writehost {
  if ($isfile($char($nick)) = $true) { 
    if ($2 != $null) { writeini $char($1) info lastIP $2 }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns a color for equipment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
equipment.color {
  var %equipment.color 3
  if (+1 isin $1) { var %equipment.color 12 }
  if (+2 isin $1) { var %equipment.color 6 }
  if ((($readini($dbfile(weapons.db), $1, legendary) = true) || ($readini($dbfile(items.db), $1, legendary) = true) || ($readini($dbfile(equipment.db), $1, legendary) = true))) { var %equipment.color 7 }
  return %equipment.color
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if someone
; has entered the max # of
; controlled chars into battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
access.enter.limit.check {
  ; $1 = the person we're checking
  var %controlled.chars.entered $readini($txtfile(battle2.txt), BattleInfo, Entered. $+ $1)

  if (%controlled.chars.entered = $null) { var %controlled.chars.entered 0 }
  inc %controlled.chars.entered 1

  if (%controlled.chars.entered > 2) { $display.message($translate(MaxAccessEnteredAdventure), private) | halt }

  writeini $txtfile(battle2.txt) BattleInfo Entered. $+ $1 %controlled.chars.entered
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A timer runs this every 5
; minutes. This will restart 
; the bot if it stalls.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
system.autobattle.timercheck {
  if (%adventureisopen = on) { return }
  if (%adventureis = on) { return }
  if ($readini(system.dat, system, automatedbattlesystem) = off) { return }

  var %battlestart.timer.secs $timer(battlestart).secs
  if (%battlestart.timer.secs = $null) { $clear_adventure }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for illegal 
; characters/commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkscript {
  var %command $1-
  %command = $remove(%command,$set_chr_name)
  %command = $remove(%command,$chr(36) $+ 1, $chr(36) $+ 2, $chr(36) $+ 3, $chr(36) $+ 4, $chr(36) $+ 5)
  %command = $remove(%command,$chr(36) $+ set_chr_name())
  %command = $remove(%command,$chr(36) $+ $chr(43))
  %command = $replacex(%command,$chr(36) $+ gender(),OK)
  %command = $replacex(%command,$chr(36) $+ gender2(),OK)
  %command = $replacex(%command,$chr(36) $+ gender3(),OK)
  if ($chr(47) $+ set isin %command) {  $display.private.message($translate(NoScriptsWithCommands)) | halt }
  if (| isin %command) {  $display.private.message($translate(NoScriptsWithCommands)) | halt }
  if (/ isin %command) {  $display.private.message($translate(NoScriptsWithCommands)) | halt }
  if (($chr(36) $+ readini isin %command) || ($chr(36) $+ decode isin $1-)) {  $display.private.message($translate(NoScriptsWithCommands)) | halt }
  if (writeini isin %command) {  $display.private.message($translate(NoScriptsWithCommands)) | halt }
  if (encode isin %command) {  $display.private.message($translate(NoScriptsWithCommands)) | halt }
  if (decode isin %command) {  $display.private.message($translate(NoScriptsWithCommands)) | halt }
  if ($chr(36) isin %command) {  $display.private.message($translate(NoScriptsWithCommands)) | halt }
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if a char
; exists
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkchar {
  var %check $readini($char($1), Battle, HP)
  if (%check = $null) { $display.message($translate(NotInDataBank, $1), private) | halt }
  else { return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks to see if the char
; has control over the second char
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
controlcommand.check {
  var %player.access.list $readini($char($2), access, list)
  if (%player.access.list = $null) { writeini $char($2) access list $2 | var %player.access.list $2 }
  if ($istok(%player.access.list,$1,46) = $false) { $display.message($translate(DoNotHaveAccessToThatChar), private) | halt }

  if ($readini($char($2), info, clone) = yes) {
    var %clone.owner $readini($char($2), info, cloneowner)
    var %style.equipped $readini($char(%clone.owner), styles, equipped)
    if (%style.equipped != doppelganger) { $set_chr_name(%clone.owner) | $display.message($translate(MustUseDoppelgangerStyleToControl), private) | halt }
  }

  if ($readini($char($2), info, summon) = yes) {
    var %owner $readini($char($2), info, owner)
    var %style.equipped $readini($char(%owner), styles, equipped)
    if (%style.equipped != beastmaster) {  $set_chr_name(%owner) | $display.message($translate(MustUseBeastmasterStyleToControl), private) | halt }
  }

  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Password aliases
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
password { set %password $readini($char($1), n, Info, Password) }
passhurt { set %passhurt $readini($char($1), Info, Passhurt) | return }
clr_passhurt { writeini $char($1) Info Passhurt 0 | unset %passhurt | return }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Replaces a list that has , with ,
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clean.list {
  ; replace . with ,
  return $replace($1, $chr(046), $chr(044) $chr(032))
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the char's user level
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
userlevel { set %userlevel $readini($char($1), Info, user) | return }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns enemy's name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
enemy { return %enemy }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the name of the main
; currency (gil)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
currency {
  var %currency $readini(system.dat, system, currency)
  if (%currency = $null) { return Gil }
  else { return %currency }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the combined total
; of all player's death counts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
total.player.deaths {
  var %player.deaths 0 

  var %value 1
  while ($findfile( $char_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($char_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if ((%name = new_chr) || (%name = $null)) { inc %value 1 } 
    if (($readini($char(%name), info, flag) = npc) || ($readini($char(%name), info, flag) = monster)) { inc %value 1 }
    else { 
      var %temp.playerdeaths $readini($char(%name), Stuff, TotalDeaths)
      if (%temp.playerdeaths = $null) { var %temp.playerdeaths 0 }

      inc %player.deaths %temp.playerdeaths
      inc %value 1
    }
  }

  unset %file | unset %name
  return %player.deaths
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the total number
; of battles that players
; have participated in.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
total.player.battles {
  var %player.totalbattles 0 

  var %value 1
  while ($findfile( $char_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($char_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if ((%name = new_chr) || (%name = $null)) { inc %value 1 } 
    if (($readini($char(%name), info, flag) = npc) || ($readini($char(%name), info, flag) = monster)) { inc %value 1 }
    else { 
      var %temp.playershop $readini($char(%name), Stuff, TotalBattles)
      inc %player.totalbattles %temp.playershop
      inc %value 1
    }
  }

  unset %file | unset %name
  return %player.totalbattles
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the total average
; player levels
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
total.player.averagelevel {
  var %player.totallevels 0

  var %value 1 | var %total.players 0
  while ($findfile( $char_path , *.char, %value , 0) != $null) {
    set %file $nopath($findfile($char_path ,*.char,%value)) 
    set %name $remove(%file,.char)

    if ((%name = new_chr) || (%name = $null)) { inc %value 1 } 
    if (($readini($char(%name), info, flag) = npc) || ($readini($char(%name), info, flag) = monster)) { inc %value 1 }
    else { 
      var %temp.playerlevel $get.level(%name)
      inc %player.totallevels %temp.playerlevel 
      inc %total.players 1
      inc %value 1
    }
  }
  unset %file | unset %name
  return $round($calc(%player.totallevels / %total.players),0)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns true/false if 
; the bot is allowing colors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
allowcolors {
  if ($readini(system.dat, system, AllowColors) = false) { return false }
  return true
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns true/false if 
; the bot is allowing bold
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
allowbold {
  if ($readini(system.dat, system, AllowBold) = false) { return false }
  return true
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aliases that display
; messages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display.message {
  ; $1 = the message
  ; $2 = is a flag for the DCCchat option to determine where it sends the message

  var %message.to.display $1
  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }
  if ($allowbold = false) { var %message.to.display $strip(%message.to.display, b) }

  if ($readini(system.dat, system, botType) = IRC) {  query %battlechan %message.to.display  }
  if ($readini(system.dat, system, botType) = TWITCH) {
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    /.timerThrottleDisplayMessage $+ $2 $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,1000) -d 1 %twitch.delay /query %battlechan %message.to.display 
  }
  if ($readini(system.dat, system, botType) = DCCchat) { 
    if ((%battle.type = ai) && ($2 = battle)) { $dcc.global.message(%message.to.display) | return } 

    if ($2 = private) { $dcc.private.message($nick, %message.to.display) }
    if ($2 = battle) { $dcc.battle.message(%message.to.display) }
    if ($2 = $null) { $dcc.global.message(%message.to.display) }
    if ($2 = global) { $dcc.global.message(%message.to.display) }
  }
}
display.message.delay {
  ; $1 = the message
  ; $2 = is a flag for the DCCchat option to determine where it sends the message
  ; $3 = delay

  var %message.to.display $1
  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }
  if ($allowbold = false) { var %message.to.display $strip(%message.to.display, b) }

  var %delay.time $3
  if (%delay.time = $null) { var %delay.time 1 }

  if ($readini(system.dat, system, botType) = IRC) { 
    /.timerThrottleDisplayMessage $+ $2 $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,1000) -d 1 %delay.time /query %battlechan %message.to.display
  }

  if ($readini(system.dat, system, botType) = TWITCH) { 
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    inc %delay.time %twitch.delay
    /.timerThrottleDisplayMessage $+ $2 $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,1000) -d 1 %delay.time /query %battlechan %message.to.display
  }

  if ($readini(system.dat, system, botType) = DCCchat) { 
    if ((%battle.type = ai) && ($2 = battle)) { $dcc.global.message(%message.to.display) | return } 

    if ($2 = private) { $dcc.private.message($nick, %message.to.display) }
    if ($2 = battle) { $dcc.battle.message(%message.to.display) }
    if ($2 = $null) { $dcc.global.message(%message.to.display) }
    if ($2 = global) { $dcc.global.message(%message.to.display) }
  }
}

display.private.message {
  var %message.to.display $1-

  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }
  if ($allowbold = false) { var %message.to.display $strip(%message.to.display, b) }

  if (($event == chat) || ($readini(system.dat, system, botType) = DCCchat)) $dcc.private.message($nick, %message.to.display)
  elseif ($readini(system.dat, system, botType) = IRC) {
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) -d 1 1 /.msg $nick %message.to.display
  }
  elseif ($readini(system.dat, system, botType) = TWITCH) {
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) -d 1 %twitch.delay /query %battlechan %message.to.display
  }
}
display.private.message2 {
  var %message.to.display $2-

  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }
  if ($allowbold = false) { var %message.to.display $strip(%message.to.display, b) }

  if (($event == chat) || ($readini(system.dat, system, botType) = DCCchat)) $dcc.private.message($1, %message.to.display)
  elseif ($readini(system.dat, system, botType) = IRC) {
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) -d 1 1 /.msg $1 %message.to.display 
  }
  elseif ($readini(system.dat, system, botType) = TWITCH) {
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) -d 1 %twitch.delay /query %battlechan %message.to.display
  }
}
display.private.message.delay {
  var %message.to.display $1
  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }
  if ($allowbold = false) { var %message.to.display $strip(%message.to.display, b) }

  if (($event == chat) || ($readini(system.dat, system, botType) = DCCchat)) $dcc.private.message($nick, %message.to.display)
  elseif ($readini(system.dat, system, botType) = IRC) {
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) -d 1 2 /.msg $nick %message.to.display 
  }
  elseif ($readini(system.dat, system, botType) = TWITCH) {
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    inc %twitch.delay 1 
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) -d 1 %twitch.delay /query %battlechan %message.to.display
  }
}
display.private.message.delay.custom {
  var %message.to.display $1

  if ($allowcolors = false) { var %message.to.display $strip(%message.to.display, c) }
  if ($allowbold = false) { var %message.to.display $strip(%message.to.display, b) }

  if (($event == chat) || ($readini(system.dat, system, botType) = DCCchat)) $dcc.private.message($nick, %message.to.display)
  elseif ($readini(system.dat, system, botType) = IRC) {
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) -d 1 $2 /.msg $3 %message.to.display 
  }
  elseif ($readini(system.dat, system, botType) = TWITCH) {
    var %twitch.delay $readini(system.dat, system, TwitchDelayTime)
    if (%twitch.delay = $null) { var %twitch.delay 2 }
    inc %twitch.delay $2
    /.timerDisplayPM $+ $rand(1,1000) $+ $rand(a,z) $+ $rand(1,1000) -d 1 %twitch.delay /query %battlechan %message.to.display
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the status line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
status_message_check { 
  if (%all_status = $null) { %all_status = 4 $+ $1- | return }
  else { %all_status = 4 $+ %all_status $+ $chr(0160) $+ 3 $+ $chr(124) $+ 4 $+ $chr(0160) $+ $1- | return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the skills line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
skills_message_check { 
  if (%all_skills = $null) { %all_skills = 4 $+ $1- | return }
  else { %all_skills = 4 $+ %all_skills $+ $chr(0160) $+ 3 $+ $chr(124) $+ 4 $+ $chr(0160) $+ $1- | return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; !id aliases
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
idcheck { 
  if ($readini($char($1), info, flag) != $null) { $display.private.message($translate(Can'tLogIntoThisChar)) | halt }
  if ($readini($char($1), info, banned) = yes) {  $display.private.message(4This character has been banned and cannot be used to log in.) | halt }
  $passhurt($1) | $password($1)
  if (%password = $null) { unset %passhurt | unset %password |  $display.private.message($translate(NeedToMakeACharacter)) | halt }
  if ($2 = $null) { halt }
  else { 
    var %encode.type $readini($char($1), info, PasswordType)
    if (%encode.type = $null) { var %encode.type encode }
    if (%encode.type = encode) { 
      if ($encode($2) == %password) { 
        if ($version < 6.3) { writeini $char($1) info PasswordType encode }
        else { writeini $char($1) info PasswordType hash |  writeini $char($1) info password $sha1($2) }
        $id_login($1) | unset %password | return 
      } 
      if ($encode($2) != %password)  { 
        if ((%passhurt = $null) || (%passhurt < 3)) {  $display.private.message2($1, $translate(WrongPassword2)) | inc %passhurt 1 | writeini $char($1) info passhurt %passhurt | unset %password | unset %passhurt | halt }
        else { kick %battlechan $1 $translate(TooManyWrongPass)  | unset %passhurt | unset %password | writeini $char($1) Info passhurt 0 | halt } 
      }
    }
    if (%encode.type = hash) {
      if ($sha1($2) == %password) { $id_login($1) | unset %password | return } 
      if ($sha1($2) != %password) { 
        if ((%passhurt = $null) || (%passhurt < 3)) {  $display.private.message2($1, $translate(WrongPassword2)) | inc %passhurt 1 | writeini $char($1) info passhurt %passhurt | unset %password | unset %passhurt | halt }
        else { kick %battlechan $1 $translate(TooManyWrongPass)  | unset %passhurt | unset %password | writeini $char($1) Info passhurt 0 | halt } 
      }
    }
  }
}
id_login {
  var %bot.adminss $readini(system.dat, botinfo, bot.admins)
  if ($istok(%bot.adminss,$1, 46) = $true) { 
    var %bot.admins $gettok(%bot.adminss, 1, 46)
    if ($nick = %bot.admins) { .auser 100 $nick }
    else { .auser 50 $nick }

    if ($readini(system.dat, system, botType) = DCCchat) { 
      unset %dcc.alreadyloggedin
      $dcc.check.for.double.login($1)
      if (%dcc.alreadyloggedin != true) { dcc chat $nick }
      unset %dcc.alreadyloggedin
    }
  }
  else { 
    if ($creatingcharacter($1) = true) { .auser 2 $1 }
    else { .auser 3 $1 }

    if ($readini(system.dat, system, botType) = DCCchat) { .auser 2 $1 
      unset %dcc.alreadyloggedin
      $dcc.check.for.double.login($1)
      if (%dcc.alreadyloggedin != true) { dcc chat $nick }
      unset %dcc.alreadyloggedin
    }
  }

  $loginpoints($1,add)
  writeini $char($1) Info LastSeen $fulldate
  writeini $char($1) info passhurt 0 
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Capacity Points
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
capacitypoints {
  var %capacitypoints $readini($char($1), exp, CapacityPoints)
  if (%capacitypoints = $null) { return 0 }
  else { return %capacitypoints }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Login Points
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loginpoints {
  if ($2 = add) {
    var %char.lastseen $readini($char($1), info, lastloginpoint)
    if (%char.lastseen = $null) { var %char.lastseen 0 } 

    if ($calc($ctime - %char.lastseen) >= 86400) {
      $currency.add($1, LoginPoints, 10)
      writeini $char($1) info lastloginpoint $ctime 
    }
  }


  if ($2 = check) {
    var %player.loginpoints $readini($char($1), stuff, LoginPoints)
    if (%player.loginpoints = $null) { return 0 }
    else { return %player.loginpoints }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays the Description Set
; message
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
okdesc { 
  $display.private.message2($1,$readini(translation.dat, system,OKDesc)) 
  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The fulls command brings
; everyone back to max hp
; and regular stats.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fulls {  
  if (($readini($char($1), info, NeedsFulls) = no) && ($2 != yes)) { return } 

  if ($flag($1) != monster) {  remini $char($1) info ai_type }

  ; Restore the stats
  $copyini($1, BaseStats, Battle)

  ; Restore full HP
  writeini $char($1) Battle HP $resting.hp($1)

  ; Restore full MP
  writeini $char($1) Battle MP $resting.mp($1)

  ; Restore full TP
  writeini $char($1) Battle TP $max.tp

  ; Check for things that shouldn't be null
  if ($readini($char($1), battle, status) != inactive) {  writeini $char($1) Battle Status alive }
  if ($readini($char($1), status, FoodEffect) = $null) { writeini $char($1) Status FoodEffect none }

  ; If an adventure is over, let's write that we're not in battle any more
  if (%adventureis != on) { writeini $char($1) Battle InBattle false }

  ; Clear status
  ; $clear_status($1)

  ; Clear ability cooldowns
  remini $char($1) cooldowns 

  ; Remove the Renkei value
  remini $char($1) Renkei

  ; Check on, and fill Natural Armor
  $fullNaturalArmor($1)

  ; We're all done here
  writeini $char($1) info NeedsFulls no
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if a char is
; older than 6 mo and erase it
; if so. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
oldchar.check {
  if ($istok(%bot.adminss,$1,46) = $true) { return }

  var %lastseen.date $readini($char($1), info, LastSeen)
  if (%lastseen.date = $null) { writeini $char($1) info LastSeen $fulldate | return }
  if (%lastseen.date = N/A) { var %lastseen.date $readini($char($1), info, Created) | writeini $char($1) info LastSeen %lastseen.date }

  var %lastseen.ctime $ctime(%lastseen.date)
  var %ctime.calc.sixmonths 15901200
  var %current.ctime $calc( $ctime($fulldate) - %lastseen.ctime)

  if (%current.ctime > %ctime.calc.sixmonths) { 
    ; It's been greater than six months.  Zap the char.
    echo -a 4 $+ $1 is older than 6 months and is being removed..
    $zap_char($1)
  }

  else { $fulls($1, clearSotH) }

  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns true if a char has
; logged in in the last week
; false if not
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
char.seeninaweek {
  if ($readini($char($1), info, summon) = yes) { return }
  var %lastseen.date $readini($char($1), info, LastSeen)
  if (%lastseen.date = $null) { writeini $char($1) info LastSeen $fulldate | return true }
  if (%lastseen.date = N/A) { var %lastseen.date $readini($char($1), info, Created) | writeini $char($1) info LastSeen %lastseen.date }

  var %lastseen.ctime $ctime(%lastseen.date)
  var %ctime.calc.week 604800
  var %current.ctime $calc( $ctime($fulldate) - %lastseen.ctime)

  if (%current.ctime > %ctime.calc.week) { return false }
  else { return true }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Battle HP list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
build_battlehp_list {
  var %battletxt.lines $lines($txtfile(battle.txt)) | var %battletxt.current.line 1 
  while (%battletxt.current.line <= %battletxt.lines) { 
    set %who.battle $read -l $+ %battletxt.current.line $txtfile(battle.txt)
    if ($readini($char(%who.battle), info, flag) = monster) { inc %battletxt.current.line }
    else { 
      $set_chr_name(%who.battle) | $hp_status_hpcommand(%who.battle) 
      var %hp.to.add  3 $+ $chr(91) $+  $+ %who.battle $+ :  %hstats $+ 3 $+ $chr(93) 
      %battle.hp.list = $addtok(%battle.hp.list,%hp.to.add,46) 
      inc %battletxt.current.line
    }
  }

  if ($chr(046) isin %battle.hp.list) { 
    %battle.hp.list = $replace(%battle.hp.list, $chr(046), $chr(032))
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the jobs list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
jobs.list {
  set %job.name $remove($2,.job)
  set %job.name $nopath(%job.name)

  var %player.job.level $readini($char($1), jobs, %job.name)
  if (%player.job.level = $null) { writeini $char($1) jobs %job.name 1 }

  %jobs.list = $addtok(%jobs.list,  $+ %job.name $+  $+ $chr(040) $+ %player.job.level $+ $chr(041), 46) 

  unset %job.name 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the equipped weapon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
weapon_equipped { 
  set %weapon.equipped $readini($char($1), Equipment, Weapon)
  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the weapons list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
weapons.list {
  unset %weapons.list* | unset %token.count.weapons

  var %number.of.ini.items $ini($char($1), inventory, 0)
  var %current.ini.item.num 1 | var %replacechar $chr(044) $chr(032)

  while (%current.ini.item.num <= %number.of.ini.items) { 

    ; get item name
    var %current.ini.item $ini($char($1), inventory, %current.ini.item.num)
    var %current.ini.value $readini($char($1), np, inventory, %current.ini.item)
    var %item.type $readini($dbfile(weapons.db), %current.ini.item, Type)

    if (%item.type = $2) {
      inc %token.count.weapons 1

      var %weapons.name %current.ini.item
      var %player.amount $inventory.amount($1, %current.ini.item)
      var %weapons.color $rarity.color.check(%weapons.name, weapon)

      ; If the player's level is too low for this accessory, the color is maroon
      if ($get.level($1) < $readini($dbfile(weapons.db), %current.ini.item, PlayerLevel)) { var %weapons.color 5 }

      ; If the player's job can't use this accessory, the color is bright red
      var %jobs.list $readini($dbfile(weapons.db), %current.ini.item, jobs)
      if (($istok(%jobs.list, $current.job($1), 46) = $false) && (%jobs.list != all))  { var %weapons.color 4 }

      ; Is the player wearing this weapons? If so we'll add a (w) to the name.
      if ($readini($char($1), equipment, Weapon) = %current.ini.item) { var %wearing.weapons (w) }

      ; Build the name
      var %weapons.name  $+ %weapons.color $+ %weapons.name %wearing.weapons $iif(%current.ini.item != fists, 3x $+ %player.amount) $+ 

      if (%token.count.weapons <= 20) { 
        %weapons.list = $addtok(%weapons.list, %weapons.name,46) 
        %weapons.list = $replace(%weapons.list , $chr(046), %replacechar)
      }

      if ((%token.count.weapons > 20) && ( %token.count.weapons <= 40)) { 
        %weapons.list2 = $addtok(%weapons.list2, %weapons.name,46) 
        %weapons.list2 = $replace(%weapons.list2 , $chr(046), %replacechar)
      }

      if ((%token.count.weapons > 40) && ( %token.count.weapons <= 60)) { 
        %weapons.list3 = $addtok(%weapons.list3, %weapons.name,46) 
        %weapons.list3 = $replace(%weapons.list3 , $chr(046), %replacechar)
      }

      if ((%token.count.weapons > 60) && ( %token.count.weapons <= 80)) { 
        %weapons.list4 = $addtok(%weapons.list4, %weapons.name,46) 
        %weapons.list4 = $replace(%weapons.list4 , $chr(046), %replacechar)
      }

      if ((%token.count.weapons > 80) && ( %token.count.weapons <= 100)) { 
        %weapons.list5 = $addtok(%weapons.list5, %weapons.name,46) 
        %weapons.list5 = $replace(%weapons.list5 , $chr(046), %replacechar)
      }

      if ((%token.count.weapons > 100) && ( %token.count.weapons <= 120)) { 
        %weapons.list6 = $addtok(%weapons.list6, %weapons.name,46) 
        %weapons.list6 = $replace(%weapons.list6 , $chr(046), %replacechar)
      }


    }
    inc %current.ini.item.num 1
  }

  unset %token.count.weapons
}



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the NPC Trusts list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
trusts.list {
  unset %trust.items.list
  set %trust.items.list $trusts.get.list($1)

  if ($1 = return) { return %trust.items.list }

  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %trust.items.list = $replace(%trust.items.list, $chr(046), %replacechar)

  unset %value | unset %replacechar

  return
}
trusts.get.list {
  ; CHECKING TRUST ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_trust.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_trust.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) {  %trust.items.list = $addtok(%trust.items.list, 6 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46)  }

    unset %item.name | unset %item_amount
    inc %value 1 
  }
  unset %item.name | unset %item_amount

  return %trust.items.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Ingredients list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ingredients.list {
  unset %ingredients.items.list
  set %ingredients.items.list $ingredients.get.list($1)

  if ($1 = return) { return %ingredients.items.list }

  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %ingredients.items.list = $replace(%ingredients.items.list, $chr(046), %replacechar)

  unset %value | unset %replacechar

  return
}
ingredients.get.list {
  ; CHECKING POTION INGREDIENT ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_potioningredient.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_potioningredient.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) {  %ingredients.items.list = $addtok(%ingredients.items.list, 5 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46)  }

    unset %item.name | unset %item_amount
    inc %value 1 
  }
  unset %item.name | unset %item_amount

  return %ingredients.items.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Songs list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
songs.list {
  unset %songs.list
  set %songs.list $songs.get.list($1)

  if ($1 = return) { return %songs.list }

  ; CLEAN UP THE LIST
  set %replacechar $chr(044) $chr(032)
  %songs.list = $replace(%songs.list, $chr(046), %replacechar)

  unset %value | unset %replacechar

  return
}
songs.get.list { 
  unset %songs.list | unset %songs.list2 | unset %songs | unset %number.of.songs

  var %value 1 | var %items.lines $lines($lstfile(songs.lst))
  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(songs.lst)
    set %item_amount $readini($char($1), songs, %item.name)

    if ((%item_amount = 0) && ($readini($char($1), info, flag) = $null)) { remini $char($1) songs %item.name }
    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      %songs.list = $addtok(%songs.list, %item.name, 46) 
    }

    unset %item.name | unset %item_amount
    inc %value 1 
  }
  return %songs.list
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Items list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
items.list {
  unset %*.items.lis* | unset %items.lis*

  ; CHECKING HEALING ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_healing.lst))

  while (%value <= %items.lines) {
    var %item.name $read -l $+ %value $lstfile(items_healing.lst)
    var %item_amount $inventory.amount($1, %item.name) 

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
      if ($numtok(%items.list,46) <= 20) { %items.list = $addtok(%items.list, 3 $+ %item.name 3x $+ %item_amount, 46) }
      else { %items.list2 = $addtok(%items.list2, 3 $+ %item.name 3x $+ %item_amount, 46) }
    }
    unset %item.name | unset %item_amount
    inc %value 1 
  }

  ; CHECKING CRYSTALS
  var %value 1 | var %items.lines $lines($lstfile(items_crystals.lst))

  while (%value <= %items.lines) {
    var %item.name $read -l $+ %value $lstfile(items_crystals.lst)
    var %item_amount $inventory.amount($1, %item.name) 

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
    %crystal.items.list = $addtok(%crystal.items.list, 12 $+ %item.name 3x $+ %item_amount, 46) }

    unset %item.name | unset %item_amount
    inc %value 1 
  }

  ; Check for misc items
  $miscitems.list($1)

  ; CLEAN UP THE LISTS
  var %replacechar $chr(044) $chr(032)
  %items.list = $replace(%items.list, $chr(046), %replacechar)
  %items.list2 = $replace(%items.list2, $chr(046), %replacechar)
  %crystal.items.list = $replace(%crystal.items.list, $chr(046), %replacechar)

  unset %item.name | unset %item_amount | unset %number.of.items | unset %value | unset %food.items | unset %consume.items
  unset %replacechar
  return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Instrument list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instruments.list {
  ; CHECKING INSTRUMENT ITEMS
  var %value 1 | var %items.lines $lines($lstfile(items_instruments.lst))

  while (%value <= %items.lines) {
    set %item.name $read -l $+ %value $lstfile(items_instruments.lst)
    set %item_amount $readini($char($1), item_amount, %item.name)
    if (%item_amount <= 0) { remini $char($1) item_amount %item.name }

    if ((%item_amount != $null) && (%item_amount >= 1)) { 
    %instruments.items.list = $addtok(%instruments.items.list, 6 $+ %item.name $+ $chr(040) $+ %item_amount $+ $chr(041), 46) }

    unset %item.name | unset %item_amount
    inc %value 1 
  }

  if (%instruments.items.list != $null) {
    set %replacechar $chr(044) $chr(032)
    %instruments.items.list = $replace(%instruments.items.list, $chr(046), %replacechar)
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds the Armor list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
armor.list {
  unset %armor.list* | unset %token.count.armor

  var %number.of.ini.items $ini($char($1), inventory, 0)
  var %current.ini.item.num 1 | var %replacechar $chr(044) $chr(032)

  while (%current.ini.item.num <= %number.of.ini.items) { 

    ; get item name
    var %current.ini.item $ini($char($1), inventory, %current.ini.item.num)
    var %current.ini.value $readini($char($1), np, inventory, %current.ini.item)
    var %item.type $readini($dbfile(equipment.db), %current.ini.item, EquipLocation)

    if (%item.type = $2) {
      inc %token.count.armor 1

      var %armor.name %current.ini.item
      var %player.amount $inventory.amount($1, %current.ini.item)
      var %armor.color $rarity.color.check(%armor.name, armor)
      unset %wearing.armor

      ; If the player's level is too low for this accessory, the color is maroon
      if ($get.level($1) < $readini($dbfile(equipment.db), %current.ini.item, PlayerLevel)) { var %armor.color 5 }

      ; If the player's job can't use this armor, the color is bright red
      var %jobs.list $readini($dbfile(equipment.db), %current.ini.item, jobs)
      if (($istok(%jobs.list, $current.job($1), 46) = $false) && (%jobs.list != all))  { var %armor.color 4 }

      ; Is the player wearing this armor? If so we'll add a (w) to the name.
      if ($return.equipped($1, %item.type) = %armor.name) {  var %wearing.armor (w) }

      ; Build the name
      var %armor.name  $+ %armor.color $+ %armor.name  $+ %wearing.armor 3x $+ %player.amount

      if (%token.count.armor <= 20) { 
        %armor.list = $addtok(%armor.list, %armor.name,46) 
        %armor.list = $replace(%armor.list , $chr(046), %replacechar)
      }

      if ((%token.count.armor > 20) && ( %token.count.armor <= 40)) { 
        %armor.list2 = $addtok(%armor.list2, %armor.name,46) 
        %armor.list2 = $replace(%armor.list2 , $chr(046), %replacechar)
      }

      if ((%token.count.armor > 40) && ( %token.count.armor <= 60)) { 
        %armor.list3 = $addtok(%armor.list3, %armor.name,46) 
        %armor.list3 = $replace(%armor.list3 , $chr(046), %replacechar)
      }

      if ((%token.count.armor > 60) && ( %token.count.armor <= 80)) { 
        %armor.list4 = $addtok(%armor.list4, %armor.name,46) 
        %armor.list4 = $replace(%armor.list4 , $chr(046), %replacechar)
      }

      if ((%token.count.armor > 80) && ( %token.count.armor <= 100)) { 
        %armor.list5 = $addtok(%armor.list5, %armor.name,46) 
        %armor.list5 = $replace(%armor.list5 , $chr(046), %replacechar)
      }

      if ((%token.count.armor > 100) && ( %token.count.armor <= 120)) { 
        %armor.list6 = $addtok(%armor.list6, %armor.name,46) 
        %armor.list6 = $replace(%armor.list6 , $chr(046), %replacechar)
      }


    }
    inc %current.ini.item.num 1
  }

  unset %token.count.armor
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns a color based on
; how rare an item is.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rarity.color.check {
  if ($2 = armor) { var %dbfile equipment.db } 
  if ($2 = weapon) { var %dbfile weapons.db }
  if ($2 = item) { var %dbfile items.db }

  var %rarity $readini($dbfile(%dbfile), $1, rarity)
  if (%rarity = 2) { var %rarity.color 10 }
  if (%rarity = 3) { var %rarity.color 6 } 
  if (%rarity = 4) { var %rarity.color 13 }
  if (%rarity = 5) { var %rarity.color 7 }

  return %rarity.color
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Turns skills off on chars.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_skills {
}

clear_skill_timers {
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear Certain Skills
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_certain_skills {
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clears most statuses on
; chars. This is for the 
; clearstatus type items.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_most_status {
}

clear_negative_status {
}

clear_positive_status {
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clears statuses on chars
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_status {
  ; Negative status effects
  $clear_negative_status($1)

  ; Clear Charm, since the clear_negative_status doesn't.
  writeini $char($1) status charmer noOneThatIKnow | writeini $char($1) status charm.timer 0 | writeini $char($1) status charmed no | writeini $char($1) status boosted no 

  ; Positive status effects
  $clear_positive_status($1)

  writeini $char($1) status orbbonus no | writeini $char($1) status revive no | writeini $char($1) status FinalGetsuga no
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; These two statuses return
; the HP status (perfect,
; injured, good, etc)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hp_status { 
  set %current.hp $current.hp($1) | set %max.hp $resting.hp($1) | set %hp.percent $calc((%current.hp / %max.hp)*100) |  unset %current.hp | unset %max.hp 
  if (%hp.percent > 100) { set %hstats $translate(beyondperfect)  | return }
  if (%hp.percent = 100) { set %hstats $translate(perfect)  | return }
  if ((%hp.percent < 100) && (%hp.percent >= 90)) { set %hstats $translate(great) | return }
  if ((%hp.percent < 90) && (%hp.percent >= 80)) { set %hstats $translate(good) | return }
  if ((%hp.percent < 80) && (%hp.percent >= 70)) { set %hstats $translate(decent) | return }
  if ((%hp.percent < 70) && (%hp.percent >= 60)) { set %hstats $translate(scratched)  | return }
  if ((%hp.percent < 60) && (%hp.percent >= 50)) { set %hstats $translate(bruised) | return }
  if ((%hp.percent < 50) && (%hp.percent >= 40)) { set %hstats $translate(hurt) | return }
  if ((%hp.percent < 40) && (%hp.percent >= 30)) { set %hstats $translate(injured) | return }
  if ((%hp.percent < 30) && (%hp.percent >= 15)) { set %hstats $translate(injuredbadly) | return } 
  if ((%hp.percent < 15) && (%hp.percent > 2)) { set %hstats $translate(critical) | return }
  if ((%hp.percent <= 2) && (%hp.percent > 0)) { set %hstats $translate(AliveHairBredth) | return }
  if (%hp.percent <= 0) { set %whoturn $1 |  next | halt }
}
hp_status_hpcommand { 
  set %current.hp $current.hp($1) | set %max.hp $resting.hp($1) | set %hp.percent $calc((%current.hp / %max.hp)*100) |  unset %current.hp | unset %max.hp 
  if (%hp.percent > 100) { set %hstats $translate(beyondperfect)  | return }
  if (%hp.percent = 100) { set %hstats $translate(perfect)  | return }
  if ((%hp.percent < 100) && (%hp.percent >= 90)) { set %hstats $translate(great) | return }
  if ((%hp.percent < 90) && (%hp.percent >= 80)) { set %hstats $translate(good) | return }
  if ((%hp.percent < 80) && (%hp.percent >= 70)) { set %hstats $translate(decent) | return }
  if ((%hp.percent < 70) && (%hp.percent >= 60)) { set %hstats $translate(scratched)  | return }
  if ((%hp.percent < 60) && (%hp.percent >= 50)) { set %hstats $translate(bruised) | return }
  if ((%hp.percent < 50) && (%hp.percent >= 40)) { set %hstats $translate(hurt) | return }
  if ((%hp.percent < 40) && (%hp.percent >= 30)) { set %hstats $translate(injured) | return }
  if ((%hp.percent < 30) && (%hp.percent >= 15)) { set %hstats $translate(injuredbadly) | return } 
  if ((%hp.percent < 15) && (%hp.percent > 2)) { set %hstats $translate(critical) | return }
  if ((%hp.percent <= 2) && (%hp.percent > 0)) { set %hstats $translate(AliveHairBredth) | return }
  if (%hp.percent <= 0) { set %hstats $translate(Dead)  | return }
}
hp_mech_hpcommand { 
  set %current.hp $readini($char($1), Mech, HpCurrent) | set %max.hp $readini($char($1), Mech, HpMax) | set %hp.percent $calc((%current.hp / %max.hp)*100) |  unset %current.hp | unset %max.hp 
  if (%hp.percent >= 100) { set %hstats $translate(perfect)  | return }
  if ((%hp.percent < 100) && (%hp.percent >= 90)) { set %hstats $translate(great) | return }
  if ((%hp.percent < 90) && (%hp.percent >= 80)) { set %hstats $translate(good) | return }
  if ((%hp.percent < 80) && (%hp.percent >= 70)) { set %hstats $translate(decent) | return }
  if ((%hp.percent < 70) && (%hp.percent >= 60)) { set %hstats $translate(scratched)  | return }
  if ((%hp.percent < 60) && (%hp.percent >= 50)) { set %hstats $translate(smoking) | return }
  if ((%hp.percent < 50) && (%hp.percent >= 40)) { set %hstats $translate(sparking) | return }
  if ((%hp.percent < 40) && (%hp.percent >= 30)) { set %hstats $translate(shortingout) | return }
  if ((%hp.percent < 30) && (%hp.percent > 10)) { set %hstats $translate(critical) | return }
  if ((%hp.percent <= 10) && (%hp.percent > 0)) { set %hstats $translate(malfunctioning) | return }
  if (%hp.percent <= 0) { set %hstats $translate(Disabled)  | return }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functions to restore HP
; and MP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $1 = person being restored
; $2 = amount
restore_hp {
  var %max.hp $readini($char($1), basestats, hp)
  var %current.hp $readini($char($1), battle, hp)
  inc %current.hp $2

  writeini $char($1) battle hp %current.hp 
}

restore_mp {
  var %max.mp $readini($char($1), basestats, tp)
  var %current.mp $readini($char($1), battle, tp)
  inc %current.mp $2
  writeini $char($1) battle tp %current.tp 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; These two functions clear
; variables.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_variables { 
  unset %adventure.* | unset %*.turn
  unset %name | unset %found.monster | unset %multiple.monster.counter
  unset %battle.* |  unset %monsters.* | unset %curbat
  unset %line | unset %next.person | unset %who | unset %whoturn | unset %temp.battle.list | unset %file.to.read.lines
  unset %current.room | unset %file | unset %total.targets | unset %random.target | unset %damage.display.color
  unset %true.turn | unset %adventureisopen
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Zap (erase) a character
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zap_char {
  set %new.name $1 $+ _ $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,100) $+ $rand(a,z)
  .rename $char($1) $zapped(%new.name)

  if ($return.systemsetting(ShowDeleteEcho) = true) { echo -a -=- DELETING $1 :: Reason: Zapped }

  .remove $char($1)
  unset %new.name
  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UnZap (restore) a character
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
unzap_char {
  set %new.name $gettok($1,1,95)
  .rename $zapped($1) $char(%new.name)
  .remove $zapped($1)
  writeini $char(%new.name) info lastseen $fulldate
  $set_chr_name(%new.name) 
  unset %new.name
  return 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for an augment
; and returns true/false
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
augment.check {
  ; 1 = user
  ; 2 = augment name

  if ($1 = battlefield) { return }

  if ($person_in_mech($1) = false) {

    set %weapon.name.temp $readini($char($1), weapons, equipped)
    var %weapon.name.left.temp $readini($char($1), weapons, equippedLeft)
    set %ignition.augment $readini($char($1), status, ignition.augment) 
    set %weapon.augment $readini($char($1), augments, %weapon.name.temp)
    var %weapon.augment.left $readini($char($1), augments, %weapon.name.left.temp)

    if (%weapon.augment = $null) {  set %weapon.augment $readini($char($1), augments, %weapon.name.temp) }

    set %equipment.head.augment $readini($dbfile(equipment.db), $readini($char($1), equipment, head), augment)
    set %equipment.body.augment $readini($dbfile(equipment.db), $readini($char($1), equipment, body), augment)
    set %equipment.legs.augment $readini($dbfile(equipment.db), $readini($char($1), equipment, legs), augment)
    set %equipment.feet.augment $readini($dbfile(equipment.db), $readini($char($1), equipment, feet), augment)
    set %equipment.hands.augment $readini($dbfile(equipment.db), $readini($char($1), equipment, hands), augment)

    unset %weapon.name.temp
    set %augment.strength 0

    if ($istok(%ignition.augment,$2,46) = $true) {  inc %augment.strength 1 | set %augment.found true }
    if ($istok(%weapon.augment,$2,46) = $true) {  inc %augment.strength 1 | set %augment.found true }
    if ($istok(%weapon.augment.left,$2,46) = $true) {  inc %augment.strength 1 | set %augment.found true }
    if ($istok(%equipment.head.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok(%equipment.body.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok(%equipment.legs.augment,$2,46) = $true) {  inc %augment.strength 1 | set %augment.found true }
    if ($istok(%equipment.feet.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok(%equipment.hands.augment,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }

    ; check the name of the armor in the character file too. This is mostly used for NPCs and not players, as players can't augment armor
    if ($istok($readini($char($1), augments, $readini($char($1), equipment, head)),$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok($readini($char($1), augments, $readini($char($1), equipment, body)),$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok($readini($char($1), augments, $readini($char($1), equipment, legs)),$2,46) = $true) {  inc %augment.strength 1 | set %augment.found true }
    if ($istok($readini($char($1), augments, $readini($char($1), equipment, feet)),$2,46) = $true) {  inc %augment.strength 1 | set %augment.found true }
    if ($istok($readini($char($1), augments, $readini($char($1), equipment, hands)),$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }

    ; If the character is in FinalGetsuga mode, increase the augment strength by 5
    if (($readini($char($1), status, FinalGetsuga) = yes) && ($readini($char($1), info, flag) = $null)) { inc %augment.strength 5 | set %augment.found true }
  }

  var %style.equipped $readini($char($1), styles, equipped)
  if ($istok($readini($dbfile(playerstyles.db), augments, %style.equipped),$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }

  if ($person_in_mech($1) = true) {
    set %augment.strength 0
    set %augments $readini($char($1), mech, augments)
    if ($istok(%augments,$2,46) = $true) { inc %augment.strength 2 | set %augment.found true }
    unset %augments

    ; check the file itself for the mech weapon/core name in the character's [augments]  Mostly used for NPCs
    var %mech.weapon.equipped $readini($char($1), mech, EquippedWeapon) 
    var %mech.core.equipped $readini($char($1), mech, EquippedCore)

    var %mech.weapon.augments $readini($char($1), augments, %mech.weapon.equipped)
    var %mech.core.augments $readini($char($1), augments, %mech.core.equipped)
    if ($istok(%mech.weapon.augments,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
    if ($istok(%mech.core.augments,$2,46) = $true) { inc %augment.strength 1 | set %augment.found true }
  }


  if ($readini(adventure.dat, dragonballs, ShenronWish) = on) { 
    if ($readinI($char($1), info, flag) = $null) { inc %augment.strength 2 | set %augment.found true }
  }

  if ($return.potioneffect($1) = Augment Bonus) { 
    inc %augment.strength 1 | set %augment.found true
  }

  unset %weapon.augment  | unset %ignition.augment | unset %equipment.head.augment | unset %equipment.body.augment
  unset %equipment.legs.augment | unset %equipment.feet.augment | unset %equipment.hands.augment

  if (%augment.found != true) { return false }
  if (%augment.found = true) { unset %augment.found | return true }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for an accessory
; and returns true/false
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
accessory.check {
  ; 1 = user or target
  ; 2 = accessory type

  if ($person_in_mech($1) = true) { return } 

  unset %amount

  set %accessory.found false | set %accessory.amount 0 

  var %current.accessory $readini($char($1), equipment, accessory) 
  var %accessory.type $readini($dbfile(items.db), %current.accessory, accessoryType)

  if ($istok(%accessory.type,$2,46) = $true) {
    set %accessory.amount $readini($dbfile(items.db), %current.accessory, %accessory.type $+ .amount)

    if (%accessory.amount = $null) { set %accessory.amount 0 }
    var %accessory.found true
  }

  ; Does the player have a secondary accessory slot?  If so, let's check it.
  if ($readini($char($1), enhancements, accessory2) = true) {
    var %current.accessory2 $readini($char($1), equipment, accessory2) 
    var %accessory2.type  $readini($dbfile(items.db), %current.accessory2, accessoryType)

    if ($istok(%accessory2.type,$2,46) = $true) {
      var %accessory.amount2 $readini($dbfile(items.db), %current.accessory2, %accessory2.type $+ .amount)
      if (%accessory.amount2 = $null) { var %accessory.amount2 0 }

      inc %accessory.amount %accessory.amount2
      var %accessory.found true
    }
  }

  unset %current.accessory | unset %accessory.type 

  return %accessory.found
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Increases the monsterdeaths.lst
; death tally
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
increase.death.tally {
  if ($readini($char($1), info, flag) = monster) {

    if ($isfile($boss($1)) = $true) { 
      var %boss.deaths $readini($lstfile(monsterdeaths.lst), boss, $1) 
      if (%boss.deaths = $null) { var %boss.deaths 0 }
      inc %boss.deaths 1
      writeini $lstfile(monsterdeaths.lst) boss $1 %boss.deaths
    }
    if ($isfile($mon($1)) = $true) { 
      var %monster.deaths $readini($lstfile(monsterdeaths.lst), monster, $1) 
      if (%monster.deaths = $null) { var %monster.deaths 0 }
      inc %monster.deaths 1
      writeini $lstfile(monsterdeaths.lst) monster $1 %monster.deaths
    }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Increases monster kills
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inc_monster_kills {
  var %monster.kills $readini($char($1), stuff, MonsterKills)
  if (%monster.kills = $null) { var %monster.kills 0 }
  inc %monster.kills 1 
  writeini $char($1) stuff MonsterKills %monster.kills
  $achievement_check($1, MonsterSlayer)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Increases the character 
; total deaths
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
increase_death_tally {
  if ($readini($char($1), info, flag) = npc) { return }
  var %deaths $readini($char($1), stuff, TotalDeaths)
  if (%deaths = $null) { var %deaths 0 } 
  inc %deaths 1
  writeini $char($1) stuff TotalDeaths %deaths
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Checks for clone/summon
; deaths
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check.clone.death {
  if ($isfile($char($1 $+ _clone)) = $true) { 
    if ($readini($char($1 $+ _clone), battle, status) != dead) { writeini $char($1 $+ _clone) battle status dead | writeini $char($1 $+ _clone) battle hp 0 | $set_chr_name($1 $+ _clone) 
      $display.message(4 $+ %real.name disappears back into $set_chr_name($1) %real.name $+ 's shadow., battle) 
    }
  }
  if ($isfile($char($1 $+ _summon)) = $true) { 
    if ($readini($char($1 $+ _summon), battle, status) != dead) { writeini $char($1 $+ _summon) battle status dead | writeini $char($1 $+ _summon) battle hp 0 | $set_chr_name($1 $+ _summon) 
      $display.message(4 $+ %real.name fades away.,battle) 
    }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clears dead monsters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_monsters {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)
  if ((%name = new_chr) || (%name = $null)) { return } 
  else { 
    var %monster.flag $flag(%name) 
    if (%monster.flag = monster) { 
      if ($return.systemsetting(ShowDeleteEcho) = true) { echo -a -=- DELETING %name :: Reason: Dead Monster }
      .remove $char(%name) 
      unset %name
    }
    else { unset %name | return }    
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Recalculates Total Battles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
recalc_totalbattles {
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds a list of players
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
buildplayerlist {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)
  if ((%name = new_chr) || (%name = $null)) { return } 
  else { 
    if ($readini($char(%name), info, flag) != $null) { return }
    write $nick $+ _players.txt %name 
    unset %name
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Builds a list of zapped players
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
buildzappedlist {
  set %file $nopath($1-) 
  set %name $remove(%file,.char)
  if ((%name = new_chr) || (%name = $null)) { return } 
  else { 

    write $nick $+ _zapped.txt %name - $asctime($file($1-).mtime,mm/dd/yyyy - hh:mm:ss tt) 
    write zapped.html  <td> %name </td>
    write zapped.html  <td> $asctime($file($1-).mtime,mm/dd/yyyy - hh:mm:ss tt) </td>
    write zapped.html  </tr>
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Displays a list of bot admins
; or allows the owner to add
; or remove admins
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bot.admin {
  if ($1 = list) { var %bot.admins $readini(system.dat, botinfo, bot.admins) 
    if (%bot.admins = $null) { $display.message(4There are no bot admins set., private) | halt }
    else {
      set %replacechar $chr(044) $chr(032)
      %bot.admins = $replace(%bot.admins, $chr(046), %replacechar)
      unset %replacechar
      $display.message(3Bot Admins:12 %bot.admins, private) | halt 
    }
  }

  if ($1 = add) { $checkchar($2) | var %bot.admins $readini(system.dat, botinfo, bot.admins) 
    if ($istok(%bot.admins,$2,46) = $true) { $display.message(4Error: $2 is already a bot admin, private) | halt }
    %bot.admins = $addtok(%bot.admins,$2,46) | $display.message(3 $+ $2 has been added as a bot admin., private) 
    writeini system.dat botinfo bot.admins %bot.admins | halt 
  }

  if ($1 = remove) { var %bot.admins $readini(system.dat, botinfo, bot.admins) 
    if ($istok(%bot.admins,$2,46) = $false) { $display.message(4Error: $2 is not a bot admin, private) | halt }

    ; The bot admin in the first position is considered to be the "bot owner" and cannot be removed via this command.
    var %bot.admins $gettok(%bot.admins,1,46)
    if ($2 = %bot.admins) { $display.message(4Error: $2 cannot be removed from the bot admin list using this command, private) | halt }

    %bot.admins = $remtok(%bot.admins,$2,46) | $display.message(3 $+ $2 has been removed as a bot admin., private) 
    writeini system.dat botinfo bot.admins %bot.admins | halt 
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Finalize a new character
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
finalize.newchar {
  ; First up, copy the basestats to the startingstats
  $copyini($1, BaseStats, StartingStats)

  ; Turn off the creating character flag
  writeini $char($1) info CreatingCharacter false

  ; Give the person auser 3
  .auser 3 $1

  ; Is the person a bot owner/admin?  If so, give them auser 50 or 100
  var %bot.adminss $readini(system.dat, botinfo, bot.admins)
  if ($istok(%bot.adminss,$1, 46) = $true) { 
    var %bot.admins $gettok(%bot.adminss, 1, 46)
    if ($nick = %bot.admins) { .auser 100 $1 }
    else { .auser 50 $nick }
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reset Equipment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
equipment.reset {
  writeini $char($1) equipment weapon fists
  writeini $char($1) equipment head nothing
  writeini $char($1) equipment body nothing
  writeini $char($1) equipment legs nothing
  writeini $char($1) equipment feet nothing
  writeini $char($1) equipment hands nothing
  writeini $char($1) equipment ears nothing
  writeini $char($1) equipment neck nothing
  writeini $char($1) equipment wrists nothing
  writeini $char($1) equipment ring nothing
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;An/A grammar check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
an.a.grammar.check {
  ; $1 = the word we're checking

  if (A = $left($1, 1)) { return An }
  if (E = $left($1, 1)) { return An }
  if (I = $left($1, 1)) { return An }
  if (O = $left($1, 1)) { return An }
  if (U = $left($1, 1)) { return An }
  return A
}
