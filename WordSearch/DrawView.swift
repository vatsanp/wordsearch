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
		
		currentLine = Line(begin: location, end: location);
		setNeedsDisplay(); //this view needs to be updated
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print(#function) //for debugging
		let touch = touches.first!; //get first touch event and unwrap optional
		let location = touch.location(in: self); //get location in view co-ordinate
		
		
		currentLine?.end = location
		setNeedsDisplay(); //this view needs to be updated
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print(#function) //for debugging
		let touch = touches.first!; //get first touch event and unwrap optional
		let location = touch.location(in: self); //get location in view co-ordinate
		
		currentLine?.end = location
		finishedLines.append(currentLine!)
		setNeedsDisplay(); //this view needs to be updated
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
//		print(#function) //for debugging
		currentLine = nil
		setNeedsDisplay()
	}

}
