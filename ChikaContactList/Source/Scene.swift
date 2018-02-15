//
//  Scene.swift
//  ChikaContactList
//
//  Created by Mounir Ybanez on 2/14/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import UIKit
import ChikaUI
import ChikaCore

public final class Scene: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    var data: Data!
    
    var contactQuery: (() -> ContactQuery)!
    var contactQueryOperator: ContactQueryOperator!
    
    var presenceListener: PresenceListener!
    var presenceListenerOperator: PresenceListenerOperator!
    
    var contactTableViewController: ContactTableViewController!
    var contactTableViewControllerFactory: ContactTableViewControllerFactory!
    
    var onSelectContact: ((Contact) -> Void)?
    var onDeselectContact: ((Contact) -> Void)?
    
    public var isSelectionEnabled: Bool = false {
        didSet {
            guard isViewLoaded, contactTableViewController != nil else {
                return
            }
            
            contactTableViewController.style = isSelectionEnabled ? .selection : .default
        }
    }
    
    var initialSelectedContactIDs: [ID] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        queryContacts()
    }
    
    public override func viewDidLayoutSubviews() {
        guard contactTableViewController != nil else {
            return
        }
        
        contactTableViewController.view.frame = containerView.bounds
    }
    
    public func dispose() {
        contactQuery = nil
        onSelectContact = nil
        onDeselectContact = nil
    }
    
    @discardableResult
    public func selectAllContacts() -> Bool {
        guard contactTableViewController != nil else {
            return false
        }
        
        return contactTableViewController.selectAll()
    }
    
    @discardableResult
    public func deselectAllContacts() -> Bool {
        guard contactTableViewController != nil else {
            return false
        }
        
        return contactTableViewController.deselectAll()
    }
    
    @discardableResult
    private func queryContacts() -> Bool {
        guard contactQueryOperator != nil, contactQuery != nil else {
            return false
        }
        
        return contactQueryOperator.withCompletion(completion).getContacts(using: contactQuery())
    }
    
    private func completion(_ result: Result<[Contact]>) {
        guard data != nil else {
            return
        }
        
        switch result {
        case .ok(let contacts):
            stopPresenceListener()
            data.refreshItems(withNewList: contacts)
            
            if !attachContactTableViewController() {
                contactTableViewController.tableView.reloadData()
            }
            
            startPresenceListener()
            
        case .err:
            break
        }
    }
    
    @discardableResult
    private func attachContactTableViewController() -> Bool {
        guard contactTableViewController == nil else {
            return false
        }
        
        contactTableViewController = contactTableViewControllerFactory.withItemCount({ [weak self] in
            return self?.data.itemCount ?? 0
            
        }).withItemAt({ [weak self] index -> ContactTableViewCellItem in
            guard let item = self?.data.itemAt(index) else {
                return ContactTableViewCellItem()
            }
            
            return item.toCellItem()
            
        }).withStyle({ [weak self] in
            guard let this = self, this.isSelectionEnabled else {
                return .default
            }
            
            return  .selection
            
        }).onSelectItemAt({ [weak self] index in
            guard let data = self?.data, let contact = data.itemAt(index)?.contact else {
                return
            }
            
            self?.onSelectContact?(contact)
            
        }).onDeselectItemAt({ [weak self] index in
            guard let data = self?.data, let contact = data.itemAt(index)?.contact else {
                return
            }
            
            self?.onDeselectContact?(contact)
            
        }).withSelectedIndexes({ [weak self] in
            guard let this = self, let data = this.data else {
                return []
            }
            
            return data.indexes(withContactIDs: this.initialSelectedContactIDs)
            
        }).build()
        
        containerView.addSubview(contactTableViewController.view)
        addChildViewController(contactTableViewController)
        contactTableViewController.didMove(toParentViewController: self)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        return true
    }
    
    @discardableResult
    private func startPresenceListener() -> Bool {
        guard data != nil, presenceListenerOperator != nil, presenceListener != nil else {
            return false
        }
        
        var ok = true
        
        for i in 0..<data.itemCount {
            guard let personID = data.itemAt(i)?.contact.person.id else {
                continue
            }
            
            ok = ok && presenceListenerOperator.withPersonID(personID).withCallback(onChangedPresence).startListening(using: presenceListener)
        }
        
        return ok
    }
    
    @discardableResult
    private func stopPresenceListener() -> Bool {
        guard presenceListenerOperator != nil, presenceListener != nil else {
            return false
        }
        
        return presenceListenerOperator.stopAll(using: presenceListener)
    }
    
    private func onChangedPresence(_ result: Result<Presence>) {
        guard data != nil else {
            return
        }
        
        switch result {
        case .ok(let presence):
            let index = data.updatePresenceStatus(with: presence)
            updateCell(at: index)
        
        case .err:
            break
        }
    }
    
    private func updateCell(at index: Int?) {
        guard contactTableViewController != nil, let row = index else {
            return
        }
        
        let rows = [IndexPath(row: row, section: 0)]
        
        contactTableViewController.tableView.beginUpdates()
        contactTableViewController.tableView.reloadRows(at: rows, with: .none)
        contactTableViewController.tableView.endUpdates()
    }
    
}
