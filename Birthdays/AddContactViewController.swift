// Last Updated: 2 June 2024, 3:42PM.
// Copyright © 2024 Gedeon Koh All rights reserved.
// No part of this publication may be reproduced, distributed, or transmitted in any form or by any means, including photocopying, recording, or other electronic or mechanical methods, without the prior written permission of the publisher, except in the case of brief quotations embodied in reviews and certain other non-commercial uses permitted by copyright law.
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHOR OR COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// Use of this program for pranks or any malicious activities is strictly prohibited. Any unauthorized use or dissemination of the results produced by this program is unethical and may result in legal consequences.
// This code have been tested throughly. Please inform the operator or author if there is any mistake or error in the code.
// Any damage, disciplinary actions or death from this material is not the publisher's or owner's fault.
// Run and use this program this AT YOUR OWN RISK.
// Version 0.1

// This Space is for you to experiment your codes
// Start Typing Below :) ↓↓↓

import UIKit
import Contacts
import ContactsUI

protocol AddContactViewControllerDelegate {
  func didFetchContacts(_ contacts: [CNContact])
}

class AddContactViewController: UIViewController {
  
  @IBOutlet weak var txtLastName: UITextField!
  @IBOutlet weak var pickerMonth: UIPickerView!
  
  let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
  
  var currentlySelectedMonthIndex = 1
  var delegate: AddContactViewControllerDelegate!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    pickerMonth.delegate = self
    txtLastName.delegate = self
    
    let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(AddContactViewController.performDoneItemTap))
    navigationItem.rightBarButtonItem = doneBarButtonItem
  }
}
  // MARK: IBAction functions

extension AddContactViewController: CNContactPickerDelegate {
  @IBAction func showContacts(_ sender: AnyObject) {
    let contactPickerViewController = CNContactPickerViewController()
    
    contactPickerViewController.predicateForEnablingContact = NSPredicate(format: "birthday != nil")
    
    contactPickerViewController.delegate = self
    
    contactPickerViewController.displayedPropertyKeys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey]
    
    present(contactPickerViewController, animated: true, completion: nil)
  }
  
  func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
    delegate.didFetchContacts([contact])
    navigationController?.popViewController(animated: true)
  }
}
  
// MARK: UIPickerView Delegate and Datasource functions
extension AddContactViewController: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return months.count
  }
  
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return months[row]
  }
  
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    currentlySelectedMonthIndex = row + 1
  }
}

// MARK: UITextFieldDelegate functions
extension AddContactViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    AppDelegate.appDelegate.requestForAccess { (accessGranted) -> Void in
      if accessGranted {
        let predicate = CNContact.predicateForContacts(matchingName: self.txtLastName.text!)
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName), CNContactEmailAddressesKey, CNContactBirthdayKey] as [Any]
        var contacts = [CNContact]()
        var warningMessage: String!
        
        let contactsStore = AppDelegate.appDelegate.contactStore
        do {
          contacts = try contactsStore.unifiedContacts(matching: predicate, keysToFetch: keys as! [CNKeyDescriptor])
          
          if contacts.count == 0 {
            warningMessage = "No contacts were found matching the given name."
          }
        } catch {
          warningMessage = "Unable to fetch contacts."
        }
        
        
        if let warningMessage = warningMessage {
          DispatchQueue.main.async {
            Helper.show(message: warningMessage)
          }
        } else {
          DispatchQueue.main.async {
            self.delegate.didFetchContacts(contacts)
            self.navigationController?.popViewController(animated: true)
          }
        }
      }
    }
    
    return true
  }
  
  // MARK: Custom functions
  
  @objc func performDoneItemTap() {
    AppDelegate.appDelegate.requestForAccess { (accessGranted) -> Void in
      if accessGranted {
        var contacts = [CNContact]()
        
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName), CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey] as [Any]
        
        do {
          let contactStore = AppDelegate.appDelegate.contactStore
          try contactStore.enumerateContacts(with: CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])) { [weak self] (contact, pointer) -> Void in
            
            if contact.birthday != nil && contact.birthday!.month == self?.currentlySelectedMonthIndex {
              contacts.append(contact)
            }
          }
          
          DispatchQueue.main.async {
            self.delegate.didFetchContacts(contacts)
            self.navigationController?.popViewController(animated: true)
          }
        }
        catch let error as NSError {
          print(error.description, separator: "", terminator: "\n")
        }
      }
    }
  }
}
