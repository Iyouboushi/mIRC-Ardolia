;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; HELP and VIEW-INFO
;;;; Last updated: 04/26/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 1:TEXT:!help*:*: { $gamehelp($2, $nick) }
alias gamehelp { 
  set %help.topics $readini %help_folder $+ topics.help Help List | set %help.topics2 $readini %help_folder $+ topics.help Help List2 | set %help.topics3 $readini %help_folder $+ topics.help Help List3
  if ($1 = $null) { $display.private.message2($2, 14::[Current Help Topics]::) |  $display.private.message2($2,2 $+ %help.topics) | $display.private.message2($2,2 $+ %help.topics2) | unset %help.topics | unset %help.topics2 | $display.private.message2($2, 14::[Type !help <topic> (without the <>) to view the topic]::) | halt }

  if ($isfile(%help_folder $+ $1 $+ .help) = $true) {  set %topic %help_folder $+ $1 $+ .help |  set %lines $lines(%topic) | set %l 0 | goto help }
  else { $display.private.message2($2, 3The Librarian searchs through the ancient texts but returns with no results for your inquery!  Please try again) | halt }
  :help
  inc %l 1
  if (%l <= %lines) {  
    if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) { 
      var %timer.delay.help $calc(%l - 1)
      var %line.to.send $read(%topic, %l)
      if (%line.to.send != $null) { $display.private.message.delay.custom(%line.to.send, %timer.delay.help, $2) }
    }
    if ($readini(system.dat, system, botType) = DCCchat) { $display.private.message($read(%topic, %l))  }
    goto help
  }
  else { goto endhelp }
  :endhelp
  unset %help.topics3 |  unset %topic | unset %help.topics | unset %help.topics2 | unset %lines | unset %l | unset %help
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The view-info command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON 1:TEXT:!view-info*:*: { $view-info($nick, $2, $3, $4) }
alias view-info {
  if ($2 = $null) { var %error.message 4Error: The command is missing what you want to view.  Use it like:  !view-info <tech $+ $chr(44) item $+ $chr(44) skill $+ $chr(44) weapon, armor, accessory, ignition, shield> <name> (and remember to remove the < >) | $display.private.message(%error.message) | halt }
  if ($3 = $null) { var %error.message 4Error: The command is missing the name of what you want to view.   Use it like:  !view-info <tech, item, skill, weapon, armor, accessory, ignition, shield> <name> (and remember to remove the < >) | $display.private.message(%error.message) | halt }




}
