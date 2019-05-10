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

struct Direction: Hashable {
	let x: Int
	let y: Int
	
	init(_ xParam: Int, _ yParam: Int) {
		x = xParam
		y = yParam
	}
}

enum Difficulty {
	case easy
	case hard
}

protocol WordCheckProtocol {
	func checkWord(startingCell: CollectionViewCell, endingCell: CollectionViewCell, direction: CGPoint)
}

class GameViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, WordCheckProtocol {
	
	var wordBank: [String] = ["ObjectiveC", "Variable", "Mobile", "Kotlin", "Swift", "Java"]
	var directions: [Direction: Int]!
	var grid: [[Character]] = []
	var wordsFound = 0
	
	var difficulty: Difficulty!
	var timerOn = false
	
	@IBOutlet var gridView: CollectionView!
	@IBOutlet var drawView: DrawView!
	@IBOutlet var wordBankView: CollectionView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		grid = [[Character]](repeating: [Character](repeating: "-", count: NUM_COLS), count: NUM_ROWS)
		
		switch difficulty! {
		case .easy:
			directions = [	Direction(1,0): 0,
							  Direction(0,1): 0,
							  Direction(-1,0): 0,
							  Direction(0,-1): 0]
		case .hard:
			directions = [	Direction(1,0): 0,
							  Direction(1,1): 0,
							  Direction(0,1): 0,
							  Direction(-1,1): 0,
							  Direction(-1,0): 0,
							  Direction(-1,-1): 0,
							  Direction(0,-1): 0,
							  Direction(1,-1): 0]
		}
		
		for word in wordBank {
			placeWord(word: word, grid: &grid)
		}
		
		fillGrid(grid: &grid)
		
		self.drawView.delegate1 = self
		self.drawView.delegate2 = gridView
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if (collectionView == gridView) { return NUM_ROWS * NUM_COLS }
		else { return wordBank.count }
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if (collectionView == gridView) {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! CollectionViewCell
			
			cell.x = indexPath.item/10
			cell.y = indexPath.item%10
			cell.label.text = String(grid[cell.x][cell.y])
			
			return cell
		}
		else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordBankCell", for: indexPath) as! CollectionViewCell
			
			cell.label.text = wordBank[indexPath.item]
			print(cell.label.text!)
			return cell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if (collectionView == gridView) { return CGSize(width: 35, height: 35) }
		else { return CGSize(width: 100, height: 35) }
	}
	
	func placeWord(word: String, grid: inout [[Character]]) {
		var direction: Direction
		var wordPlaced = false
		while !wordPlaced {
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
					x += direction.x; y += direction.y
				}
				if (success == false) { continue }
				wordPlaced = true
				
				x = xStart
				y = yStart
				
				for letter in word {
					grid[x][y] = letter
					x += direction.x; y += direction.y
				}
				
				let value = directions[direction]!
				directions.updateValue(value+1, forKey: direction)
				
				break
			}
		}
		print(directions!)
	}
	
	func getBounds(direction: Direction, word: String) -> Bounds {
		var bounds = Bounds()
		
		switch direction.x {
		case 0:
			bounds.xMin = 0; bounds.xMax = NUM_ROWS
		case 1:
			bounds.xMin = 0; bounds.xMax = NUM_ROWS - (word.count-1)
		case -1:
			bounds.xMin = word.count-1; bounds.xMax = NUM_COLS
		default:
			bounds.xMin = 0; bounds.xMax = NUM_ROWS
		}
		switch direction.y {
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
	
	func checkWord(startingCell: CollectionViewCell, endingCell: CollectionViewCell, direction: CGPoint) {
		var x = startingCell.x!
		var y = startingCell.y!
		
		var currentLetter = grid[x][y]
		var word = ""
		
		word.append(currentLetter)
		if direction != CGPoint(x: 0, y: 0) {
			while (x != endingCell.x || y != endingCell.y) {
				x += Int(direction.x)
				y += Int(direction.y)
				currentLetter = grid[x][y]
				word.append(currentLetter)
			}
		}
		print(word)
		
		if wordBank.contains(word) || wordBank.contains(String(word.reversed())){
			drawView.finishedLines.append(drawView.currentLine!)
			print("Correct")
			wordsFound += 1
			print(wordBankView)
			print(wordBank.firstIndex(of: word)!)
			print(wordBankView.visibleCells.count)
			let c = wordBankView.cellForItem(at: IndexPath(row: wordBank.firstIndex(of: word)!, section: 0)) as! CollectionViewCell
			c.label.isHidden = true
		}
		else {
			drawView.currentLine = nil
			print("Wrong")
		}
		
		if wordsFound == wordBank.count {
			performSegue(withIdentifier: "gameOverSegue", sender: nil)
		}
	}
}
