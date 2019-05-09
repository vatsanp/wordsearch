//
//  CollectionView.swift
//  WordSearch
//
//  Created by Vatsan Prabhu on 2019-05-08.
//  Copyright © 2019 vatsan. All rights reserved.
//

import UIKit

protocol GetDetailsProtocol {
	func getView() -> CollectionView
	func getCellAtPoint(point: CGPoint) -> CollectionViewCell!
	func getDirection(startingCell: CollectionViewCell, endingCell: CollectionViewCell) -> CGPoint!
}

class CollectionView: UICollectionView, GetDetailsProtocol {

	func getView() -> CollectionView {
		return self
	}
	
	func getCellAtPoint(point: CGPoint) -> CollectionViewCell! {
		let index = self.indexPathForItem(at: point)
		if (index != nil) {
			let cell = self.cellForItem(at: index!) as! CollectionViewCell
			
			return cell
		}
		return nil
	}
	
	func getDirection(startingCell: CollectionViewCell, endingCell: CollectionViewCell) -> CGPoint! {
		if (startingCell == endingCell) {
			return CGPoint(x: 0, y: 0)
		}
		else if (startingCell.x == endingCell.x) {
			if (startingCell.y < endingCell.y) {
				return CGPoint(x: 0, y: 1)
			}
			return CGPoint(x: 0, y: -1)
		}
		else if (startingCell.y == endingCell.y) {
			if (startingCell.x < endingCell.x) {
				return CGPoint(x: 1, y: 0)
			}
			return CGPoint(x: -1, y: 0)
		}
		else if (abs(startingCell.x - endingCell.x) == abs(startingCell.y - endingCell.y)) {
			if (startingCell.x < endingCell.x && startingCell.y < endingCell.y) {
				return CGPoint(x: 1, y: 1)
			}
			else if (startingCell.x < endingCell.x && startingCell.y > endingCell.y) {
				return CGPoint(x: 1, y: -1)
			}
			else if (startingCell.x > endingCell.x && startingCell.y > endingCell.y) {
				return CGPoint(x: -1, y: -1)
			}
			return CGPoint(x: -1, y: 1)
		}
		return nil
	}

}
