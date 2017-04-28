ARDOLIA RPG BOT 
--------------

## ABOUT

Ardollia is a text game written in mIRC's scripting language.  This is a game of exploration where players will party up and go on adventures into dungeons, caverns and haunted forests. Their goal? Gain loot and fame while vanquishing evil monsters.

Once set up the game is entirely automatic and does not need anyone to run it.

A full in-depth guide with commands and more in-depth information will eventually be listed on this game's wiki.

Note: As of April 28, 2017 the game is still in heavy development and is not fully playable.


## SETUP

Getting it set up is easy.

 1. Clone this repository or download the ZIP.  If you download the zip, unzip it into a folder of your choice (I recommend C:\Ardolia)
 2. Run the mirc.exe that is included.
 3. The bot will attempt to help you get things set up.  Set the bot owner's nick and the IRC channel you wish to game in.  Be sure to set a password for the bot that you'll register to nickserv with.
 4. (as with all mIRC programs) change the nickname and add a server
 5. Connect.
 6. Using another IRC connection as the bot owner's nick, join the game channel you set and use !new char (race)  without the () to get the character creation process started.
 7. Follow what the bot tells you to do. 

Note, you do NOT have to install it to C:\Ardolia\ However, it's recommended to make life simple.

   
## WHAT'S NEW?

* APRIL 28, 2017

!new char (race) can now have human, elf, or galka

Basic stats added. Starting Stats are based on the race you pick and will be used for every level 1 job.

Lots of work done on viewing current and resting stats.

Started copying the FFXIV damage formula over to this game. It might not be 100% but it's close enough for what I need it for.

Battle system improved slightly.

Still a lot to do but it's chugging along.

* APRIL 27, 2017

As of right now only basic commands and systems have been added.  Players can create new characters (!new char human) to join the game, set new passwords (the bot will tell you how), start an adventure (!start adventure test), join other people's parties (!enter) and do basic adventure commands (!go, !look, !warp, !push/!pull/!read/!open).  The battle system is incredibly basic and players will only do 1 damage to monsters but it can be done with (/me attacks monstername or !attack monstername)

## TO-DO

In order to make this game fully playable there are still a huge amount of things to be done.  Before I can do any of those I first need to decide what system the game will be based on.  Deciding the system will determine what stats the characters use, how the battle system will be coded, what items/armor/weapons will be added, among many other things. Until the system is chosen this is about as far as the game will get except for maybe some minor code adjustments and finishing up a few of the commands (chests and tree chopping). 

## THANKS

These are people who have helped me by helping me test, making monsters/weapons/etc, finding bugs, or just by giving me some ideas.  This bot would not as good/far along as it is without these fine folks.

* Scott "Smz" of Esper.net

