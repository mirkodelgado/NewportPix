//
//  RepairCallsViewController.m
//  Newport Pix
//
//  Created by Mirko Delgado on 08/15/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import "RepairCallsViewController.h"
#import "CustomCallViewController.h"
#import "RepairSummaryViewController.h"
#import "LoginViewController.h"
#import "CommunicationManager.h"
#import "CallsDao.h"
#import "DBUtils.h"
#import "Globals.h"
#import "Utilities.h"
#import "UserLocationsDao.h"

@interface RepairCallsViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray *CallInfo;

@end

@implementation RepairCallsViewController

/**********************************************
 *
 **********************************************/

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    
    [Utilities removeJPGFiles];

    CallsDao *callsDao = [[CallsDao alloc]initWithDataBase];
    self.CallInfo = [callsDao getCallInfo];
    [callsDao closeAll];
    
    self.navigationController.toolbar.clipsToBounds = YES;
}

/**********************************************
 *
 **********************************************/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

/**********************************************
 *
 **********************************************/

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    BOOL ok = YES;
    
    if ([sender tag] == 1) {
		PixLog(@"compose bar item");
        return YES;
    }
    else if ([sender tag] == 2) {
		PixLog(@"change client bar item");
        return YES;
    }
        
    return ok;
}

/********************************************************************************************************
 * In a storyboard-based application, you will often want to do a little preparation before navigation
 ********************************************************************************************************/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     if ([segue.identifier isEqualToString:@"RCSummarySegue"])
     {
         NSMutableArray *call = [self.CallInfo objectAtIndex:self.tableView.indexPathForSelectedRow.row];
                  
         [(RepairSummaryViewController*)segue.destinationViewController setCallNumber:[call objectAtIndex:0]];
     }
}

#pragma mark - Table view data source

/**********************************************
 *
 **********************************************/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.CallInfo count];
}

/**********************************************
 *
 **********************************************/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *call = [self.CallInfo objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    cell.textLabel.text = [NSString stringWithFormat:@"%@\t%@\t\t%@",[call objectAtIndex:0],[call objectAtIndex:1], [call objectAtIndex:3]];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[call objectAtIndex:2]];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    
    return cell;
}

/**************************************************************
 * Override to support conditional editing of the table view
 **************************************************************/

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;     // Return NO if you do not want the specified item to be editable
}

/***********************************************
 * Override to support editing the table view
 ***********************************************/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/***************************************************
 * Override to support rearranging the table view
 ***************************************************/

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}

/******************************************************************
 * Override to support conditional rearranging of the table view
 ******************************************************************/

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;     // Return NO if you do not want the item to be re-orderable
}

#pragma mark -
#pragma mark IBActions

/*******************************************************************
 * IBAction for the various bar button items shown in this example
 *******************************************************************/

- (IBAction)action:(id)sender
{
	PixLog(@"-[%@ %@]", [self class], NSStringFromSelector(_cmd));
}

#pragma mark -
#pragma mark Style Action Sheet

/**********************************************
 *
 **********************************************/

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *selectedBillToClientName = [modalView buttonTitleAtIndex:buttonIndex];

    Globals *gbls = [Globals getInstance];
    
    if ([selectedBillToClientName isEqualToString:gbls.billToClientName])
    {
		PixLog(@"Bill to client did not change");
    }
    else
    {
        UserLocationsDao *userLocationsDao = [[UserLocationsDao alloc]initWithDataBase];
        [userLocationsDao updateBillToClientInfo:selectedBillToClientName];
        [userLocationsDao closeAll];
        
        if ([Globals getPixClient])
        {
            [self performSegueWithIdentifier: @"CCallSegue" sender: self];
        }
        else
        {
            @try {
                
                CommunicationManager *commManager = [[CommunicationManager alloc]initCommunicationManager];
                NSData *returnedData = [commManager doClientCallsRequest:gbls.billToCID : gbls.billToVendorID : gbls.billToDepotID];
                
                DBUtils *dbUtils = [[DBUtils alloc]initWithDataBase];
                [dbUtils processRequest:returnedData];
                [dbUtils closeAll];

                CallsDao *callsDao = [[CallsDao alloc]initWithDataBase];
                self.CallInfo = [callsDao getCallInfo];
                [callsDao closeAll];                
                
                [self.tableView reloadData];
                
            }@catch (NSException *e){
                
                NSString *excep = e.reason;
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:excep
                                                          delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alert show];
                
                PixLogAll(@"Exception %@", e);
                
            }@finally {
                
                return;
            }
        }
    }
}

/**********************************************
 *
 **********************************************/

- (IBAction)styleAction:(id)sender
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Choose a Bill to Client:", @"")
                                                       delegate:self
                                                       cancelButtonTitle:nil
                                                       destructiveButtonTitle:nil
                                                       otherButtonTitles:nil];
    
    UserLocationsDao *userLocationsDao = [[UserLocationsDao alloc]initWithDataBase];
    NSArray *array = [userLocationsDao getBillToClientNames];
    [userLocationsDao closeAll];
    
    for (NSString *title in array) {
        [actionSheet addButtonWithTitle:title];
    }

    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    
	actionSheet.actionSheetStyle = (UIActionSheetStyle)self.navigationController.navigationBar.barStyle;
	
	[actionSheet showInView:self.view];
}

@end
