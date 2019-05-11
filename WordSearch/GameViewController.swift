//
//  ViewController.swift
//  WordSeach
//
//  Created by Vatsan Prabhu on 2019-05-05.
//  Copyright © 2019 vatsan. All rights reserved.
//

import UIKit
import AVFoundation

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
	var timer = Timer()
	var seconds: Int!
	var gameWon = false
	
	let timerLayer = CAShapeLayer()
	let progressLayer = CAShapeLayer()
	let pulseTimerLayer = CAShapeLayer()
	let pulseProgressLayer = CAShapeLayer()
	
	let correctSound: SystemSoundID = 1114
	let wrongSound: SystemSoundID = 1257
	
	var difficulty: Difficulty!
	var timerOn = false
	
	@IBOutlet var gridView: CollectionView!
	@IBOutlet var drawView: DrawView!
	@IBOutlet var wordBankView: CollectionView!
	@IBOutlet var timerLabel: UILabel!
	@IBOutlet var progressLabel: UILabel!
	@IBOutlet var timerView: UIView!
	@IBOutlet var progressView: UIView!
	@IBOutlet var startButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initializeLayers()
		timerLabel.layer.zPosition = 5
		progressLabel.layer.zPosition = 5
		
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
		
		if timerOn {
			seconds = 120
			timerLabel.text = String(format: "%i:%02i", seconds/60, seconds%60)
		}
		else {
			seconds = 0
			timerLabel.text = "0"
		}
		
		progressLabel.text = "\(wordsFound)/\(wordBank.count)"
		
		for word in wordBank {
			placeWord(word: word, grid: &grid)
		}
		
		fillGrid(grid: &grid)
		
		self.drawView.delegate1 = self
		self.drawView.delegate2 = gridView
	}
	
	@IBAction func startGame(_ sender: Any) {
		startButton.isHidden = true
		gridView.isHidden = false
		drawView.isHidden = false
		timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(GameViewController.updateTimer)), userInfo: nil, repeats: true)
		animateTimerView()
		animatePulse()
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
		
		if wordBank.contains(word) || wordBank.contains(String(word.reversed())) {
			if (wordBank.contains(String(word.reversed()))) {
				word = String(word.reversed())
			}
			drawView.finishedLines.append(drawView.currentLine!)
			print("Correct")
			wordsFound += 1
			AudioServicesPlaySystemSound(correctSound)
			progressLabel.text = "\(wordsFound)/\(wordBank.count)"
			animateProgressView()
			let index = wordBank.firstIndex(of: word)!
			let cell = wordBankView.cellForItem(at: IndexPath(row: index, section: 0)) as! CollectionViewCell
			cell.label.isHidden = true
		}
		else {
			drawView.currentLine = nil
			print("Wrong")
			AudioServicesPlaySystemSound(wrongSound)
		}
		
		if wordsFound == wordBank.count {
			gameWon = true
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
				self.performSegue(withIdentifier: "gameOverSegue", sender: nil)
			}
		}
	}
	
	@objc func updateTimer() {
		if timerOn {
			if seconds < 1 {
				timer.invalidate()
				gameWon = false
				performSegue(withIdentifier: "gameOverSegue", sender: nil)
			}
			else if seconds < 60 {
				seconds -= 1
				timerLabel.text = String(seconds)
			}
			else {
				seconds -= 1     //This will decrement(count down)the seconds.
				timerLabel.text = String(format: "%i:%02i", seconds/60, seconds%60) //This will update the label.
			}
		}
		else {
			if seconds < 60 {
				seconds += 1
				timerLabel.text = String(seconds)
			}
			else if seconds % 60 == 0 {
				seconds += 1
				timerLabel.text = String(format: "%i:%02i", seconds/60, seconds%60)
				timerLayer.removeAllAnimations()
				animateTimerView()
			}
			else if seconds > 60 {
				seconds += 1
				timerLabel.text = String(format: "%i:%02i", seconds/60, seconds%60)
			}
		}
	}
	
	func initializeLayers() {
		let trackLayer1 = CAShapeLayer()
		let trackLayer2 = CAShapeLayer()
		
		let center = timerView.center
		let circularPath = UIBezierPath(arcCenter: center, radius: 50, startAngle: -CGFloat.pi/2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
		
		trackLayer1.path = circularPath.cgPath
		trackLayer2.path = circularPath.cgPath
		
		trackLayer1.strokeColor = UIColor.lightGray.cgColor
		trackLayer2.strokeColor = UIColor.lightGray.cgColor
		trackLayer1.fillColor = UIColor.clear.cgColor
		trackLayer2.fillColor = UIColor.clear.cgColor
		trackLayer1.lineWidth = 5
		trackLayer2.lineWidth = 5
		trackLayer1.lineCap = CAShapeLayerLineCap.round
		trackLayer2.lineCap = CAShapeLayerLineCap.round
		
		timerLayer.path = circularPath.cgPath
		timerLayer.strokeColor = UIColor.red.cgColor
		timerLayer.fillColor = UIColor.white.cgColor
		timerLayer.lineWidth = 10
		timerLayer.lineCap = CAShapeLayerLineCap.round
		timerLayer.strokeEnd = 0
		
		progressLayer.path = circularPath.cgPath
		progressLayer.strokeColor = UIColor.blue.cgColor
		progressLayer.fillColor = UIColor.white.cgColor
		progressLayer.lineWidth = 10
		progressLayer.lineCap = CAShapeLayerLineCap.round
		progressLayer.strokeEnd = 0
		
		pulseTimerLayer.path = UIBezierPath(arcCenter: .zero, radius: 50, startAngle: -CGFloat.pi/2, endAngle: 1.5 * CGFloat.pi, clockwise: true).cgPath
		pulseTimerLayer.strokeColor = UIColor.clear.cgColor
		pulseTimerLayer.fillColor = UIColor.red.cgColor
		pulseTimerLayer.opacity = 0.2
		pulseTimerLayer.lineWidth = 10
		pulseTimerLayer.lineCap = CAShapeLayerLineCap.round
		pulseTimerLayer.position = CGPoint(x: timerView.frame.width/2, y: timerView.frame.height/2)
		
		pulseProgressLayer.path = UIBezierPath(arcCenter: .zero, radius: 50, startAngle: -CGFloat.pi/2, endAngle: 1.5 * CGFloat.pi, clockwise: true).cgPath
		pulseProgressLayer.strokeColor = UIColor.clear.cgColor
		pulseProgressLayer.fillColor = UIColor.blue.cgColor
		pulseProgressLayer.opacity = 0.2
		pulseProgressLayer.lineWidth = 10
		pulseProgressLayer.lineCap = CAShapeLayerLineCap.round
		pulseProgressLayer.position = CGPoint(x: progressView.frame.width/2, y: progressView.frame.height/2)
		
		
		timerView.layer.addSublayer(pulseTimerLayer)
		timerView.layer.addSublayer(trackLayer1)
		timerView.layer.addSublayer(timerLayer)
		
		progressView.layer.addSublayer(pulseProgressLayer)
		progressView.layer.addSublayer(trackLayer2)
		progressView.layer.addSublayer(progressLayer)
		
		animatePulse()
	}
	
	func animateTimerView() {
		if timerOn {
			let timerAnimation = CABasicAnimation(keyPath: "strokeEnd")
		
			timerAnimation.toValue = 1
			timerAnimation.duration = CFTimeInterval(seconds)
			
			timerAnimation.fillMode = CAMediaTimingFillMode.forwards
			timerAnimation.isRemovedOnCompletion = false
			
			timerLayer.add(timerAnimation, forKey: "timerAnimation")
		}
		else {
			print("TEST1")
			let timerAnimation = CABasicAnimation(keyPath: "strokeEnd")
		
			timerAnimation.toValue = 1
			timerAnimation.duration = 60
			timerAnimation.repeatCount = Float.infinity
		
			timerAnimation.fillMode = CAMediaTimingFillMode.forwards
			timerAnimation.isRemovedOnCompletion = false
		
			timerLayer.add(timerAnimation, forKey: "timerAnimation")
		}
	}
	
	func animateProgressView() {
		let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
		
		progressAnimation.fromValue = (Float(wordsFound-1)) / Float(wordBank.count)
		progressAnimation.toValue = Float(wordsFound) / Float(wordBank.count)
		progressAnimation.duration = 1

		progressAnimation.fillMode = CAMediaTimingFillMode.forwards
		progressAnimation.isRemovedOnCompletion = false
		
		progressLayer.add(progressAnimation, forKey: "progressAnimation")
	}
	
	func animatePulse() {
		let animation = CABasicAnimation(keyPath: "transform.scale")
		
		animation.toValue = 1.3
		animation.duration = 0.5
		animation.autoreverses = true
		animation.repeatCount = Float.infinity
		
		pulseProgressLayer.add(animation, forKey: "pulsingProgress")
		pulseTimerLayer.add(animation, forKey: "pulsingTimer")
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destinationVC = segue.destination as! EndViewController
		
		if (segue.identifier == "gameOverSegue") {
			destinationVC.gameWon = gameWon
		}
	}
}
