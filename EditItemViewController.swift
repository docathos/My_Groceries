//
//  EditItemViewController.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-02-08.
//  Copyright (c) 2015 Steve. All rights reserved.
//



import UIKit

protocol EditItemViewControllerDelegate: class {
  func editItemViewControllerDidCancel(controller: EditItemViewController)
  func editItemViewController(controller: EditItemViewController, didFinishEditingItem item:Item)
}

class EditItemViewController: UITableViewController, UITextFieldDelegate {
  
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var doneBarButton: UIBarButtonItem!
  
  weak var delegate: EditItemViewControllerDelegate?
  var itemToEdit: Item!
  
  @IBAction func cancel() {
    delegate?.editItemViewControllerDidCancel(self)
  }
  
  @IBAction func done() {
    if let itemToEdit = itemToEdit {
      itemToEdit.name = textField.text
      delegate?.editItemViewController(self, didFinishEditingItem: itemToEdit)
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    textField.becomeFirstResponder()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = 44
    if let itemToEdit = itemToEdit {
      title = "Edit Item"
      textField.text = itemToEdit.name
      doneBarButton.enabled = true
    }
  }
  
  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    return nil
  }
  
  // delegate methods
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    let oldText: NSString = textField.text
    let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
    doneBarButton.enabled = (newText.length > 0)
    return true
  }
}




