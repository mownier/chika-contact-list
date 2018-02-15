//
//  ViewController.swift
//  ChikaContactList
//
//  Created by Mounir Ybanez on 2/14/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import UIKit
import ChikaCore
import ChikaFirebase

class ViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    var scene: Scene!
    
    override func loadView() {
        super.loadView()
        
        let scene = Factory().onSelectContact({
            print("select", $0)
            
        }).onDeselectContact({
            print("deselect:", $0)
            
        }).isSelectionEnabled({
            true
            
        }).build()
        
        containerView.addSubview(scene.view)
        addChildViewController(scene)
        scene.didMove(toParentViewController: self)
        
        self.scene = scene
    }
    
    override func viewDidLayoutSubviews() {
        scene.view.frame = containerView.bounds
    }
    
    @IBAction func showActions(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Actions", message: "Select action to perform", preferredStyle: .actionSheet)
        let selectAllAction = UIAlertAction(title: "Select All Contacts", style: .default) { _ in
            self.scene.selectAllContacts()
        }
        let deselectAllAction = UIAlertAction(title: "Deselect All Contacts", style: .default) { _ in
            self.scene.deselectAllContacts()
        }
        let selectRandomContactAction = UIAlertAction(title: "Select Random Contacts", style: .default) { _ in
            var contactIDs: [ID] = []
            let randomCount = Int(arc4random()) % self.scene.data.itemCount
            
            for _ in 0..<randomCount {
                let index = Int(arc4random()) % self.scene.data.itemCount
                
                guard let contactID = self.scene.data.itemAt(index)?.contact.person.id else {
                    continue
                }
                
                contactIDs.append(contactID)
            }
            
            self.scene.selectContact(withIDs: contactIDs)
        }
        let deselectRandomContactAction = UIAlertAction(title: "Deselect Random Contacts", style: .default) { _ in
            let selections = self.scene.contactTableViewController.selections
            
            guard !selections.isEmpty else {
                return
            }
            
            var contactIDs: [ID] = []
            let randomCount = Int(arc4random()) % selections.count
            
            for _ in 0..<randomCount {
                let index = selections[Int(arc4random()) % selections.count]
                
                guard let contactID = self.scene.data.itemAt(index)?.contact.person.id else {
                    continue
                }
                
                contactIDs.append(contactID)
            }
            
            self.scene.deselectContact(withIDs: contactIDs)
        }
        
        let enableSelectionAction = UIAlertAction(title: "Enable Selection", style: .default) { _ in
            self.scene.isSelectionEnabled = true
        }
        let disableSelectionAction = UIAlertAction(title: "Disable Selection", style: .default) { _ in
            self.scene.isSelectionEnabled = false
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(selectAllAction)
        alert.addAction(deselectAllAction)
        alert.addAction(selectRandomContactAction)
        alert.addAction(deselectRandomContactAction)
        
        alert.addAction(enableSelectionAction)
        alert.addAction(disableSelectionAction)
        
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        let switcher = OfflinePresenceSwitcher()
        let _ = switcher.switchToOffline { result in
            print("[ChikaFirebase/Writer:OfflinePresenceSwitcher]", result)
        }
        
        let action = SignOut()
        let operation = SignOutOperation()
        let _ = operation.withCompletion({ result in
            switch result {
            case .ok(let ok):
                print("[ChikaFirebase/Auth:SignOut]", ok)
                showSignIn()
            
            case .err(let error):
                showAlert(withTitle: "Error", message: "\(error)", from: self)
            }
            
        }).signOut(using: action)
    }
    
}

