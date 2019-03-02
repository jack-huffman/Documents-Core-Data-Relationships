//
//  NewExpenseViewController.swift
//  Expenses
//
//  Created by Shawn Moore on 11/6/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import UIKit

class NewExpenseViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var category: Category?
    var selectedExpense: Expense?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.delegate = self
        amountTextField.delegate = self
        
        // populate fields if editing record
        if let expense = selectedExpense {
            nameTextField.text = expense.name
            amountTextField.text = String(expense.amount)
            datePicker.date = expense.date ?? Date()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
    }
    
    @IBAction func saveExpense(_ sender: Any) {
        
        let name = nameTextField.text
        let amountText = amountTextField.text ?? ""
        let amount = Double(amountText) ?? 0.0
        let date = datePicker.date
       
        // Attempt to unwrap passed expense. If works, then updating record
        if let selectedExpense = selectedExpense {
            print(selectedExpense)
            selectedExpense.setValue(name, forKey: "name")
            selectedExpense.setValue(amount, forKey: "amount")
            selectedExpense.setValue(date, forKey: "rawDate")
            
            self.navigationController?.popViewController(animated: true)
        }
        else {
            if let expense = Expense(name: name, amount: amount, date: date) {
                category?.addToRawExpenses(expense)
                
                do {
                    try expense.managedObjectContext?.save()
                    self.navigationController?.popViewController(animated: true)
                } catch {
                    print("Expense couldn't be created")
                }
            }
        }

    }
}

extension NewExpenseViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
