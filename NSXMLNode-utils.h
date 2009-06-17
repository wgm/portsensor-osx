//
//  NSXMLNode-utils.h
//  PortSensor
//
//  Created by Jeff Standen on 11/29/08.
//  Copyright 2008 WebGroup Media, LLC.. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSXMLNode(utils)
	- (NSXMLNode *)childNamed:(NSString *)name;
	- (NSArray *)childrenAsStrings;

@end
