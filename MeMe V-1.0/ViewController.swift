//
//  ViewController.swift
//  MeMe V-1.0
//
//  Created by Vasanth Kodeboyina on 6/1/16.
//  Copyright © 2016 Anish Kodeboyina. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageViewer: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topToolbar: UIToolbar!
    
    var selectedTextField: UITextField!
    var memedImage: UIImage!
    var pickerController: UIImagePickerController!
    let cannotAccessCameraAlertMessage = "Application cannot access the camera"

    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        shareButton.enabled = false
        cameraAvailabilityCheck()
        let textFieldsArray = [topTextField, bottomTextField]
        textFieldsConfiguration(textFieldsArray)
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(true)
        unsubsribeToKeyboardNotification()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        view.endEditing(true) // KeyBoard will disappear when user Tap on view
    }
    
    
    // MARK: - Image Picking and Delegation

    // Album Button is Pressed: Pick Image from Photo Library
    @IBAction func pickAnImage(sender: AnyObject)
    {
        pickerController = imagePickerWith(.PhotoLibrary)
        pickerController.delegate = self
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    // Image Picking Delegation : Selected image assigned to ImageViewer
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        imageViewer.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        pickerController.dismissViewControllerAnimated(true, completion: nil)
        shareButton.enabled = true
    }
    
    // Image Picking Delegation : Selected image assigned to ImageViewer
    func imagePickerWith(type: UIImagePickerControllerSourceType) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = type
        return pickerController
    }
    
    
    // MARK: - Camera Button Pressed Actions
    
    @IBAction func cameraButtonPressed(sender: AnyObject)
    {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil
            {
                pickerController = imagePickerWith(.Camera)
                pickerController.allowsEditing = false
                pickerController.cameraCaptureMode = .Photo
                presentViewController(pickerController, animated: true, completion: {})
            }
            else
            {
                createAlertWithMessage("No Rear Camera")
            }
    }
    
    // Check for camera avaialbility in device
    func cameraAvailabilityCheck()
    {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera))
        {
            cameraButton.enabled = true
        }
        else
        {
            cameraButton.enabled = false
        }
        
    }
    
    
    // Alert Message with Ok Action
    func createAlertWithMessage(title: String)
    {
        let UIAlert = UIAlertController(title: title, message: cannotAccessCameraAlertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        UIAlert.addAction(UIAlertAction(title: "ok",style: .Default, handler: {(ACTION:UIAlertAction!) in }))
        presentViewController(UIAlert, animated: true, completion: nil)
    }
    
    
    // MARK: - Share Button Pressed Actions

    @IBAction func shareButtonPressed(sender: AnyObject) {
        let imageToShare = generateMemedImage()
        let activityItems = [imageToShare]
        let ac = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        presentViewController(ac, animated: true, completion: {self.save()})
    }
    
    func save() {
        //Create the meme
       let meme = MemeModel(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageViewer.image, memedImage: memedImage)
        print(meme)
        cancelButtonPressed(true)
    }
    
    func generateMemedImage() -> UIImage
    {
        //Hide Toolbar
        var size = view.frame.size
        size.height -= topToolbar.frame.size.height + 20
        size.height -= bottomToolbar.frame.size.height 
        
        //render view to an image:
        var frame = self.view.frame
        frame.origin.y -= (topToolbar.frame.size.height + 20)
        UIGraphicsBeginImageContext(size)
        self.view.drawViewHierarchyInRect(frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    // MARK: - KeyBoard Resigning and Notification
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        selectedTextField = textField
    }
    
    
    // Calculation of keyBoard Height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat
    {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    // Move frame upward
    func keyboardWillShow(notification: NSNotification)
    {
        if selectedTextField == bottomTextField && self.view.frame.origin.y == 0.0
        {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    // Move frame back to its original position
    func keyboardWillHide(notification: NSNotification)
    {
        if -self.view.frame.origin.y > 0
        {
            self.view.frame.origin.y = 0
        }
    }
   
    //Suscribe the view controller to the UIKeyboardWillShowNotification:
    func subscribeToKeyboardNotification()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Unsubscribe the view controller to the UIKeyboardWillShowNotification:
    func unsubsribeToKeyboardNotification()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    // MARK: - TextFields Configuration
    
    func textFieldsConfiguration(textFields: [UITextField!])
    {
        let memeTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 40)!,
            NSStrokeWidthAttributeName : -4.0
        ]
        
        for textField in textFields
        {
            textField.defaultTextAttributes = memeTextAttributes
            textField.textAlignment = .Center
        }
    }
    
    // MARK: - Cancel Button Pressed Actions
    
    @IBAction func cancelButtonPressed(sender: AnyObject)
    {
        topTextField.text = nil                     // Clear Top TextField
        bottomTextField.text = nil                  // Clear Bottom TextField
        imageViewer.image = nil                     // Clear ImageViewer
        shareButton.enabled = false                 // Disabled share button
        if(selectedTextField != nil)
        {
            textFieldShouldReturn(selectedTextField)    // Keyboard should resign
        }
    }
    
}

