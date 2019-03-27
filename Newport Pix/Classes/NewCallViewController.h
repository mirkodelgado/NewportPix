//
//  NewCallViewController.h
//  Newport Pix
//
//  Created by Mirko Delgado on 9/17/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGalleryViewController.h"

//@interface NewCallViewController : UIViewController <FGalleryViewControllerDelegate>
@interface NewCallViewController : UIViewController <FGalleryViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *TxtEquipmentID;

@property (strong, nonatomic) IBOutlet UIProgressView *progress;
    

@end
