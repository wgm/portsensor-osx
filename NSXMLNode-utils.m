//
//  NSXMLNode-utils.m
//  PortSensor
//
//  Created by Jeff Standen on 11/29/08.
//  Copyright 2008 WebGroup Media, LLC.. All rights reserved.
//

@implementation NSXMLNode(utils)

- (NSXMLNode *)childNamed:(NSString *)name
{
	NSEnumerator *e = [[self children] objectEnumerator];
	
	NSXMLNode *node;
	while (node = [e nextObject]) 
		if ([[node name] isEqualToString:name])
			return node;
    
	return nil;
}

- (NSArray *)childrenAsStrings
{
	NSMutableArray *ret = [[NSMutableArray arrayWithCapacity:
							[[self children] count]] retain];
	NSEnumerator *e = [[self children] objectEnumerator];
	NSXMLNode *node;
	while (node = [e nextObject])
		[ret addObject:[node stringValue]];
	
	return [ret autorelease];
}

@end
