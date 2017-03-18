//
//  AxesDrawer.swift
//  Calculator
//
//  Created by CS193p Instructor.
//  Copyright © 2015-17 Stanford University.
//  All rights reserved.
//

import UIKit

struct AxesDrawer
{
    var color: UIColor
    var contentScaleFactor: CGFloat             // set this from UIView's contentScaleFactor to position axes with maximum accuracy
    var minimumPointsPerHashmark: CGFloat = 40  // public even though init doesn't accommodate setting it (it's rare to want to change it)

    init(color: UIColor = UIColor.blue, contentScaleFactor: CGFloat = 1) {
        self.color = color
        self.contentScaleFactor = contentScaleFactor
    }
    
    // this method is the heart of the AxesDrawer
    // it draws in the current graphic context's coordinate system
    // therefore origin and bounds must be in the current graphics context's coordinate system
    // pointsPerUnit is essentially the "scale" of the axes
    // e.g. if you wanted there to be 100 points along an axis between -1 and 1,
    //    you'd set pointsPerUnit to 50

    func drawAxes(in rect: CGRect, origin: CGPoint, pointsPerUnit: CGFloat)
    {
        UIGraphicsGetCurrentContext()?.saveGState()
        color.set()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX, y: origin.y).aligned(usingScaleFactor: contentScaleFactor)!)
        path.addLine(to: CGPoint(x: rect.maxX, y: origin.y).aligned(usingScaleFactor: contentScaleFactor)!)
        path.move(to: CGPoint(x: origin.x, y: rect.minY).aligned(usingScaleFactor: contentScaleFactor)!)
        path.addLine(to: CGPoint(x: origin.x, y: rect.maxY).aligned(usingScaleFactor: contentScaleFactor)!)
        path.stroke()
        drawHashmarks(in: rect, origin: origin, pointsPerUnit: abs(pointsPerUnit))
        UIGraphicsGetCurrentContext()?.restoreGState()
    }

    // the rest of this class is private

    private struct Constants {
        static let hashmarkSize: CGFloat = 6
    }
    
    private let formatter = NumberFormatter() // formatter for the hashmark labels
    
    private func drawHashmarks(in rect: CGRect, origin: CGPoint, pointsPerUnit: CGFloat)
    {
        if ((origin.x >= rect.minX) && (origin.x <= rect.maxX)) || ((origin.y >= rect.minY) && (origin.y <= rect.maxY))
        {
            // figure out how many units each hashmark must represent
            // to respect both pointsPerUnit and minimumPointsPerHashmark
            var unitsPerHashmark = minimumPointsPerHashmark / pointsPerUnit
            if unitsPerHashmark < 1 {
                unitsPerHashmark = pow(10, ceil(log10(unitsPerHashmark)))
            } else {
                unitsPerHashmark = floor(unitsPerHashmark)
            }

            let pointsPerHashmark = pointsPerUnit * unitsPerHashmark
            
            // figure out which is the closest set of hashmarks (radiating out from the origin) that are in rect
            var startingHashmarkRadius: CGFloat = 1
            if !rect.contains(origin) {
                let leftx = max(origin.x - rect.maxX, 0)
                let rightx = max(rect.minX - origin.x, 0)
                let downy = max(origin.y - rect.minY, 0)
                let upy = max(rect.maxY - origin.y, 0)
                startingHashmarkRadius = min(min(leftx, rightx), min(downy, upy)) / pointsPerHashmark + 1
            }
            
            // pick a reasonable number of fraction digits
            formatter.maximumFractionDigits = Int(-log10(Double(unitsPerHashmark)))
            formatter.minimumIntegerDigits = 1

            // now create a bounding box inside whose edges those four hashmarks lie
            let bboxSize = pointsPerHashmark * startingHashmarkRadius * 2
            var bbox = CGRect(center: origin, size: CGSize(width: bboxSize, height: bboxSize))

            // radiate the bbox out until the hashmarks are further out than the rect
            while !bbox.contains(rect)
            {
                let label = formatter.string(from: (origin.x-bbox.minX)/pointsPerUnit)!
                if let leftHashmarkPoint = CGPoint(x: bbox.minX, y: origin.y).aligned(inside: rect, usingScaleFactor: contentScaleFactor) {
                    drawHashmark(at: leftHashmarkPoint, label: .top("-\(label)"))
                }
                if let rightHashmarkPoint = CGPoint(x: bbox.maxX, y: origin.y).aligned(inside: rect, usingScaleFactor: contentScaleFactor) {
                    drawHashmark(at: rightHashmarkPoint, label: .top(label))
                }
                if let topHashmarkPoint = CGPoint(x: origin.x, y: bbox.minY).aligned(inside: rect, usingScaleFactor: contentScaleFactor) {
                    drawHashmark(at: topHashmarkPoint, label: .left(label))
                }
                if let bottomHashmarkPoint = CGPoint(x: origin.x, y: bbox.maxY).aligned(inside: rect, usingScaleFactor: contentScaleFactor) {
                    drawHashmark(at: bottomHashmarkPoint, label: .left("-\(label)"))
                }
                bbox = bbox.insetBy(dx: -pointsPerHashmark, dy: -pointsPerHashmark)
            }
        }
    }
    
    private func drawHashmark(at location: CGPoint, label: AnchoredText)
    {
        var dx: CGFloat = 0, dy: CGFloat = 0
        switch label {
            case .left: dx = Constants.hashmarkSize / 2
            case .right: dx = Constants.hashmarkSize / 2
            case .top: dy = Constants.hashmarkSize / 2
            case .bottom: dy = Constants.hashmarkSize / 2
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: location.x-dx, y: location.y-dy))
        path.addLine(to: CGPoint(x: location.x+dx, y: location.y+dy))
        path.stroke()
        
        label.draw(at: location, usingColor: color)
    }
    
    private enum AnchoredText
    {
        case left(String)
        case right(String)
        case top(String)
        case bottom(String)
        
        static let verticalOffset: CGFloat = 3
        static let horizontalOffset: CGFloat = 6
        
        func draw(at location: CGPoint, usingColor color: UIColor) {
            let attributes = [
                NSFontAttributeName : UIFont.preferredFont(forTextStyle: .footnote),
                NSForegroundColorAttributeName : color
            ]
            var textRect = CGRect(center: location, size: text.size(attributes: attributes))
            switch self {
                case .top: textRect.origin.y += textRect.size.height / 2 + AnchoredText.verticalOffset
                case .left: textRect.origin.x += textRect.size.width / 2 + AnchoredText.horizontalOffset
                case .bottom: textRect.origin.y -= textRect.size.height / 2 + AnchoredText.verticalOffset
                case .right: textRect.origin.x -= textRect.size.width / 2 + AnchoredText.horizontalOffset
            }
            text.draw(in: textRect, withAttributes: attributes)
        }

        var text: String {
            switch self {
                case .left(let text): return text
                case .right(let text): return text
                case .top(let text): return text
                case .bottom(let text): return text
            }
        }
    }
}

private extension CGPoint
{
    func aligned(inside bounds: CGRect? = nil, usingScaleFactor scaleFactor: CGFloat = 1.0) -> CGPoint?
    {
        func align(_ coordinate: CGFloat) -> CGFloat {
            return round(coordinate * scaleFactor) / scaleFactor
        }
        let point = CGPoint(x: align(x), y: align(y))
        if let permissibleBounds = bounds, !permissibleBounds.contains(point) {
            return nil
        }
        return point
    }
}

private extension NumberFormatter
{
    func string(from point: CGFloat) -> String? {
        return string(from: NSNumber(value: Double(point)))
    }
}

private extension CGRect
{
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x-size.width/2, y: center.y-size.height/2, width: size.width, height: size.height)
    }
}
