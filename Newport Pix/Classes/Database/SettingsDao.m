//
//  SettingsDao.m
//  Newport Pix
//
//  Created by Mirko Delgado on 08/08/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import "SettingsDao.h"
#import "SQLiteLock.h"

static NSString *serverName = @"newportedi.com";
static NSUInteger serverPort = 80;
static NSString *serverPath = @"/newportpix/";

@implementation SettingsDao

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

-(NSUInteger)getDbVersion
{
	sqlite3_stmt *stmt = nil;
    
    NSUInteger version = 0;
    
	@try {
        
		[SQLiteLock getReadWriteLock:YES];
		
		char *sql1 = "select db_version from settings";
        
		if (sqlite3_prepare_v2(database, sql1, -1, &stmt, NULL) != SQLITE_OK)
			version = 0;
        
		if (sqlite3_step(stmt) == SQLITE_ROW)
            version = sqlite3_column_int(stmt, 0);
        
	}@catch (NSException *e){
		
		
	}@finally {
		sqlite3_finalize(stmt);
		
		[SQLiteLock freeNotification:YES];
        
        return version;
	}
}

/**********************************************
 *
 **********************************************/

-(void)updateDbVersion:(NSUInteger)version {
	    
    int success;
    
    sqlite3_stmt *sql_statement = nil;
    
    @try {
        
        [SQLiteLock getReadWriteLock:YES];
        
        if (version == 1)
        {
            char *sql = "insert into settings(db_version, server, port, path) values(?, ?, ?, ?)";
            
            if (sqlite3_prepare_v2(database, sql, -1, &sql_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error:insertSettings failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }

            sqlite3_bind_int (sql_statement, 1, version);
            sqlite3_bind_text(sql_statement, 2, [serverName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int (sql_statement, 3, serverPort);
            sqlite3_bind_text(sql_statement, 4, [serverPath UTF8String], -1, SQLITE_TRANSIENT);
        }
        else
        {
            char *sql = "update settings SET db_version=?";
            
            if (sqlite3_prepare_v2(database, sql, -1, &sql_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error:updateSettings failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
            
            sqlite3_bind_int (sql_statement, 1, version);
        }
        
        // Execute the query.
        success = sqlite3_step(sql_statement);
    }
    @catch (NSException * e) {
        PixLogAll(@"Exception %@", e);
    }
    @finally {
        sqlite3_finalize(sql_statement);
        [SQLiteLock freeNotification:YES];
    }
    
    if (success != SQLITE_DONE) {
        PixLogAll(@"Error:insertLoginUser failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
    }
}

/**********************************************
 *
 **********************************************/

-(NSArray *)getPixSettings
{
	sqlite3_stmt *stmt = nil;
    
    NSMutableArray *values = [[NSMutableArray alloc]init];
    
	@try {
        
		[SQLiteLock getReadWriteLock:YES];
		
		char *sql = "select server, port, path from settings";
        
		if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error:getPixSettings failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    
		if (sqlite3_step(stmt) == SQLITE_ROW) {
            
            [values addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)]];
            [values addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)]];
            [values addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)]];
        }
        
	}@catch (NSException *e){
		
		
	}@finally {
		sqlite3_finalize(stmt);
		
		[SQLiteLock freeNotification:YES];
	}
    
    return values;
}

/**********************************************
 *
 **********************************************/

-(void)updateWithLoginResponse:(NSString *)status : (NSString *)ownername{
	
		sqlite3_stmt *update_statement = nil;
		@try {
			[SQLiteLock getReadWriteLock:YES];
			char *sql = "update me_login set isvalid=?, owner=?";
			if (sqlite3_prepare_v2(database, sql, -1, &update_statement, NULL) != SQLITE_OK) {
				PixLog(@"Error:updateWithLoginResponse failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
			//(@"binding..updateLoginUser");
			sqlite3_bind_text(update_statement, 1, [status UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(update_statement, 2, [ownername UTF8String], -1, SQLITE_TRANSIENT);
			
			//(@"executing..updateLoginUser");
			sqlite3_step(update_statement);
			
		}
		@catch (NSException * e) {
			PixLog(@"Exception %@", e);
		}
		@finally {
			sqlite3_finalize(update_statement);
			[SQLiteLock freeNotification:YES];
		}
}

/**********************************************
 *
 **********************************************/

-(NSUInteger) checkLoginRequired
{
	sqlite3_stmt *stmt0 = nil;
	sqlite3_stmt *stmt = nil;
    
	@try{
		
		[SQLiteLock getReadWriteLock:YES];
		
		char *sql = "select name from sqlite_master where type='table' and name='me_login'";
		if (sqlite3_prepare_v2(database, sql, -1, &stmt0, NULL) != SQLITE_OK) {
			
			
			return 0;
		}else{
			if(sqlite3_step(stmt0) != SQLITE_ROW) {         //mgd+080514
//			if(sqlite3_step(stmt0) != SQLITE_DONE) {
				PixLog(@"me_login table is not exist, activation required !!!");
				return 0;
			}
		}
		
		char *sql1 = "select isremember, isvalid from me_login";
        
        int mgd = sqlite3_prepare_v2(database, sql1, -1, &stmt, NULL);
        
		if (mgd != SQLITE_OK) {
			
			return 1;
		}
		
		if(sqlite3_step(stmt) == SQLITE_ROW) {
			
			char *isremember = (char *)sqlite3_column_text(stmt, 0);
			char *isvalid = (char *)sqlite3_column_text(stmt, 1);
			//MELog(@"isremember= %s",isremember);
			//MELog(@"isvalid= %s",isvalid);
			if(strcmp(isremember , "0") == 0 || strcmp(isvalid, "0")== 0){
				//MELog(@"login display");
				return 1;//go to login page
			}else{
				//MELog(@"tab display");
				return 2;//goto tab display
			}
			
		}else{
			
			//MELog(@"no row exist in me_login table, activation required !!!");
			return 1;
		}
	}@catch(NSException *e){
		
	}@finally{
		sqlite3_finalize(stmt0);
		if(stmt != nil)
			sqlite3_finalize(stmt);
		[SQLiteLock freeNotification:YES];
	}
	return 0;
}

/**********************************************
 *
 **********************************************/

-(NSString *)getUserName{
	
	sqlite3_stmt *stmt = nil;
	@try{
		[SQLiteLock getReadWriteLock:YES];
		//(@"getUserName");
		
		char *sql1 = "select user from me_login";
		if (sqlite3_prepare_v2(database, sql1, -1, &stmt, NULL) != SQLITE_OK) {
			
			return @"";
		}
		if(sqlite3_step(stmt) == SQLITE_ROW) {
			
			return [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
		}
	}@catch(NSException *e){
		
		
	}@finally{
		sqlite3_finalize(stmt);
		
		[SQLiteLock freeNotification:YES];
	}
	return @"";
}

/**********************************************
 *
 **********************************************/

-(NSString *)getOwnerName{
	
	sqlite3_stmt *stmt = nil;
	NSString *ownerName = @"";
	@try{
		
		//(@"getOwnerName");
		[SQLiteLock getReadWriteLock:NO];
		
		char *sql1 = "select owner from me_login";
		if (sqlite3_prepare_v2(database, sql1, -1, &stmt, NULL) != SQLITE_OK) {
			
			//return @"";
		}
		if(sqlite3_step(stmt) == SQLITE_ROW) {
			
			ownerName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
			//MELog(@"gettinggg owner name = %@", ownerName);
			
			//return ownerName;
		}
	}@catch(NSException *e){
		
		
	}@finally{
		sqlite3_finalize(stmt);
	
		[SQLiteLock freeNotification:NO];
	}
	return ownerName;
}

/**********************************************
 *
 **********************************************/

-(void)closeAll{
	
	if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
}

//- (void)dealloc {
//    [super dealloc];
//}

@end
