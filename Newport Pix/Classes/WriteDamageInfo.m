//
//  WriteDamageInfo.m
//  Newport Pix
//
//  Created by Mirko Delgado on 09/18/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import "WriteDamageInfo.h"
#import "Globals.h"

@implementation WriteDamageInfo

NSString *callNumber;
NSString *equipmentID;
NSString *relatedID;

NSString *photoCount;

NSString *proActiveRepair;

NSString *row1;
NSString *row2;
NSString *row3;
NSString *row4;
NSString *row5;
NSString *row6;

static WriteDamageInfo *instance = nil;

- (WriteDamageInfo *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance = [WriteDamageInfo new];
            
            callNumber = @"";
            relatedID = @"";
            photoCount = @"0";
            
            proActiveRepair = @"0";
            
            row1 = @"";
            row2 = @"";
            row3 = @"";
            row4 = @"";
            row5 = @"";
            row6 = @"";
        }
    }
    return instance;
}

/**********************************************
 *
 **********************************************/

- (void) setDmgInfo: (NSString *) call : (NSString *) unitID : (NSString *) relID : (NSString *) pCount : (BOOL) proRepair
{
    callNumber = call;
    equipmentID = unitID;
    relatedID = relID;
    photoCount = pCount;
    
    if (proRepair == YES)
        proActiveRepair = @"1";
    else
        proActiveRepair = @"0";
    
    row1 = @"";
    row2 = @"";
    row3 = @"";
    row4 = @"";
    row5 = @"";
    row6 = @"";    
}

/**********************************************
 *
 **********************************************/

- (void) setRows: (NSArray *) rows {
    row1 = [rows objectAtIndex:0];
    row2 = [rows objectAtIndex:1];
    row3 = [rows objectAtIndex:2];
    row4 = [rows objectAtIndex:3];
    row5 = [rows objectAtIndex:4];
    row6 = [rows objectAtIndex:5];
}

/**********************************************
 *
 **********************************************/

- (void)createFile {
    
	BOOL fileExists, success;
    
    NSString* filename = @"depics";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *depicsWithPath = [documentsDir stringByAppendingPathComponent:filename];
    
    fileExists = [fileManager fileExistsAtPath:depicsWithPath];
	
    if (fileExists) {
        
        success = [fileManager removeItemAtPath:depicsWithPath error:&error];
        
        if (success) {
            PixLog(@"cache file successfully deleted");
        }
        else
        {
            PixLog(@"Could not delete cache file -:%@ ",[error localizedDescription]);
        }
    }

    NSMutableString *data = [NSMutableString stringWithString:@"\aPICS_Taken"];
    
    NSArray *ColumnNames = [NSArray arrayWithObjects:@"\tptBillToClientID",
                                                     @"\tptBillToVendorID",
                                                     @"\tptBillToDepotID",
                                                     @"\tptEquipmentID",
                                                     @"\tptCallNmbr",
                                                     @"\tptRelatedEquipmentID",
                                                     @"\tptUserID",
                                                     @"\tptVendorID",
                                                     @"\tptDepotID",
                                                     @"\tptCount",
                                                     @"\tptRow1",
                                                     @"\tptRow2",
                                                     @"\tptRow3",
                                                     @"\tptRow4",
                                                     @"\tptRow5",
                                                     @"\tptRow6",
                                                     @"\tptProActiveRepair",
                                                     nil];

    for (NSString *colName in ColumnNames)
    {
        [data appendString:colName];
    }
 
    [data appendString:@"\r\n"];
    
    Globals *glbls =[Globals getInstance];
    
    [data appendString:glbls.billToCID];
    [data appendString:@"\t"];
    
    [data appendString:glbls.billToVendorID];
    [data appendString:@"\t"];
    
    [data appendString:glbls.billToDepotID];
    [data appendString:@"\t"];
    
    [data appendString:equipmentID];
    [data appendString:@"\t"];
    
    [data appendString:callNumber];
    [data appendString:@"\t"];
    
    [data appendString:relatedID];
    [data appendString:@"\t"];
    
    [data appendString:glbls.userID];
    [data appendString:@"\t"];
    
    [data appendString:glbls.vendorID];
    [data appendString:@"\t"];
    
    [data appendString:glbls.depotID];
    [data appendString:@"\t"];
    
    [data appendString:photoCount];
    [data appendString:@"\t"];
    
    [data appendString:row1];
    [data appendString:@"\t"];
    
    [data appendString:row2];
    [data appendString:@"\t"];
    
    [data appendString:row3];
    [data appendString:@"\t"];
    
    [data appendString:row4];
    [data appendString:@"\t"];
    
    [data appendString:row5];
    [data appendString:@"\t"];
    
    [data appendString:row6];
    [data appendString:@"\t"];
    
    [data appendString:proActiveRepair];
    [data appendString:@"\t"];
    
    NSData* nsdata = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    [nsdata writeToFile:depicsWithPath atomically:YES];
}

@end
