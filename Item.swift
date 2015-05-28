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
  var inList = false
  var aisleName = ""
  var recordID: CKRecordID!
  var updateDate: NSDate!
  var imageFileName: String? = nil
  var itemID: NSUUID!

  
  override var description: String {
    var retval = aisleName + ": " + name + " : "
    if let recordID = recordID {
      retval += "has CK"
    } else {
      retval += "no  CK"
    }
    if inList {
      retval += " ** "
    } else {
      retval += "    "
    }
    if let updateDate=updateDate {
      retval += "updated \(updateDate)"
    }
    return retval
  }

  // MARK: - New functions
  
  func toggleInList() {
    inList = !inList
    updateDate = NSDate()
  }
  
  // MARK: - NSCoding
  
  /*
  var name = ""
  var inList = false
  var aisleName = ""
  var cloudKitRecord: CKRecord!
  var updateDate: NSDate!
  var imageFileName: String? = nil
  */

  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(name, forKey: "name")
    aCoder.encodeObject(updateDate, forKey: "updateDate")
    aCoder.encodeBool(inList, forKey: "inList")
    aCoder.encodeObject(aisleName, forKey: "aisleName")
    aCoder.encodeObject(recordID  , forKey: "recordID")
    aCoder.encodeObject(imageFileName, forKey: "imageFileName")
  }
  
  required init(coder aDecoder: NSCoder) {
    name = aDecoder.decodeObjectForKey("name") as! String
    updateDate = aDecoder.decodeObjectForKey("updateDate") as! NSDate
    inList = aDecoder.decodeBoolForKey("inList")
    aisleName = aDecoder.decodeObjectForKey("aisleName") as! String
    recordID = aDecoder.decodeObjectForKey("recordID") as! CKRecordID!
    imageFileName = aDecoder.decodeObjectForKey("imageFileName") as! String?
    super.init()
  }
  
  // MARK: - Init
  
  override init() {
    self.itemID = NSUUID()
    updateDate = NSDate()
    super.init()
  }
  
  init(name: String, aisleName: String, inList: Bool) {
    self.itemID = NSUUID()
    self.name = name
    self.aisleName = aisleName
    self.inList = inList
    updateDate = NSDate()
    super.init()
  }

  init(name: String, aisleName: String) {
    self.itemID = NSUUID()
    self.name = name
    self.aisleName = aisleName
    updateDate = NSDate()
    super.init()
  }

  init(name: String) {
    self.itemID = NSUUID()
    self.name = name
    updateDate = NSDate()
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

// MARK: - CloudKit
/*
  var name = ""
  var inList = false
  var aisleName = ""
  var cloudKitRecord: CKRecord!
  var updateDate: NSDate!
  var imageFileName: String? = nil
*/
  
  init(record: CKRecord) {
    itemID    = record.objectForKey("name") as! NSUUID
    name      = record.objectForKey("name") as! String
    inList    = record.objectForKey("inList") as! Bool
    aisleName = record.objectForKey("aisleName") as! String
    updateDate = record.modificationDate
    recordID = record.recordID
  }

  func makeRecord() -> CKRecord! {
    if recordID == nil {
      var record = CKRecord(recordType: "Item")
      record.setObject(itemID, forKey: "itemID")
      record.setObject(name, forKey: "name")
      record.setObject(inList, forKey: "inList")
      record.setObject(aisleName, forKey: "aisleName")
      return record
    } else {
      return nil
    }
}
