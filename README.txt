Shopify Mobile Developer Intern Challenge (iOS)

Program:	Collections and Products list
Author:		Vatsan Prabhu
Date:		15–MAY–2019

Purpose:	To create a WordSearch game where the user can swipe over words to select and play.

Run:		Launch XCode project, connect iOS device and build and run onto device
Use:		User will first be given a main menu where they can either select 'Easy' or 			'Hard' buttons to start the game in the given difficulty, choose to play 			with a countdown timer or not by using a switch, or click an 'About Me' 			button.
			Clicking 'About Me' will give the user a modal popup with a short message about the author. Switching the timer on will set a countdown timer of 2 minutes for the user to complete the game. Otherwise the game will have a timer counting up. If the user clicks 'Easy' the game will load with words going only in 4 directions: Up, Right, Left, and Down. If the user clicks 'Hard', the game will load with the words being able to be arranged in the 4 'Easy' directions as well as the 4 diagonal directions.
			Once in the game, the user is presented with a start button and once clicked, the game will begin and the timer will then start (if on). There is also a back button if the user wishes to leave the game. If clicked, the user is given a chance to stay in the game by being shown a modal explaining that their current score will not be saved if exited.
			During the game every time the user finds a word, points are awarded. The game will have a hidden bonus word and when found, bonus points are awarded.
			Omce the timer runs out or all words are found, the app then moves on to the ending screen where a final message is shown along with a leaderboard of top scores and a restart button if the user wishes to play again.

Future Improvements:
			Side slide out menu where more options are given to user (home, sign in, leaderboard, stats, etc.)
			More animations
				Animation when word is found
				Animation when word is incorrect
				Better viwe transition animations - custom segues
			Better sound effects
			
