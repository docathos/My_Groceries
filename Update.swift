//
//  Update.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-06-08.
//  Copyright (c) 2015 Steve. All rights reserved.
//

import UIKit

class Update: NSObject, NSCoding {
  var updateType = ""
  var item = ""
  var aisle = ""
  var aisleOrder: [String] = []
  
  // MARK: - NSCoding
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(updateType, forKey: "updateType")
    aCoder.encodeObject(item, forKey: "item")
    aCoder.encodeObject(aisle, forKey: "aisle")
    aCoder.encodeObject(aisleOrder, forKey: "aisleOrder")
  }
  
  required init(coder aDecoder: NSCoder) {
    updateType = aDecoder.decodeObjectForKey("updateType") as! String
    item = aDecoder.decodeObjectForKey("item") as! String
    aisle = aDecoder.decodeObjectForKey("aisle") as! String
    aisleOrder = aDecoder.decodeObjectForKey("aisleOrder") as! [String]
    super.init()
  }

}
