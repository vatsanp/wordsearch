//
//  DrawView.swift
//  WordSearch
//
//  Created by Vatsan Prabhu on 2019-05-07.
//  Copyright © 2019 vatsan. All rights reserved.
//

import UIKit
import Foundation
import CoreGraphics
import AVFoundation

//Struct to draw lines
struct Line {
	var begin = CGPoint.zero
	var end = CGPoint.zero
	var colour = UIColor.blue
}

//Class to draw lines on behind game board
class DrawView: UIView {

	//––––––VARIABLES––––––––
	var delegate1: WordCheckProtocol?
	var delegate2: CollectionViewProtocol?
	
	var currentLine: Line?
	var finishedLines = [Line]()
	var currentDirection: CGPoint!
	
	let strokeColours: [UIColor] = [UIColor.blue, UIColor.red, UIColor.purple, UIColor.orange, UIColor.black]		//Line colours
	var currentColour = UIColor.blue
	
	let generator = UIImpactFeedbackGenerator(style: .light)	//Haptic
	let tapSound: SystemSoundID = 1104							//Sound
	
	//Draw line
	func strokeLine(line: Line){
		//Use BezierPath to draw lines
		let path = UIBezierPath()
		path.lineWidth = 20
		path.lineCapStyle = CGLineCap.round
		
		line.colour.setStroke()
		
		path.move(to: line.begin)
		path.addLine(to: line.end)
		path.stroke() //Draw the path
	}
	
	override func draw(_ rect: CGRect) {
		for line in finishedLines{
			strokeColours.randomElement()!.setStroke()
			strokeLine(line: line)
		}
		//draw current line if it exists
		if let line = currentLine {
			strokeLine(line: line)
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print(#function) //for debugging
		let touch = touches.first!
		let location = touch.location(in: self)
		
		generator.prepare()
		currentColour = strokeColours.randomElement()!	//Pick random colour for line
		
		let cell = self.delegate2?.getCellAtPoint(point: location)	//Get cell that is touched
		let backUpCell = self.delegate2?.getCellAtPoint(point: CGPoint(x: location.x-5, y: location.y-5))
		let frame = self.delegate2?.getView().convert(cell?.frame ?? backUpCell!.frame, to: self.delegate2?.getView())
		let point = CGPoint(x: frame!.midX, y: frame!.midY)
		
		generator.impactOccurred()
		AudioServicesPlaySystemSound(tapSound)
		
		currentLine = Line(begin: point, end: point, colour: currentColour)	//Start line
		setNeedsDisplay()
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print(#function) //for debugging
		let touch = touches.first!
		let location = touch.location(in: self)
		
		generator.prepare()
		
		let startingCell = self.delegate2?.getCellAtPoint(point: currentLine!.begin)	//Get cell that was moved to
		let endingCell = self.delegate2?.getCellAtPoint(point: location)
		if (endingCell != nil ) {
			let direction = self.delegate2?.getDirection(startingCell: startingCell!, endingCell: endingCell!)
			
			if (direction != nil) {		//If valid line update line
				let frame = self.delegate2?.getView().convert(endingCell!.frame, to: self.delegate2?.getView())
				let point = CGPoint(x: frame!.midX, y: frame!.midY)
				
				
				if currentLine?.end != point { //If new cell play sound and haptic
					generator.impactOccurred()
					AudioServicesPlaySystemSound(tapSound)
				}
				
				currentLine?.end = point		//Update line
				currentDirection = direction
				self.delegate2?.updateTextColor(point1: currentLine!.begin, point2: currentLine!.end)
			}
		}
		setNeedsDisplay()
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print(#function) //for debugging
		let touch = touches.first!
		let location = touch.location(in: self)
		
		let startingCell = self.delegate2?.getCellAtPoint(point: currentLine!.begin)	//Get cell that was moved to
		let endingCell = self.delegate2?.getCellAtPoint(point: location)
		if (endingCell != nil) {
			let direction = self.delegate2?.getDirection(startingCell: startingCell!, endingCell: endingCell!)
			
			if (direction != nil) {		//Update line if valid
				let frame = self.delegate2?.getView().convert(endingCell!.frame, to: self.delegate2?.getView())
				let point = CGPoint(x: frame!.midX, y: frame!.midY)
				
				currentLine?.end = point
				currentDirection = direction
				self.delegate2?.updateTextColor(point1: currentLine!.begin, point2: currentLine!.end)
			}
		}
		let start = self.delegate2?.getCellAtPoint(point: currentLine!.begin)!
		let end = self.delegate2?.getCellAtPoint(point: currentLine!.end)!
		self.delegate1?.checkWord(startingCell: start!, endingCell: end!, direction: currentDirection)			//Check if word is valid
		setNeedsDisplay()
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
//		print(#function) //for debugging
		currentLine = nil
		currentDirection = nil
		setNeedsDisplay()
	}

}
