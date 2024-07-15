//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//
    
import UIKit
import RealmSwift

class TodoListViewController: SwipeTableViewController {
    
    //Initialise Realm
    let realm = try! Realm()
    //Initialise Variables
    var todoItems: Results<Item>?
    var selectedCategory : Category?{
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(dataFilePath)
    }

    //MARK: - Table View Datasource Methods

    //Required function for Table View
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    //Creates Cells for the Table View
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Create Cell
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        //Sets Title and Checkmark for Cell
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //Function for clicking the Todo List Item
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Checks or Unchecks the List Item
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write {
                    item.done = !item.done
                }
            }catch{
                print("Error while saving done status \(error)")
            }
        }
        //Animation
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Functions
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //Local Global Variable for UITextField
        var textField = UITextField()
        
        //Pop Up
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        //Button in the Pop Up
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            //Initialise a new Item
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error while saving new items \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        //Text Field in the Pop up
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new Item"
            
            //Sets the Global Text field equal to the Local one
            textField = alertTextField
        }
        
        //Animation or Creation
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //Function for Loading Data
    func loadItems(){
        //Loading the Data
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: false)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = todoItems?[indexPath.row]{
            do{
                try realm.write {
                    realm.delete(itemForDeletion)
                }
            }catch{
                print("Error while deleting category \(error)")
            }
        }
    }
}

//MARK: - Search Bar
extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //If Search Bar is empty
        if searchBar.text?.count == 0{
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else{
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
            tableView.reloadData()
        }
    }
}
