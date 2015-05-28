//
//  EditAisleViewController.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-02-09.
//  Copyright (c) 2015 Steve. All rights reserved.
//




import UIKit

protocol EditAisleViewControllerDelegate: class {
  func editAisleViewControllerDidCancel(controller: EditAisleViewController)
  func editAisleViewController(controller: EditAisleViewController, didFinishEditingAisle numToEdit: Int, withText text:String)
}

class EditAisleViewController: UITableViewController, UITextFieldDelegate {
  
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var doneBarButton: UIBarButtonItem!
  
  weak var delegate: EditAisleViewControllerDelegate?
  var numToEdit: Int = -1
  var textToEdit: String!
  
  @IBAction func cancel() {
    delegate?.editAisleViewControllerDidCancel(self)
  }
  
  @IBAction func done() {
      delegate?.editAisleViewController(self, didFinishEditingAisle: numToEdit, withText: textField.text)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    textField.becomeFirstResponder()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = 44
    if let textToEdit = textToEdit {
      title = "Edit Item"
      textField.text = textToEdit
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




