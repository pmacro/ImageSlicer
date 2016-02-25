//  Copyright © 2016 Jeremy W. Sherman. Released with NO WARRANTY.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol Undoing {
    func record(undo: () -> Void)
}


extension NSUndoManager: Undoing {
    func record(undo: () -> Void) {
        let target = PerformableClosure(undo)
        self.registerUndoWithTarget(target, selector: Selector("perform"), object: nil)
    }
}


/// Added to provide undo support.
class PerformableClosure {
    let closure: () -> Void
    init(_ closure: () -> Void) {
        self.closure = closure
    }

    @objc
    func perform() {
        closure()
    }
}