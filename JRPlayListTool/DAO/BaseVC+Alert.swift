//
//  BaseVC+Alert.swift
//  JRPlayListTool
//
//  Created by ikaros on 2022/4/16.
//

import Cocoa

extension BaseVC: ikarosCompatible {}
extension ikaros where T: BaseVC {
    func showWarningAlert(title: String = "", msg: String = "", completion closure: ((NSApplication.ModalResponse)->Void)? = nil) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = msg
        alert.alertStyle = .warning
        alert.beginSheetModal(for: self.base.view.window!, completionHandler: closure)
    }
}
