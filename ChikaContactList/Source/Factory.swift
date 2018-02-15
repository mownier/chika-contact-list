//
//  Factory.swift
//  ChikaContactList
//
//  Created by Mounir Ybanez on 2/14/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import UIKit
import ChikaUI
import ChikaCore
import ChikaFirebase

public final class Factory {

    var contactQuery: (() -> ChikaCore.ContactQuery)?
    var onSelectContact: ((Contact) -> Void)?
    var onDeselectContact: ((Contact) -> Void)?
    var isSelectionEnabled: Bool
    var initialSelectedContactIDs: [ID]
    
    public init() {
        self.contactQuery = { ContactQuery() }
        self.isSelectionEnabled = false
        self.initialSelectedContactIDs = []
    }
    
    public func onSelectContact(_ callback: @escaping (Contact) -> Void) -> Factory {
        onSelectContact = callback
        return self
    }
    
    public func onDeselectContact(_ callback: @escaping (Contact) -> Void) -> Factory {
        onDeselectContact = callback
        return self
    }
    
    public func isSelectionEnabled(_ block: @escaping () -> Bool) -> Factory {
        isSelectionEnabled = block()
        return self
    }
    
    public func withInitialSelectedContactIDs(_ block: @escaping () -> [ID]) -> Factory {
        initialSelectedContactIDs = block()
        return self
    }
    
    public func build() -> Scene {
        defer {
            contactQuery = nil
            onSelectContact = nil
            onDeselectContact = nil
            initialSelectedContactIDs.removeAll()
        }
        
        let bundle = Bundle(for: Factory.self)
        let storyboard = UIStoryboard(name: "ContactList", bundle: bundle)
        let scene = storyboard.instantiateInitialViewController() as! Scene
        
        scene.data = DataProvider()
        
        scene.contactQuery = contactQuery
        scene.contactQueryOperator = ContactQueryOperation()
        
        scene.presenceListener = PresenceListener()
        scene.presenceListenerOperator = PresenceListenerOperation()
        
        scene.contactTableViewControllerFactory = ContactTableViewControllerFactory()
        
        scene.isSelectionEnabled = isSelectionEnabled
        
        scene.onSelectContact = onSelectContact
        scene.onDeselectContact = onDeselectContact
        
        scene.initialSelectedContactIDs = initialSelectedContactIDs
        
        return scene
    }
    
}
