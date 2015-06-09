//
//  SharingModel.swift
//  My Groceries
//
//  Created by Stephen Astels on 2015-06-07.
//  Copyright (c) 2015 Steve. All rights reserved.
//

import UIKit
import CloudKit


class SharingModel: NSObject, NSCoding {
  var publicDatabase: CKDatabase?
  var userID: String!
  var shareWith: [String] = []
  var sharing = false
  var updateList: [Update] = []

  // MARK: - NSCoding

  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(userID, forKey: "userID")
    aCoder.encodeObject(shareWith, forKey: "shareWith")
    aCoder.encodeBool(sharing, forKey: "sharing")
    aCoder.encodeObject(updateList, forKey: "updateList")
  }
  
  required init(coder aDecoder: NSCoder) {
    userID = aDecoder.decodeObjectForKey("userID") as! String
    shareWith = aDecoder.decodeObjectForKey("shareWith") as! [String]
    sharing = aDecoder.decodeBoolForKey("aisle")
    updateList = aDecoder.decodeObjectForKey("updateList") as! [Update]
    super.init()
  }
  
  // MARK: - Initialize
  
  override init() {
    let defaultContainer = CKContainer.defaultContainer()
    publicDatabase = defaultContainer.publicCloudDatabase
  
    // TODO: spiff this up a bit...
    userID = toString(random())
    /*
    defaultContainer.fetchUserRecordIDWithCompletionHandler({
    userID, error in
    if (error == nil) {
    self.userRecordID = userID.description
    }
    })
    */

    
    super.init()
  }
  
  func startSharingWith(ID: String) {
    shareWith.append(ID)
    // TODO: add updates for everything currently on list (add items to aisles) as well as aisle order
  }
 
  func stopSharingWith(ID: String) {
    var idx = find(shareWith, ID)
    if let idx = idx {
      shareWith.removeAtIndex(idx)
    }
  }
  
}
