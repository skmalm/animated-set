//
//  CardShape.swift
//  Graphical Set
//
//  Created by Sebastian Malm on 1/30/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class ShapeView: UIView {
    
    var modelCard: ModelCard!
    
    private var cardColor: UIColor {
        switch modelCard.color {
        case .color1: return UIColor(cgColor: Styles.green)
        case .color2: return UIColor(cgColor: Styles.red)
        case .color3: return UIColor(cgColor: Styles.purple)
        }
    }
    
    private var cardShadingColor: UIColor {
        switch modelCard.shading {
        case .shading1: return UIColor.clear // empty
        case .shading2: return UIColor.clear // striped
        case .shading3: return cardColor // filled
        }
    }
    
    private func cardShape() -> UIBezierPath {
        var shape = UIBezierPath()
        switch modelCard.shape {
        case .shape1: // diamond
            shape.move(to: CGPoint(x: bounds.minX, y: bounds.midY))
            shape.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY))
            shape.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
            shape.addLine(to: CGPoint(x: bounds.midX, y: bounds.minY))
            shape.close()
        case .shape2: // squiggle
            shape.move(to: CGPoint(x: bounds.minX, y: squiggleBottomMidY))
            shape.addQuadCurve(to: CGPoint(x: bounds.midX, y: squiggleTopMidY), controlPoint: CGPoint(x: squiggleLeftMidX, y: bounds.minY))
            shape.addQuadCurve(to: CGPoint(x: bounds.maxX, y: squiggleTopMidY), controlPoint: CGPoint(x: squiggleRightMidX, y: bounds.midY))
            shape.addQuadCurve(to: CGPoint(x: bounds.midX, y: squiggleBottomMidY), controlPoint: CGPoint(x: squiggleRightMidX, y: bounds.maxY))
            shape.addQuadCurve(to: CGPoint(x: bounds.minX, y: squiggleBottomMidY), controlPoint: CGPoint(x: squiggleLeftMidX, y: bounds.midY))
        case .shape3: // rounded rect
            shape = UIBezierPath(roundedRect: bounds, cornerRadius: Constants.roundedRectCornerRadiusRatio * bounds.width)
        }
        // additional drawing for stripe pattern
        if modelCard.shading == .shading2 {
            shape.addClip()
            for x in stride(from: bounds.minX, to: bounds.maxX, by: Constants.stripeDensity) {
                let stripe = UIBezierPath()
                stripe.lineWidth = Constants.stripeWidth
                cardColor.setStroke()
                stripe.move(to: CGPoint(x: x, y: bounds.minY))
                stripe.addLine(to: CGPoint(x: x, y: bounds.maxY))
                stripe.stroke()
            }
        }
        shape.lineWidth = Constants.lineWidth
        return shape
    }
    
    override func draw(_ rect: CGRect) {
        let shape = cardShape()
        cardColor.setStroke()
        cardShadingColor.setFill()
        shape.stroke()
        shape.fill()
    }

    init(fromModelCard modelCard: ModelCard, withFrame frame: CGRect) {
        self.modelCard = modelCard
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
     }
}

extension ShapeView {
    private struct Constants {
        static let lineWidth: CGFloat = 1.5
        
        // special values for drawing squiggle shape
        static let squigglyFirstMidPosition: CGFloat = 0.25
        static let squigglySecondMidPosition: CGFloat = 0.75
        
        static let roundedRectCornerRadiusRatio: CGFloat = 0.17
        
        static let stripeDensity: CGFloat = 3.0 // lower is higher density
        static let stripeWidth: CGFloat = 1.0
    }
    // calculated values for drawing squiggle shape, taking bounds into account
    private var squiggleLeftMidX: CGFloat { return Constants.squigglyFirstMidPosition * bounds.width }
    private var squiggleRightMidX: CGFloat { return Constants.squigglySecondMidPosition * bounds.width }
    private var squiggleTopMidY: CGFloat { return Constants.squigglyFirstMidPosition * bounds.height }
    private var squiggleBottomMidY: CGFloat { return Constants.squigglySecondMidPosition * bounds.height }
}
