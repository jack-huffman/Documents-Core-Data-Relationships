//
//  CategoriesViewController.swift
//  ExpensesCoreData
//
//  Created by Shawn Moore on 11/9/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import UIKit
import CoreData

class CategoriesViewController: UIViewController {

    @IBOutlet weak var categoriesTableView: UITableView!
    
    var categories: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categories = try managedContext.fetch(fetchRequest)
            categoriesTableView.reloadData()
            
        } catch {
            print("Could not fetch categories")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? ExpensesViewController,
             let selectedRow = categoriesTableView.indexPathForSelectedRow?.row else {
            return
        }
        destination.category = categories[selectedRow]
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        let category = categories[indexPath.row]
        guard let managedContext = category.managedObjectContext else {
            return
        }
        managedContext.delete(category)
        
        do {
            try managedContext.save()
            categories.remove(at: indexPath.row)
            categoriesTableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            print("Could not delete")
            categoriesTableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

}

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoriesTableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let category = categories[indexPath.row]
            guard let count = category.expenses?.count else {
                return
            }
            
            if count > 0 {
                let alert = UIAlertController(title: "Confirm deletion", message: "Are you sure you want to delete this record?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    self.deleteCategory(at: indexPath)
                    }))
            
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            else {
                self.deleteCategory(at: indexPath)
            }
        }
    }
    
}
