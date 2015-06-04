//
//  FaceView.swift
//  Happiness
//
//  Created by Antonio081014 on 6/3/15.
//  Copyright (c) 2015 Antonio081014.com. All rights reserved.
//

import UIKit

class FaceView: UIView {
    
    var lineWidth: CGFloat = 3 {
        didSet { setNeedsDisplay() }
    }
    
    var color: UIColor = UIColor.blueColor() {
        didSet { setNeedsDisplay() }
    }
    
    var scale: CGFloat = 0.90 {
        didSet { setNeedsDisplay() }
    }

    var faceCenter: CGPoint {
        get { return convertPoint(center, fromView: superview) }
    }
    
    var faceRadius: CGFloat {
        get { return min(bounds.size.width, bounds.size.height) / 2 * scale }
    }
    
    var fraction: Double = 0.75 {
        didSet { setNeedsDisplay() }
    }
    
    private struct Scaling {
        static let FaceRadiusToEyeRadiusRatio: CGFloat = 10
        static let FaceRadiusToEyeOffsetRatio: CGFloat = 3
        static let FaceRadiusToEyeSeparationRatio: CGFloat = 1.5
        static let FaceRadiusToMouthWidthRatio: CGFloat = 1
        static let FaceRadiusToMouthHeightRatio: CGFloat = 3
        static let FaceRadiusToMouthOffsetRatio: CGFloat = 3
    }
    
    private enum Eye {
        case Left
        case Right
    }
    
    private func bezierPathForEye(whichEye: Eye) ->UIBezierPath {
        let eyeRadius = faceRadius / Scaling.FaceRadiusToEyeRadiusRatio
        let eyeVerticleOffset = faceRadius / Scaling.FaceRadiusToEyeRadiusRatio
        let eyeHorizontalSeparation = faceRadius / Scaling.FaceRadiusToEyeSeparationRatio
        
        var eyeCenter = faceCenter
        eyeCenter.y -= eyeVerticleOffset
        switch whichEye {
        case .Left: eyeCenter.x -= eyeHorizontalSeparation / 2
        case .Right: eyeCenter.x += eyeHorizontalSeparation / 2
        }
        
        let path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: CGFloat(0), endAngle: CGFloat(2 * M_PI), clockwise: true)
        path.lineWidth = lineWidth
        return path
    }
    
    private func bezierPathForSmile(fractionOfMaxSmail: Double) ->UIBezierPath {
        let mouthWidth = faceRadius / Scaling.FaceRadiusToMouthWidthRatio
        let mouthHeight = faceRadius / Scaling.FaceRadiusToMouthHeightRatio
        let mouthVerticleOffset = faceRadius / Scaling.FaceRadiusToMouthOffsetRatio
        
        let smileHeight = CGFloat(max(min(fractionOfMaxSmail, 1), -1)) * mouthHeight
        
        let start = CGPoint(x: faceCenter.x - mouthWidth / 2, y: faceCenter.y + mouthVerticleOffset)
        let end = CGPoint(x: faceCenter.x + mouthWidth / 2, y: faceCenter.y + mouthVerticleOffset)
        let cp1 = CGPoint(x: start.x + mouthWidth / 3, y: start.y + smileHeight)
        let cp2 = CGPoint(x: end.x - mouthWidth / 3, y: cp1.y)
        
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth

        return path
    }
    
    override func drawRect(rect: CGRect)
    {
        let facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadius, startAngle: CGFloat(0), endAngle: CGFloat(2 * M_PI), clockwise: true)
        facePath.lineWidth = lineWidth
        color.set()
        facePath.stroke()
        
        bezierPathForEye(Eye.Left).stroke()
        bezierPathForEye(Eye.Right).stroke()
        
        bezierPathForSmile(fraction).stroke()
    }
}
