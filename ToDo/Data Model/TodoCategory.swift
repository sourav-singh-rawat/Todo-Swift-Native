//
//  Category.swift
//  ToDo
//
//  Created by Sourav Singh Rawat on 03/11/22.
//

import Foundation
import RealmSwift

class TodoCategory: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var colorHex: String = ""
    
    var todos = List<Todo>()
}
