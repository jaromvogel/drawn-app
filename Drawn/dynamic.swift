//
//  dynamic.swift
//  Drawn
//
//  Created by Jarom Vogel on 7/19/15.
//  Copyright © 2015 Jarom Vogel. All rights reserved.
//

import Foundation

class Dynamic<T> {
    typealias Listener = T -> Void
    var listener: Listener?
    
    func bind(listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ v: T) {
        value = v
    }
}
