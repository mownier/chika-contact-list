//
//  Data.swift
//  ChikaContactList
//
//  Created by Mounir Ybanez on 2/14/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaUI
import ChikaCore

protocol Data {

    var itemCount: Int { get }
    
    func itemAt(_ index: Int) -> Item?
    func indexes(withContactIDs contactIDs: [ID]) -> [Int]
    func refreshItems(withNewList list: [Contact])
    
    
    @discardableResult
    func updatePresenceStatus(with presence: Presence) -> Int?
}

struct Item {
    
    var contact: Contact
    var isActive: Bool
    
    init() {
        contact = Contact()
        isActive = false
    }
    
    func toCellItem() -> ContactTableViewCellItem {
        var cellItem = ContactTableViewCellItem()
        cellItem.isActive = isActive
        cellItem.avatarURL = contact.person.avatarURL
        cellItem.displayName = contact.person.displayName
        return cellItem
    }
}

class DataProvider: Data {
    
    var items: [Item]
    
    var itemCount: Int {
        return items.count
    }
    
    init() {
        self.items = []
    }
    
    func itemAt(_ index: Int) -> Item? {
        guard index >= 0, index < itemCount else {
            return nil
        }
        
        return items[index]
    }
    
    func indexes(withContactIDs contactIDs: [ID]) -> [Int] {
        var indexes: [Int] = []
        items.enumerated().forEach { item in
            guard contactIDs.contains(item.element.contact.person.id) else {
                return
            }
            
            indexes.append(item.offset)
        }
        return indexes
    }
    
    func refreshItems(withNewList list: [Contact]) {
        items = list.map({ contact in
            var item = Item()
            item.contact = contact
            return item
        })
    }
    
    @discardableResult
    func updatePresenceStatus(with presence: Presence) -> Int? {
        guard let index = items.index(where: { $0.contact.person.id == presence.personID }) else {
            return nil
        }
        
        items[index].isActive = presence.isActive
        return index
    }
    
}
