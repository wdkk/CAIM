//
//  UnsafeRawPointer+Ext.swift
//  caimmetal15_AR
//
//  Created by Kengo on 2017/12/10.
//  Copyright © 2017年 TUT Creative Application. All rights reserved.
//

import Foundation

public func << <T>(ptr:UnsafeMutableRawPointer, obj:T) {
    let p = ptr.assumingMemoryBound(to: T.self)
    p.pointee = obj
}
