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
  if ($2 = $null) { var %error.message 4Error: The command is missing what you want to view.  Use it like:  !view-info <ability $+ $chr(44) item $+ $chr(44) weapon, armor, shield> <name> (and remember to remove the < >) | $display.private.message(%error.message) | halt }
  if ($3 = $null) { var %error.message 4Error: The command is missing the name of what you want to view.   Use it like:  !view-info <ability, item, weapon, armor, shield> <name> (and remember to remove the < >) | $display.private.message(%error.message) | halt }

  if ($2 = weapon ) {
    if ($readini($dbfile(weapons.db), $3, type) = $null) { $display.private.message(4Invalid weapon) | halt }
    if ($readini($dbfile(weapons.db), $3, type) = shield) { $display.private.message(4Invalid weapon Use 12!view-info shield $3 4to see info on this) | halt }

    var %info.type $readini($dbfile(weapons.db), $3, type) |  var %info.jobs $readini($dbfile(weapons.db), $3, jobs) 
    var %info.stat $readini($dbfile(weapons.db), $3, stat) |  var %info.damage $readini($dbfile(weapons.db), $3, damage) 
    var %info.speed $readini($dbfile(weapons.db), $3, speed) | var %info.element $readini($dbfile(weapons.db), $3, Element) 
    var %info.minlevel [4Minimum Job Level to Equip12 $readini($dbfile(weapons.db), $3, PlayerLevel) $+ ]
    var %info.wpnlevel [4Weapon iLevel12 $readini($dbfile(weapons.db), $3, ItemLevel) $+ ]
    var %info.cost $readini($dbfile(weapons.db), $3, cost)
    if (%info.cost = $null) { var %info.cost 0 }

    if ($readini($dbfile(weapons.db), $3, AmmoRequired) != $null) {
      var %info.ammo [4Ammo Required12 $readini($dbfile(weapons.db), $3, AmmoRequired) $+ ] [4Ammo Consumed12 $readini($dbfile(weapons.db), $3, AmmoAmountNeeded) $+ ] 
    }

    $display.private.message([4Name12 $3 $+ ] [4Weapon Type12 %info.type $+ ] [4Weapon Speed12 %info.speed $+ ] %info.minlevel %info.wpnlevel %info.ammo) 
    $display.private.message([4Weapon Damage12 %info.damage $+ ][4Cost12 $iif(%info.cost > 0, %info.cost $currency, cannot be purchased in a shop) $+ ] [4Element of Weapon12 %info.element $+ ]) 
    $display.private.message([4Stat Bonuses: 12 $+ $chr(043) $+ $readini($dbfile(weapons.db), $3, str) 4str $+ $chr(44) 12 $+ $chr(043) $+ $readini($dbfile(weapons.db), $3, dex) 4dex $+ $chr(44) 12 $+ $chr(043) $+ $readini($dbfile(weapons.db), $3, vit) 4vit $+ $chr(44) 12 $+ $chr(043) $+ $readini($dbfile(weapons.db), $3, int) 4int $+ $chr(44) 12 $+ $chr(043) $+ $readini($dbfile(weapons.db), $3, mnd) 4mnd $+ $chr(44) 12 $+ $chr(043) $+ $readini($dbfile(weapons.db), $3, pie) 4pie $+ $chr(44) 12 $+ $chr(043) $+ $readini($dbfile(weapons.db), $3, pdefense) 4physical defense $+ $chr(44) 12 $+ $chr(043) $+ $readini($dbfile(weapons.db), $3, mdefense) 4magic defense $+ ] )
    $display.private.message([4Weapon Description12 $readini($dbfile(weapons.db), $3, Info) $+ ])
  }


  if ($2 = ability) { $display.private.message(To Be Added) } 

  if ($2 = item) { $display.private.message(To Be Added) } 

  if ($2 = shield) { $display.private.message(To Be Added) } 

  if ($2 = armor) { $display.private.message(To Be Added) } 

}
