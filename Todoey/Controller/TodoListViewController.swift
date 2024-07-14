//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//
    
import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    //Initialise Variables
    var itemArray = [Item]()
    var selectedCategory : Category?{
        didSet{
            loadItems()
        }
    }
    
    //FilePath for the Save Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
//        print(dataFilePath)
        
        //Loads the data at startup
        loadItems()
    }

    //MARK: - Table View Datasource Methods

    //Required function for Table View
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //Creates Cells for the Table View
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Constant
        let item = itemArray[indexPath.row]
        
        //Create Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = item.title
        
        //Sets the Tick Mark for the Todo List
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //Function for clicking the Todo List Item
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Checks or Unchecks the List Item
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //Saves the Progress
        saveItems()
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
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            //Appends it to the List
            self.itemArray.append(newItem)
            
            //Saves the Progress
            self.saveItems()
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
    
    //Function for Saving Data
    func saveItems(){
        do{
            try context.save()
        } catch{
            print("Error while Saving Context \(error)")
        }
        
        //Reloads the TableView after saving so the user could see what he actually feed
        self.tableView.reloadData()
    }
    
    //Function for Loading Data
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
        //Loading the Data
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }

        do{
            itemArray = try context.fetch(request)
        }catch{
            print("Error while fetching the Request \(error)")
        }
        
        tableView.reloadData()
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
        
        if searchBar.text?.count == 0{
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else{
            let request : NSFetchRequest<Item> = Item.fetchRequest()
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            loadItems(with: request, predicate: predicate)
        }
    }
}
