//
//  Todo.swift
//  ToDo
//
//  Created by Sourav Singh Rawat on 03/11/22.
//

import Foundation
import RealmSwift

class Todo: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var isDone: Bool = false
    @objc dynamic var createdAt: Date = Date.now
    
    var parentCategory = LinkingObjects(fromType: TodoCategory.self, property: "todos")
}
