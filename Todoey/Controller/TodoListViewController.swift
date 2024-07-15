//
//  ViewController.swift
//  Todoey
//
//  Created by Kanha Gupta on 15/07/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//
    
import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    //Initialise Realm
    let realm = try! Realm()
    //Declearing OBoutlet
    @IBOutlet weak var searchBar: UISearchBar!
    //Initialise Variables
    var todoItems: Results<Item>?
    var selectedCategory : Category?{
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
//        print(dataFilePath)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Sets up the NavBar
        if let colorHex = selectedCategory?.colour {
            title = selectedCategory?.name
            updateNavBarColor(withHexCode: colorHex)
        }
        tableView.backgroundColor = FlatBlack()
    }
    
    //Hanles the Disappear function for good practice
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let originalColor = UIColor(hexString: "36374C") {
            updateNavBarColor(withHexCode: originalColor.hexValue())
        }
    }
    
    //Used for UpdatingNavBarColor
    func updateNavBarColor(withHexCode colorHexCode: String) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }
        if let navBarColor = UIColor(hexString: colorHexCode) {
            //New Instance
            let appearance = UINavigationBarAppearance()
            //Configure Solid Background
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = navBarColor
            appearance.largeTitleTextAttributes = [.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
            appearance.titleTextAttributes = [.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
            
            //Different State Apprearances
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            navBar.compactAppearance = appearance
            
            //Properties
            navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
            navBar.isTranslucent = false
            
            searchBar.barTintColor = navBarColor
        }
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
            
            //Setting the color of Item Cells
            if let color = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        }else{
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK: - Table View Delegate Methods
    
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
        tableView.reloadData()
        
        //Animation
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - IBActions
    
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
    
    
    //MARK: - Database Function
    
    //Function for Loading Data
    func loadItems(){
        //Loading the Data
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: false)
        
        tableView.reloadData()
    }
    
    //For Deleting an item
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
