//
//  EndViewController.swift
//  WordSearch
//
//  Created by Vatsan Prabhu on 2019-05-09.
//  Copyright © 2019 vatsan. All rights reserved.
//

import UIKit

class EndViewController: UIViewController {
	
	var gameWon: Bool!

	@IBOutlet var endMessageLabel: UILabel!
	@IBOutlet var restartButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		if gameWon {
			endMessageLabel.text = "Congratulations!"
		}
		else {
			endMessageLabel.text = "So Close! Try Again!"
		}
        // Do any additional setup after loading the view.
    }
	
	@IBAction func restartGame(_ sender: UIButton) {
		performSegue(withIdentifier: "restartSegue", sender: sender)
	}
	
}
