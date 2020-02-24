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
    
    func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.angle = CGFloat.random(in: 0...2*CGFloat.pi)
        push.magnitude = CGFloat.random(in: 1...3)
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    func add(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        push(item)
    }
    
    func remove(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
    }
    
    convenience init(inAnimator animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}
