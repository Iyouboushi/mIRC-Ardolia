;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; admin.mrc
;;;; Last updated: 05/01/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

on 2:TEXT:!bot admin*:*: {  $bot.admin(list) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bot Admin Commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bot Admins have  the ability to zap/erase characters.
on 50:TEXT:@zap *:*: {  $set_chr_name($2) | $checkchar($2) | $zap_char($2) | $display.message($translate(zappedcomplete),global) | halt }
on 50:TEXT:@unzap *:*: {  
  if ($isfile($zapped($2)) = $false) { $display.private.message(4Error: $2 does not exist as a zapped file) | halt }
  $unzap_char($2) | $display.message($translate(unzappedcomplete),global) | halt
}

; Force the bot to quit
on 50:TEXT:@quit*:*:{ /quit $game.version }

; Force the bot to do a system.dat default check
on 50:TEXT:@force system default check*:*: { 
  writeini version.ver versions systemdat $replace($adate, /, ) $+ _ $+ $ctime
  $system_defaults_check
  .msg $nick 3The bot has finished with the system.dat default check.
}

; Add or remove a bot admin (note: cannot remove the person in position 1 with this command)
on 50:TEXT:@bot admin*:*: {  
  if (($3 = $null) || ($3 = list)) { $bot.admin(list) }
  if ($3 = add) { $bot.admin(add, $4) }
  if ($3 = remove) { $bot.admin(remove, $4) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clears achievements
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 50:TEXT:@clear achievement*:*:{
  $checkchar($3)
  if ($4 = $null) { $display.message(4!clear achievement <person> <achievement name>, private) | halt }

  .remini $char($3) achievements $4 
  if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) {   $display.message(4Achievement ( $+ $4  $+ ) has been cleared for $3 $+ .,global) }
  if ($readini(system.dat, system, botType) = DCCchat) { $dcc.global.message(4Achievement ( $+ $4  $+ ) has been cleared for $3 $+ .) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cleans out the main folder of .txt, .lst, and .db files.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 50:TEXT:@main folder cleanup:*:{ 
  .echo -q $findfile( $mircdir , *.lst, 0, 0, clean_mainfolder $1-) 
  .echo -q $findfile( $mircdir  , *.db, 0, 0, clean_mainfolder $1-) 
  .echo -q $findfile( $mircdir  , *.txt, 0, 0, clean_mainfolder $1-) 
  .echo -q $findfile( $mircdir , *.html, 0, 0, clean_mainfolder $1-) 
  $display.message(4.db & .lst & .txt & .html files have been cleaned up from the main bot folder.)
}


; clear the battletable
on 50:TEXT:@clear battletable*:*:{   
  hfree BattleTable
  .remove BattleTable.file
  .msg $nick BattleTable cleared
}

; Bot admins can toggle Player Access commands on and off
on 50:TEXT:@toggle playerAccessCmds*:*:{   
  if ($readini(system.dat, system,AllowPlayerAccessCmds) = false) { 
    writeini system.dat system AllowPlayerAccessCmds true
    $display.message($translate(AllowPlayerAccessCmdsOn), global)
  }
  else {
    writeini system.dat system AllowPlayerAccessCmds false
    $display.message($translate(AllowPlayerAccessCmdsOff), global)
  }
}

; Bot admins can toggle if the bot uses colors
on 50:TEXT:@toggle bot colors*:*:{   
  if ($readini(system.dat, system,AllowColors) = false) { 
    writeini system.dat system AllowColors true
    $display.message($translate(AllowColorsOn), global)
    halt
  }
  else {
    writeini system.dat system AllowColors false
    $display.message($translate(AllowColorsOff), global)
    halt
  }
}

; Bot admins can toggle if the bot uses bold
on 50:TEXT:@toggle bot bold*:*:{   
  if ($readini(system.dat, system,AllowBold) = false) { 
    writeini system.dat system AllowBold true
    $display.message($translate(AllowBoldOn), global)
    halt
  }
  else {
    writeini system.dat system AllowBold false
    $display.message($translate(AllowBoldOff), global)
    halt
  }
}

; Bot admins can toggle the AI system on/off.
on 50:TEXT:@toggle ai system*:*:{   
  if ($readini(system.dat, system, aisystem) = off) { 
    writeini system.dat system aisystem on
    $display.message($translate(AiSystemOn), global)
  }
  else {
    writeini system.dat system aisystem off
    $display.message($translate(AiSystemOff), global)
  }
}


; Bot owners can change the time for !enter allownace.
on 50:TEXT:@time to enter *:*:{  
  if ($4 isnum) {
    writeini system.dat System TimeToEnter $4
    $display.message($translate(ChangeTimeForEnter), global)
  }
  else { $display.message(4You must enter a number for the time,global) | halt }
}

; Bot admins can set the MOTD, everyone else can just see it
on 3:TEXT:@motd*:*:{   
  $checkscript($2-) 

  if (($2 = $null) || ($2 = list)) { 
    if ($isfile($txtfile(motd.txt)) = $true) { $display.private.message(4Current Admin Message2: $read($txtfile(motd.txt))) }
    else { $display.private.message(4No admin message has been set) }
    halt
  }

  if (($2 = remove) && ($istok($readini(system.dat, botinfo, bot.admins), $nick, 46) = $true)) {
    if ($isfile($txtfile(motd.txt)) = $true) {  .remove $txtfile(motd.txt) }
    $display.private.message(4The admin message has been removed) 
    halt
  }

  if (($2 = set) || ($2 = add)) {
    if ($istok($readini(system.dat, botinfo, bot.admins), $nick, 46) = $true) {
      if ($3 = $null) { $display.private.message(4You need to supply a message to set) | halt }
      if ($isfile($txtfile(motd.txt)) = $true) {  .remove $txtfile(motd.txt) }
      write $txtfile(motd.txt) $3-
      $display.private.message(4Admin message has been set)
    }
  }
}

; bot admin command to reset a player's password
; !password reset <playername>
on 50:TEXT:@password reset *:*:{  
  if ($3 = $null) { .msg $nick 4!password reset playername | halt }
  $checkchar($3)

  var %encode.type $readini($char($3), info, PasswordType) 
  if ($version < 6.3) { var %encode.type encode }
  if (%encode.type = $null) { var %encode.type encode | writeini $char($3) info PasswordType encode }

  var %newpassword battlearena $+ $rand(1,100)

  if (%encode.type = encode) { writeini $char($3) info password $encode(%newpassword)  }
  if (%encode.type = hash) { writeini $char($3) info password $sha1(%newpassword)  }

  .msg $nick 3 $+ $3 $+ 's password has been reset.
  .msg $3 4 $+ $nick has reset your password. Your new password is now: %newpassword 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bot owners can add items and xp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 50:TEXT:@add *:*:{  
  if (($3 = xp) || ($3 = exp)) { 
    $checkchar($2)

    var %current.xp $current.xp($2) |  inc %current.xp $4

    var %level.cap $return.systemsetting(PlayerLevelCap)
    if (%level.cap = null) { var %level.cap 60 }

    if ($current.level($2) >= %level.cap) { echo -a can't do this }

    writeini $char($2) exp $current.job($2) %current.xp | $display.message(7* 2 $+ $get_chr_name($2) has gained $4 experience points) 

    $levelup.check($2)

    $fulls($2)
  }

  if ($3 = money) {  $currency.add($2, money, $4) |  $display.message(7* 2 $+ $get_chr_name($2) has gained $4 $return.systemsetting(currency) }
  if ($3 = craftingpoints) {  $currency.add($2, CraftingPoints, $4) |  $display.message(7* 2 $+ $get_chr_name($2) has gained $4 crafting points) }

  if ($3 = item) { 
    if ($readini($dbfile(items.db), $4, type) = $null) { $display.message(4Invalid item) | halt }
    $inventory.add($2, $4, $5)
    $display.message(3 $+ $2 has gained $5 $+ x $4, global) 
  }

  if ($3 = armor) { 

  }

  if ($3 = weapon) { 

  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bot owners can force the next turn
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 50:TEXT:@next*:*: { 
  if (%battleis = on)  { $next | halt }
  else { $display.message($translate(NoBattleCurrently), private) | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bot owners can start an adventure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 50:TEXT:@adventure start *:*: {
  $start.newadventure($nick, $3)
}

on 50:TEXT:@start adventure *:*: {
  $start.newadventure($nick, $3)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bot owners can force the 
; adventure to begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 50:TEXT:@adventure go:*: {
  /.timerAdventureBegin off
  $adventure.begin
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bot owners can end the adventure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 50:TEXT:@adventure end*:*: {  $adventure.end($3) }
on 50:TEXT:@end adventure*:*: {  $adventure.end($3) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bot owners can end the current battle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 50:TEXT:@battle end*:*: { $battle.end($3) }
on 50:TEXT:@end battle*:*: { $battle.end($3) }
