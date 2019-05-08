//
//  ViewController.swift
//  WordSeach
//
//  Created by Vatsan Prabhu on 2019-05-05.
//  Copyright © 2019 vatsan. All rights reserved.
//

import UIKit

let NUM_ROWS = 10, NUM_COLS = 10

struct Bounds {
	var xMin: Int = 0
	var xMax: Int = 10
	var yMin: Int = 0
	var yMax: Int = 10
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	
	var wordBank: [String] = ["ObjectiveC", "Variable", "Mobile", "Kotlin", "Swift", "Java"]
	var directions = [[1,0]: 0, [1,1]: 0, [0,1]: 0, [-1,1]: 0, [-1,0]: 0, [-1,-1]: 0, [0,-1]: 0, [1,-1]: 0]
	var grid: [[Character]] = []
	
	@IBOutlet var gridView: UICollectionView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		grid = [[Character]](repeating: [Character](repeating: "-", count: NUM_COLS), count: NUM_ROWS)
		
		for row in grid {
			print(row)
		}
		
		for word in wordBank {
			placeWord(word: word, grid: &grid)
			
			print("\n\n\(word)\n")
			for row in grid {
				print(row)
			}
		}
		
		fillGrid(grid: &grid)
		
		print("\n\n")
		for row in grid {
			print(String(row))
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return NUM_ROWS * NUM_COLS
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! CollectionViewCell
		
		cell.label.text = String(grid[indexPath.item/10][indexPath.item%10])
		
		return cell
	}
	
	func placeWord(word: String, grid: inout [[Character]]) {
		var direction: [Int]
		repeat {
			direction = directions.randomElement()!.key
		} while (directions[direction]! >= 2)
		
		for _ in 0..<(NUM_ROWS * NUM_COLS) {
			let bounds = getBounds(direction: direction, word: word)
			
			let xStart = Int.random(in: bounds.xMin..<bounds.xMax)
			let yStart = Int.random(in: bounds.yMin..<bounds.yMax)
			
			var x = xStart
			var y = yStart
			
			var success = true
			for letter in word {
				if (grid[x][y] != letter && grid[x][y] != "-") {
					success = false
				}
				x += direction[0]; y += direction[1]
			}
			if (success == false) { continue }
			
			x = xStart
			y = yStart
			
			for letter in word {
				grid[x][y] = letter
				x += direction[0]; y += direction[1]
			}
			
			let value = directions[direction]!
			directions.updateValue(value+1, forKey: direction)
			
			break
		}
		print(directions)
	}
	
	func getBounds(direction: [Int], word: String) -> Bounds {
		var bounds = Bounds()
		
		switch direction[0] {
		case 0:
			bounds.xMin = 0; bounds.xMax = NUM_ROWS
		case 1:
			bounds.xMin = 0; bounds.xMax = NUM_ROWS - (word.count-1)
		case -1:
			bounds.xMin = word.count-1; bounds.xMax = NUM_COLS
		default:
			bounds.xMin = 0; bounds.xMax = NUM_ROWS
		}
		switch direction[1] {
		case 0:
			bounds.yMin = 0; bounds.yMax = NUM_COLS
		case 1:
			bounds.yMin = 0; bounds.yMax = NUM_COLS - (word.count-1)
		case -1:
			bounds.yMin = word.count-1; bounds.yMax = NUM_COLS
		default:
			bounds.yMin = 0; bounds.yMax = NUM_COLS
		}
		
		return bounds
	}
	
	func fillGrid(grid: inout [[Character]]) {
		for i in 0..<NUM_ROWS {
			for j in 0..<NUM_COLS {
				if (grid[i][j] == "-") {
					let randChar = Character(UnicodeScalar(Int.random(in: 65..<91))!)
					grid[i][j] = randChar
				}
			}
		}
	}
}