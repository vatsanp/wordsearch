//
//  EndViewController.swift
//  WordSearch
//
//  Created by Vatsan Prabhu on 2019-05-09.
//  Copyright © 2019 vatsan. All rights reserved.
//

import UIKit
import AVFoundation

class EndViewController: UIViewController {
	
	var gameWon: Bool!
	
	let successSound: SystemSoundID = 1005
	let failSound: SystemSoundID = 1006

	@IBOutlet var endMessageLabel: UILabel!
	@IBOutlet var restartButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		if gameWon {
			endMessageLabel.text = "Congratulations!"
			AudioServicesPlaySystemSound(successSound)
		}
		else {
			endMessageLabel.text = "So Close! Try Again!"
			AudioServicesPlaySystemSound(failSound)
			
		}
        // Do any additional setup after loading the view.
    }
	
	@IBAction func restartGame(_ sender: UIButton) {
		performSegue(withIdentifier: "restartSegue", sender: sender)
	}
	
}
