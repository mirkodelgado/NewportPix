//
//  SettingsViewController.m
//  Newport Pix
//
//  Created by Mirko Delgado on 08/11/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsDao.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
	SettingsDao *settingsDao = [[SettingsDao alloc] initWithDataBase];
    NSArray *values = [settingsDao getPixSettings];
    [settingsDao closeAll];
    
    _ServerName.text = [values objectAtIndex:0];
    _ServerPort.text = [values objectAtIndex:1];
    _ServerPath.text = [values objectAtIndex:2];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
