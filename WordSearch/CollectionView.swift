//
//  CollectionView.swift
//  WordSearch
//
//  Created by Vatsan Prabhu on 2019-05-08.
//  Copyright © 2019 vatsan. All rights reserved.
//

import UIKit

//Protocol to use member functions
protocol CollectionViewProtocol {
	func getView() -> CollectionView
	func getCellAtPoint(point: CGPoint) -> CollectionViewCell!
	func getDirection(startingCell: CollectionViewCell, endingCell: CollectionViewCell) -> CGPoint!
	func updateTextColor(point1: CGPoint, point2: CGPoint)
}

//Class for custom collection views
class CollectionView: UICollectionView, CollectionViewProtocol {

	func getView() -> CollectionView {
		return self
	}
	
	//Get cell that is at any point on view
	func getCellAtPoint(point: CGPoint) -> CollectionViewCell! {
		let index = self.indexPathForItem(at: point)
		if (index != nil) {
			let cell = self.cellForItem(at: index!) as! CollectionViewCell
			
			return cell
		}
		return nil
	}
	
	//Get direction between 2 cells, also checks if 2 cells create valid line
	func getDirection(startingCell: CollectionViewCell, endingCell: CollectionViewCell) -> CGPoint! {
		if (startingCell == endingCell) {
			startingCell.label.textColor = UIColor.white
			return CGPoint(x: 0, y: 0)
		}
		else if (startingCell.x == endingCell.x) {
			if (startingCell.y < endingCell.y) {
				
				var y = startingCell.y!
				while y <= endingCell.y {
					let cell = self.cellForItem(at: IndexPath(row: startingCell.x*10 + y, section: 0)) as! CollectionViewCell
					cell.label.textColor = UIColor.white
					y += 1
				}
				return CGPoint(x: 0, y: 1)
			}
			var y = startingCell.y!
			while y >= endingCell.y {
				let cell = self.cellForItem(at: IndexPath(row: startingCell.x*10 + y, section: 0)) as! CollectionViewCell
				cell.label.textColor = UIColor.white
				y -= 1
			}
			return CGPoint(x: 0, y: -1)
		}
		else if (startingCell.y == endingCell.y) {
			if (startingCell.x < endingCell.x) {
				var x = startingCell.x!
				while x <= endingCell.x {
					let cell = self.cellForItem(at: IndexPath(row: x*10 + startingCell.y, section: 0)) as! CollectionViewCell
					cell.label.textColor = UIColor.white
					x += 1
				}
				return CGPoint(x: 1, y: 0)
			}
			var x = startingCell.x!
			while x <= endingCell.x {
				let cell = self.cellForItem(at: IndexPath(row: x*10 + startingCell.y, section: 0)) as! CollectionViewCell
				cell.label.textColor = UIColor.white
				x += 1
			}
			return CGPoint(x: -1, y: 0)
		}
		else if (abs(startingCell.x - endingCell.x) == abs(startingCell.y - endingCell.y)) {
			if (startingCell.x < endingCell.x && startingCell.y < endingCell.y) {
				var x = startingCell.x!
				var y = startingCell.y!
				while x <= endingCell.x && y <= endingCell.y {
					let cell = self.cellForItem(at: IndexPath(row: x*10 + y, section: 0)) as! CollectionViewCell
					cell.label.textColor = UIColor.white
					x += 1
					y += 1
				}
				return CGPoint(x: 1, y: 1)
			}
			else if (startingCell.x < endingCell.x && startingCell.y > endingCell.y) {
				var x = startingCell.x!
				var y = startingCell.y!
				while x <= endingCell.x && y >= endingCell.y {
					let cell = self.cellForItem(at: IndexPath(row: x*10 + y, section: 0)) as! CollectionViewCell
					cell.label.textColor = UIColor.white
					x += 1
					y -= 1
				}
				return CGPoint(x: 1, y: -1)
			}
			else if (startingCell.x > endingCell.x && startingCell.y > endingCell.y) {
				var x = startingCell.x!
				var y = startingCell.y!
				while x >= endingCell.x && y >= endingCell.y {
					let cell = self.cellForItem(at: IndexPath(row: x*10 + y, section: 0)) as! CollectionViewCell
					cell.label.textColor = UIColor.white
					x -= 1
					y -= 1
				}
				return CGPoint(x: -1, y: -1)
			}
			var x = startingCell.x!
			var y = startingCell.y!
			while x >= endingCell.x && y <= endingCell.y {
				let cell = self.cellForItem(at: IndexPath(row: x*10 + y, section: 0)) as! CollectionViewCell
				cell.label.textColor = UIColor.white
				x -= 1
				y += 1
			}
			return CGPoint(x: -1, y: 1)
		}
		return nil
	}

	//Update colour of text on game board
	func updateTextColor(point1: CGPoint, point2: CGPoint) {
		resetTextColor()
		
		let start = getCellAtPoint(point: point1)!
		let end = getCellAtPoint(point: point2)!
		let direction = getDirection(startingCell: start, endingCell: end)!
		
		var x = start.x!
		var y = start.y!
		
		let currentCell = cellForItem(at: IndexPath(row: x*10 + y, section: 0)) as! CollectionViewCell
		
		currentCell.label.textColor = UIColor.white
		
		while x != end.x || y != end.y {	//Iterate through current line
			x += Int(direction.x)
			y += Int(direction.y)
			
			let currentCell = cellForItem(at: IndexPath(row: x*10 + y, section: 0)) as! CollectionViewCell
			
			currentCell.label.textColor = UIColor.white
		}
	}
	
	//Reset all cells to black except confirmed words
	func resetTextColor() {
		for cell in self.visibleCells as! [CollectionViewCell] {			
			if cell.isInLine { cell.label.textColor = UIColor.white }
			else { cell.label.textColor = UIColor.black }
		}
	}
}
