//
//  Contact.swift
//  appContact
//
//  Created by Frans Kurniawan on 6/24/18.
//  Copyright © 2018 Frans Kurniawan. All rights reserved.
//

import Foundation
import RealmSwift

class Contact: Object {
    @objc dynamic var id = 0
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var profilePic = ""
    @objc dynamic var isFavorite = false
    @objc dynamic var url = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(Person.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    class func inBound(dict : NSDictionary, dbContact : Contact?) -> Contact {
        
        var contact = Contact()
        
        if let input = dbContact{
            contact = input
        }
        
        if contact.id == 0 {
            contact.id = dict["id"] as! Int
        }
        
        contact.firstName = dict["first_name"] as! String
        contact.lastName = dict["last_name"] as! String
        
        if (CommonFunction.verifyUrl(urlString: (dict["profile_pic"] as! String))){
            contact.profilePic = (dict["profile_pic"] as! String)
        }
        else{
            contact.profilePic = kUrlBase + (dict["profile_pic"] as! String)
        }
        
        contact.isFavorite = dict["favorite"] as! Bool
        contact.url = dict["url"] as! String
        
        return contact
    }
    
    class func getById(id : Int) -> Contact? {
        let contact :Contact? = try! Realm().object(ofType: Contact.self, forPrimaryKey: id)
        
        if contact != nil {
            return contact!
        }
        
        return nil
    }
    
    func getFullName() -> String {
        return self.firstName + " " + self.lastName;
    }
    
}
