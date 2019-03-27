//
//  SQLiteLock.h
//  NewportPix
//
//  Created by Mirko Delgado on 08/08/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

/*
 We are aware of no other embedded SQL database engine that supports as much concurrency as SQLite. SQLite allows multiple processes to have the database file open at once, 
 and for multiple processes to read the database at once. When any process wants to write, it must lock the entire database file for the duration of its update. 
 But that normally only takes a few milliseconds. Other processes just wait on the writer to finish then continue about their business. 
 Other embedded SQL database engines typically only allow a single process to connect to the database at once.
 
 When SQLite tries to access a file that is locked by another process, the default behavior is to return SQLITE_BUSY. 
 You can adjust this behavior from C code using the sqlite3_busy_handler() or sqlite3_busy_timeout() API functions.
 ref:http://www.sqlite.org/faq.html
 
 the static NSString *lock is used to synchronize all create and insert, update and delete statemets.
 
 */

#import <UIKit/UIKit.h>

@interface SQLiteLock : NSObject {

}
+(id)getReadWriteLock:(BOOL)isWrite;
+(void)freeNotification:(BOOL)isWrite;

@end
