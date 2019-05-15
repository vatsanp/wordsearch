//
//  BackViewController.swift
//  WordSearch
//
//  Created by Vatsan Prabhu on 2019-05-14.
//  Copyright © 2019 vatsan. All rights reserved.
//

import UIKit

//View Controller for 'Are You Sure' screen
class BackViewController: UIViewController {

	//–––––VARIABLES AND OUTLETS–––––
	@IBOutlet var modalView: UIView!
	@IBOutlet var cancelButton: UIButton!
	@IBOutlet var exitButton: UIButton!
	
	//–––––FUNCTIONS–––––
	override func viewDidLoad() {
        super.viewDidLoad()

		modalView.clipsToBounds = true		//Round the corners of modalView
		modalView.layer.cornerRadius = 20
	}
    //Dismiss Modal Segue
	@IBAction func cancel(_ sender: UIButton) {
		dismiss(animated: true) {}
	}
	//Segue Back to Home
	@IBAction func exit(_ sender: UIButton) {
		let parentVC = self.presentingViewController as! GameViewController
		parentVC.timer.invalidate()
		let pausedTime = parentVC.timerLayer.convertTime(CACurrentMediaTime(), from: nil)
		parentVC.timerLayer.speed = 0.0
		parentVC.timerLayer.timeOffset = pausedTime
		performSegue(withIdentifier: "backHomeSegue", sender: nil)
	}
	

}
