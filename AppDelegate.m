//
//  GrowlDelegate.m
//  PortSensor
//
//  Created by Jeff Standen on 11/29/08.
//  Copyright 2008 WebGroup Media, LLC.. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

-(void) awakeFromNib {
	NSLog(@"Yawn!");
	//[GrowlApplicationBridge setGrowlDelegate:self];
	NSLog(@"Yawn2!");	
}

-(NSDictionary *) registrationDictionaryForGrowl {
	NSArray *notifications;
	notifications = [NSArray arrayWithArray:@"Growl Test"];
	
	NSDictionary *dict;
	dict = [NSDictionary dictionaryWithObjectsAndKeys:
			notifications, GROWL_NOTIFICATIONS_ALL,
			notifications, GROWL_NOTIFICATIONS_DEFAULT,
			nil];
	
	return dict;
}

-(IBAction) growl:(id) sender {
	NSLog(@"Grrrrrrrrrooowl!");
	 [GrowlApplicationBridge
	 notifyWithTitle:@"Title"
	 description:@"Description"
	 notificationName:@"Growl Test"
	 iconData:nil
	 priority:0
	 isSticky:NO
	 clickContext:nil
	 ];
}

@end
