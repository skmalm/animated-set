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
        behavior.resistance = 10.0
        return behavior
    }()
    
//    lazy var snapBehavior: UISnapBehavior = {
//        let behavior = UISnapBehavior()
//        behavior.snapPoint = CGPoint(x: 0, y: 0)
//        return behavior
//    }()
    
    func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .continuous)
        push.magnitude = 0.25 * item.bounds.height
        push.action = { [unowned push] in
            push.angle += 0.1
        }
        addChildBehavior(push)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
