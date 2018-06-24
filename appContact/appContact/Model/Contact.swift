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
    @objc dynamic var url = ""
    @objc dynamic var person: Person!
}

import Foundation
import RealmSwift

class Person: Object {
    @objc dynamic var id = 0
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var email = ""
    @objc dynamic var phoneNumber = ""
    @objc dynamic var profilePic = ""
    @objc dynamic var favorite = false
    @objc dynamic var createdAt = NSDate()
    @objc dynamic var updatedAt = NSDate()
    
}
