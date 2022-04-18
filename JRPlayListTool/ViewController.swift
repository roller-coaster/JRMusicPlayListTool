//
//  ViewController.swift
//  JRPlayListTool
//
//  Created by ikaros on 2022/4/2.
//

import Cocoa
import AppKit

class JRMusicModel {
    
    var name: String
    
    private(set) var path: String
    
    init(_ path: String) {
        self.path = path
        if self.path.isEmpty {
            self.name = "未知"
            return
        }
        let url = URL.init(fileURLWithPath: path)
        var name = url.deletingPathExtension().lastPathComponent
        if name.isEmpty {
            name = "未知"
        }
        self.name = name
    }
    
}


class ViewController: BaseVC {
    
//    private var tableView: NSTableView

    @IBOutlet weak var tableView: NSTableView!
    
    private var dataSources: [JRMusicModel] = [JRMusicModel]()
    
    private var mainPath: String?
    
    @IBOutlet weak var pickMainPathButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer?.backgroundColor = NSColor.clear.cgColor;
        // Do any additional setup after loading the view.
        self.view.ikaros.register(draggedTypes: nil) {[weak self] abc in
            abc?.forEach({ str in
                if str is String {
                    let rs = str as! String;
                    let url = URL.init(fileURLWithPath: rs)
                    if url.isDirectory {
                        let array = FileManager.subpathsOfDirectory(rs)
                        self?.dataSources.append(contentsOf: array.map({ JRMusicModel.init($0) }).filter({!$0.path.isEmpty}))
                    } else {
                        if !(self?.dataSources.contains(where: { $0.path == rs }) ?? false) {
                            let model = JRMusicModel.init(rs);
                            if !model.path.isEmpty {
                                self?.dataSources.append(model)
                            }
                        }
                    }
                }
            })
            self?.tableView.reloadData()
        }
        let menu = NSMenu.init(title: "menu")
        let item0 = NSMenuItem.init(title: "删除", action: #selector(delete(_ :)), keyEquivalent: "")
        item0.target = self;
        menu.addItem(item0)
        self.tableView.menu = menu;
        
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}

fileprivate extension ViewController {
    
    @IBAction func openMusicFromAction(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.begin { rs in
            if rs == .OK {
                guard let path = openPanel.url?.path else {
                    return
                }
                guard FileManager.directoryExists(path) else {
                    return
                }
                self.mainPath = path;
                self.pickMainPathButton.title = path;
            }
        }
    }
    
    @IBAction func exportAction(_ sender: Any) {
        
        guard self.mainPath != nil else {
            self.ikaros.showWarningAlert(title: "错误", msg: "请设置音乐主目录!") { rs in
            }
            return
        }
        var string = "#EXTM3U"
        var idx = 1;
        self.dataSources.forEach { obj in
            string += "\n#EXTINF:\(idx), \(obj.name)"
            if !string.isEmpty {
                string += "\n"
            }
            string += obj.path.replacingOccurrences(of: self.mainPath!+"/", with: "")
            idx += 1
        }
        print("export:", string)
        let exportFileName = self.dataSources.first?.path.replacingOccurrences(of: self.mainPath!+"/", with: "").components(separatedBy: "/").first ?? "bbq"
        let savePanel = NSSavePanel()
        savePanel.allowsOtherFileTypes = false
        savePanel.message = "选择导出文件路径"
        savePanel.nameFieldStringValue = "\(exportFileName).m3u8"
        savePanel.canCreateDirectories = true
        savePanel.begin { rs in
            if rs == .OK {
                guard let outPath = savePanel.url?.path else {
                    return
                }
                guard FileManager.createFile(outPath) else {
                    return
                }
                do {
                    try string.write(toFile: outPath, atomically: true, encoding: .utf8)
                } catch let e {
                    print(e.localizedDescription)
                }
            }
        }
    }
    @IBAction func cleanAction(_ sender: Any) {
        self.dataSources.removeAll()
        self.tableView.reloadData()
    }
    @IBAction func delete(_ sender: Any) {
        let row = self.tableView.selectedRow
        self.dataSources.remove(at: row)
        self.tableView.reloadData()
    }
}

// MARK: TableView Delegate
extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    fileprivate enum CellIdentifiers {
        static let TextCell = "kTextCellIdentifierID"
        static let TextFiledCell = "kTextFieldCellIdentifierID"
    }

    fileprivate enum JRColumnIdentifiers {
        static let TextColumn = "kTextColumnIdentifierID"
        static let TextFiledColumn = "kTextFieldColumnIdentifierID"
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.dataSources.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return self.dataSources[row]
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cellIdentifier = "";
        let model = self.dataSources[row]
        guard let columnIdentifier = tableColumn?.identifier.rawValue else {
            return nil
        }
        if columnIdentifier == JRColumnIdentifiers.TextColumn {
            cellIdentifier = CellIdentifiers.TextCell
        } else if columnIdentifier == JRColumnIdentifiers.TextFiledColumn {
            cellIdentifier = CellIdentifiers.TextFiledCell
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier) , owner: nil) as? NSTableCellView {
            
            cell.textField?.isEditable = cellIdentifier == CellIdentifiers.TextFiledCell
            cell.textField?.stringValue = NSNumber.init(value: row).stringValue
            if tableColumn == tableView.tableColumns[2] {
                cell.textField?.stringValue = model.path
            }
            if tableColumn == tableView.tableColumns[1] {
                cell.textField?.stringValue = model.name
                cell.textField?.delegate = self
            }
            if tableColumn == tableView.tableColumns[0] {
                cell.textField?.stringValue = (String)(row + 1)
            }
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true;
    }
        
}

extension ViewController: NSControlTextEditingDelegate, NSTextFieldDelegate {
    
    func controlTextDidBeginEditing(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        print("controlTextDidBeginEditing:", textField.stringValue)
    }
    
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        print("controlTextDidChange", textField.stringValue)
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        print("controlTextDidEndEditing", textField.stringValue)
    }
    
}
