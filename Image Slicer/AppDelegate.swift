//  Created by Jeremy on 2016-02-13.
//  Copyright © 2016 Jeremy W. Sherman. Released with NO WARRANTY.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func application(sender: NSApplication, openFiles filenames: [String]) {
        NSLog("%@", "asked to open files: \(filenames.joined(separator: "\n- "))")
        for file in filenames {
            guard openFile(file: file) else {
                NSApp.reply(toOpenOrPrint: .failure)
                return
            }
        }
        NSApp.reply(toOpenOrPrint: .success)
    }

    func openFile(file: String) -> Bool {
        let controller = NSDocumentController.shared

        let url = URL(fileURLWithPath: file)
        if let image = NSImage(contentsOf: url) {
            do {
                let someDocument = try controller.makeUntitledDocument(ofType: Document.nativeType)
                guard let myDocument = someDocument as? Document else {
                    NSLog("%@", "\(someDocument) has wrong class: opened \(file)")
                    return false
                }

                controller.addDocument(someDocument)

                myDocument.job = Job(image: image)
                let imageName = url.deletingPathExtension().lastPathComponent
                myDocument.displayName = imageName
                myDocument.makeWindowControllers()
                myDocument.showWindows()
                return true
            } catch {
                NSLog("%@", "failed creating untitled document: \(error)")
                return false
            }
        }

        if let type = try? controller.typeForContents(of: url) {
            NSLog("%@", "\(file): has type \(type)")
        }

        controller.openDocument(withContentsOf: url, display: true) {
        (document, alreadyOpen, error) -> Void in
            let result: AnyObject? = document ?? error as AnyObject
            NSLog("%@", "opening \(file): already open? \(alreadyOpen) - result \(String(describing: result))")

            if let error = error {
                NSApp.presentError(error)
            }
        }
        return true
    }
}
