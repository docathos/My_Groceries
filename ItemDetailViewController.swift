//
//  ItemDetailViewController.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-03-23.
//  Copyright (c) 2015 Steve. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol ItemDetailViewControllerDelegate: class {
  func itemDetailViewControllerDidCancel(controller: ItemDetailViewController)
  func itemDetailViewController(controller: ItemDetailViewController, didFinishEditingItem item:Item)
}

class ItemDetailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var doneBarButton: UIBarButtonItem!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var removeImageButton: UIButton!
  
  weak var delegate: ItemDetailViewControllerDelegate?
  var itemToEdit: Item!
  var dataModel: DataModel!
  var image: UIImage? = nil
  
  @IBAction func removeImage(sender: UIButton) {
    image = nil
    removeImageButton.enabled = false
    imageView.image = nil
  }
  
  
  @IBAction func cancel() {
    delegate?.itemDetailViewControllerDidCancel(self)
  }
  
  @IBAction func done() {
    if let itemToEdit = itemToEdit {
      if itemToEdit.name != textField.text {
        dataModel.addUpdate("renameTo:"+textField.text, item: itemToEdit)
      }
      itemToEdit.name = textField.text
      if let image = image {
        itemToEdit.saveImage(image)
      } else {
        itemToEdit.deleteImage()
      }
      delegate?.itemDetailViewController(self, didFinishEditingItem: itemToEdit)
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    textField.becomeFirstResponder()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.contentMode = .ScaleAspectFill
    if let itemToEdit = itemToEdit {
      title = "Edit Item"
      textField.delegate = self
      textField.text = itemToEdit.name
      let image = itemToEdit.loadImage()
      if let image = image {
        imageView.image = image
        removeImageButton.enabled = true
      } else {
        removeImageButton.enabled = false
      }
      doneBarButton.enabled = true
    }
    var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
    view.addGestureRecognizer(tap)
  }
  
  func DismissKeyboard(){
    //Causes the view (or one of its embedded text fields) to resign the first responder status.
    view.endEditing(true)
  }
    
  // delegate methods
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    let oldText: NSString = textField.text
    let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
    doneBarButton.enabled = (newText.length > 0)
    return true
  }
  
  // MARK: - Images for items
  
  @IBAction func selectPhoto(sender: AnyObject) {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    imagePicker.mediaTypes = [kUTTypeImage as NSString]
    self.presentViewController(imagePicker, animated: true, completion:nil)
  }
  
  @IBAction func takePhoto(sender: AnyObject) {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
    imagePicker.mediaTypes = [kUTTypeImage as NSString]
    self.presentViewController(imagePicker, animated: true, completion:nil)
  }
  
   
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    self.dismissViewControllerAnimated(true, completion: nil)
    image = (info[UIImagePickerControllerOriginalImage] as! UIImage)
    imageView.image = image
    removeImageButton.enabled = true
  }
  
  func imagePickerControllerDidCancel(picker:
    UIImagePickerController) {
      self.dismissViewControllerAnimated(true, completion: nil)
  }
}
