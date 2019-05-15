//
//  BackViewController.swift
//  WordSearch
//
//  Created by Vatsan Prabhu on 2019-05-14.
//  Copyright © 2019 vatsan. All rights reserved.
//

import UIKit

class BackViewController: UIViewController {

	@IBOutlet var modalView: UIView!
	@IBOutlet var cancelButton: UIButton!
	@IBOutlet var exitButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		modalView.clipsToBounds = true
		modalView.layer.cornerRadius = 20
	}
    
	@IBAction func cancel(_ sender: UIButton) {
		dismiss(animated: true) {}
	}
	
	@IBAction func exit(_ sender: UIButton) {
		performSegue(withIdentifier: "backHomeSegue", sender: nil)
	}
	

}
