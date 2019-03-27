//
//  UserLocationsDao.m
//  Newport Pix
//
//  Created by Mirko Delgado on 08/20/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import "UserLocationsDao.h"
#import "Globals.h"
#import "SQLiteLock.h"

@implementation UserLocationsDao

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

-(NSMutableArray *) getBillToClientNames {

	sqlite3_stmt *stmt = nil;
    
    NSMutableArray *dataArray;
    
	@try {
        
		[SQLiteLock getReadWriteLock:YES];
		
		char *sql = "select BillToClientName from user_locations";
        
		if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error:getBillToClientNames failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
        
        NSUInteger rows = sqlite3_column_count(stmt);   //mgd-not right

        dataArray = [[NSMutableArray alloc] initWithCapacity: rows];
        
        NSUInteger index = 0;
        
		while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            [dataArray insertObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)] atIndex:index];
            
            index++;
        }
        
        [dataArray insertObject:nil atIndex:index];
        
	}@catch (NSException *e){
		
		
	}@finally {
		sqlite3_finalize(stmt);
		
		[SQLiteLock freeNotification:YES];
	}
    
    return dataArray;
}

/**********************************************
 *
 **********************************************/

-(void) setActiveClientInfo {
    
	sqlite3_stmt *stmt = nil;
    
	@try {
        
		[SQLiteLock getReadWriteLock:YES];
		
		char *sql = "select _id, VendorID, DepotID, BillToClientID, BillToVendorID, BillToDepotID, BillToClientName, PixClient, Row1, Row2, Row3, Row4, Row5, Row6 from user_locations where ActiveClient = '1'";
        
		if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error:setActiveClientInfo failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
        
//        NSUInteger rows = sqlite3_column_count(stmt);   //mgd-not right
                
//        if (rows > 1)
//            PixLog(@"More than one row returned in setActiveClientInfo");
		
        Globals *glbls =[Globals getInstance];
        
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            
            [Globals setActiveClient:YES];
            
            glbls.recID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)];
            glbls.vendorID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
            glbls.depotID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)];
            glbls.billToCID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)];
            glbls.billToVendorID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)];
            glbls.billToDepotID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 5)];
            glbls.billToClientName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)];
            
            NSString *pixClient = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 7)];
            
            if ([pixClient isEqualToString:@"1"])
                [Globals setPixClient:YES];
            else
                [Globals setPixClient:NO];
            
            glbls.row1 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 8)];
            glbls.row2 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 9)];
            glbls.row3 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 10)];
            glbls.row4 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 11)];
            glbls.row5 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 12)];
            glbls.row6 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 13)];
        }
        
	}@catch (NSException *e){
		
		
	}@finally {
		sqlite3_finalize(stmt);
		
		[SQLiteLock freeNotification:YES];
	}
    
    return;
}

/**********************************************
 *
 **********************************************/

-(void) updateBillToClientInfo: billToClientName {
    
    int success;
    
	sqlite3_stmt *stmt1 = nil;
	sqlite3_stmt *stmt2 = nil;
	sqlite3_stmt *stmt3 = nil;
    
	@try {
        
		[SQLiteLock getReadWriteLock:YES];

		char *sql1 = "update user_locations set ActiveClient = '0' where ActiveClient = '1'";
        
		if (sqlite3_prepare_v2(database, sql1, -1, &stmt1, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error:updateBillToClientInfo:Update ActiveClient failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
        
        success = sqlite3_step(stmt1);       // Execute the query
        
        sqlite3_finalize(stmt1);
        
		char *sql2 = "update user_locations set ActiveClient = '1' where BillToClientName = ?";
        
		if (sqlite3_prepare_v2(database, sql2, -1, &stmt2, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error:updateBillToClientInfo:Update of ActiveClient for new BillToClientName failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }

        sqlite3_bind_text(stmt2, 1, [billToClientName UTF8String], -1, SQLITE_TRANSIENT);
        
        success = sqlite3_step(stmt2);       // Execute the query

		sqlite3_finalize(stmt2);

		char *sql3 = "select _id, VendorID, DepotID, BillToClientID, BillToVendorID, BillToDepotID, BillToClientName, PixClient, Row1, Row2, Row3, Row4, Row5, Row6 from user_locations where ActiveClient = '1'";
        
		if (sqlite3_prepare_v2(database, sql3, -1, &stmt3, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error:updateBillToClientInfo:Select failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
        
        NSUInteger rows = sqlite3_column_count(stmt3);  //mgd-not right
        
        if (rows > 1)
            PixLog(@"More than one row returned in updateBillToClientInfo");
		
        Globals *glbls =[Globals getInstance];
        
        if (sqlite3_step(stmt3) == SQLITE_ROW) {
            
            [Globals setActiveClient:YES];
            
            glbls.recID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt3, 0)];
            glbls.vendorID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt3, 1)];
            glbls.depotID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt3, 2)];
            glbls.billToCID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt3, 3)];
            glbls.billToVendorID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt3, 4)];
            glbls.billToDepotID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt3, 5)];
            glbls.billToClientName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt3, 6)];
            
            NSString *pixClient = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt3, 7)];
            
            if ([pixClient isEqualToString:@"1"])
                [Globals setPixClient:YES];
            else
                [Globals setPixClient:NO];
            
            glbls.row1 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt3, 8)];
            glbls.row2 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt3, 9)];
            glbls.row3 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt3, 10)];
            glbls.row4 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt3, 11)];
            glbls.row5 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt3, 12)];
            glbls.row6 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt3, 13)];
        }

	}@catch (NSException *e){
		
		
	}@finally {
		sqlite3_finalize(stmt3);
		
		[SQLiteLock freeNotification:YES];
	}
    
    return;
}





/*
 
 
 
 -(NSArray *)getAllWritableModule{
 
 const char *sql = "select module_id, menuname, grouped from cad_menuitems where readonly='0'";
 sqlite3_stmt *stmt;
 NSMutableArray *arrayIdss = [[NSMutableArray alloc]init];
 
 if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) == SQLITE_OK) {
 
 
 
 [SQLiteLock getReadWriteLock:NO];
 while (sqlite3_step(stmt) == SQLITE_ROW) {
 
 NSUInteger entityId = sqlite3_column_int(stmt, 0);
 
 NSString *moduleid = [NSString stringWithFormat:@"%i", entityId];
 
 NSString *menuname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)];
 
 
 char *grouped = (char *)sqlite3_column_text(stmt, 2);
 NSString *grpd = @"NO";
 if(strcmp(grouped, "1") == 0){
 grpd = @"YES";
 }
 
 NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:moduleid, @"moduleid",menuname, @"menuname", grpd, @"grouped", nil];
 //[arrayIdss setValue:<#(id)value#> forKey:<#(NSString *)dicty#>
 [arrayIdss addObject:dict];
 }
 [SQLiteLock freeNotification:NO];
 sqlite3_finalize(stmt);
 }
 
 return [arrayIdss autorelease];
 }
 
 
*********************************************************************
 
 
-(NSArray *)getAllFromQueue{
	
	NSMutableArray *requestQ = nil;
	
	@try {
		
		//check CAD received or not !!
		sqlite3_stmt *listStmt = nil;
		const char *cadsql = "select count(*) from me_requestqueue where  strftime('%s', datetime(current_timestamp, 'localtime')) - strftime('%s', createdtime) > (retryinterval*60)";
		NSUInteger count = 0;
		
		if (sqlite3_prepare_v2(database, cadsql, -1, &listStmt, NULL) == SQLITE_OK) {
			
			[SQLiteLock getReadWriteLock:NO];
            
			if (sqlite3_step(listStmt) == SQLITE_ROW) {
				
				count = sqlite3_column_int(listStmt, 0);
			}
			sqlite3_finalize(listStmt);
            
			[SQLiteLock freeNotification:NO];
            
		}else{
			
			PixLog(@"Error: listAllTables failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
		
		if(count == 0){
			
			return nil;
		}
		
		requestQ = [[NSMutableArray alloc] init];
		
		//retrive all
		
		NSMutableArray *array = [[NSMutableArray alloc]init];
		
		sqlite3_stmt *selectStmt = nil;//datetime('2009-04-30 06:23:22')
		char *sql = "select  xml_data, auto_number from me_requestqueue where  strftime('%s', datetime(current_timestamp, 'localtime')) - strftime('%s', createdtime) > (retryinterval*60)   order by auto_number";//retryinterval > 0
		
		if (sqlite3_prepare_v2(database, sql, -1, &selectStmt, NULL) != SQLITE_OK) {
			PixLog(@"Error:removeFromQueue failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}else{
			
			[SQLiteLock getReadWriteLock:NO];
			
			while(sqlite3_step(selectStmt) == SQLITE_ROW) {
				
				[requestQ addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStmt, 0)]];
				
				NSUInteger meauto = sqlite3_column_int(selectStmt, 1);
				
				[array addObject:[NSNumber numberWithInt:meauto]];
				
			}
			sqlite3_finalize(selectStmt);
			[SQLiteLock freeNotification:NO];
			
		}
		
		//update retrieved records
		//if retryinterval is less than 16 update with retryinterval *=3
		//if >=16 update the created time with current time
		
		if([array count] > 0){
			
			NSMutableString *updateTimeSql = [[NSMutableString alloc]initWithString:@"update me_requestqueue set retryinterval=retryinterval+1 , createdtime =datetime(current_timestamp, 'localtime') where retryinterval>=18 and auto_number in("];
			NSMutableString *updateSql = [[NSMutableString alloc]initWithString:@"update me_requestqueue set retryinterval = retryinterval*3, createdtime =datetime(current_timestamp, 'localtime') where retryinterval<18 and auto_number in("];
			for(NSUInteger i=0; i<[array count] ; i++){
				
				NSUInteger n = [[array objectAtIndex:i] intValue];
				if(i==0){
					[updateSql appendFormat:@"%i", n];
					[updateTimeSql appendFormat:@"%i", n];
					
				}else{
					
					[updateSql appendFormat:@",%i", n];
					[updateTimeSql appendFormat:@",%i", n];
				}
			}
			[updateSql appendString:@")"];
			[updateTimeSql appendString:@")"];
			
			//update time
			sqlite3_stmt *updateStmt2 = nil;
            
			if (sqlite3_prepare_v2(database, [updateTimeSql UTF8String], -1, &updateStmt2, NULL) != SQLITE_OK) {
				PixLog(@"Error:update requestTable failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
            //			[updateTimeSql release];
			
			[SQLiteLock getReadWriteLock:YES];
			
			NSUInteger sucessint = sqlite3_step(updateStmt2);
			
			if (sucessint != SQLITE_DONE) {
				PixLog(@"Error:update request table failed to delete with message '%s'.", sqlite3_errmsg(database));
				
			}
			sqlite3_finalize(updateStmt2);
			[SQLiteLock freeNotification:YES];
            
			//update retryinterval
			sqlite3_stmt *updateStmt1 = nil;
            
			if (sqlite3_prepare_v2(database, [updateSql UTF8String], -1, &updateStmt1, NULL) != SQLITE_OK) {
				PixLog(@"Error:update requestTable failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
            //			[updateSql release];
			
			[SQLiteLock getReadWriteLock:YES];
			
            sucessint = sqlite3_step(updateStmt1);
			
			if (sucessint != SQLITE_DONE) {
				PixLog(@"Error:update request table failed to delete with message '%s'.", sqlite3_errmsg(database));
				
			}
			sqlite3_finalize(updateStmt1);
			[SQLiteLock freeNotification:YES];
            
		}
        
        //		[array release];
	}
	@catch (NSException * e) {
		
		PixLog(@"Exception %@", e);
	}
	@finally {
		
		
	}
	
    //	return [requestQ autorelease];
	return requestQ;
	
}


*/






/**********************************************
 *
 **********************************************/

-(void)updateWithLoginResponse:(NSString *)status owner:(NSString *)ownername{
	
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

-(NSUInteger) checkLoginRequired{
	
	sqlite3_stmt *stmt0 = nil;
	sqlite3_stmt *stmt = nil;
	@try{
		
		//MELog(@"checkLoginRequired");
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
		
		//MELog(@"row exist in me_login table");
		
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
