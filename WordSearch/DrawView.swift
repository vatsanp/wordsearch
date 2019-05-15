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


struct Line {
	var begin = CGPoint.zero
	var end = CGPoint.zero
	var colour = UIColor.blue
}

class DrawView: UIView {

	var delegate1: WordCheckProtocol?
	var delegate2: CollectionViewProtocol?
	
	var currentLine: Line?
	var finishedLines = [Line]()
	var currentDirection: CGPoint!
	
	let strokeColours: [UIColor] = [UIColor.blue, UIColor.red, UIColor.purple, UIColor.orange, UIColor.cyan, UIColor.green, UIColor.black]
	var currentColour = UIColor.blue
	
	let generator = UIImpactFeedbackGenerator(style: .light)
	let tapSound: SystemSoundID = 1104
	
	func strokeLine(line: Line){
		//Use BezierPath to draw lines
		let path = UIBezierPath();
		path.lineWidth = 20;
		path.lineCapStyle = CGLineCap.round;
		
		line.colour.setStroke()
		
		path.move(to: line.begin);
		path.addLine(to: line.end);
		path.stroke(); //actually draw the path
	}
	
	override func draw(_ rect: CGRect) {
		for line in finishedLines{
			strokeColours.randomElement()!.setStroke()
			strokeLine(line: line);
		}
		//draw current line if it exists
		if let line = currentLine {
			strokeLine(line: line);
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print(#function) //for debugging
		let touch = touches.first!; //get first touch event and unwrap optional
		let location = touch.location(in: self); //get location in view co-ordinate
		
		generator.prepare()
		currentColour = strokeColours.randomElement()!
		
		let cell = self.delegate2?.getCellAtPoint(point: location)
		let backUpCell = self.delegate2?.getCellAtPoint(point: CGPoint(x: location.x-5, y: location.y-5))
		let frame = self.delegate2?.getView().convert(cell?.frame ?? backUpCell!.frame, to: self.delegate2?.getView())
		let point = CGPoint(x: frame!.midX, y: frame!.midY)
		
		generator.impactOccurred()
		AudioServicesPlaySystemSound(tapSound)
		
		currentLine = Line(begin: point, end: point, colour: currentColour);
		setNeedsDisplay(); //this view needs to be updated
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print(#function) //for debugging
		let touch = touches.first!; //get first touch event and unwrap optional
		let location = touch.location(in: self); //get location in view co-ordinate
		
		generator.prepare()
		
		let startingCell = self.delegate2?.getCellAtPoint(point: currentLine!.begin)
		let endingCell = self.delegate2?.getCellAtPoint(point: location)
		if (endingCell != nil ) {
			let direction = self.delegate2?.getDirection(startingCell: startingCell!, endingCell: endingCell!)
			
			if (direction != nil) {
				let frame = self.delegate2?.getView().convert(endingCell!.frame, to: self.delegate2?.getView())
				let point = CGPoint(x: frame!.midX, y: frame!.midY)
				
				
				if currentLine?.end != point {
					generator.impactOccurred()
					AudioServicesPlaySystemSound(tapSound)
				}
				
				currentLine?.end = point
				currentDirection = direction
				self.delegate2?.updateTextColor(point1: currentLine!.begin, point2: currentLine!.end)
			}
		}
		setNeedsDisplay(); //this view needs to be updated
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print(#function) //for debugging
		let touch = touches.first!; //get first touch event and unwrap optional
		let location = touch.location(in: self); //get location in view co-ordinate
		
		let startingCell = self.delegate2?.getCellAtPoint(point: currentLine!.begin)
		let endingCell = self.delegate2?.getCellAtPoint(point: location)
		if (endingCell != nil) {
			let direction = self.delegate2?.getDirection(startingCell: startingCell!, endingCell: endingCell!)
			
			if (direction != nil) {
				let frame = self.delegate2?.getView().convert(endingCell!.frame, to: self.delegate2?.getView())
				let point = CGPoint(x: frame!.midX, y: frame!.midY)
				
				currentLine?.end = point
				currentDirection = direction
				self.delegate2?.updateTextColor(point1: currentLine!.begin, point2: currentLine!.end)
			}
		}
		let start = self.delegate2?.getCellAtPoint(point: currentLine!.begin)!
		let end = self.delegate2?.getCellAtPoint(point: currentLine!.end)!
		self.delegate1?.checkWord(startingCell: start!, endingCell: end!, direction: currentDirection)
		setNeedsDisplay(); //this view needs to be updated
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
//		print(#function) //for debugging
		currentLine = nil
		currentDirection = nil
		setNeedsDisplay()
	}

}
