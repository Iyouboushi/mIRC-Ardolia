;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; HELP and VIEW-INFO
;;;; Last updated: 09/25/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 1:TEXT:!help*:*: { $gamehelp($2, $nick) }
alias gamehelp { 
  var %help.topics $readini %help_folder $+ topics.help Help List 
  var %help.topics2 $readini %help_folder $+ topics.help Help List2 
  var %help.topics3 $readini %help_folder $+ topics.help Help List3
  var %help.topics4 $readini %help_folder $+ topics.help Help List4
  var %help.topics5 $readini %help_folder $+ topics.help Help List5
  if ($1 = $null) { 
    $display.private.message2($2, 14::[Current Help Topics]::) 
    $display.private.message2($2,2 $+ %help.topics) 
    $display.private.message2($2,2 $+ %help.topics2) 
    $display.private.message2($2,2 $+ %help.topics3) 
    $display.private.message2($2,2 $+ %help.topics4) 
    $display.private.message2($2,2 $+ %help.topics5) 
    $display.private.message2($2, 14::[Type !help <topic> (without the <>) to view the topic]::) 
    halt 
  }

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
  if ($2 = $null) { var %error.message 4Error: The command is missing what you want to view.  Use it like:  !view-info <adventure $+ $chr(44) ability $+ $chr(44) item $+ $chr(44) weapon, armor, shield> <name> (and remember to remove the < >) | $display.private.message(%error.message) | halt }
  if ($3 = $null) { var %error.message 4Error: The command is missing the name of what you want to view.   Use it like:  !view-info <adventure, ability, item, weapon, armor, shield> <name> (and remember to remove the < >) | $display.private.message(%error.message) | halt }

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

    var %info.sellprice $readini($dbfile(weapons.db), $3, sellPrice)
    if (%info.sellprice = $null) { var %info.sellprice 0 }

    if ($readini($dbfile(weapons.db), $3, AmmoRequired) != $null) {
      var %info.ammo [4Ammo Required12 $readini($dbfile(weapons.db), $3, AmmoRequired) $+ ] [4Ammo Consumed12 $readini($dbfile(weapons.db), $3, AmmoAmountNeeded) $+ ] 
    }

    $display.private.message([4Name12 $rarity.color.check($3, weapon) $+ $3 $+ ] [4Weapon Type12 %info.type $+ ] [4Weapon Speed12 %info.speed $+ ] [4Jobs that can equip12 %info.jobs $+ ] %info.minlevel %info.wpnlevel [4Element of Weapon12 %info.element $+ ] %info.ammo) 
    $display.private.message([4Weapon Damage12 %info.damage $+ ][4Cost12 $iif(%info.cost > 0, %info.cost $currency, cannot be purchased in a shop) $+ ] [4Sell Price12 $iif(%info.sellprice > 0, %info.sellprice $currency, cannot be sold to a shop) $+ ]) 
    $display.private.message([4Stat Bonuses] [4STR12 $chr(43) $+ $readini($dbfile(weapons.db), $3, str) $+ ] [4DEX12 $chr(043) $+ $readini($dbfile(weapons.db), $3, dex) $+ ] [4VIT12 $chr(043) $+ $readini($dbfile(weapons.db), $3, vit) $+ ] [4INT12 $chr(043) $+ $readini($dbfile(weapons.db), $3, int) $+ ] [4MND12 $chr(043) $+ $readini($dbfile(weapons.db), $3, mnd) $+ ] [4PIE12 $chr(043) $+ $readini($dbfile(weapons.db), $3, pie) $+ ] [4Physical Defense12 $chr(043) $+ $readini($dbfile(weapons.db), $3, pDefense) $+ ] [4Magical Defense12 $chr(043) $+ $readini($dbfile(weapons.db), $3, mDefense) $+ ]) 
    $display.private.message([4Weapon Description12 $readini($dbfile(weapons.db), $3, Info) $+ ])
  }


  if ($2 = ability) { 
    var %info.type $readini($dbfile(abilities.db), $3, type)

    if (%info.type = $null) { $display.private.message(4Invalid ability) | halt }

    var %info.level $readini($dbfile(abilities.db), $3, level)
    var %info.aoe $readini($dbfile(abilities.db), $3, aoe)
    var %info.info $readini($dbfile(abilities.db), $3, info)
    var %info.cooldown $readini($dbfile(abilities.db), $3, cooldown)
    var %info.cost $readini($dbfile(abilities.db), $3, cost)
    var %info.stat $readini($dbfile(abilities.db), $3, stat)
    var %info.potency $readini($dbfile(abilities.db), $3, potency)
    var %info.enmity $readini($dbfile(abilities.db), $3, enmityMultiplier)
    var %info.jobs $readini($dbfile(abilities.db), $3, job)
    var %info.statuseffect $readini($dbfile(abilities.db), $3, statuseffect)

    var %info.instant $readini($dbfile(abilities.db), $3, instant)
    if (%info.instant = $null) { var %info.instant false }

    if (%info.jobs != $null) { var %info.jobs $clean.list(%info.jobs) } 
    if (%info.jobs = $null) { var %info.jobs any }

    var %non.buff.line [4Ability Stat12 %info.stat $+ ] [4Ability Potency12 %info.potency $+ ] [4Ability Enmity Multiplier12 %info.enmity $+ ]


    $display.private.message([4Ability Name12 $3 $+ ] [4Ability Type12 %info.type $+ ] [4Target12 $iif(%info.aoe = true, AOE, Single) $+ ] [4Jobs that can use this ability12 %info.jobs $+ ] [4Ability Level12 %info.level $+ ] [4Instant Use12 %info.instant $+ ] ) 
    $display.private.message([4Ability TP Cost12 %info.cost $+ ] [4Ability Cooldown12 %info.cooldown battle turns] $iif(%info.type != buff, %non.buff.line) $iif(%info.statuseffect != $null, [4Status Effect12 %info.statuseffect $+ ]))
    $display.private.message([4Ability Info12 %info.info $+ ])

    if ($readini($dbfile(abilities.db), $3, CanUseOutsideBattle) = true) { $display.private.message(7*2 This ability can be used outside of battle while inside of an adventure) } 
  } 

  if ($2 = Spell) { 
    var %info.type $readini($dbfile(spells.db), $3, type)
    if (%info.type = $null) { $display.private.message(4Invalid Spell) | halt }

    var %info.level $readini($dbfile(spells.db), $3, level)
    var %info.aoe $readini($dbfile(spells.db), $3, aoe)
    var %info.info $readini($dbfile(spells.db), $3, info)
    var %info.cooldown $readini($dbfile(spells.db), $3, cooldown)
    var %info.cost $readini($dbfile(spells.db), $3, cost)
    var %info.stat $readini($dbfile(spells.db), $3, stat)
    var %info.potency $readini($dbfile(spells.db), $3, potency)
    var %info.enmity $readini($dbfile(spells.db), $3, enmityMultiplier)
    var %info.jobs $readini($dbfile(spells.db), $3, jobs)
    var %info.statuseffect $readini($dbfile(spells.db), $3, statuseffect)

    var %info.element $readini($dbfile(spells.db), $3, element)
    if (%info.element = $null) { var %info.element none }

    var %info.instant $readini($dbfile(spells.db), $3, instant)
    if (%info.instant = $null) { var %info.instant false }

    if (%info.jobs != $null) { var %info.jobs $clean.list(%info.jobs) } 
    if (%info.jobs = $null) { var %info.jobs any }

    var %non.buff.line [4Spell Stat12 %info.stat $+ ] [4Spell Potency12 %info.potency $+ ] [4Spell Enmity Multiplier12 %info.enmity $+ ]


    $display.private.message([4Spell Name12 $3 $+ ] [4Spell Type12 %info.type $+ ] [4Target12 $iif(%info.aoe = true, AOE, Single) $+ ] [4Jobs that can use this Spell12 %info.jobs $+ ] [4Spell Level12 %info.level $+ ] [4Instant Use12 %info.instant $+ ] ) 
    $display.private.message([4Spell MP Cost12 %info.cost $+ ] [4Spell Cooldown12 %info.cooldown battle turns] $iif(%info.type != buff, %non.buff.line) $iif(%info.statuseffect != $null, [4Status Effect12 %info.statuseffect $+ ]) [4Element12 %info.element $+ ])
    $display.private.message([4Spell Info12 %info.info $+ ])

    if ($readini($dbfile(spells.db), $3, CanUseOutsideBattle) = true) { $display.private.message(7*2 This Spell can be used outside of battle while inside of an adventure) } 
  }  

  if (($2 = armor) || ($2 = shield)) {

    var %info.name $readini($dbfile(equipment.db), $3, name) 
    var %info.name $rarity.color.check($3, armor) $+ %info.name
    var %info.type $readini($dbfile(equipment.db), $3, EquipLocation) 

    var %info.jobs $readini($dbfile(equipment.db), $3, jobs) 

    if (%info.jobs != $null) { var %info.jobs $clean.list(%info.jobs) } 
    if (%info.jobs = $null) { var %info.jobs any }

    var %info.minlevel [4Minimum Job Level to Equip12 $readini($dbfile(equipment.db), $3, PlayerLevel) $+ ]
    var %info.armorlevel [4 $+ $2 iLevel12 $readini($dbfile(equipment.db), $3, ItemLevel) $+ ]

    var %info.cost $readini($dbfile(equipment.db), $3, cost)
    if (%info.cost = $null) { var %info.cost 0 }

    var %info.sellprice $readini($dbfile(equipment.db), $3, sellPrice)
    if (%info.sellprice = $null) { var %info.sellprice 0 }

    $display.private.message([4Name12 %info.name $+ ] [4Type12 %info.type $+ ] [4Jobs that can equip12 %info.jobs $+ ] %info.minlevel %info.armorlevel)
    $display.private.message([4Cost12 $iif(%info.cost > 0, %info.cost $currency, cannot be purchased in a shop) $+ ] [4Sell Price12 $iif(%info.sellprice > 0, %info.sellprice $currency, cannot be sold to a shop) $+ ])
    $display.private.message([4Stat Bonuses] [4STR12 $chr(43) $+ $readini($dbfile(equipment.db), $3, str) $+ ] [4DEX12 $chr(043) $+ $readini($dbfile(equipment.db), $3, dex) $+ ] [4VIT12 $chr(043) $+ $readini($dbfile(equipment.db), $3, vit) $+ ] [4INT12 $chr(043) $+ $readini($dbfile(equipment.db), $3, int) $+ ] [4MND12 $chr(043) $+ $readini($dbfile(equipment.db), $3, mnd) $+ ] [4PIE12 $chr(043) $+ $readini($dbfile(equipment.db), $3, pie) $+ ] [4Physical Defense12 $chr(043) $+ $readini($dbfile(equipment.db), $3, pDefense) $+ ] [4Magical Defense12 $chr(043) $+ $readini($dbfile(equipment.db), $3, mDefense) $+ ]) 
  }

  if ($2 = adventure) { 
    if (($isfile($zonefile($3)) = $false) || ($3 = template)) { $display.private.message(4No such adventure exists) | halt }

    var %info.name $readini($zonefile($3), Info, Name) | var %info.levelrange $readini($zonefile($3), Info, LevelRange)
    var %info.ilevel $readini($zonefile($3), Info, iLevel)
    if (%info.ilevel = $null) { var %info.ilevel 1 }
    var %info.prereq $readini($zonefile($3), Info, PreReq)
    if (%info.prereq != $null) { var %info.prereq [4Pre-requirement12 $readini($zonefile(%info.prereq), Info, Name) $+ ] }
    if (%info.prereq = $null) { var %info.prereq [4Pre-requirement12 none] }
    var %info.roomcount $calc($ini($zonefile($3),0) - 1)
    var %info.partyactions $readini($zonefile($3), Info, AdventureActions)

    $display.private.message([4Adventure Name12 %info.name $+ ] [4Level Range12 %info.levelrange $+ ] [4Minimium iLevel to Enter12 %info.ilevel $+ ] %info.prereq)
    $display.private.message([4Number of Rooms12 %info.roomcount  $+ ]  [4Starting Party Stamina12 %info.partyactions $+ ])

    if ($readini($zonefile($3), info, desc) != $null) { $display.private.message([4Desc]12 $readini($zonefile($3), info, desc)) }
  }


  if ($2 = item) {
    var %info.type $readini($dbfile(items.db), $3, type)
    if (%info.type = $null) { $display.private.message(4Invalid Item) | halt }

    var %info.cost $readini($dbfile(items.db), $3, Cost)
    var %info.sellprice $readini($dbfile(items.db), $3, SellPrice)
    var %info.cooldown $readini($dbfile(items.db), $3, CoolDown)
    var %info.itemdesc $readini($dbfile(items.db), $3, ItemDesc)

    if ((%info.type = heal) || (%info.type = restoreMP)) { 

      var %info.healamount $readini($dbfile(items.db), $3, HealAmount)
      if (%info.type = Heal) { var %info.healtype HP }
      if (%info.type = RestoreMP) { var %info.healtype MP }

      $display.private.message([4Item Name12 $3 $+ ] [4Type12 %info.type $+ ] [4Restore Type12 %info.healtype $+ ] [4Restore Amount12 %info.healamount $+ ] [4Cooldown12 %info.cooldown battle turns])
      $display.private.message([4Cost12 $iif(%info.cost > 0, %info.cost $currency, cannot be purchased in a shop) $+ ] [4Sell Price12 $iif(%info.sellprice > 0, %info.sellprice $currency, cannot be sold to a shop) $+ ])
      $display.private.message([4Item Desc12 %info.itemdesc $+ ])
    }

    if (%info.type = revive) { 
      var %info.reviveamount $calc(100 * $readini($dbfile(items.db), $3, ReviveAmount))
      $display.private.message([4Item Name12 $3 $+ ] [4Type12 %info.type $+ ] [4HP Restored Upon Revival12 %info.reviveamount $+ $chr(37) $+ ] [4Cooldown12 %info.cooldown battle turns])
      $display.private.message([4Cost12 $iif(%info.cost > 0, %info.cost $currency, cannot be purchased in a shop) $+ ] [4Sell Price12 $iif(%info.sellprice > 0, %info.sellprice $currency, cannot be sold to a shop) $+ ])
      $display.private.message([4Item Desc12 %info.itemdesc $+ ])
    }

    if (%info.type = crystal) { 
      $display.private.message([4Item Name12 $3 $+ ] [4Type12 %info.type $+ ])
      $display.private.message([4Cost12 $iif(%info.cost > 0, %info.cost $currency, cannot be purchased in a shop) $+ ] [4Sell Price12 $iif(%info.sellprice > 0, %info.sellprice $currency, cannot be sold to a shop) $+ ])
      $display.private.message([4Item Desc12 %info.itemdesc $+ ])
    }

    if (%info.type = adventure) { 
      $display.private.message([4Item Name12 $3 $+ ] [4Type12 %info.type $+ ])
      $display.private.message([4Cost12 $iif(%info.cost > 0, %info.cost $currency, cannot be purchased in a shop) $+ ] [4Sell Price12 $iif(%info.sellprice > 0, %info.sellprice $currency, cannot be sold to a shop) $+ ])
      $display.private.message([4Item Desc12 %info.itemdesc $+ ])
      $display.private.message(7*2 This item can only be used at certain points inside of adventures)
    }

    if (%info.type = crafting) { 
      $display.private.message([4Item Name12 $3 $+ ] [4Type12 %info.type $+ ])
      $display.private.message([4Cost12 $iif(%info.cost > 0, %info.cost $currency, cannot be purchased in a shop) $+ ] [4Sell Price12 $iif(%info.sellprice > 0, %info.sellprice $currency, cannot be sold to a shop) $+ ])
      $display.private.message([4Item Desc12 %info.itemdesc $+ ])
    }

    if (%info.type = food) { 
      $display.private.message([4Item Name12 $3 $+ ] [4Type12 %info.type $+ ])
      $display.private.message([4Cost12 $iif(%info.cost > 0, %info.cost $currency, cannot be purchased in a shop) $+ ] [4Sell Price12 $iif(%info.sellprice > 0, %info.sellprice $currency, cannot be sold to a shop) $+ ])
      $display.private.message([4Item Desc12 %info.itemdesc $+ ])
      $display.private.message([4Stat Bonuses] [4STR12 $chr(43) $+ $readini($dbfile(items.db), $3, str) $+ ] [4DEX12 $chr(043) $+ $readini($dbfile(items.db), $3, dex) $+ ] [4VIT12 $chr(043) $+ $readini($dbfile(items.db), $3, vit) $+ ] [4INT12 $chr(043) $+ $readini($dbfile(items.db), $3, int) $+ ] [4MND12 $chr(043) $+ $readini($dbfile(items.db), $3, mnd) $+ ] [4PIE12 $chr(043) $+ $readini($dbfile(items.db), $3, pie) $+ ] [4DET12 $chr(043) $+ $readini($dbfile(items.db), $3, det) $+ ]) 
      $display.private.message(7*2 This item can be used outside of battle while inside of adventures. Note that you can only use 1 food item per adventure.)
    }

  } 

}
