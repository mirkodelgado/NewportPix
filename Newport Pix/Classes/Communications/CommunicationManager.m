//
//  CommunicationManager.m
//  Newport Pix
//
//  Created by Mirko Delgado on 08/12/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import "CommunicationManager.h"

#import "SettingsDao.h"
//#import "DBUtils.h"
#import "NetworkUtil.h"

static NSString *Uri;

static NSString *authenticateUser = @"AuthenticateUser/";
static NSString *clientCalls = @"ClientCalls/";
static NSString *damagedEquipmentInfo = @"DEPInfo/";

@implementation CommunicationManager

/**********************************************
 *
 **********************************************/

-(id)initCommunicationManager{
	
	self = [super init];
    
	SettingsDao *settingsDao = [[SettingsDao alloc] initWithDataBase];
    NSArray *values = [settingsDao getPixSettings];
    [settingsDao closeAll];

    NSMutableString *url = [NSMutableString stringWithString:@"http://"];
    [url appendString:[values objectAtIndex:0]];
    [url appendString:@":"];
    [url appendString:[values objectAtIndex:1]];
    [url appendString:[values objectAtIndex:2]];
    
    Uri = url;
    
	return self;
}

/**********************************************
 *
 **********************************************/

-(NSData *)doLogin:(NSString *)username : (NSString *)password {
	
	NSData *returnData = nil;
    
	@try{
        
		[NetworkUtil showNWActivityIndicator];

        NSMutableString *loginUrl = [NSMutableString stringWithString:Uri];
        [loginUrl appendString:authenticateUser];
        
		NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [NSURL URLWithString: loginUrl]];
        
        PixLogAll(@"%@", loginUrl);
        
		[request setHTTPMethod: @"GET" ];

        NSMutableString *value = [NSMutableString stringWithString:@"password="];
        [value appendString:password];
        [value appendString:@";username="];
        [value appendString:username];
        [value appendString:@";"];
        
		[request setValue:value forHTTPHeaderField:@"Cookie"];
        
        NSHTTPURLResponse *response = nil;
		NSError *error = nil;
        
		returnData = [NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&error];

		request = nil;
		
		if (error){
			PixLogAll(@"%@", [error description]);
		}
        
        PixLogAll(@"Status code: %ld", (long)[response statusCode]);
		
	}@catch (NSException *e) {
		PixLog(@"doLogin %@", e);
	}@finally {
		[NetworkUtil hideNWActivityIndicator];
	}
	return returnData;
}

/**********************************************
 *
 **********************************************/

-(NSData *)doClientCallsRequest:(NSString *)billToClientID : (NSString *)billToVendorID : (NSString *)billToDepotID {
	
	NSData *returnData = nil;
    
	@try{
        
		[NetworkUtil showNWActivityIndicator];
        
        NSMutableString *callsUrl = [NSMutableString stringWithString:Uri];
        [callsUrl appendString:clientCalls];
        [callsUrl appendString:@"?BillToClient="];
        [callsUrl appendString:billToClientID];
        [callsUrl appendString:@"&BillToVendor="];
        [callsUrl appendString:billToVendorID];
        [callsUrl appendString:@"&BillToDepot="];
        [callsUrl appendString:billToDepotID];
        
		NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [NSURL URLWithString: callsUrl]];
        
        PixLogAll(@"%@", callsUrl);
        
		[request setHTTPMethod: @"GET" ];
        
//        NSMutableString *value = [NSMutableString stringWithString:@"password="];
//        [value appendString:password];
//        [value appendString:@";username="];
//        [value appendString:username];
//        [value appendString:@";"];
        
//		[request setValue:value forHTTPHeaderField:@"Cookie"];
        
        NSHTTPURLResponse *response = nil;
		NSError *error = nil;
        
		returnData = [NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&error];
        
		request = nil;
		
		if (error){
			PixLogAll(@"%@", [error description]);
		}
        
        PixLogAll(@"Status code: %ld", (long)[response statusCode]);
		
	}@catch (NSException *e) {
		PixLog(@"doLogin %@", e);
	}@finally {
		[NetworkUtil hideNWActivityIndicator];
	}
	return returnData;
}

/**********************************************
 *
 **********************************************/

/*

-(NSData *)doPhotoSend:(NSArray *)data {
	
	NSData *returnData = nil;
    
	@try{
        
		[NetworkUtil showNWActivityIndicator];
        
        NSMutableString *damagedEquipmentInfoUrl = [NSMutableString stringWithString:Uri];
        [damagedEquipmentInfoUrl appendString:damagedEquipmentInfo];
        
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: damagedEquipmentInfoUrl]];
        
        PixLogAll(@"%@", damagedEquipmentInfoUrl);
        
        [request setHTTPMethod:@"POST"];
        
        // Set Header and content type of your request
        
        NSString *boundary = @"---------------------------Boundary Line---------------------------";
        
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
 
        // now lets create the body of the request

        NSMutableData *body = [NSMutableData data];
        
        //[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

        int fcount = (int)[data count];
        
        int i = 0;
        int j = 1;
        
        NSString *name;
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString *displayName;
        NSString *fileSize;
        
        for (i=0; i < fcount-1; i++)
        {
            displayName = [fileManager displayNameAtPath:[data objectAtIndex:i]];
            
            NSString *filePath = [data objectAtIndex:i];
            NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:filePath traverseLink:YES];
            
            if (fileAttributes != nil)
            {
                fileSize = [fileAttributes objectForKey:NSFileSize];
                PixLogAll(@"File size: %@ kb", fileSize);
            }
            
            name = [NSString stringWithFormat:@"PhotoNumber%d;size=%@", j, fileSize];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, displayName] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[@"Content-Type: application/octet-stream\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[NSData dataWithContentsOfFile:[data objectAtIndex:i]]];
            
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            j++;
        }
        
//        displayName = [fileManager displayNameAtPath:[data objectAtIndex:i]];
        
        NSString *filePath = [data objectAtIndex:i];
        NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:filePath traverseLink:YES];
        
        if (fileAttributes != nil)
        {
            fileSize = [fileAttributes objectForKey:NSFileSize];
            PixLogAll(@"File size: %@ kb", fileSize);
        }
        
        name = [NSString stringWithFormat:@"EstimateFile;size=%@", fileSize];
        
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"depics\"\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[@"Content-Type: application/octet-stream\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[NSData dataWithContentsOfFile:[data objectAtIndex:i]]];
        
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // set body with request
        [request setHTTPBody:body];
        
        [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
        
        NSHTTPURLResponse *response = nil;
		NSError *error = nil;
        
        // now lets make the connection to the web
		returnData = [NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&error];
        
		request = nil;
		
		if (error){
			PixLogAll(@"%@", [error description]);
		}
        
        PixLogAll(@"Status code: %ld", (long)[response statusCode]);
		
	}@catch (NSException *e) {
		PixLog(@"doLogin %@", e);
	}@finally {
		[NetworkUtil hideNWActivityIndicator];
	}
	return returnData;
}

*/


/**********************************************
 *
 **********************************************/

-(NSString *)getPhotoSendUrl {
    
    NSMutableString *damagedEquipmentInfoUrl = [NSMutableString stringWithString:Uri];
    [damagedEquipmentInfoUrl appendString:damagedEquipmentInfo];

    PixLogAll(@"%@", damagedEquipmentInfoUrl);
    
    return damagedEquipmentInfoUrl;
}


/**********************************************
 *
 **********************************************/

-(NSData *)doPhotoSend:(NSArray *)data {
    
    NSMutableData *body = nil;
    
    @try{
        
        /* Set Header and content type of your request */
        
        NSString *boundary = @"---------------------------Boundary Line---------------------------";
        
        /* now lets create the body of the request */
        
        body = [NSMutableData data];
        
        [body appendData:[[NSString stringWithFormat:@"%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        int fcount = (int)[data count];
        
        int i = 0;
        int j = 1;
        
        NSString *name;
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString *displayName;
        NSString *fileSize;
        
        for (i=0; i < fcount-1; i++)
        {
            displayName = [fileManager displayNameAtPath:[data objectAtIndex:i]];
            
            NSString *filePath = [data objectAtIndex:i];
            
            //NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:filePath traverseLink:YES];
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            
            if (fileAttributes != nil)
            {
                fileSize = [fileAttributes objectForKey:NSFileSize];
                PixLogAll(@"File size: %@ kb", fileSize);
            }
            
            name = [NSString stringWithFormat:@"PhotoNumber%d;size=%@", j, fileSize];
            
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, displayName] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[@"Content-Type: application/octet-stream\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[NSData dataWithContentsOfFile:[data objectAtIndex:i]]];
            
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            j++;
        }
        
        //displayName = [fileManager displayNameAtPath:[data objectAtIndex:i]];
        
        NSString *filePath = [data objectAtIndex:i];
        
        //NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:filePath traverseLink:YES];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        
        if (fileAttributes != nil)
        {
            fileSize = [fileAttributes objectForKey:NSFileSize];
            PixLogAll(@"File size: %@ kb", fileSize);
        }
        
        name = [NSString stringWithFormat:@"EstimateFile;size=%@", fileSize];
        
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"depics\"\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[@"Content-Type: application/octet-stream\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[NSData dataWithContentsOfFile:[data objectAtIndex:i]]];
        
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
    }@catch (NSException *e) {
        PixLog(@"doPhotoSend %@", e);
    }@finally {

    }
    
    return body;
}

@end
