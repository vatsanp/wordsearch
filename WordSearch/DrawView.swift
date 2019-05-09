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

struct Line {
	var begin = CGPoint.zero
	var end = CGPoint.zero
}

class DrawView: UIView {

	var delegate: WordCheckProtocol?
	
	var gridView: CollectionView!
	
	var currentLine: Line?
	var finishedLines = [Line]();
	var currentDirection: CGPoint!
	
	func strokeLine(line: Line){
		//Use BezierPath to draw lines
		let path = UIBezierPath();
		path.lineWidth = 10;
		path.lineCapStyle = CGLineCap.round;
		
		path.move(to: line.begin);
		path.addLine(to: line.end);
		path.stroke(); //actually draw the path
	}
	
	override func draw(_ rect: CGRect) {
		UIColor.lightGray.setStroke()
		
		for line in finishedLines{
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
		print(location)
		
		let cell = gridView.getCellAtPoint(point: location)
		let frame = gridView.convert(cell?.frame ?? gridView.getCellAtPoint(point: CGPoint(x: location.x-5, y: location.y-5)).frame, to: gridView)
		let point = CGPoint(x: frame.midX, y: frame.midY)
		
		currentLine = Line(begin: point, end: point);
		setNeedsDisplay(); //this view needs to be updated
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print(#function) //for debugging
		let touch = touches.first!; //get first touch event and unwrap optional
		let location = touch.location(in: self); //get location in view co-ordinate
		
		let startingCell = gridView.getCellAtPoint(point: currentLine!.begin)
		let endingCell = gridView.getCellAtPoint(point: location)
		if (endingCell != nil ) {
			let direction = gridView.getDirection(startingCell: startingCell!, endingCell: endingCell!)
			
			if (direction != nil) {
				let frame = gridView.convert(endingCell!.frame, to: gridView)
				let point = CGPoint(x: frame.midX, y: frame.midY)
				
				currentLine?.end = point
				currentDirection = direction
			}
		}
		setNeedsDisplay(); //this view needs to be updated
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print(#function) //for debugging
		let touch = touches.first!; //get first touch event and unwrap optional
		let location = touch.location(in: self); //get location in view co-ordinate
		
		let startingCell = gridView.getCellAtPoint(point: currentLine!.begin)
		let endingCell = gridView.getCellAtPoint(point: location)
		if (endingCell != nil) {
			let direction = gridView.getDirection(startingCell: startingCell!, endingCell: endingCell!)
			
			if (direction != nil) {
				let frame = gridView.convert(endingCell!.frame, to: gridView)
				let point = CGPoint(x: frame.midX, y: frame.midY)
				
				currentLine?.end = point
				currentDirection = direction
			}
		}
		let start = gridView.getCellAtPoint(point: currentLine!.begin)!
		let end = gridView.getCellAtPoint(point: currentLine!.end)!
		self.delegate?.checkWord(startingCell: start, endingCell: end, direction: currentDirection)
		setNeedsDisplay(); //this view needs to be updated
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
//		print(#function) //for debugging
		currentLine = nil
		setNeedsDisplay()
	}

}
