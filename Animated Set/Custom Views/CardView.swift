//
//  CardView.swift
//  Graphical Set
//
//  Created by Sebastian Malm on 1/29/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

//@IBDesignable
class CardView: UIView {
    
    override func draw(_ rect: CGRect) {

        // generate and draw card background
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: Constants.cornerRadius)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
    }
    
    var modelCard: ModelCard?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in subviews {
            subview.removeFromSuperview()
        }
        guard modelCard != nil else { return }
        switch modelCard!.quantity {
        case .one:
            generateShape(atYPosition: yPositionFromRatio(Constants.yRatioFor1Shape))
        case .two:
            for ratio in Constants.yRatiosFor2Shapes {
                generateShape(atYPosition: yPositionFromRatio(ratio))
            }
        case .three:
            for ratio in Constants.yRatiosFor3Shapes {
                generateShape(atYPosition: yPositionFromRatio(ratio))
            }
        }
    }
    
    private func generateShape(atYPosition yPosition: CGFloat) {
        let shape = ShapeView(fromModelCard: modelCard!, withFrame: CGRect(origin: CGPoint(x: Constants.shapeLeftBoundaryRatio * bounds.width, y: yPosition), size: CGSize(width: Constants.shapeWidthRatio * bounds.width, height: Constants.shapeHeightRatio * bounds.height)))
        shape.isOpaque = false
        shape.backgroundColor = UIColor.clear
        shape.contentMode = .redraw
        addSubview(shape)
    }
 
    init(fromModelCard modelCard: ModelCard, withFrame frame: CGRect) {
        self.modelCard = modelCard
        super.init(frame: frame)
    }
    
   required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension CardView {
    private struct Constants {
        static let cornerRadius: CGFloat = 6.0
        static let shapeWidthRatio: CGFloat = 0.6
        static let shapeHeightRatio: CGFloat = 0.2
        static let shapeLeftBoundaryRatio: CGFloat = 0.2
        static let shapeRightBoundaryRatio: CGFloat = 0.8
        static let yRatioFor1Shape: CGFloat = 0.4
        static let yRatiosFor2Shapes: [CGFloat] = [0.28, 0.52]
        static let yRatiosFor3Shapes: [CGFloat] = [0.1, 0.4, 0.7]
    }
    private func yPositionFromRatio(_ ratio: CGFloat) -> CGFloat {
        return ratio * bounds.height
    }
}
