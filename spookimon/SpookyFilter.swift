//
//  SpookyFilter.swift
//  spookimon
//
//  Created by Nate Parrott on 9/20/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import GPUImage

class SpookyFilter: GPUImageFilter {
    var spookiness: Float = 1 {
        didSet {
            setFloat(GLfloat(spookiness), forUniformName: "spookiness")
        }
    }
}
