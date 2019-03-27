//
//  CustomCallViewController.m
//  Newport Pix
//
//  Created by Mirko Delgado on 8/22/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import "CustomCallViewController.h"
#import "Globals.h"

@interface CustomCallViewController ()

@end

@implementation CustomCallViewController

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
    
//    [self.navigationItem setHidesBackButton:YES];
    
    
    Globals *glbls =[Globals getInstance];
    
    if ([glbls.row1 length] == 0)
    {
       [self.LblRow1 setHidden:TRUE];
       [self.TxtRow1 setHidden:TRUE];
    }
    else
    {
        self.LblRow1.text = glbls.row1;
    }
    
    if ([glbls.row2 length] == 0)
    {
        [self.LblRow2 setHidden:TRUE];
        [self.TxtRow2 setHidden:TRUE];
    }
    else
    {
        self.LblRow2.text = glbls.row2;
    }
    
    if ([glbls.row3 length] == 0)
    {
        [self.LblRow3 setHidden:TRUE];
        [self.TxtRow3 setHidden:TRUE];
    }
    else
    {
        self.LblRow3.text = glbls.row3;
    }
    
    if ([glbls.row4 length] == 0)
    {
        [self.LblRow4 setHidden:TRUE];
        [self.TxtRow4 setHidden:TRUE];
    }
    else
    {
        self.LblRow4.text = glbls.row4;
    }
    
    if ([glbls.row5 length] == 0)
    {
        [self.LblRow5 setHidden:TRUE];
        [self.TxtRow5 setHidden:TRUE];
    }
    else
    {
        self.LblRow5.text = glbls.row5;
    }

    if ([glbls.row6 length] == 0)
    {
        [self.LblRow6 setHidden:TRUE];
        [self.TxtRow6 setHidden:TRUE];
    }
    else
    {
        self.LblRow6.text = glbls.row6;
    }
    
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
