//
//  ModalViewController.swift
//  WordSearch
//
//  Created by Vatsan Prabhu on 2019-05-14.
//  Copyright © 2019 vatsan. All rights reserved.
//

import UIKit

//View Controller for 'About Me' screen
class ModalViewController: UIViewController {
	
	//–––––VARIABLES AND OUTLETS–––––
	@IBOutlet weak var modalView: UIView!
	
	//–––––FUNCTIONS–––––
	//Function for when view controller first loads
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//Round the corners of the modal view
		modalView.layer.cornerRadius = 10
		modalView.layer.masksToBounds = true
	}
	
	@IBAction func dismiss(_ sender: UIButton) {
		dismiss(animated: true) {}
	}
}
