//
//  GrowlDelegate.h
//  PortSensor
//
//  Created by Jeff Standen on 11/29/08.
//  Copyright 2008 WebGroup Media, LLC.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import <Growl/GrowlApplicationBridge.h>

@interface AppDelegate : NSObject <GrowlApplicationBridgeDelegate> {
	
}

-(NSDictionary *) registrationDictionaryForGrowl;
-(IBAction) growl:(id)sender;

@end
