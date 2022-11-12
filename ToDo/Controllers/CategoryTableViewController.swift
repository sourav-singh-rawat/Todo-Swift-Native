//
//  CategoryTableViewController.swift
//  ToDo
//
//  Created by Sourav Singh Rawat on 02/11/22.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories : Results<TodoCategory>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let nav = navigationController?.navigationBar else {fatalError("Navigation controller failed to apper")}
        
//        nav.barTintColor = UIColor(hexString: "#007AFF")
        
        nav.tintColor = UIColor(hexString: "#000000")
    }
    
    @IBAction func onAddCategoryPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Category Name"
        }
        
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            if let safeText = alert.textFields![0].text {
                
                let category = TodoCategory()
                category.title = safeText
                category.colorHex = UIColor.randomFlat().hexValue()
                
                self.store(category: category)
                
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - TableDataSource & TableViewDelegate

extension CategoryTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let index = indexPath.row
        let category = categories?[index]
        
        cell.textLabel?.text = category?.title ?? ""
        
        cell.backgroundColor = UIColor(hexString: category?.colorHex ?? "#FFFFFF")
        
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        
        return cell
    }
    
    override func onSwipeRight(at indexPath: IndexPath) {
        deleteCategory(category: categories![indexPath.row])
    }
}

//MARK: - Navigation

extension CategoryTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.categoryToTodosSegue, sender: self)
        
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoViewController
        
        if let selectedCategoryIndex = tableView.indexPathForSelectedRow?.row {
            let selectedCategory = categories?[selectedCategoryIndex]
            
            destinationVC.selectedCategory = selectedCategory
        }
    }
}

//MARK: - Realm operations

extension CategoryTableViewController {
    func loadData(){
        categories = realm.objects(TodoCategory.self)
    }
    
    func store(category: TodoCategory) {
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("Error while saving category: \(error)")
        }
    }
    
    func deleteCategory(category: TodoCategory){
        do {
            try realm.write {
                realm.delete(category)
            }
        } catch {
            print("Error while deleteing \(error)")
        }
    }
}
