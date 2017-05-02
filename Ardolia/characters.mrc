;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; characters.mrc
;;;; Last updated: 05/02/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create a new character
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; !new char [race]
on 1:TEXT:!new char*:*: {  $checkscript($2-)
  if ($isfile($char($nick)) = $true) { $display.private.message($translate(PlayerExists)) | halt }
  if ($isfile($char($nick $+ _clone)) = $true) { $display.private.message($translate(NameReserved)) | halt }
  if ($isfile($char(evil_ $+ $nick)) = $true)  { $display.private.message($translate(NameReserved)) | halt }
  if ($isfile($char($nick $+ _summon)) = $true) { $display.private.message($translate(NameReserved)) | halt }
  if ($isfile($mon($nick)) = $true) { $display.private.message($translate(NameReserved)) | halt }
  if ($isfile($boss($nick)) = $true) { $display.private.message($translate(NameReserved)) | halt  }
  if ($isfile($npc($nick)) = $true) { $display.private.message($translate(NameReserved)) | halt }
  if ($isfile($summon($nick)) = $true) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = $nick $+ _clone) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = evil_ $+ $nick) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = monster_warmachine) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = demon_wall) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = pirate_scallywag) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = pirate_firstmatey) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = bandit_leader) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = bandit_minion) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = crystal_shadow) { $display.private.message($translate(NameReserved)) | halt }
  if ($nick = alliedforces_president) { $display.private.message($translate(NameReserved)) | halt }
  if ((($nick = frost_monster) || ($nick = frost_monster1) || ($nick = frost_monster2))) { $display.private.message($translate(NameReserved)) | halt }

  ; If the player has not supplied a valid race then we need to give the beginning instructions
  if (($3 = $null) || ($readini($racefile($3), BasicInfo, Name) = $null)) { 
    $gamehelp(welcome, $nick)
    halt
  }

  ; Create the file
  .copy $char(new_chr) $char($nick)
  writeini $char($nick) Info Name $nick 
  writeini $char($nick) Info Created $fulldate

  ; Copy the starting stats over
  writeini $char($nick) StartingStats Str $readini($racefile($3), StartingStats, Str)
  writeini $char($nick) StartingStats Dex $readini($racefile($3), StartingStats, Dex)
  writeini $char($nick) StartingStats Vit $readini($racefile($3), StartingStats, Vit)
  writeini $char($nick) StartingStats Int $readini($racefile($3), StartingStats, Int)
  writeini $char($nick) StartingStats Mnd $readini($racefile($3), StartingStats, Mnd)
  writeini $char($nick) StartingStats Pie $readini($racefile($3), StartingStats, Pie)
  writeini $char($nick) StartingStats Det $readini($racefile($3), StartingStats, Det)

  ; Generate a password
  set %password ardolia $+ $rand(1,100) $+ $rand(a,z) $+ $rand(1,1000)
  writeini $char($nick) info password $encode(%password)

  ; Send information about the password
  $display.private.message($translate(StartingCharPassword))

  ; Write current host
  if ($site != $null) { writeini $char($nick) info LastIP $site } 

  ; Give voice
  mode %battlechan +v $nick
  .auser 2 $nick

  var %bot.owners $readini(system.dat, botinfo, bot.owner)
  if ($istok(%bot.owners,$nick,46) = $true) {
    var %bot.owner $gettok(%bot.owners, 1, 46)
    if ($nick = %bot.owner) { .auser 100 $nick }
    else { .auser 50 $nick }
  }

  ; Give 10 starting login points
  $currency.add($nick, LoginPoints, 10)
  writeini $char($nick) info lastloginpoint $ctime 

  ; Tell the world we've joined
  $display.message($translate(CharacterCreated))

  ; Copy the starting stats to the current stats
  $copyini($nick, StartingStats, BaseStats)
  $fulls($nick)

  unset %password
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Password and ID commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ON 2:TEXT:!newpass *:?:{ $checkscript($2-) | $password($nick) 
  var %encode.type $readini($char($nick), info, PasswordType)

  if (%encode.type = $null) { var %encode.type encode }
  if (%encode.type = encode) { 
    if ($encode($2) = %password) {  
      if ($version < 6.3) { writeini $char($nick)  info PasswordType encode | writeini $char($nick) info password $encode($3)  }
      else { writeini $char($nick) info PasswordType hash |  writeini $char($nick) info password $sha1($3) }
      $display.private.message($readini(translation.dat, translation, newpassword)) | unset %password | halt
    }
    if ($encode($2) != %password) {  $display.private.message($translate(wrongpassword)) | unset %password | halt }
  }
  if (%encode.type = hash) {
    if ($sha1($2) = %password) { writeini $char($nick) info password $sha1($3) | writeini $char($nick) info PasswordType hash | $display.private.message($readini(translation.dat, translation, newpassword)) | unset %password | halt }
    if ($sha1($2) != %password) { $display.private.message($translate(wrongpassword)) | unset %password | halt }
  }
}

ON 1:TEXT:!id*:*:{ 
  if ($readini(system.dat, system, botType) = TWITCH) {
    if ($isfile($char($nick)) = $true) {
      $set_chr_name($nick) | $display.message(10 $+ %real.name %custom.title  $+ $readini($char($nick), Descriptions, Char), global)
      var %bot.owners $readini(system.dat, botinfo, bot.owner)
      if ($istok(%bot.owners,$nick,46) = $true) {
        var %bot.owner $gettok(%bot.owners, 1, 46)
        if ($nick = %bot.owner) { .auser 100 $nick }
        else { .auser 50 $nick }
      }
      mode %battlechan +v $nick | unset %passhurt
      halt
    }
  }

  $idcheck($nick , $2) | mode %battlechan +v $nick |  unset %passhurt | $writehost($nick, $site) |  $system.intromessage($nick) | /close -m* 
  if ($readini($char($nick), info, CustomTitle) != $null) { var %custom.title " $+ $readini($char($nick), info, CustomTitle) $+ " }
  if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) { $display.message(10 $+ $get_chr_name($nick) %custom.title  $+  $readini($char($nick), Descriptions, Char), global) }
}
ON 1:TEXT:!quick id*:*:{ $idcheck($nick , $3, quickid) | mode %battlechan +v $nick |  $writehost($nick, $site) | $system.intromessage($nick)
  if (($readini(system.dat, system, botType) = IRC) || ($readini(system.dat, system, botType) = TWITCH)) { $set_chr_name($nick) }
  unset %passhurt 
  /close -m* 
}
on 2:TEXT:!logout*:*:{ .auser 1 $nick | close -c $nick | mode %battlechan -v $nick | .flush 1 }
on 2:TEXT:!log out*:*:{ .auser 1 $nick | close -c $nick | mode %battlechan -v $nick | .flush 1 }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Allocate your free stat points
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!stat *:?: {
  ; !stat [add] [stat] [amount]
  if (($2 = point) || ($2 = points)) { $display.private.message($translate(ViewMyStatPoints)) | halt }
  if (($2 != add) && ($2 != remove)) { $gamehelp(!stat, $nick) | halt }
  if (($3 = $null) || ($4 !isnum)) { $gamehelp(!stat, $nick) | halt }
  if ((. isin $4) || ($4 <= 0)) { $gamehelp(!stat, $nick) | halt }

  var %valid.stats str.dex.vit.int.mnd.pie
  if ($istok(%valid.stats, $3, 46) = $false) { $display.private.message($translate(InvalidStatSelection)) | halt }

  ; Are we in an adventure?  If so, we can't do this.
  if ($in.adventure($nick) = true) { $display.private.message($translate(Can'tAllocateRightNow)) | halt }

  if ($2 = add) {
    ; Do we have enough stat points?
    if ($4 > $current.freestatpoints($nick)) { $display.private.message($translate(NotEnoughStatPoints)) | halt }

    if ($3 = str) { var %current.stat $resting.str($nick) } 
    if ($3 = dex) { var %current.stat $resting.dex($nick) }
    if ($3 = vit) { var %current.stat $resting.vit($nick) }  
    if ($3 = int) { var %current.stat $resting.int($nick) } 
    if ($3 = mnd) { var %current.stat $resting.mnd($nick) } 
    if ($3 = pie) { var %current.stat $resting.pie($nick) }

    inc %current.stat $4

    writeini $char($nick) basestats $3 %current.stat 
    writeini $char($nick) info UnallocatedStatPoints $calc($current.freestatpoints($nick) - $4)
    $miscstats($nick, add, TotalStatPointsSpent, $4)

    $display.private.message($translate(AllocatedStatPoints, $4, $3, %current.stat)) 

    $fulls($nick, yes)
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Changing/Checking Jobs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!job change *:*: {
  ; !job change [job]

  ; Can't change jobs if you're in an
  if ($in.adventure($nick) = true) { $display.private.message($translate(Can'tChangeJobsRightNow)) | halt }

  ; Is this the same job you already are?
  if ($3 = $current.job($nick)) { $display.private.message($translate(SameJob)) | halt }

  ; does the player still have unallocated stat points?
  if ($current.freestatpoints($nick) > 0) { $display.private.message($translate(Can'tChangeJobsWithStatPointsLeft)) | halt }

  ; Is this a valid job?
  if ($isfile($jobfile($3)) != $true) { $display.private.message($translate(JobDoesNotExist)) | halt }

  ; If the player's file doesn't have that job write that we're now level 1 to it
  var %job.level $readini($char($nick), jobs, $3)
  if ((%job.level = $null) || (%job.level = 0)) { writeini $char($nick) jobs $3 1 | writeini $char($nick) Exp $3 0 }

  ; Make a current copy of the stats of the old job and clear the equipment
  if ($current.job($nick) != none) {  
    $copyini($nick, BaseStats, Stats- $+ $current.job($nick)) 
    $equipment.reset($nick)
  }

  ; Do we need to restore a back up of the job's stats?
  if ($readini($char($nick), Stats- $+ $3, str) != $null) {  
    $copyini($nick, Stats- $+ $3, BaseStats) 
  }

  ; If a back up is not found then it means it's the first time we're switching to this job. Time to do some stuff.
  if ($readini($char($nick), Stats- $+ $3, str) = $null) {

    ; Get a copy from the starting stats
    $copyini($nick, StartingStats, BaseStats)
  }

  writeini $char($nick) Jobs CurrentJob $3

  ; Restore the player's HP/MP/battle stats
  $fulls($nick, yes)

  ; Tell the world we've changed jobs
  $display.message($translate(ChangedJob))
}

on 2:TEXT:!jobs:#: {  var %jobs.list $jobs.list($nick) |  $display.message($translate(ViewMyJobs), private) }
on 2:TEXT:!jobs:?: {  var %jobs.list $jobs.list($nick) |  $display.private.message($translate(ViewMyJobs)) }
on 2:TEXT:!job:*: {  $display.message($translate(ViewMyCurrentJob),private) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set your gender
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; !setgender male/female/neither/none
on 3:TEXT:!setgender*:*: { $checkscript($2-)
  if ($2 = neither) { writeini $char($nick) Info Gender its | writeini $char($nick) Info Gender2 its | $display.private.message($translate(SetGenderNeither)) | unset %check | halt }
  if ($2 = none) { writeini $char($nick) Info Gender its | writeini $char($nick) Info Gender2 its | $display.private.message($translate(SetGenderNeither))  | unset %check | halt }
  if ($2 = male) { writeini $char($nick) Info Gender his | writeini $char($nick) Info Gender2 him | $display.private.message($translate(SetGenderMale))  | unset %check | halt }
  if ($2 = female) { writeini $char($nick) Info Gender her | writeini $char($nick) Info Gender2 her | $display.private.message($translate(SetGenderFemale)) | unset %check | halt }
  else { $display.private.message($translate(NeedValidGender)) | unset %check | halt }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your HP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!hp:#: { $display.message($translate(ViewMyHP), private) }
on 2:TEXT:!hp:?: { $display.private.message($translate(ViewMyHP)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your MP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!mp:#: { $display.message($translate(ViewMyMP), private) }
on 2:TEXT:!mp:?: { $display.private.message($translate(ViewMyHP)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your TP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!tp:#: { $display.message($translate(ViewMyTP), private) }
on 2:TEXT:!tp:?: { $display.private.message($translate(ViewMyTP)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your level
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!level:#: { $display.message($translate(ViewMyLevel), private) }
on 2:TEXT:!level:?: { $display.private.message($translate(ViewMyLevel)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your iLevel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!ilevel:#: { $display.message($translate(ViewMyiLevel), private) }
on 2:TEXT:!ilevel:?: { $display.private.message($translate(ViewMyiLevel)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your xp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!xp:#: { $display.message($translate(ViewMyXP), private) }
on 2:TEXT:!xp:?: { $display.private.message($translate(ViewMyXP)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your main currency
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!gil:#: { $display.message($translate(ViewMyMoney), private) }
on 2:TEXT:!gil:?: { $display.private.message($translate(ViewMyMoney), private) }
on 2:TEXT:!money:#: { $display.message($translate(ViewMyMoney), private) }
on 2:TEXT:!money:?: { $display.private.message($translate(ViewMyMoney), private) }
on 2:TEXT:!gold:#: { $display.message($translate(ViewMyMoney), private) }
on 2:TEXT:!gold:?: { $display.private.message($translate(ViewMyMoney), private) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your craftingpoints
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!craftingpoints:#: { $display.message($translate(ViewMycraftingpoints), private) }
on 2:TEXT:!craftingpoints:?: { $display.private.message($translate(ViewMycraftingpoints)) }
on 2:TEXT:!crafting points:#: { $display.message($translate(ViewMycraftingpoints), private) }
on 2:TEXT:!crafting points:?: { $display.private.message($translate(ViewMycraftingpoints)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your guildpoints
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!guildpoints:#: { $display.message($translate(ViewMyguildpoints), private) }
on 2:TEXT:!guildpoints:?: { $display.private.message($translate(ViewMyguildpoints)) }
on 2:TEXT:!guild points:#: { $display.message($translate(ViewMyguildpoints), private) }
on 2:TEXT:!guild points:?: { $display.private.message($translate(ViewMyguildpoints)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your fame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!fame:#: { $display.message($translate(ViewMyfame), private) }
on 2:TEXT:!fame:?: { $display.private.message($translate(ViewMyfame)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your loginpoints
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!loginpoints:#: { $display.message($translate(ViewMyloginpoints), private) }
on 2:TEXT:!loginpoints:?: { $display.private.message($translate(ViewMyloginpoints)) }
on 2:TEXT:!login points:#: { $display.message($translate(ViewMyloginpoints), private) }
on 2:TEXT:!login points:?: { $display.private.message($translate(ViewMyloginpoints)) }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View all currencies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!currencies:#: { $display.message($translate(ViewMyCurrencies), private) }
on 2:TEXT:!currencies:?: { $display.private.message($translate(ViewMyCurrencies)) }


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View stats
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!stats*:*: {

  ; to be re-added later
  halt

  if ($2 = $null) { 
    $display.private.message.delay.custom([4 $+ $get_chr_name($nick) 4the12 $race($nick) $+ ] [4Job12 $current.job($nick) $+ ]  [4Level12 $get.level($nick) $+ ] [4Exp12 $current.xp($nick) $chr(47) $xp.to.level($nick) $chr(40) $+ $round($calc(($current.xp($nick) / $xp.to.level($nick)) * 100),0) $+ $chr(37) $+ $chr(41) $+ ]    ,2,$nick)
    $display.private.message.delay.custom([4HP12 $current.hp($nick) $+ 1/ $+ 12 $+ $resting.hp($nick) $+ ] [4MP12 $current.mp($nick) $+ 1/ $+ 12 $+ $resting.mp($nick) $+ ] [4TP12 $current.tp($nick) $+ ], 2, $nick)
    $display.private.message.delay.custom([4STR:12 $resting.str($nick) 3+ $+ $bonus.stat($nick,str) $+ ]  [4AGI:12 $resting.agi($nick) 3+ $+ $bonus.stat($nick,agi) $+ ] [4VIT:12 $resting.vit($nick) 3+ $+ $bonus.stat($nick,vit) $+ ] [4MAG:12 $resting.mag($nick) 3+ $+ $bonus.stat($nick,mag) $+ ] [4CHR:12 $resting.chr($nick) 3+ $+ $bonus.stat($nick,chr) $+ ] [4SPD:12 $resting.spd($nick) 3+ $+ $bonus.stat($nick,spd) $+ ], 2, $nick)
    $display.private.message.delay.custom([4 $+ $iif($return.equipped($nick, LeftHand) != nothing, Weapons, Weapon) Equipped12 $return.equipped($nick, RightHand) $iif($return.equipped($nick, LeftHand) != nothing, 4and12 $return.equipped($nick, LeftHand)) $+ ] [4Accessory Slot 112 $return.equipped($nick, accessory1) $+ ]  [4Accessory Slot 212 $return.equipped($nick, accessory1) $+ ] [4Head Armor12 $return.equipped($nick, head) $+ ] [4Body Armor12 $return.equipped($nick, body) $+ ] [4Leg Armor12 $return.equipped($nick, legs) $+ ] [4Feet Armor12 $return.equipped($nick, feet) $+ ] [4Hand Armor12 $return.equipped($nick, hands) $+ ] ,2, $nick)
  }

  else { $checkchar($2) 
    if ($flag($2) != $null) { $display.private.message($translate(CanOnlyViewPlayerStats)) | halt }

    $display.private.message.delay.custom([4 $+ $get_chr_name($2) 4the12 $race($2) $+ ] [4Job12 $current.job($2) $+ ]  [4Level12 $get.level($2) $+ ] [4Exp12 $current.xp($2) $chr(47) $xp.to.level($2) $chr(40) $+ $round($calc(($current.xp($2) / $xp.to.level($2)) * 100),0) $+ $chr(37) $+ $chr(41) $+ ]    ,2,$nick)
    $display.private.message.delay.custom([4HP12 $current.hp($2) $+ 1/ $+ 12 $+ $resting.hp($2) $+ ] [4MP12 $current.mp($2) $+ 1/ $+ 12 $+ $resting.mp($2) $+ ] [4TP12 $current.tp($2) $+ ], 2, $nick)
    $display.private.message.delay.custom([4STR:12 $resting.str($2) 3+ $+ $bonus.stat($2,str) $+ ]  [4AGI:12 $resting.agi($2) 3+ $+ $bonus.stat($2,agi) $+ ] [4VIT:12 $resting.vit($2) 3+ $+ $bonus.stat($2,vit) $+ ] [4MAG:12 $resting.mag($2) 3+ $+ $bonus.stat($2,mag) $+ ] [4CHR:12 $resting.chr($2) 3+ $+ $bonus.stat($2,chr) $+ ] [4SPD:12 $resting.spd($2) 3+ $+ $bonus.stat($2,spd) $+ ], 2, $nick)
    $display.private.message.delay.custom([4 $+ $iif($return.equipped($2, LeftHand) != nothing, Weapons, Weapon) Equipped12 $return.equipped($2, RightHand) $iif($return.equipped($2, LeftHand) != nothing, 4and12 $return.equipped($2, LeftHand)) $+ ] [4Accessory Slot 112 $return.equipped($2, accessory1) $+ ]  [4Accessory Slot 212 $return.equipped($2, accessory1) $+ ] [4Head Armor12 $return.equipped($2, head) $+ ] [4Body Armor12 $return.equipped($2, body) $+ ] [4Leg Armor12 $return.equipped($2, legs) $+ ] [4Feet Armor12 $return.equipped($2, feet) $+ ] [4Hand Armor12 $return.equipped($2, hands) $+ ] ,2, $nick)
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your abilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!abilities*:*: {

  ; to be re-added later
  halt

  if ($2 = $null) { 
    var %active.abilities $character.abilities($nick, active)
    var %passive.abilities $character.abilities($nick, passive)
    $set_chr_name($nick)

  }
  else { $checkchar($2)
    var %active.abilities $character.abilities($2, active)
    var %passive.abilities $character.abilities($2, passive)
    $set_chr_name($2)
  }

  $display.message($translate(ActiveAbilities)) 
  if (%passive.abilities != $null) { $display.message($translate(PassiveAbilities)) }

  unset %real.name
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your spells
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!spells*:*: {

  if ($2 = $null) {
    $set_chr_name($nick)
    if ($resting.mp($nick) = 0) { $display.message($translate(Can'tCastSpells)) | unset %real.name | halt }


    ; to be readded later
    halt

    var %spells.white $character.spells($nick, white)
    var %spells.black $character.spells($nick, black)

    if ($current.job = NIN) { var %spells.ninja $character.spells($nick, ninja) }
    if ($current.job = BLU) { var %spells.black $character.spells($nick, blue) }
  }

  else { $checkchar($2)
    $set_chr_name($2)
    if ($resting.mp($2) = 0) { $display.message($translate(Can'tCastSpells)) | unset %real.name | halt }

    var %spells.white $character.spells($2, white)
    var %spells.black $character.spells($2, black)

    if ($current.job = NIN) { var %spells.ninja $character.spells($2, ninja) }
    if ($current.job = BLU) { var %spells.black $character.spells($2, blue) }
  }

  if (%spells.white != $null) { $display.message($translate(SpellsWhite)) }
  if (%spells.black != $null) { $display.message($translate(SpellsBlack)) }
  if (%spells.ninja != $null) { $display.message($translate(SpellsNinja)) }
  if (%spells.blue != $null) { $display.message($translate(SpellsBlue)) }

  unset %real.name
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your weapons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!weapons*:*: {
  unset %weapon.list
  if ($2 = $null) { $display.message($translate(NeedToSayWhichWeaponType, $nick), global) | halt }
  $weapons.list($nick, $2) | $readweapons($nick, channel, $2)  
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your armor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!armor*:#:{ 
  if ($2 = $null) { $display.message($translate(NeedToSayWhichArmor, $nick), global) | halt }
  $armor.list($nick, $2) | $readarmor($nick, channel, $2)  
}
on 2:TEXT:!armor*:?:{ 
  if ($2 = $null) { $display.private.message($translate(NeedToSayWhichArmor, $nick) | halt }
  $armor.list($nick, $2) | $readarmor($nick, private, $2)  
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; View your inventory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!items*:#:{ 
  ; To be re-added
  halt

  if ($2 != $null) { $checkchar($2) | $items.list($2) | $readitems($2, channel) }
  else {  $items.list($nick) | $readitems($nick, channel) }
}
on 2:TEXT:!inventory*:#:{ 
  ; to be re-added
  halt

  if ($2 != $null) { $checkchar($2) | $items.list($2) | $readitems($2, channel) }
  else {  $items.list($nick) | $readitems($nick, channel) }
}
on 2:TEXT:!spoils*:#:{ 
  ; to be re-added
  halt
  if ($3 != $null) { $checkchar($3) | $miscitems.list($3) | $readmiscitems($3, channel) }
  else {  $miscitems.list($nick) | $readmiscitems($nick, channel) }
}
on 2:TEXT:!spoils*:?:{ 
  ; to be re-added
  half
  if ($3 != $null) { $checkchar($3) | $miscitems.list($3) | $readmiscitems($3, private) }
  else {  $miscitems.list($nick) | $readmiscitems($nick, private) }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set your descriptions
; Also read descs of other players
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; !desc <person's name or [set character/whatever]> [description]

on 2:TEXT:!desc*:#: {  $checkscript($2-)
  if ($2 = $null) { $display.message(10 $+ $get_chr_name($nick)  $+ $readini($char($nick), Descriptions, Char),private) | halt }
  if ($2 = set) {

    if (($3 = character) || ($3 = char)) { writeini $char($nick) Descriptions Char $4- | $okdesc($nick , Character)  }
    if (($3 = abilitiy) || ($3 = skill)) { $display.message(Not implemented yet) }

    halt
  }

  ; Check someone else's desc
  $checkchar($2) |  $display.message(3 $+ $get_chr_name($2)  $+ $readini($char($2), Descriptions, Char), private) 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Equip command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; !equip weaponname
; !equip armor armorname
; !equip shield shieldname

on 2:TEXT:!equip *:*: { 
  if ($2 = armor) { $wear.armor($nick, $3) | halt }
  if ($2 = shield) { $wear.armor($nick, $3) | halt }

  if ((%adventureis = on) && ($adventure.alreadyinparty.check($nick) = true)) { $display.message($translate(CanOnlySwitchOutsideAdventure, $nick), private) | halt }

  ; Is the weapon already equipped?
  if ($2 = $return.equipped($nick, Weapon)) { $set_chr_name($nick) | $display.message($translate(WeaponAlreadyEquipped, $nick, $2), private) | unset %real.name | halt }

  ; Does the player own this weapon?
  if ($inventory.amount($nick, $2) < 1) { $set_chr_name($nick) | $display.message($translate(DoNotHaveWeapon, $nick) , private) | unset %real.name | halt }

  ; Is the player the correct level and job to use this weapon?
  var %jobs.list $readini($dbfile(weapons.db), $2, jobs)
  if (($istok(%jobs.list, $current.job($nick), 46) = $false) && (%jobs.list != all))  { $display.message($translate(WrongJobToEquip, $nick) , private) | halt }

  ; Is the player's level too low to equip this?
  if ($get.level($nick) < $readini($dbfile(weapons.db), $2, PlayerLevel)) { $display.message($translate(LevelTooLowToEquip, $nick) , private) | halt }

  $character.wieldweapon($nick, $2)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Unequip command
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; !unequip armor armorname
; !unequip shield shieldname
; !unequip weaponname

on 2:TEXT:!unequip *:*: { 

  if ($2 = armor) { $remove.armor($nick, $3) | halt }
  if ($2 = shield) { $remove.armor($nick, $3) | halt }

  ; Can only swap equipment outside of adventures
  if ((%adventureis = on) && ($adventure.alreadyinparty.check($nick) = true)) { $display.message($translate(CanOnlySwitchOutsideAdventure), private) | halt }

  ; We can hardly unequip our fists
  if ($2 = fists) { $set_chr_name($nick) | $display.message($translate(Can'tDetachHands),private) | halt }

  if ($return.equipped($nick, weapon) != $2) { $display.private.message($translate(WrongEquippedWeapon, $nick, $2)) | halt } 

  writeini $char($nick) equipment Weapon Fists 
  $display.message($translate(UnequipWeapon, $nick, $2),private) 
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rolls the dice
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
on 2:TEXT:!roll *:#: { 
  if (d !isin $2) { $display.private.message(4!roll #d#(+#)  - example: !roll 1d10 or !roll 1d6+3) | halt }
  $display.message(7* 2Result for $2 $+ : $roll($2),global)
}

on 2:TEXT:!roll *:?: { 
  if (d !isin $2) { $display.private.message(4!roll #d#(+#)  - example: !roll 1d10 or !roll 1d6+3) | halt }
  $display.private.message(7* 2Result for $2 $+ : $roll($2))
}
