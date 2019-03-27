//
//  LoginViewController.m
//  Newport Pix
//
//  Created by Mirko Delgado on 08/15/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import "LoginViewController.h"
#import "CommunicationManager.h"
#import "DBUtils.h"
#import "Globals.h"
#import "UserLocationsDao.h"

@implementation LoginViewController

/**********************************************
 *
 **********************************************/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/**********************************************
 *
 **********************************************/

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.    
}

/**********************************************
 *
 **********************************************/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**********************************************
 *
 **********************************************/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([_Password isFirstResponder] && [touch view] != _Password) {
        [_Password resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}


#pragma mark - Navigation

/**********************************************
 *
 **********************************************/

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

/**********************************************
 *
 **********************************************/

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    BOOL ok = YES;
    
    if ([sender tag] == 1) {
		PixLog(@"settings bar item");
        return YES;
    }
    else if ([sender tag] == 2) {
		PixLog(@"about bar item");
        return YES;
    }
    
    if ([_UserName.text length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login"
                                                  message:@"Please enter a Username"
                                                  delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    if ([_Password.text length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password"
                                                  message:@"Please enter a Password"
                                                  delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alert show];
        return NO;
    }    

	@try {
        
        CommunicationManager *commManager = [[CommunicationManager alloc]initCommunicationManager];
        NSData *returnedData = [commManager doLogin:_UserName.text : _Password.text];
        
        DBUtils *dbUtils = [[DBUtils alloc]initWithDataBase];
        [dbUtils processRequest:returnedData];
        [dbUtils closeAll];
        
        UserLocationsDao *userLocations = [[UserLocationsDao alloc]initWithDataBase];
        [userLocations setActiveClientInfo];
        [userLocations closeAll];

        Globals *glbls =[Globals getInstance];
        
        glbls.userID = [_UserName.text uppercaseString];
        
	}@catch (NSException *e){
	
        NSString *excep = e.reason;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                  message:excep
                                                  delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alert show];
        
        PixLogAll(@"Exception %@", e);
        ok = NO;
		
	}@finally {

        return ok;
	}

    return YES;
}

/**********************************************
 *
 **********************************************/

- (IBAction)action:(id)sender
{
	PixLog(@"-[%@ %@]", [self class], NSStringFromSelector(_cmd));
}

//| ----------------------------------------------------------------------------
//  Unwind action that is targeted by the demos which present a modal view
//  controller, to return to the main screen.

/**********************************************
 *
 **********************************************/

- (IBAction)unwindToLoginViewController:(UIStoryboardSegue*)sender
{
    PixLog(@"from segue id: %@", sender.identifier);
}

@end
