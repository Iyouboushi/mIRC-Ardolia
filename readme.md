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

For older updates please read the versions.txt: https://github.com/Iyouboushi/mIRC-Ardolia/blob/master/Ardolia/documentation/versions.txt

* APRIL 29, 2017

With this update it is now possible to equip and unequip weapons and armor.  Players will now start with a basic tunic already equipped and their fists weapon. 

Also with this update comes more player commands.  !party will display a list of who's in the adventure party (if an adventure is currently going) and !view-info weapon weaponname will display information on a weapon. !weapons weapontype will show you what weapons of that type you own. !armor armortype will show you the armor you own of that type (for example use !armor body)

Rarity has been added weapons and armor. It can go from 1 to 5 with 1 being super common and 5 being legendary.

Armor will now return the proper defense/magic defense values.

And last, but not least, a bad bug that was erasing player files at the end of adventures should be fixed.

## TO-DO

In order to make this game fully playable there are still a huge amount of things to be done.  Up next will be fixing !look and adding help information to help players learn more about the game,  

## THANKS

These are people who have helped me by helping me test, making monsters/weapons/etc, finding bugs, or just by giving me some ideas.  This bot would not as good/far along as it is without these fine folks.

* Scott "Smz" of Esper.net

