//
//  DBUtils.h
//  Newport Pix
//
//  Created by Mirko Delgado on 08/08/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

#define iosDbVersion	    1               // only change if DB schema has changed

@interface DBUtils : NSObject {

	sqlite3 *database;	
}

- (id)initWithDataBase;

- (void) createPixTables;
- (void) updatePixTables;

- (void) processRequest: (NSData *)returnedData;

+ (NSArray *) callTableColumns;
+ (NSArray *) infoTableColumns;
+ (NSArray *) settingsTableColumns;
+ (NSArray *) userlocationsTableColumns;

- (void) closeAll;

- (void) importData: (NSScanner *) data : (NSUInteger) lines;

- (void) insertRecord: (NSString *) currTable : (NSMutableArray *) columnNames : (NSArray *) pieces;
- (void) clearRecords: (NSString *) tableName;
- (void) clearTariffRecords: (NSString *) tableName : (NSString *) tariffID;

+ (NSString *) validateTableName: (NSString *) tableName;

+ (BOOL) containsColumn: (NSString *) currTable : (NSString *) columnName;

/**********************************************
 *
 **********************************************/

typedef enum
{
    CLEAR, CLEARTARIFF, INSERTHERE, ERROR, UNKNOWN
    
} Commands;

-(Commands) CommandEnumFromString: (NSString *)cmd;

@end
