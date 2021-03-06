//
//  RemovedCardBehavior.swift
//  Animated Set
//
//  Created by Sebastian Malm on 2/24/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class DynamicCardBehavior: UIDynamicBehavior {
    
    lazy private var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        behavior.collisionMode = .boundaries
        return behavior
    }()
    
    lazy private var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.resistance = Constants.itemResistance
        return behavior
    }()
    
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .continuous)
        push.magnitude = Constants.pushMagnitudeToItemHeightRatio * item.bounds.height
        push.angle = 0.0
        push.action = { [unowned push] in
            push.angle += Constants.pushAngleToItemHeightRatio / item.bounds.height
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
        // larger value -> more magnitude
        static let pushMagnitudeToItemHeightRatio: CGFloat = 0.25
        // larger value -> larger angle increment
        static let pushAngleToItemHeightRatio: CGFloat = 15.6
        static let pushRemovalDelay: TimeInterval = 1.5
        static let itemResistance: CGFloat = 10.0
    }
}
