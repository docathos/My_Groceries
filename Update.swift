//
//  Update.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-04-11.
//  Copyright (c) 2015 Steve. All rights reserved.
//

//import UIKit
import CloudKit

class Update: NSObject, NSCoding {
  var item: Item!
  var changeName: String!
  var changeTo: NSObject!
  var itemID: NSUUID!
  
  var recordID: CKRecordID! { return item?.recordID }

  init(item: Item, changeName: String, changeTo: NSObject) {
    self.itemID = NSUUID()
    self.item = item
    self.changeName = changeName
    self.changeTo = changeTo
  }
/*
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(itemID, forKey: "itemID")
    aCoder.encodeObject(name, forKey: "name")
//    aCoder.encodeObject(updateDate, forKey: "updateDate")
    aCoder.encodeBool(inList, forKey: "inList")
    aCoder.encodeObject(aisleName, forKey: "aisleName")
    aCoder.encodeObject(recordID  , forKey: "recordID")
    aCoder.encodeObject(imageFileName, forKey: "imageFileName")
  }
  
  required init(coder aDecoder: NSCoder) {
    itemID = aDecoder.decodeObjectForKey("itemID") as! NSUUID
    name = aDecoder.decodeObjectForKey("name") as! String
    updateDate = aDecoder.decodeObjectForKey("updateDate") as! NSDate
    inList = aDecoder.decodeBoolForKey("inList")
    aisleName = aDecoder.decodeObjectForKey("aisleName") as! String
    recordID = aDecoder.decodeObjectForKey("recordID") as! CKRecordID!
    imageFileName = aDecoder.decodeObjectForKey("imageFileName") as! String?
    super.init()
  }
  */

  
  
}