//
//  ToDoViewController.swift
//  ToDo
//
//  Created by Sourav Singh Rawat on 29/10/22.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var todos: Results<Todo>!
    
    var selectedCategory: TodoCategory? {
        didSet {
            title = selectedCategory?.title
            
            loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let nav = navigationController?.navigationBar else {fatalError("Navigation controller did not appear")}
        
//        nav.barTintColor = UIColor(hexString: selectedCategory!.colorHex)
        
        nav.tintColor = UIColor(hexString: "#000000")
    }
    
    @IBAction func onAddBtnPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New TODO", message: "", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Create New Item"
        }
        
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            let textField = alert.textFields![0]
            
            if let safeText = textField.text {
                
                let todo = Todo()
                todo.title = safeText
                
                self.store(todo: todo)
                
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
}

//MARK: - TableViewDataSource & TableViewDelegateMethods

extension TodoViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let index = indexPath.row
        let todoValue = todos[index]
        
        cell.textLabel?.text = todoValue.title
        cell.accessoryType = todoValue.isDone ? .checkmark : .none
        
        let alpha = Double(index)/Double(selectedCategory?.todos.count ?? 1)
        cell.backgroundColor = UIColor(hexString: selectedCategory!.colorHex, withAlpha: alpha)
        // OR
//      cell.backgroundColor = UIColor(hexString: selectedCategory1.colorHex)?.darken(byPercentage: alpha)
        
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let index = indexPath.row
        
        let isDone = todos[index].isDone
        tableView.cellForRow(at: indexPath)?.accessoryType = isDone ? .none : .checkmark
        
        markDone(todo: todos[index], isDone: isDone)
    }
    
    override func onSwipeRight(at indexPath: IndexPath) {
        deleteTodo(todo: todos![indexPath.row])
    }
}

//MARK: - UISearchBarDelegate

extension TodoViewController: UISearchBarDelegate {
    
    func searchForString(searchText: String){
        
        todos = todos?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "createdAt", ascending: true)

        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            searchForString(searchText: searchText)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadData()

            tableView.reloadData()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }else{
            searchForString(searchText: searchText)
        }
    }
}


//MARK: - Realm

extension TodoViewController {
    
    func loadData() {
        todos = selectedCategory?.todos.sorted(byKeyPath: "createdAt", ascending: true)
    }
    
    func store(todo: Todo){
        do {
            try realm.write({
                selectedCategory?.todos.append(todo)
            })
        } catch {
            print("Error while saving in DataModel: \(error)")
        }
    }
    
    func markDone(todo: Todo,isDone: Bool){
        do {
            try realm.write {
                todo.isDone = !isDone
            }
        } catch {
            print("Error while updating: \(error)")
        }
    }
    
    func deleteTodo(todo: Todo){
        do {
            try realm.write {
                realm.delete(todo)
            }
        } catch {
            print("Error while deleteing \(error)")
        }
    }
}
