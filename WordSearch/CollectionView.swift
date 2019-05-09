//
//  CollectionView.swift
//  WordSearch
//
//  Created by Vatsan Prabhu on 2019-05-08.
//  Copyright © 2019 vatsan. All rights reserved.
//

import UIKit

class CollectionView: UICollectionView {

	func getCellAtPoint(point: CGPoint) -> CollectionViewCell! {
		let index = self.indexPathForItem(at: point)
		if (index != nil) {
			let cell = self.cellForItem(at: index!) as! CollectionViewCell
			
			return cell
		}
		return nil
	}
	
	func getDirection(startingCell: CollectionViewCell, endingCell: CollectionViewCell) -> [Int]! {
		if (startingCell == endingCell) {
			return [0, 0]
		}
		else if (startingCell.x == endingCell.x) {
			if (startingCell.y < endingCell.y) {
				return [0, 1]
			}
			return [0, -1]
		}
		else if (startingCell.y == endingCell.y) {
			if (startingCell.x < endingCell.x) {
				return [1, 0]
			}
			return [-1, 0]
		}
		else if (abs(startingCell.x - endingCell.x) == abs(startingCell.y - endingCell.y)) {
			if (startingCell.x < endingCell.x && startingCell.y < endingCell.y) {
				return [1, 1]
			}
			else if (startingCell.x < endingCell.x && startingCell.y > endingCell.y) {
				return [1, -1]
			}
			else if (startingCell.x > endingCell.x && startingCell.y > endingCell.y) {
				return [-1, -1]
			}
			return [-1, 1]
		}
		return nil
	}

}
