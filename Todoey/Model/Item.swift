//
//  Item.swift
//  Todoey
//
//  Created by Kanha Gupta on 15/07/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    //Inverse Relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
