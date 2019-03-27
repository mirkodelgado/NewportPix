//
//  UserLocationsDao.m
//  Newport Pix
//
//  Created by Mirko Delgado on 08/20/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import "InfoDao.h"
//#import "Globals.h"
#import "SQLiteLock.h"

@implementation InfoDao

/**********************************************
 *
 **********************************************/

-(id)initWithDataBase{
	
	self = [super init];
    
	BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"depics.db"];

    success = [fileManager fileExistsAtPath:dbPath];
	
    if (!success)
    {
		// The writable database does not exist, so copy the default to the appropriate location.
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"depics.db"];
        
		success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        
		if (!success)
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
	}
	
	if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
		
		//PixLog(@"database connection established !!");
	}
	
	return self;
}

/**********************************************
 *
 **********************************************/

-(ResponseInfo *) getResponseInfo {

	sqlite3_stmt *stmt = nil;
    
    ResponseInfo *responseInfo;
    
	@try {
        
		[SQLiteLock getReadWriteLock:YES];
		
		char *sql = "select status, call_number, message, unit_number, photo_count from info";
        
		if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error:getResponseInfo failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
        
        responseInfo = [[ResponseInfo alloc] getInstance];

        
		while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            NSString *status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
            NSString *call_number = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
            NSString *message = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
            NSString *unit_number = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
            NSString *photo_count = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)];
            
            [responseInfo setResponseInfo: status : call_number : message : unit_number : photo_count];
        }
        
	}@catch (NSException *e){
		
		
	}@finally {
		sqlite3_finalize(stmt);
		
		[SQLiteLock freeNotification:YES];
	}
    
    return responseInfo;
}

/**********************************************
 *
 **********************************************/

-(void)closeAll{
	
	if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
}

@end
