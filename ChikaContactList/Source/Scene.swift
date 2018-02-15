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
    
    var onSelectContact: ((Contact) -> Void)?
    var onDeselectContact: ((Contact) -> Void)?
    
    public var isSelectionEnabled: Bool = false {
        didSet {
            guard isViewLoaded, contactTableViewController != nil, isSelectionEnabled != oldValue else {
                return
            }
            
            contactTableViewController.style = isSelectionEnabled ? .selection : .default
        }
    }
    
    var initialSelectedContactIDs: [ID] = []
    
    public override func loadView() {
        super.loadView()
        
        guard contactTableViewController != nil else {
            return
        }
        
        containerView.addSubview(contactTableViewController.view)
        addChildViewController(contactTableViewController)
        contactTableViewController.didMove(toParentViewController: self)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        contactTableViewController?.style = isSelectionEnabled ? .selection : .default
        contactTableViewController?.isPlaceholderCellShown = true
        queryContacts()
    }
    
    public override func viewDidLayoutSubviews() {
        contactTableViewController?.view.frame = containerView.bounds
    }
    
    public func dispose() {
        contactQuery = nil
        onSelectContact = nil
        onDeselectContact = nil
    }
    
    @discardableResult
    public func selectAllContacts() -> Bool {
        return contactTableViewController?.selectAll() ?? false
    }
    
    @discardableResult
    public func deselectAllContacts() -> Bool {
        return contactTableViewController?.deselectAll() ?? false
    }
    
    @discardableResult
    public func selectContact(withIDs contactIDs: [ID]) -> Bool {
        guard data != nil else {
            return false
        }
        
        let indexes = data.indexes(withContactIDs: contactIDs)
        return selectContact(withIndexes: indexes)
    }
    
    @discardableResult
    public func selectContact(withIndexes indexes: [Int]) -> Bool {
        return contactTableViewController?.select(indexes: indexes) ?? false
    }
    
    @discardableResult
    public func deselectContact(withIDs contactIDs: [ID]) -> Bool {
        guard data != nil else {
            return false
        }
        
        let indexes = data.indexes(withContactIDs: contactIDs)
        return deselectContact(withIndexes: indexes)
    }
    
    @discardableResult
    public func deselectContact(withIndexes indexes: [Int]) -> Bool {
        return contactTableViewController?.deselect(indexes: indexes) ?? false
    }
    
    @discardableResult
    private func queryContacts() -> Bool {
        guard contactQueryOperator != nil, contactQuery != nil else {
            return false
        }
        
        return contactQueryOperator.withCompletion(completion).getContacts(using: contactQuery())
    }
    
    private func completion(_ result: Result<[Contact]>) {
        switch result {
        case .ok(let contacts):
            stopPresenceListener()
            data?.refreshItems(withNewList: contacts)
            startPresenceListener()
            
        case .err:
            break
        }
        
        let indexes = data?.indexes(withContactIDs: initialSelectedContactIDs) ?? []
        contactTableViewController?.select(indexes: indexes)
        contactTableViewController?.isPlaceholderCellShown = false
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
        switch result {
        case .ok(let presence):
            let index = data?.updatePresenceStatus(with: presence)
            updateCell(at: index)
        
        case .err:
            break
        }
    }
    
    private func updateCell(at index: Int?) {
        guard let row = index else {
            return
        }
        
        let rows = [IndexPath(row: row, section: 0)]
        
        contactTableViewController?.tableView.beginUpdates()
        contactTableViewController?.tableView.reloadRows(at: rows, with: .none)
        contactTableViewController?.tableView.endUpdates()
    }
    
}
