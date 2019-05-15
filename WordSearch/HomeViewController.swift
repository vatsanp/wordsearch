//
//  HomeViewController.swift
//  WordSearch
//
//  Created by Vatsan Prabhu on 2019-05-09.
//  Copyright © 2019 vatsan. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

	@IBOutlet var timerSwitch: UISwitch!
	@IBOutlet var easyButton: UIButton!
	@IBOutlet var hardButton: UIButton!
	@IBOutlet var aboutButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		easyButton.clipsToBounds = true
		easyButton.layer.cornerRadius = 10
		hardButton.clipsToBounds = true
		hardButton.layer.cornerRadius = 10
		aboutButton.clipsToBounds = true
		aboutButton.layer.cornerRadius = 10
		// Do any additional setup after loading the view.
	}
	
	@IBAction func startGame(_ sender: UIButton) {
		performSegue(withIdentifier: "startGameSegue", sender: sender)
	}
	
	@IBAction func aboutMe(_ sender: UIButton) {
		performSegue(withIdentifier: "aboutMeSegue", sender: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination as? GameViewController != nil {
			let destinationVC = segue.destination as! GameViewController
			let button = sender as! UIButton
			
			if (segue.identifier == "startGameSegue") {
				switch button {
				case easyButton:
					destinationVC.difficulty = .easy
				case hardButton:
					destinationVC.difficulty = .hard
				default:
					destinationVC.difficulty = .hard
				}
				destinationVC.timerOn = timerSwitch.isOn
			}
		}
	}

}
