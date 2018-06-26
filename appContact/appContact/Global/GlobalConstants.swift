//
//  GlobalConstants.swift
//  appContact
//
//  Created by Frans Kurniawan on 6/25/18.
//  Copyright © 2018 Frans Kurniawan. All rights reserved.
//

import Foundation
import UIKit

// MARK: - URL
let kUrlBase            = "http://gojek-contacts-app.herokuapp.com"
let kUrlSecuredBase     = "https://gojek-contacts-app.herokuapp.com"
let kUrlContacts        = "/contacts/"
let kUrlContactsJSON    = "/contacts"
let kUrlJSON            = ".json"

// MARK: - Title
let kTitleContact       = "Contact"

// MARK: - Segue
let kSegueDetailContact = "detailContactSegue"

// MARK: - Segue
let kPersonFirstName    = "First Name"
let kPersonLastName     = "Last Name"
let kPersonMobile       = "mobile"
let kPersonEmail        = "email"

// MARK: - Alerts
let kError                      = "Error"
let kErrorContacts              = "Error Fetching Contacts"
let kErrorContactDetail         = "Error Load Contact Detail"
let kErrorUpdateCreateContact   = "Error Update/Create Contact"

// MARK: - Validations
let kErrorEmailValidation       = "Email is not Valid"
let kErrorPhoneValidation       = "Phone is not Valid"
let kErrorFirstNameValidation   = "First Name is not Valid, Min. 2 Characters"
let kErrorLastNameValidation    = "Last Name is not Valid, Min. 2 Characters"
