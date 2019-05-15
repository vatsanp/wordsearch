//
//  EndViewController.swift
//  WordSearch
//
//  Created by Vatsan Prabhu on 2019-05-09.
//  Copyright © 2019 vatsan. All rights reserved.
//

import UIKit
import AVFoundation

//View Controller for End screen
class EndViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//–––––VARIABLES AND OUTLETS–––––
	var gameWon: Bool!
	var points: Int!
	var pointsHistory: [Int]!
	var timerOn: Bool!
	
	let successSound: SystemSoundID = 1005
	let failSound: SystemSoundID = 1006

	@IBOutlet var endMessageLabel: UILabel!
	@IBOutlet var finalScoreLabel: UILabel!
	@IBOutlet var restartButton: UIButton!
	@IBOutlet var leaderboardTableView: UITableView!
	
	//–––––FUNCTIONS–––––
	override func viewDidLoad() {
        super.viewDidLoad()
		
		restartButton.clipsToBounds = true		//Round corners or restart button
		restartButton.layer.cornerRadius = 10
		
		pointsHistory.sort()					//Sort points
		pointsHistory.reverse()
		
		leaderboardTableView.reloadData()

		if gameWon {							//Display screen based on win or lose
			endMessageLabel.text = "Congratulations!"
			AudioServicesPlaySystemSound(successSound)
		}
		else {
			endMessageLabel.text = "So Close! Try Again!"
			AudioServicesPlaySystemSound(failSound)
		}
		finalScoreLabel.text = "You scored \(points!) points!"
    }
	
	//Segue back to home screen
	@IBAction func restartGame(_ sender: UIButton) {
		performSegue(withIdentifier: "restartSegue", sender: sender)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return pointsHistory.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = leaderboardTableView.dequeueReusableCell(withIdentifier: "leaderboardCell", for: indexPath) as! TableViewCell

		cell.scoreLabel.text = "\(indexPath.row + 1) )    \(pointsHistory[indexPath.row])"

		return cell
	}
}
