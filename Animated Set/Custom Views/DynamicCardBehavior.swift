//
//  RemovedCardBehavior.swift
//  Animated Set
//
//  Created by Sebastian Malm on 2/24/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class DynamicCardBehavior: UIDynamicBehavior {
    
    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        behavior.collisionMode = .boundaries
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.resistance = Constants.itemResistance
        return behavior
    }()
    
    func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .continuous)
        push.magnitude = Constants.pushMagnitudeToItemHeightRatio * item.bounds.height
        push.action = { [unowned push] in
            push.angle += Constants.pushAngleIncrement
        }
        addChildBehavior(push)
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.pushRemovalDelay) {
            self.removeChildBehavior(push)
        }
    }
    
    func add(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    // initial/default value, replaced in convenience init
    var snapPoint = CGPoint.zero
    
    func switchToSnap() {
        let items = collisionBehavior.items
        for item in items {
            collisionBehavior.removeItem(item)
            itemBehavior.removeItem(item)
            let snapBehavior = UISnapBehavior(item: item, snapTo: snapPoint)
            addChildBehavior(snapBehavior)
        }
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(inAnimator animator: UIDynamicAnimator, withSnapPoint snapPoint: CGPoint) {
        self.init()
        animator.addBehavior(self)
        self.snapPoint = snapPoint
    }
}

extension DynamicCardBehavior {
    private struct Constants {
        static let pushMagnitudeToItemHeightRatio: CGFloat = 0.25
        static let pushAngleIncrement: CGFloat = 0.1
        static let pushRemovalDelay: TimeInterval = 1.5
        static let itemResistance: CGFloat = 10.0
    }
}
