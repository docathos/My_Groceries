//
//  SharingViewController.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-06-04.
//  Copyright (c) 2015 Steve. All rights reserved.
//

import UIKit

class SharingViewController: UITableViewController, UITextFieldDelegate {
  var dataModel: DataModel!
  
  @IBOutlet weak var userIDTextField: UITextField!
  
  @IBOutlet weak var shareWithTextField: UITextField!
  
  
  @IBAction func inputEditingChanged(sender: UITextField) {
 
  }
  
  @IBAction func inputEditingDidEnd(sender: UITextField) {
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if count(textField.text) > 0 {
      dataModel.shareWith.append(textField.text)
      dataModel.saveDataModel()
    } else {
      dataModel.shareWith = []
      dataModel.saveDataModel()
    }
    textField.resignFirstResponder()
    return true
  }

  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if (textField == userIDTextField) {
      return false
    } else {
      return true
    }
  }
  
  // MARK: Rest
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.allowsSelection = false;
    
    if (dataModel.userID) == nil {
      userIDTextField.text = "None - logon to iCloud"
    } else {
      userIDTextField.text =  dataModel.userID
    }
    if (dataModel.shareWith) == [] {
      shareWithTextField.text = ""
    } else {
      shareWithTextField.text = dataModel.shareWith[0]
    }
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}
