//
//  ViewController.swift
//  CloudKitGDPR iOS Demo
//
//  Created by Artur Grigor on 02.05.2018.
//  Copyright © 2018 Artur Grigor. All rights reserved.
//

import UIKit
import CloudKitGDPR
import ZIPFoundation

//
//  # Class
//

class ViewController: UITableViewController {

    // MARK: - Types -
    
    struct Cell {
        static let exportData = IndexPath(row: 0, section: 0)
        static let deleteData = IndexPath(row: 1, section: 0)
    }
    
    // MARK: - Outlets -
    
    @IBOutlet weak var exportDataCell: UITableViewCell!
    @IBOutlet weak var exportDataLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deleteDataCell: UITableViewCell!
    @IBOutlet weak var deleteDataLoadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties -
    
    lazy var applicationCachesDirectory: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    // MARK: - UITableViewDelegate Methods -
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
            case Cell.exportData: self.exportData(tableView)
            case Cell.deleteData: self.askDeleteData(tableView)
            default: break
        }
    }
    
    // MARK: - Actions -
    
    @IBAction func exportData(_ sender: Any?) {
        // Feedback
        self.startActivity(in: self.exportDataCell, withLoadingIndicator: self.exportDataLoadingIndicator, flag: true)
        
        // Operation
        GDPR.shared.exportData(usingTransformer: JSONDataTransformer.default) { result in
            switch result {
                case .failure(let error):
                    print("GDPR export data error: \(error)")
                    self.presentError("Failed to export your data at the moment. Please try again later.", completion: nil)
                    self.startActivity(in: self.exportDataCell, withLoadingIndicator: self.exportDataLoadingIndicator, flag: false)
                
                case .success(let value):
                    DispatchQueue.global(qos: .background).async {
                        let url = self.applicationCachesDirectory.appendingPathComponent("data.zip")
                        let archive = Archive(url: url, accessMode: .create)
                        for (fileName, csvContents) in value {
                            let data = Data(bytes: Array(csvContents.utf8))
                            try? archive?.addEntry(with: fileName, type: .file, uncompressedSize: UInt32(data.count), provider: { position, size -> Data in
                                return data
                            })
                        }
                        
                        DispatchQueue.main.async {
                            let viewController = UIActivityViewController(activityItems: [url], applicationActivities: [])
                            viewController.popoverPresentationController?.sourceView = self.exportDataCell
                            viewController.completionWithItemsHandler = { _, _, _, _ in
                                try? FileManager.default.removeItem(at: url)
                            }
                            
                            self.present(viewController, animated: true, completion: nil)
                            self.startActivity(in: self.exportDataCell, withLoadingIndicator: self.exportDataLoadingIndicator, flag: false)
                        }
                    }
            }
        }
    }
    
    @IBAction func askDeleteData(_ sender: Any?) {
        let alertController = UIAlertController(title: nil,
            message: "Are you sure you want to delete all your data?",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.deleteData()
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func deleteData() {
        // Feedback
        self.startActivity(in: self.deleteDataCell, withLoadingIndicator: self.deleteDataLoadingIndicator, flag: true)
        
        // Operation
        let genericErrorMessage = "Failed to delete your data at the moment. Please try again later."
        GDPR.shared.deleteData { result in
            switch result {
                case .failure(let error):
                    print("GDPR delete data error: \(error)")
                    self.presentError(genericErrorMessage, completion: nil)
                    self.startActivity(in: self.deleteDataCell, withLoadingIndicator: self.deleteDataLoadingIndicator, flag: false)
                
                case .success(_):
                    // TODO: Cleanup local data too
                    self.startActivity(in: self.deleteDataCell, withLoadingIndicator: self.deleteDataLoadingIndicator, flag: false)
            }
        }
    }
    
    // MARK: - UI Helpers -
    
    fileprivate func presentError(_ message: String, completion: (() -> Void)?) {
        let alertController = UIAlertController(title: "Ooops!", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            completion?()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func startActivity(in cell: UITableViewCell, withLoadingIndicator loadingIndicatorView: UIActivityIndicatorView, flag: Bool) {
        cell.selectionStyle = flag ? .none : .default
        loadingIndicatorView.isHidden = flag ? false : true
        if flag {
            loadingIndicatorView.startAnimating()
        } else {
            loadingIndicatorView.stopAnimating()
        }
    }
    
}

