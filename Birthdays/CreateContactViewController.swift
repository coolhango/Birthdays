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

class CreateContactViewController: UIViewController {
  
  @IBOutlet weak var txtFirstname: UITextField!
  @IBOutlet weak var txtLastname: UITextField!
  @IBOutlet weak var txtHomeEmail: UITextField!
  @IBOutlet weak var datePicker: UIDatePicker!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    txtFirstname.delegate = self
    txtLastname.delegate = self
    txtHomeEmail.delegate = self
    
    let saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(CreateContactViewController.createContact))
    navigationItem.rightBarButtonItem = saveBarButtonItem
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  // MARK: Custom functions
  
  @objc func createContact() {
    let newContact = CNMutableContact()
    
    newContact.givenName = txtFirstname.text!
    newContact.familyName = txtLastname.text!
    
    if let homeEmail = txtHomeEmail.text {
      let homeEmail = CNLabeledValue(label: CNLabelHome, value: homeEmail as NSString)
      newContact.emailAddresses = [homeEmail]
    }
    
    let birthdayComponents = Calendar.current.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day], from: datePicker.date)
    newContact.birthday = birthdayComponents
    
    do {
      let saveRequest = CNSaveRequest()
      saveRequest.add(newContact, toContainerWithIdentifier: nil)
      try AppDelegate.appDelegate.contactStore.execute(saveRequest)
      
      navigationController?.popViewController(animated: true)
    } catch {
      Helper.show(message: "Unable to save the new contact.")
    }
  }
}

// MARK: UITextFieldDelegate functions
extension CreateContactViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
