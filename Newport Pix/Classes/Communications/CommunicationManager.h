//
//  CommunicationManager.h
//  Newport Pix
//
//  Created by Mirko Delgado on 08/12/14.
//  Copyright (c) 2014 Newport Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommunicationManager : NSObject {
	
}

-(id)initCommunicationManager;

-(NSData *)doLogin:(NSString *)username : (NSString *)password;
-(NSData *)doClientCallsRequest:(NSString *)billToClientID : (NSString *)billToVendorID : (NSString *)billToDepotID;

-(NSString *)getPhotoSendUrl;

-(NSData *)doPhotoSend:(NSArray *)data ;

@end
