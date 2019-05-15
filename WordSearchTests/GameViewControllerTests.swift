//
//  GameViewControllerTests.swift
//  WordSearchTests
//
//  Created by Vatsan Prabhu on 2019-05-15.
//  Copyright © 2019 vatsan. All rights reserved.
//

import XCTest
@testable import WordSearch

class GameViewControllerTests: XCTestCase {

	var controller: GameViewController!
	
	override func setUp() {
		super.setUp()
		
		controller = GameViewController()
	}
	
	func testBounds() {
		let direction: Direction = Direction(-1, 0)
		let word: String = "TEST"
		
		let bounds = controller.getBounds(direction: direction, word: word)
		
		XCTAssert(bounds == Bounds(xMin: 3, xMax: 10, yMin: 0, yMax: 10))
	}
	
	func testPlaceWord() {
		let word: String = "TEST"
		var grid: [[Character]] = [[Character]](repeating: [Character](repeating: "-", count: NUM_COLS), count: NUM_ROWS)
		
		var testWord: String = ""
		
		controller.placeWord(word: word, grid: &grid)
		
		for row in grid {
			for char in row {
				if char != "-" {
					testWord.append(char)
				}
			}
		}
		
		XCTAssert(testWord == word || String(testWord.reversed()) == word)
	}
	
	func testFillGrid() {
		var grid: [[Character]] = [[Character]](repeating: [Character](repeating: "-", count: NUM_COLS), count: NUM_ROWS)
		var success = true
		
		controller.fillGrid(grid: &grid)
		
		for row in grid {
			for char in row {
				if char == "-" {
					success = false
				}
			}
		}
		
		XCTAssert(success)
	}
}
