//
//  Item.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-02-04.
//  Copyright (c) 2015 Steve. All rights reserved.
//

import UIKit

import Foundation
import CloudKit

class Item: NSObject, NSCoding {
  var name = ""
  var inList = true
  var imageFileName: String? = nil
  
  // MARK: - Init
  
  override init() {
    super.init()
  }
  
  init(name: String, aisle: Aisle, inList: Bool) {
    self.name = name
    self.inList = inList
    super.init()
  }
  
  init(name: String, aisle: Aisle) {
    self.name = name
    super.init()
  }
  
  init(name: String) {
    self.name = name
    super.init()
  }

  // MARK: - description
  
  override var description: String {
    var retval = name + " : "
    if inList {
      retval += " ** "
    } else {
      retval += "    "
    }
    return retval
  }
  
  // MARK: - NSCoding

  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(name, forKey: "name")
    aCoder.encodeBool(inList, forKey: "inList")
    aCoder.encodeObject(imageFileName, forKey: "imageFileName")
  }
  
  required init(coder aDecoder: NSCoder) {
    name = aDecoder.decodeObjectForKey("name") as! String
    inList = aDecoder.decodeBoolForKey("inList")
    imageFileName = aDecoder.decodeObjectForKey("imageFileName") as! String?
    super.init()
  }
  
  // MARK: - Save and load images
  
  func createImageFileName() {
    if imageFileName == nil {
      imageFileName = NSUUID().UUIDString
    }
  }
  
  func imageFilePath() -> String? {
    if let imageFileName = imageFileName {
      let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
      let docsDir: AnyObject = dirPaths[0]
      return docsDir.stringByAppendingPathComponent(imageFileName + ".png")
    } else {
      return nil 
    }
  }

  func saveImage(image: UIImage) {
    createImageFileName()
    UIImageJPEGRepresentation(image, 0.5).writeToFile(imageFilePath()!, atomically: true)
  }
  
  func deleteImage() {
    if let filePath = imageFilePath() {
      NSFileManager.defaultManager().removeItemAtPath(filePath, error: nil)
      self.imageFileName = nil
    }
  }
  
  func loadImage() -> UIImage? {
    if let filePath = imageFilePath() {
      return UIImage(contentsOfFile: filePath)
    } else {
      return nil
    }
  }
}
