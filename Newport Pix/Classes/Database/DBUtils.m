//
//  DBUtils.m
//  Newport Pix
//
//  Created by Mirko Delgado on 08/08/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import "DBUtils.h"
#import "SQLiteLock.h"

static NSUInteger numlines = 0;
static NSUInteger linesprocessed = 0;

@implementation DBUtils

-(id)initWithDataBase{
	
	self = [super init]; 
	
	BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    NSString *documentsDirectory = [paths objectAtIndex:0];    
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"depics.db"];
    
    success = [fileManager fileExistsAtPath:dbPath];
	
    if (!success){
		
		// The writable database does not exist, so copy the default to the appropriate location.
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"depics.db"];
        
		success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        
		if (!success) {
			PixLog(@"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		}
	}
	
	if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {		
		
		//PixLog(@"database connection established !!");
	}
		
	return self;	
}

/**********************************************
 *
 **********************************************/

-(void) createPixTables{

	[SQLiteLock getReadWriteLock:YES];
	
    [self createCallTable];
    [self createInfoTable];
    [self createSettingsTable];
    [self createUserLocationsTable];
    
	[SQLiteLock freeNotification:YES];
}

/**********************************************
 *
 **********************************************/

-(void) updatePixTables{
    
	[SQLiteLock getReadWriteLock:YES];
	
    [self updateCallTable];
    [self updateInfoTable];
//    [self updateSettingsTable];
    [self updateUserLocationsTable];
    
	[SQLiteLock freeNotification:YES];
}

/**********************************************
 *
 **********************************************/

-(void) createCallTable{
    
	char *createCallTbl = "create table if not exists calls(CallNumber text, EquipmentID text not null, RelatedEquipmentID text, PictureCount text not null, CallStatus text not null, primary key (CallNumber))";
    
	if (sqlite3_exec(database, createCallTbl, NULL, NULL, NULL) == SQLITE_OK){
		PixLog(@"call table created");
	}
}

/**********************************************
 *
 **********************************************/

-(void) updateCallTable{
    
	char *dropCallTbl = "drop table if exists calls";
    
	if (sqlite3_exec(database, dropCallTbl, NULL, NULL, NULL) == SQLITE_OK){
		PixLog(@"call table deleted");
        
        [self createCallTable];
	}
}

/**********************************************
 *
 **********************************************/

+(NSArray *)callTableColumns
{
    static NSArray *callTblColumns;
    
    if (nil == callTblColumns) {
        callTblColumns = [NSArray arrayWithObjects:@"CallNumber", @"EquipmentID", @"RelatedEquipmentID", @"PictureCount", @"CallStatus", nil];
    }
    
    return callTblColumns;
}

/**********************************************
 *
 **********************************************/

-(void) createInfoTable{
    
	char *createInfoTbl = "create table if not exists info(_id integer, status text, call_number text, message text, unit_number text, photo_count integer, primary key (_id))";
    
	if (sqlite3_exec(database, createInfoTbl, NULL, NULL, NULL) == SQLITE_OK){
		PixLog(@"info table created");
	}
}

/**********************************************
 *
 **********************************************/

-(void) updateInfoTable{
    
	char *dropInfoTbl = "drop table if exists info";
    
	if (sqlite3_exec(database, dropInfoTbl, NULL, NULL, NULL) == SQLITE_OK){
		PixLog(@"info table deleted");
        
        [self createInfoTable];
	}
}

/**********************************************
 *
 **********************************************/

+ (NSArray *)infoTableColumns
{
    static NSArray *infoTblColumns;
    
    if (nil == infoTblColumns) {
        infoTblColumns = [NSArray arrayWithObjects:@"_id", @"status", @"call_number", @"message", @"unit_number", @"photo_count", nil];
    }
    
    return infoTblColumns;
}

/**********************************************
 *
 **********************************************/

-(void) createSettingsTable{
    
	char *createSettingsTbl = "create table if not exists settings(db_version integer, server text, port integer, path text)";
    
	if (sqlite3_exec(database, createSettingsTbl, NULL, NULL, NULL) == SQLITE_OK){
		PixLog(@"settings table created");
	}
}

/**********************************************
 *
 **********************************************/

-(void) updateSettingsTable{
    
	char *dropSettingsTbl = "drop table if exists settings";
    
	if (sqlite3_exec(database, dropSettingsTbl, NULL, NULL, NULL) == SQLITE_OK){
		PixLog(@"settings table deleted");
        
        [self createSettingsTable];
	}
}

/**********************************************
 *
 **********************************************/

+ (NSArray *)settingsTableColumns
{
    static NSArray *settingsTblColumns;
    
    if (nil == settingsTblColumns) {
        settingsTblColumns = [NSArray arrayWithObjects:@"db_version", @"server", @"port", @"path", nil];
    }
    
    return settingsTblColumns;
}

/**********************************************
 *
 **********************************************/

-(void) createUserLocationsTable{
    
	char *createUserLocationsTbl = "create table if not exists user_locations(_id integer, VendorID text not null, DepotID text not null, BillToClientID text not null, BillToVendorID text not null, BillToDepotID text not null, BillToClientName text not null, ActiveClient text not null, PixClient text not null, Row1 text, Row2 text, Row3 text, Row4 text, Row5 text, Row6 text)";
    
	if (sqlite3_exec(database, createUserLocationsTbl, NULL, NULL, NULL) == SQLITE_OK){
		PixLog(@"user locations table created");
	}
}

/**********************************************
 *
 **********************************************/

-(void) updateUserLocationsTable{
    
	char *dropUserLocationsTbl = "drop table if exists user_locations";
    
	if (sqlite3_exec(database, dropUserLocationsTbl, NULL, NULL, NULL) == SQLITE_OK){
		PixLog(@"user locations table deleted");
        
        [self createUserLocationsTable];
	}
}

/**********************************************
 *
 **********************************************/

+ (NSArray *)userlocationsTableColumns
{
    static NSArray *userlocationsTblColumns;
    
    if (nil == userlocationsTblColumns) {
        userlocationsTblColumns = [NSArray arrayWithObjects:@"_id", @"VendorID", @"DepotID", @"BillToClientID", @"BillToVendorID", @"BillToDepotID", @"BillToClientName", @"ActiveClient", @"PixClient", @"Row1", @"Row2", @"Row3", @"Row4", @"Row5", @"Row6", nil];
    }
    
    return userlocationsTblColumns;
}

/**********************************************
 *
 **********************************************/

-(void) processRequest: (NSData *)data{

	BOOL fileExists, success;
    
    NSString* filename = @"cache";

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *cachePath = [documentsDir stringByAppendingPathComponent:filename];

    fileExists = [fileManager fileExistsAtPath:cachePath];
	
    if (fileExists) {
    
        success = [fileManager removeItemAtPath:cachePath error:&error];
        
        if (success) {
            PixLog(@"cache file successfully deleted");
        }
        else
        {
            PixLog(@"Could not delete cache file -:%@ ",[error localizedDescription]);
        }
    }
    
    if (data) {
//        NSString *content = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding: NSUTF8StringEncoding];
//        NSLog(@"%@", content); // verifies data was downloaded correctly
        
//        NSError* error;
        success = [data writeToFile:cachePath options:NSDataWritingAtomic error:&error];
        
        if (success == NO)
            PixLog(@"write error %@", error);
    }
    
    NSString *dataFile = [NSString stringWithContentsOfFile:cachePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSScanner *scanner = [NSScanner scannerWithString:dataFile];
    NSString *foundString;
    scanner.charactersToBeSkipped = nil;
    
    NSMutableString *formattedResponse = [NSMutableString string];

    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];

    NSArray* pieces;
    numlines = 0;
    linesprocessed = 0;
    
    if ([scanner scanUpToString:@"\n" intoString:&foundString]) {
        [formattedResponse appendString:foundString];
 
        pieces = [foundString componentsSeparatedByString: @"\t"];
        
        if (([pieces count] != 3) || [[pieces objectAtIndex: 0] caseInsensitiveCompare:@"meta"] != NSOrderedSame)
            [NSException raise:@"InvalidArguementException" format:@"invalid length or meta"];
    }
    
    numlines = [[pieces objectAtIndex: 2] intValue];
    
    while(![scanner isAtEnd]) {
        
        [scanner scanString:@"\n" intoString:nil];
        foundString = @"";
        
        if([scanner scanUpToString:@"\n" intoString:&foundString]) {
            [formattedResponse appendString:foundString];

            linesprocessed++;
            
            pieces = [foundString componentsSeparatedByString: @"\t"];

            NSString *cmd = [[pieces objectAtIndex: 0] uppercaseString];
            
            if ([cmd isEqualToString:@"0"] || [cmd isEqualToString:@""])
                continue;
            
            NSString *currTableName;
            NSString *currTable;
            NSString *tariffID;
            NSUInteger count = 0;
            
            Commands command = [self CommandEnumFromString:cmd];
            
            switch (command)
            {
                case CLEAR:
                    currTableName = [pieces objectAtIndex: 1];
                    currTable = [DBUtils validateTableName:currTableName];
                    
                    if ([currTable length] == 0)
                        continue;
                    
                    [self clearRecords:currTable];
                    break;
                    
                case CLEARTARIFF:
                    currTableName = [pieces objectAtIndex: 1];
                    currTable = [DBUtils validateTableName:currTableName];
                    
                    if ([currTable length] == 0)
                        continue;
                    
                    tariffID = [pieces objectAtIndex: 2];
                    
                    [self clearTariffRecords:currTable : tariffID];                    
                    break;
                    
                case INSERTHERE:
                    
                    count = [[pieces objectAtIndex: 1] intValue];
                    
                    [self importData:scanner : count];
                    break;
                    
                case ERROR:
                    [NSException raise:@"InvalidArguementException" format:@"%@", (NSString *)[pieces objectAtIndex: 1]];
                    break;
                    
                case UNKNOWN:
                    break;
            }
        }
    }
}





/**********************************************
 *
 **********************************************/

-(void)closeAll{
		
	if (sqlite3_close(database) != SQLITE_OK) {
        PixLogAll(@"Error:DBUtils. failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
}


/**********************************************
 *
 **********************************************/

- (void)importData: (NSScanner *) scanner : (NSUInteger) lines {
    
    NSString *currline;
    NSString *currTable;
    NSString *currTableName;

    NSUInteger linenum = 0;

    NSString *foundString;
    NSMutableString *formattedResponse = [NSMutableString string];

    NSMutableArray *columnNames;
    
    BOOL skipTable = NO;
    
    NSUInteger i = 0;
    
    while ((linenum < lines) && (![scanner isAtEnd])) {
        
        [scanner scanString:@"\n" intoString:nil];
        foundString = @"";
        
        if ([scanner scanUpToString:@"\n" intoString:&foundString]) {
            [formattedResponse appendString:foundString];
            
            if ([foundString hasPrefix:@"\a"])
            {
                currline = [foundString substringFromIndex:1];
                
                NSArray *lineInfo = [currline componentsSeparatedByString: @"\t"];
                
                currTableName = [lineInfo objectAtIndex: 0];
                currTable = [DBUtils validateTableName:currTableName];
                
                if ([currTable length] == 0)
                {
                    skipTable = YES;
                    continue;
                }
                
                columnNames = [[NSMutableArray alloc]init];
                
                NSUInteger size = [lineInfo count];

                for (i = 1; i < size; i++)
                    [columnNames addObject:[lineInfo objectAtIndex: i]];
                
                for (i = 0; i < [columnNames count]; i++)
                {
                    NSString *colName = [columnNames objectAtIndex: i];
                    
                    if ([DBUtils containsColumn: currTable : colName] == NO)
                    {
                        PixLog(@"Could not find column %@", [columnNames objectAtIndex: i]);
                        [columnNames replaceObjectAtIndex:i withObject:@""];
                    }
                }
            }
            else if (skipTable == YES)
            {
                continue;
            }
            else
            {
                NSArray *pieces = [foundString componentsSeparatedByString: @"\t"];
                
                [self insertRecord: currTable : columnNames : pieces];
            }
        }
        
        linenum++;
    }
}

/**********************************************
 *
 **********************************************/

- (void)insertRecord: (NSString *) tableName : (NSMutableArray *) columnNames : (NSArray *) pieces {
    
    int success;
    
    sqlite3_stmt *sql_statement = nil;
    
    @try {
        
        [SQLiteLock getReadWriteLock:YES];
    
        NSMutableString *insRecordInfo = [NSMutableString stringWithString:@"insert into "];
        [insRecordInfo appendString:tableName];
    
        [insRecordInfo appendString:@" ("];
    
        NSUInteger i = 0;
        NSUInteger count = 0;

        for (i = 0; i < [columnNames count]; i++)
        {
            NSString *colName = [columnNames objectAtIndex: i];
        
            if ([colName isEqualToString:@""]) {
            }
            else
            {
                [insRecordInfo appendString:colName];
            
                count++;
            
                if (count < [columnNames count])
                    [insRecordInfo appendString:@", "];
            }
        }

        [insRecordInfo appendString:@") values ("];

        NSUInteger qcount = 0;
    
        for (i = 0; i < count; i++)
        {
            [insRecordInfo appendString:@"?"];
        
            qcount++;
            
            if (qcount < count)
                [insRecordInfo appendString:@", "];
        }
    
        [insRecordInfo appendString:@");"];
    
        const char *insertRecordInfo = [insRecordInfo UTF8String];
        
        if (sqlite3_prepare_v2(database, insertRecordInfo, -1, &sql_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error:insertSettings failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }

        for (i = 0; i < [columnNames count]; i++)
        {
            NSString *colName = [columnNames objectAtIndex: i];
            
            if ([colName isEqualToString:@""]) {
            }
            else
            {
                NSUInteger pcount = [pieces count];
                
                NSString *colvalue = [pieces objectAtIndex: i];
                
                sqlite3_bind_text(sql_statement, i + 1, [colvalue UTF8String], -1, SQLITE_TRANSIENT);
            }
        }
        
        success = sqlite3_step(sql_statement);  // Execute the query
    }
    @catch (NSException * e) {
        PixLogAll(@"Exception %@", e);
    }
    @finally {
        sqlite3_finalize(sql_statement);
        [SQLiteLock freeNotification:YES];
    }
    
    if (success != SQLITE_DONE) {
        PixLogAll(@"Error:insertRecord failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
    }
}

/**********************************************
 *
 **********************************************/

- (void)clearRecords: (NSString *) tableName {

	[SQLiteLock getReadWriteLock:YES];

    NSMutableString *clrRecordInfo = [NSMutableString stringWithString:@"delete from "];
    [clrRecordInfo appendString:tableName];
    
    const char *clearRecordInfo = [clrRecordInfo UTF8String];
    
	if (sqlite3_exec(database, clearRecordInfo, NULL, NULL, NULL) == SQLITE_OK){
		PixLog(@"records deleted from %@", tableName);
	}
    
	[SQLiteLock freeNotification:YES];
}

/**********************************************
 *
 **********************************************/

- (void)clearTariffRecords: (NSString *) tableName : (NSString *) tariffID {
    
	[SQLiteLock getReadWriteLock:YES];
    
    NSMutableString *clrRecordInfo = [NSMutableString stringWithString:@"delete * from "];
    [clrRecordInfo appendString:tableName];
    [clrRecordInfo appendString:@" where tariff_id = "];
    [clrRecordInfo appendString:tariffID];
    
    const char *clearRecordInfo = [clrRecordInfo UTF8String];
    
	if (sqlite3_exec(database, clearRecordInfo, NULL, NULL, NULL) == SQLITE_OK){
		PixLog(@"records deleted from %@ for tariff %@", tableName, tariffID);
	}
    
	[SQLiteLock freeNotification:YES];
}

/**********************************************
 *
 **********************************************/

+ (BOOL)containsColumn: (NSString *) currTable : (NSString *) columnName {

    BOOL columnExists = NO;
    
    NSArray *columnNames;
    
    if ([currTable isEqualToString:@"user_locations"])
        columnNames = [DBUtils userlocationsTableColumns];
    else if ([currTable isEqualToString:@"info"])
        columnNames = [DBUtils infoTableColumns];
    else if ([currTable isEqualToString:@"calls"])
        columnNames = [DBUtils callTableColumns];
    else if ([currTable isEqualToString:@"settings"])
        columnNames = [DBUtils settingsTableColumns];
    
    for (NSUInteger i = 0; i < [columnNames count]; i++)
    {
        NSString *colName = [columnNames objectAtIndex: i];
        
        if ([colName isEqualToString:columnName]) {
            columnExists = YES;
            break;
        }
    }
    
    return columnExists;
}

/**********************************************
 *
 **********************************************/

+ (NSString *)validateTableName: (NSString *) tableName {
    
    if ([tableName isEqualToString:@"user_locations"])
    	return @"user_locations";
    else if ([tableName isEqualToString:@"info"])
    	return @"info";
    else if ([tableName isEqualToString:@"calls"])
    	return @"calls";
    else if ([tableName isEqualToString:@"settings"])
    	return @"settings";
    
    return nil;
}

/**********************************************
 *
 **********************************************/

- (Commands)CommandEnumFromString: (NSString *) cmd {

    if ([cmd isEqualToString:@"CLEAR"])
    	return CLEAR;
    if ([cmd isEqualToString:@"CLEARTARIFF"])
    	return CLEARTARIFF;
    if ([cmd isEqualToString:@"INSERTHERE"])
    	return INSERTHERE;
    if ([cmd isEqualToString:@"ERROR"])
    	return ERROR;
    
    return UNKNOWN;
}

@end
