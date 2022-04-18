//
//  NSView+Drag.swift
//  JRPlayListTool
//
//  Created by ikaros on 2022/4/6.
//

import Foundation
import AppKit

//fileprivate let kJRCanDraggedKey = "kJRCanDraggedKey"

extension NSView: ikarosCompatible {}

extension ikaros where T == NSView {
    
//    var canDrag: Bool {
//        set {
//            objc_setAssociatedObject(self, kJRCanDraggedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
//        }
//        get {
//            if let rs = objc_getAssociatedObject(self, kJRCanDraggedKey) as? Bool {
//                return rs
//            }
//            return false
//        }
//    }
    
    func register(draggedTypes types: [NSPasteboard.PasteboardType]? = nil, draggingEnded closure: (([Any]?)->Void)? = nil) {
        var muTypes: [NSPasteboard.PasteboardType]
        if #available(macOS 10.13, *) {
            muTypes = [.fileURL, .URL]
        } else {
            // Fallback on earlier versions
            muTypes = [.fileNameType(forPathExtension: "NSFilenamesPboardType")]
        }
        if types != nil {
            muTypes.append(contentsOf: types!)
        }
        self.base.registerForDraggedTypes(muTypes)
        let dragView = JRDragView()
        dragView.autoresizingMask = [.width, .height]
        dragView.layer?.backgroundColor = NSColor.blue.cgColor
        dragView.frame = self.base.frame
        dragView.draggedFilesBlock = closure
        self.base.addSubview(dragView)
        dragView.registerForDraggedTypes(muTypes)
    }
    
    
    
}

fileprivate class JRDragView: NSView {
    
    private var dragInSide: Bool = false
    var draggedFilesBlock: (([Any]?)->Void)? = nil
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.dragInSide = true
        return .generic
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.dragInSide = true
        return .generic
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        if self.dragInSide {
            let pasteboard = sender.draggingPasteboard
            let files = pasteboard.propertyList(forType: .init(rawValue: "NSFilenamesPboardType")) as? [Any]
            draggedFilesBlock?(files)
        }
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.dragInSide = false
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
//        let pasteboard = sender.draggingPasteboard
//        var files = pasteboard.propertyList(forType: .fileURL)
        
        return translatesAutoresizingMaskIntoConstraints
    }
}

