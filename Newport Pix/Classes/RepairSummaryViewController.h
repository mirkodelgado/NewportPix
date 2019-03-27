//
//  RepairSummaryViewController.h
//  Newport Pix
//
//  Created by Mirko Delgado on 08/15/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGalleryViewController.h"

@interface RepairSummaryViewController : UIViewController<FGalleryViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) NSString *callNumber;

@property (strong, nonatomic) IBOutlet UILabel *billtoClientTxt;
@property (strong, nonatomic) IBOutlet UILabel *callNumberTxt;
@property (strong, nonatomic) IBOutlet UILabel *equipmentIDTxt;
@property (strong, nonatomic) IBOutlet UILabel *relatedIDTxt;
@property (strong, nonatomic) IBOutlet UILabel *photosTakenTxt;
@property (strong, nonatomic) IBOutlet UILabel *callStatusTxt;

@property (strong, nonatomic) IBOutlet UIProgressView *rs_progress;

@end
