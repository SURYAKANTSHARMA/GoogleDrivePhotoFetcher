//
//  ViewController.swift
//  IOS Task
//
//  Created by SuryaKant Sharma on 09/12/17.
//  Copyright © 2017 SuryaKant Sharma. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeDrivePhotosReadonly]
    
    private let service = GTLRDriveService()
    let signInButton = GIDSignInButton()
    let output = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        // Add the sign-in button.
        view.addSubview(signInButton)
        
        // Add a UITextView to display output.
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        output.isHidden = true
        view.addSubview(output);
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.output.isHidden = false
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            listFiles()
        }
    }
    
    // List up to 10 files in Drive
    func listFiles() {
        
        let query = GTLRDriveQuery_FilesList.query()
        //let query = GTLQueryDrive.queryForFilesList()
        query.fields = "files(id, name, thumbnailLink)"
        //query.pageSize = 10
        query.spaces = "photos"
        
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:))
        )
    }
    
    // Process the response and display output
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                 finishedWithObject result : GTLRDrive_FileList,
                                 error : NSError?) {
        
        if let error = error {
            print(error.localizedDescription)
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        print(result)
        var text = "";
        if let files = result.files, !files.isEmpty {
            text += "Files:\n"
            for file in files {
                //print(file.identifier?.debugDescription)
                text += "\(file.name!) (\(file.identifier!))\n"
                print(file.debugDescription)
            }
        } else {
            text += "No files found."
        }
        output.text = text
    }
    
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
