//
//  ViewController.swift
//  WordSeach
//
//  Created by Vatsan Prabhu on 2019-05-05.
//  Copyright © 2019 vatsan. All rights reserved.
//

import UIKit
import AVFoundation

//––––––CONSTANTS–––––––
let NUM_ROWS = 10, NUM_COLS = 10

//–––––––STRUCTS and ENUMS––––––––
struct Bounds: Equatable {
	var xMin: Int = 0
	var xMax: Int = NUM_ROWS
	var yMin: Int = 0
	var yMax: Int = NUM_COLS
	
	static func == (lhs: Bounds, rhs: Bounds) -> Bool {
		return 	lhs.xMin == rhs.xMin &&
				lhs.xMax == rhs.xMax &&
				lhs.yMin == rhs.yMin &&
				lhs.yMax == rhs.yMax
	}
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

//Protocol to use member functions
protocol WordCheckProtocol {
	func checkWord(startingCell: CollectionViewCell, endingCell: CollectionViewCell, direction: CGPoint)
}

//View Controller for Game screen
class GameViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, WordCheckProtocol {
	
	//–––––VARIABLES AND OUTLETS–––––
	var wordBank: [String] = ["ObjectiveC", "Variable", "Mobile", "Kotlin", "Swift", "Java"]
	var optionalWords: [String] = ["Shopify", "Intern", "Innovate", "Create", "Imagine",
 "Data", "User", "Cloud"]
	var hiddenWord: String!
	var directions: [Direction: Int] = [	Direction(1,0): 0,
											Direction(1,1): 0,
											Direction(0,1): 0,
											Direction(-1,1): 0,
											Direction(-1,0): 0,
											Direction(-1,-1): 0,
											Direction(0,-1): 0,
											Direction(1,-1): 0]
	var grid: [[Character]] = []
	var wordsFound = 0
	var pointsHistory: [Int] = []
	var points = 0
	var timer = Timer()
	var seconds: Int!
	var gameWon = false
	
	let timerLayer = CAShapeLayer()				//Animated timer and progress layers
	let progressLayer = CAShapeLayer()
	let pulseTimerLayer = CAShapeLayer()
	let pulseProgressLayer = CAShapeLayer()
	
	let correctSound: SystemSoundID = 1114		//Game sounds
	let wrongSound: SystemSoundID = 1257
	
	var difficulty: Difficulty!
	var timerOn = false
	
	@IBOutlet var gridView: CollectionView!
	@IBOutlet var drawView: DrawView!
	@IBOutlet var wordBankView: CollectionView!
	@IBOutlet var pointsLabel: UILabel!
	@IBOutlet var timerLabel: UILabel!
	@IBOutlet var progressLabel: UILabel!
	@IBOutlet var timerView: UIView!
	@IBOutlet var progressView: UIView!
	@IBOutlet var startButton: UIButton!
	
	//–––––FUNCTIONS–––––
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let storage = UserDefaults.standard
		
		if timerOn {			//Set timer
			seconds = 120
			timerLabel.text = String(format: "%i:%02i", seconds/60, seconds%60)
			
			if let storedPoints = storage.array(forKey: "storedTimerPoints") {
				pointsHistory = (storedPoints as! [Int])
			}
		}
		else {
			seconds = 0
			timerLabel.text = "0"
			
			if let storedPoints = storage.array(forKey: "storedCasualPoints") {
				pointsHistory = (storedPoints as! [Int])
			}
		}
		
		initializeLayers()		//Configure animated layers
		timerLabel.layer.zPosition = 5
		progressLabel.layer.zPosition = 5
		
		drawView.layer.cornerRadius = 20	//Round corners of game board
		drawView.clipsToBounds = true
		
		startButton.layer.cornerRadius = 10	//Round corners of start button
		startButton.clipsToBounds = true
		
		grid = [[Character]](repeating: [Character](repeating: "-", count: NUM_COLS), count: NUM_ROWS)
		
		switch difficulty! {				//Use only certain directions if easy
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
		
		for _ in 0..<2 {					//Choose 2 random words to add to word bank
			let word = optionalWords.randomElement()!
			optionalWords.remove(at: optionalWords.firstIndex(of: word)!)
			wordBank.append(word)
		}
		
		hiddenWord = optionalWords.randomElement()!	//Choose hidden word
		print(hiddenWord!)
		
		wordBank.sort { $0.count > $1.count }		//Sort word bank on length descending
		print(wordBank)
		
		for i in 0..<wordBank.count {				//Uppercase all words
			wordBank[i] = wordBank[i].uppercased()
		}
		
		progressLabel.text = "\(wordsFound)/\(wordBank.count)"
		
		pointsLabel.text = "0"
		
		for word in wordBank {						//Place words in grid
			placeWord(word: word, grid: &grid)
		}
		
		placeWord(word: hiddenWord, grid: &grid)	//Place hidden word
		
		fillGrid(grid: &grid)						//Fill grid
		
		self.drawView.delegate1 = self
		self.drawView.delegate2 = gridView
	}
	
	@IBAction func startGame(_ sender: Any) {		//Show game board and start animations and timer
		startButton.isHidden = true
		gridView.isHidden = false
		drawView.isHidden = false
		timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(GameViewController.updateTimer)), userInfo: nil, repeats: true)
		animateTimerView()
		animatePulse()
	}
	
	@IBAction func backHome(_ sender: UIButton) {	//Segue to Are You Sure modal
		performSegue(withIdentifier: "areYouSureSegue", sender: nil)
	}
	
	public func getRows() -> Int { return NUM_ROWS }	//Get functions
	public func getCols() -> Int { return NUM_COLS }
	
	//Collection View Functions ––––– Each one checks wether data is for game grid or word bank
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if (collectionView == gridView) { return NUM_ROWS * NUM_COLS }
		else { return wordBank.count + 1}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if (collectionView == gridView) {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! CollectionViewCell
			
			cell.x = indexPath.item/NUM_ROWS
			cell.y = indexPath.item%NUM_ROWS
			cell.label.text = String(grid[cell.x][cell.y])
			
			return cell
		}
		else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordBankCell", for: indexPath) as! CollectionViewCell
			
			if (indexPath.item == wordBank.count) {
				cell.label.text = "?????"
			}
			else {
				cell.label.text = wordBank[indexPath.item]
			}
			print(cell.label.text!)
			return cell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if (collectionView == gridView) { return CGSize(width: 32.5, height: 32.5) }
		else { return CGSize(width: 100, height: 25) }
	}
	
	//Place word into grid
	func placeWord(word: String, grid: inout [[Character]]) {
		var direction: Direction
		var wordPlaced = false
		var count = 0
		while !wordPlaced {				//Keep trying until word is placed
			if difficulty == .easy {	//Choose direction
				repeat {
					direction = directions.randomElement()!.key
				} while (directions[direction]! >= 3)
			}
			else {
				repeat {
					direction = directions.randomElement()!.key
				} while (directions[direction]! >= 2)
			}
			
			for _ in 0..<20 {			//Try to place word in this direction 20 times
				count += 1
				let bounds = getBounds(direction: direction, word: word)
				
				let xStart = Int.random(in: bounds.xMin..<bounds.xMax)
				let yStart = Int.random(in: bounds.yMin..<bounds.yMax)
				
				var x = xStart
				var y = yStart
				
				var success = true
				for letter in word.uppercased() {	//Check if word can be placed
					print(letter)
					if (grid[x][y] != letter && grid[x][y] != "-") {
						success = false
					}
					x += direction.x; y += direction.y
				}
				if (success == false) { continue }	//If can't be placed, skip rest and move on
				wordPlaced = true
				
				x = xStart
				y = yStart
				
				for letter in word.uppercased() {	//Place word
					grid[x][y] = letter
					x += direction.x; y += direction.y
				}
				
				let value = directions[direction]!
				directions.updateValue(value+1, forKey: direction)
				
				break
			}
			if count >= 200 {
				wordBank.remove(at: wordBank.firstIndex(of: word)!)
				break
			}
		}
		print(directions)
		for row in grid {
			print(row)
		}
	}
	
	//Get bounds of where word can start to be placed
	func getBounds(direction: Direction, word: String) -> Bounds {
		var bounds = Bounds()
		
		switch direction.x {	//Get x bounds
		case 0:
			bounds.xMin = 0; bounds.xMax = NUM_ROWS
		case 1:
			bounds.xMin = 0; bounds.xMax = NUM_ROWS - (word.count-1)
		case -1:
			bounds.xMin = word.count-1; bounds.xMax = NUM_COLS
		default:
			bounds.xMin = 0; bounds.xMax = NUM_ROWS
		}
		switch direction.y {	//Get y bounds
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
	
	//Fill grid with random letters
	func fillGrid(grid: inout [[Character]]) {
		for i in 0..<NUM_ROWS {
			for j in 0..<NUM_COLS {
				if (grid[i][j] == "-") {				//Get random letter
					let randChar = Character(UnicodeScalar(Int.random(in: 65..<91))!)
					grid[i][j] = randChar
				}
			}
		}
	}
	
	//Check if word selected is correct
	func checkWord(startingCell: CollectionViewCell, endingCell: CollectionViewCell, direction: CGPoint) {
		var x = startingCell.x!
		var y = startingCell.y!
		
		var currentLetter = grid[x][y]
		var word = ""
		var cells: [CollectionViewCell] = []
		
		word.append(currentLetter)
		let cell = gridView.cellForItem(at: IndexPath(row: x*NUM_COLS + y, section: 0)) as! CollectionViewCell
		cells.append(cell)
		if direction != CGPoint(x: 0, y: 0) {
			while (x != endingCell.x || y != endingCell.y) {	//Gather letters
				x += Int(direction.x)
				y += Int(direction.y)
				currentLetter = grid[x][y]
				word.append(currentLetter)
				let cell = gridView.cellForItem(at: IndexPath(row: x*NUM_COLS + y, section: 0)) as! CollectionViewCell
				cells.append(cell)
			}
		}
		print(word)
		
		if wordBank.contains(word) || wordBank.contains(String(word.reversed())) {	//Check if word is correct
			if (wordBank.contains(String(word.reversed()))) {
				word = String(word.reversed())
			}
			drawView.finishedLines.append(drawView.currentLine!)	//Append current line
			for cell in cells {
				cell.isInLine = true
			}
			
			print("Correct")
			wordsFound += 1
			
			if timerOn { points += 20 * seconds }					//Update points
			else { points += max(200-seconds, 20) }
			pointsLabel.text = String(points)
			
			AudioServicesPlaySystemSound(correctSound)				//Play correct sound
			
			progressLabel.text = "\(wordsFound)/\(wordBank.count)"
			animateProgressView()
			
			let index = wordBank.firstIndex(of: word)!
			let cell = wordBankView.cellForItem(at: IndexPath(row: index, section: 0)) as! CollectionViewCell
			cell.label.isEnabled = false
		}
		else if word == hiddenWord.uppercased() || String(word.reversed()) == hiddenWord.uppercased() {			//Check if word is hidden word
			drawView.finishedLines.append(drawView.currentLine!)
			for cell in cells {
				cell.isInLine = true
			}
			
			print("Correct")
			points += 5000
			pointsLabel.text = String(points)						//Bonus points
			
			AudioServicesPlaySystemSound(correctSound)				//Play correct sound
			
			let cell = wordBankView.cellForItem(at: IndexPath(row: wordBank.count, section: 0)) as! CollectionViewCell
			cell.label.text = hiddenWord.uppercased()
			cell.label.isEnabled = false
		}
		else {
			drawView.currentLine = nil
			print("Wrong")
			AudioServicesPlaySystemSound(wrongSound)				//Play wrong sound
			gridView.resetTextColor()
		}
		
		if wordsFound == wordBank.count {							//If game is finished
			gameWon = true
			
			timer.invalidate()			//Stop timer
			let pausedTime = timerLayer.convertTime(CACurrentMediaTime(), from: nil)
			timerLayer.speed = 0.0
			timerLayer.timeOffset = pausedTime
			
			gridView.isUserInteractionEnabled = false
			
			let hiddenCell = wordBankView.cellForItem(at: IndexPath(row: wordBank.count, section: 0)) as! CollectionViewCell
			if hiddenCell.label.isEnabled == true {
				hiddenCell.label.text = hiddenWord.uppercased()		//Reveal hidden word
				
			}
			pointsHistory.append(points)
																	//Store points
			if timerOn { UserDefaults.standard.set(pointsHistory, forKey: "storedTimerPoints") }
			else { UserDefaults.standard.set(pointsHistory, forKey: "storedCasualPoints") }
			
			progressLayer.strokeColor = UIColor.green.cgColor
			pulseProgressLayer.fillColor = UIColor.green.cgColor
			DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {		//Segue to end screen
				self.performSegue(withIdentifier: "gameOverSegue", sender: nil)
			}
		}
	}
	
	@objc func updateTimer() {
		if timerOn {
			if seconds < 1 {		//Turn off timer if time runs out
				timer.invalidate()
				gameWon = false			//Segue to end screen
				performSegue(withIdentifier: "gameOverSegue", sender: nil)
			}
			else if seconds < 60 {	//Remove time format if below 60 seconds
				seconds -= 1
				timerLabel.text = String(seconds)
			}
			else {
				seconds -= 1
				timerLabel.text = String(format: "%i:%02i", seconds/60, seconds%60)
			}
		}
		else {
			if seconds < 60 {		//Remove time format if below 60 seconds
				seconds += 1
				timerLabel.text = String(seconds)
			}
			else if seconds >= 60 {
				seconds += 1
				timerLabel.text = String(format: "%i:%02i", seconds/60, seconds%60)
			}
		}
	}
	
	//Initialize animating timer/progress layers
	func initializeLayers() {
		let trackLayer1 = CAShapeLayer()
		let trackLayer2 = CAShapeLayer()
		
		let circularPath = UIBezierPath(arcCenter: .zero, radius: 50, startAngle: -CGFloat.pi/2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
		
		trackLayer1.path = circularPath.cgPath
		trackLayer2.path = circularPath.cgPath
		
		//Track layers for both time and progress
		trackLayer1.strokeColor = UIColor.lightGray.cgColor
		trackLayer2.strokeColor = UIColor.lightGray.cgColor
		trackLayer1.fillColor = UIColor.clear.cgColor
		trackLayer2.fillColor = UIColor.clear.cgColor
		trackLayer1.lineWidth = 5
		trackLayer2.lineWidth = 5
		trackLayer1.lineCap = CAShapeLayerLineCap.round
		trackLayer2.lineCap = CAShapeLayerLineCap.round
		trackLayer1.position = CGPoint(x: timerView.frame.width/2, y: timerView.frame.height/2)
		trackLayer2.position = CGPoint(x: progressView.frame.width/2, y: progressView.frame.height/2)
		
		//Time layer
		timerLayer.path = circularPath.cgPath
		timerLayer.strokeColor = UIColor.red.cgColor
		timerLayer.fillColor = UIColor.white.cgColor
		timerLayer.lineWidth = 10
		timerLayer.lineCap = CAShapeLayerLineCap.round
		timerLayer.strokeEnd = 0
		timerLayer.position = CGPoint(x: timerView.frame.width/2, y: timerView.frame.height/2)
		
		//Progress Layer
		progressLayer.path = circularPath.cgPath
		progressLayer.strokeColor = UIColor.blue.cgColor
		progressLayer.fillColor = UIColor.white.cgColor
		progressLayer.lineWidth = 10
		progressLayer.lineCap = CAShapeLayerLineCap.round
		progressLayer.strokeEnd = 0
		progressLayer.position = CGPoint(x: progressView.frame.width/2, y: progressView.frame.height/2)
		
		//Animating Pulse Layer for Timer
		pulseTimerLayer.path = UIBezierPath(arcCenter: .zero, radius: 50, startAngle: -CGFloat.pi/2, endAngle: 1.5 * CGFloat.pi, clockwise: true).cgPath
		pulseTimerLayer.strokeColor = UIColor.clear.cgColor
		pulseTimerLayer.fillColor = UIColor.red.cgColor
		pulseTimerLayer.opacity = 0.5
		pulseTimerLayer.lineWidth = 10
		pulseTimerLayer.lineCap = CAShapeLayerLineCap.round
		pulseTimerLayer.position = CGPoint(x: timerView.frame.width/2, y: timerView.frame.height/2)
		
		//Animating Pulse Layer for Progress
		pulseProgressLayer.path = UIBezierPath(arcCenter: .zero, radius: 50, startAngle: -CGFloat.pi/2, endAngle: 1.5 * CGFloat.pi, clockwise: true).cgPath
		pulseProgressLayer.strokeColor = UIColor.clear.cgColor
		pulseProgressLayer.fillColor = UIColor.blue.cgColor
		pulseProgressLayer.opacity = 0.5
		pulseProgressLayer.lineWidth = 10
		pulseProgressLayer.lineCap = CAShapeLayerLineCap.round
		pulseProgressLayer.position = CGPoint(x: progressView.frame.width/2, y: progressView.frame.height/2)
		
		
		timerView.layer.addSublayer(pulseTimerLayer)
		timerView.layer.addSublayer(trackLayer1)
		timerView.layer.addSublayer(timerLayer)
		
		progressView.layer.addSublayer(pulseProgressLayer)
		progressView.layer.addSublayer(trackLayer2)
		progressView.layer.addSublayer(progressLayer)
		
		animatePulse()		//Start animating
	}
	
	//Animation for Timer Layer
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
			let timerAnimation = CABasicAnimation(keyPath: "strokeEnd")
		
			timerAnimation.toValue = 1
			timerAnimation.duration = 60
			timerAnimation.repeatCount = Float.infinity
		
			timerAnimation.fillMode = CAMediaTimingFillMode.forwards
			timerAnimation.isRemovedOnCompletion = false
		
			timerLayer.add(timerAnimation, forKey: "timerAnimation")
		}
	}
	
	//Animation for Progress Layer
	func animateProgressView() {
		let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
		
		progressAnimation.fromValue = (Float(wordsFound-1)) / Float(wordBank.count)
		progressAnimation.toValue = Float(wordsFound) / Float(wordBank.count)
		progressAnimation.duration = 1

		progressAnimation.fillMode = CAMediaTimingFillMode.forwards
		progressAnimation.isRemovedOnCompletion = false
		
		progressLayer.add(progressAnimation, forKey: "progressAnimation")
	}
	
	//Animation for pulsing for Timer/Progress Layers
	func animatePulse() {
		let animation = CABasicAnimation(keyPath: "transform.scale")
		
		animation.toValue = 1.3
		animation.duration = 0.5
		animation.autoreverses = true
		animation.repeatCount = Float.infinity
		
		pulseProgressLayer.add(animation, forKey: "pulsingProgress")
		pulseTimerLayer.add(animation, forKey: "pulsingTimer")
	}
	
	//Prepare for endgame
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination as? EndViewController != nil {
			let destinationVC = segue.destination as! EndViewController
			if (segue.identifier == "gameOverSegue") {
				destinationVC.gameWon = gameWon
				destinationVC.pointsHistory = pointsHistory
				destinationVC.points = points
			}
		}
	}
}
