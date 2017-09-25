;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; startup.mrc
;;;; Last updated: 09/25/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This file controls what happens when
; the bot starts as well as what happens
; when the bot quits.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

raw 421:*:echo -a 4,1Unknown Command: ( $+ $2 $+ ) | halt
CTCP *:PING*:?:if ($nick == $me) haltdef
CTCP *:BOTVERSION*:ctcpreply $nick BOTVERSION $game.version
on 1:QUIT: { 
  if ($nick = %bot.name) { /nick %bot.name | /.timer 1 15 /identifytonickserv } 
  .auser 1 $nick | .flush 1 
} 
on 1:EXIT: { .auser 1 $nick | .flush 1 | .flush 3 | .flush 50 | .flush 100 }
on 1:PART:%battlechan:.auser 1 $nick | .flush 1
on 1:KICK:%battlechan:.auser 1 $knick | .flush 1 
on 1:JOIN:%battlechan:{ 
  .auser 1 $nick | .flush 1 

  if ($readini(system.dat, system, botType) = TWITCH) {
    if ($isfile($char($nick)) = $true) { 
      $set_chr_name($nick) | $display.message(10 $+ %real.name %custom.title  $+  $readini($char($nick), Descriptions, Char), global) 
      var %bot.owners $readini(system.dat, botinfo, bot.admins)
      if ($istok(%bot.owners,$nick,46) = $true) {  .auser 50 $nick }

      mode %battlechan +v $nick
    }
  }
}
on 3:NICK: { .auser 1 $nick | mode %battlechan -v $newnick | .flush 1 }
on *:CTCPREPLY:PING*:if ($nick == $me) haltdef
on *:DNS: { 
  if ($isfile($char($nick)) = $true) { 
    var %lastip.address $iaddress
    if (%lastip.address != $null) { writeini $char($nick) info lastIP $iaddress }
  }
  set %ip.address. [ $+ [ $nick ] ] $iaddress
}

on 1:START: {
  echo 12*** Welcome to Ardolia - a mIRC RPG version $game.version written by James "Iyouboushi" *** 

  /.titlebar Ardolia - a mIRC RPG version $game.version written by James  "Iyouboushi" 

  if (%first.run = false) { 
    set %bot.owner $readini(system.dat, botinfo, bot.admins) 
    if (%bot.owner = $null) { echo 4*** WARNING: There is no bot admin set.  Please fix this now. 
    set %bot.owner $?="Please enter the bot admin's IRC nick" |  writeini system.dat botinfo bot.admins %bot.owner | .auser 100 %bot.owner }
    else { echo 12*** The bot admin list is currently set to:4 %bot.owner 12*** 
    }

    set %battlechan $readini(system.dat, botinfo, questchan) 
    if (%battlechan = $null) { echo 4*** WARNING: There is no battle channel set.  Please fix this now. 
    set %battlechan $?="Please enter the IRC channel you're using (include the #)" |  writeini system.dat botinfo questchan %battlechan }
    else { echo 12*** The battle channel is currently set to:4 %battlechan 12*** }

    set %bot.name $readini(system.dat, botinfo, botname)
    if (%bot.name = $null) { echo 4*** WARNING: The bot's nick is not set in the system file.  Please fix this now.
    set %bot.name $?="Please enter the nick you wish the bot to use" | writeini system.dat botinfo botname %bot.name | /nick %bot.name }
    else { /nick %bot.name } 

    var %botpass $readini(system.dat, botinfo, botpass)
    if (%botpass = $null) { 
      echo 12*** Now please set the password you plan to register the bot with
      var %botpass $?="Enter a password that you will use for the bot on Nickserv"
      if (%botpass = $null) { var %bosspass none }
      writeini system.dat botinfo botpass %botpass
      echo 12*** OK.  Your password has been set to4 %botpass  -- Don't forget to register the bot with nickserv.
    }

    $system_defaults_check
  }

  if ((%first.run = true) || (%first.run = $null)) { 
    echo 12*** It seems this is the first time you've ever run the Ardolia mIRC RPG Bot!  The bot will now attempt to help you get things set up.
    echo 12*** Please set your bot's nick/name now.   Normal IRC nick rules apply (no spaces, for example) 
    set %bot.name $?="Please enter the nick you wish the bot to use"
    writeini system.dat botinfo botname %bot.name | /nick %bot.name
    echo 12*** Great.  The bot's nick is now set to4 %bot.name

    echo 12*** Please set a bot owner now.  
    set %bot.owner $?="Please enter the bot owner's IRC nick"
    writeini system.dat botinfo bot.admins %bot.owner
    echo 12*** Great.  The bot owner has been set to4 %bot.owner

    echo 12*** Now please set the IRC channel you plan to use the bot in
    set %battlechan $?="Enter an IRC channel (include the #)"
    writeini system.dat botinfo questchan %battlechan
    echo 12*** The battles will now take place in4 %battlechan

    echo 12*** Now please set the password you plan to register the bot with
    var %botpass $?="Enter a password"
    if (%botpass = $null) { var %bosspass none }
    writeini system.dat botinfo botpass %botpass
    echo 12*** OK.  Your password has been set to4 %botpass  -- Don't forget to register the bot with nickserv.

    set %first.run false
    .auser 100 %bot.owner

    $system_defaults_check

  }

  echo 12*** This bot is best used with mIRC version4 7.41 12 *** 
  echo 12*** You are currently using mIRC version4 $version 12 ***

  if ($version < 7.41) {   echo 4*** Your version is older than the recommended version for this bot. Some things may not work right.  It is recommended you update. 12 *** }
  if ($version > 7.41) {   echo 4*** Your version is newer than the recommended version for this bot. While it should work, it is currently untested and may have quirks or bugs.  It is recommended you downgrade if you run into any problems. 12 *** }

  if ($sha1($read(key)) != e79569af2409deb8c5aa6235768fea53d47fa5e5) { .remove key |  write key M`S)4:&ES(&=A;64@:7,@<G5N;FEN9R!T:&4@`D$"<F1O;&EA(`)24$<"(%-YM<W1E;2!C<F5A=&5D(&)Y(`)*`F%M97,@`DD">6]U8F]U<VAI("TM($%V86ELM86)L92!F;W(@9G)E92!A=#H@`S$R'VAT='!S.B\O9VET:'5B+F-O;2])>6]U38F]U<VAI+VU)4D,M07)D;VQI80`` }
}

on 1:CONNECT: {
  ; Start a keep alive timer.
  /.timerKeepAlive 0 300 /.ctcp $!me PING

  ; Join the channel
  /.timerJoin 1 2 join %battlechan
  /.timerCheckForExistingBattle 1 5 /control.battlecheck

  ; Get rid of a ghost, if necessary, and send password
  var %bot.pass $readini(system.dat, botinfo, botpass)
  if ($me != %bot.name) { /.msg NickServ GHOST %bot.name %bot.pass | /.timerNick 1 3 nick %bot.name }
  $identifytonickserv

  ; Recalculate how many battles have happened.
  $recalc_totalbattles

  ; Unset the key in use check.
  unset %keyinuse
}

alias control.battlecheck { 
  ; If an adventure was on when the bot turned off, let's check it and do something with it.
  if (%adventureis = on) { 
    if ($readini($txtfile(battle2.txt), BattleInfo, Monsters) = $null) { $clear_battle }
    else { $battle.list }
  }
  if (%battleis = off) { $clear_battle } 
}

on 1:DISCONNECT:{
  .timerBattleNext off
  .timerBattleBegin off
  .flush 1 | .flush 3 | .flush 50
}
