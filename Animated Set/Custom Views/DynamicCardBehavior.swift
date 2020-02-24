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
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.resistance = 0.8
        return behavior
    }()
    
//    lazy var snapBehavior: UISnapBehavior = {
//        let behavior = UISnapBehavior()
//        behavior.snapPoint = CGPoint(x: 0, y: 0)
//        return behavior
//    }()
    
    func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.angle = CGFloat.random(in: 0...2*CGFloat.pi)
        push.magnitude = 5.0
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    func add(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    
    func switchToSnap() {
        let items = collisionBehavior.items
        for item in items {
            collisionBehavior.removeItem(item)
            itemBehavior.removeItem(item)
            let snapBehavior = UISnapBehavior(item: item, snapTo: CGPoint(x: 0, y: 0))
            addChildBehavior(snapBehavior)
        }
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(inAnimator animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}
