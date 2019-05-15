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
	override func viewDidLoad() {
		super.viewDidLoad()
		
		modalView.layer.cornerRadius = 10		//Round the corners of modalView
		modalView.layer.masksToBounds = true
	}
	//Dismiss Modal Segue
	@IBAction func dismiss(_ sender: UIButton) {
		dismiss(animated: true) {}
	}
}
