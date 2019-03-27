//
//  SettingsViewController.h
//  Newport Pix
//
//  Created by Mirko Delgado on 08/11/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *ServerName;
@property (strong, nonatomic) IBOutlet UITextField *ServerPort;
@property (strong, nonatomic) IBOutlet UITextField *ServerPath;

@end
