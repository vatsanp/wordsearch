//
//  CollectionViewCell.swift
//  WordSearch
//
//  Created by Vatsan Prabhu on 2019-05-06.
//  Copyright © 2019 vatsan. All rights reserved.
//

import UIKit

//Class for custom cells in collection view
class CollectionViewCell: UICollectionViewCell {
	
	var x: Int!
	var y: Int!
	var isInLine = false
	
	@IBOutlet var label: UILabel!
}
