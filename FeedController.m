#import "FeedController.h"
#import "NSXMLNode-utils.h"
#import "ServerModel.h"
#import "SensorModel.h"

@implementation FeedController
@synthesize serverMap;

-(id) init {
	[super init];
	serverMap = [[NSMutableDictionary alloc] init];
	
	// Attributes
	attrGreen = [[NSDictionary dictionaryWithObject:[NSColor colorWithDeviceRed:.137 green:.631 blue:.067 alpha:1] forKey:NSForegroundColorAttributeName] retain];
	attrYell = [[NSDictionary dictionaryWithObject:[NSColor colorWithDeviceRed:.961 green:.765 blue:.388 alpha:1] forKey:NSForegroundColorAttributeName] retain];
	attrRed = [[NSDictionary dictionaryWithObject:[NSColor colorWithDeviceRed:.875 green:.016 blue:.133 alpha:1] forKey:NSForegroundColorAttributeName] retain];
	attrBlack = [[NSDictionary dictionaryWithObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName] retain];
	attrWhite = [[NSDictionary dictionaryWithObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName] retain];
	
	// Icons
	ledGreenIcon = [[NSImage imageNamed:@"led_green.png"] retain];
	ledYellowIcon = [[NSImage imageNamed:@"led_yellow.png"] retain];
	ledRedIcon = [[NSImage imageNamed:@"led_red.png"] retain];
	feedIcon = [[NSImage imageNamed:@"satellite_dish.png"] retain];
	serverIcon = [[NSImage imageNamed:@"server_network.png"] retain];
	
	// Scale icons
	[ledGreenIcon setSize:NSMakeSize(16, 16)];	
	[ledYellowIcon setSize:NSMakeSize(16, 16)];
	[ledRedIcon setSize:NSMakeSize(16, 16)];
	[feedIcon setSize:NSMakeSize(16, 16)];
	[serverIcon setSize:NSMakeSize(16, 16)];

	[treeView setAutoresizesOutlineColumn:YES];
	
	NSLog(@"Instantiated...");
	
	return self;
}

-(void) awakeFromNib {
	[GrowlApplicationBridge setGrowlDelegate:self];
	
	// Icns
	NSImage *icns = [NSImage imageNamed:@"PortSensor.icns"];
	[icns setSize:NSMakeSize(16.0, 16.0)];
		
	// Menu bar item
	NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[statusItem retain];
	[statusItem setTitle:NSLocalizedString(@"0",@"")];	
	[statusItem setImage:icns];
	[statusItem setMenu:statusMenu];
	[statusItem setHighlightMode:YES];
	
	// Set up timer
	// [TODO]
	
	// Clean up
	[icns release];
}

- (IBAction)toggleTimer:(id)sender {
	// Start
	if(nil == feedTimer) {
		// Run once fast
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkFeed:) userInfo:nil repeats:NO];
		
		feedTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(checkFeed:) userInfo:nil repeats:YES];
		[timerToolbarItem setLabel:@"Stop Timer"];
		[timerToolbarItem setImage:[NSImage imageNamed:@"stopwatch_stop.png"]];
		
	// Stop
	} else {
		[feedTimer invalidate];
		feedTimer = nil;
		[timerToolbarItem setLabel:@"Start Timer"];
		[timerToolbarItem setImage:[NSImage imageNamed:@"stopwatch_run.png"]];
		
	}
}

- (IBAction)checkFeed:(id)sender {
	NSError *err=nil;
    NSURL *xmlUrl = [NSURL URLWithString:@"http://www.portsensor.com/wgm/feed/everything"];
	
	NSXMLDocument *xmlDoc = [[NSXMLDocument alloc]
							 initWithContentsOfURL:xmlUrl 
							 options:0 
							 error:&err];
		
	NSXMLNode *rootNode = [xmlDoc rootElement];
	NSArray *devices = [rootNode nodesForXPath:@"./group/devices/device" error:&err];
	
	int numDevices = [devices count];
	int totalOK=0, totalWarning=0, totalCritical=0;
		
	// Loop through devices to check their sensor statuses
	for(int i=0; i < numDevices; i++) {
		NSXMLNode *eDevice = [devices objectAtIndex:i];
		NSString *deviceName = [[eDevice childNamed:@"name"] stringValue];

		ServerModel *server = [serverMap objectForKey:deviceName];
		
		// If no hit, add the server to the dictionary
		if(nil == server) {
			server = [[ServerModel alloc] init];
			server.title = deviceName;
			
		} else { // if exists, clear the sensors
			[[server sensors] removeAllObjects];
		}
		
		// Loop through sensors
		NSArray *sensors = [eDevice nodesForXPath:@"./sensors/sensor" error:&err];
		int numSensors = [sensors count];
		int numOK=0,numWarning=0,numCritical=0;
		
		for(int j=0; j < numSensors; j++) {
			NSXMLNode *eSensor = [sensors objectAtIndex:j];

			NSString *sensorName = [[eSensor childNamed:@"name"] stringValue];
			NSString *sensorStatus = [[eSensor childNamed:@"status"] stringValue];
			NSString *sensorOutput = [[eSensor childNamed:@"output"] stringValue];
			NSString *sensorLastRan = [[eSensor childNamed:@"last_updated"] stringValue];
			
			// Release the XML
			[eSensor release];
			
			SensorModel *sensor = [[[SensorModel alloc] init] autorelease];
			sensor.title = sensorName;
			sensor.status = sensorStatus;
			sensor.output = sensorOutput;
			sensor.change = @"Change";
			sensor.lastRan = sensorLastRan;
			[server.sensors addObject:sensor];
			//[sensor release];
						
			// Check statuses
			if([sensorStatus isEqualToString:@"1"]) {
				numWarning++;
			} else if([sensorStatus isEqualToString:@"2"]) {
				numCritical++;
			} else {
				numOK++;
			}
					
			//NSLog(@"  Sensor: %@ (status: %@  output: %@", sensorName, sensorStatus, sensorOutput);
		}

		totalOK += numOK;
		totalWarning += numWarning;
		totalCritical += numCritical;		
		
		server.numOK = [NSNumber numberWithInt:numOK];
		server.numWarning = [NSNumber numberWithInt:numWarning];
		server.numCritical = [NSNumber numberWithInt:numCritical];	
		
		[serverMap setObject:server forKey:[server title]];
	}
	
	[treeView reloadData];
	
	// [TODO] Example dock icon code
	int numProblems = totalWarning + totalCritical;
	NSDockTile *dockTile = [NSApp dockTile];
	if(numProblems)
		[dockTile setBadgeLabel:[NSString stringWithFormat:@"%d",numProblems]];
	else
		[dockTile setBadgeLabel:@""];
	
	// Print statistics in a Growl notification
	// [TODO] Remove numOK > 0 (for testing)
	NSString *stats = @"";
	
	// Clear header labels
	[statusOkLabel setStringValue:@""];
	[statusWarnLabel setStringValue:@""];
	[statusCriticalLabel setStringValue:@""];
	
	// Set header labels
	if(totalWarning) {
		stats = [stats stringByAppendingString:[NSString stringWithFormat:@"%d sensors have warnings.\n", totalWarning]];
		[statusWarnLabel setStringValue:[NSString stringWithFormat:@"%d sensors WARN", totalWarning]];
	}		
	if(totalCritical) {
		stats = [stats stringByAppendingString:[NSString stringWithFormat:@"%d sensors are critical.\n", totalCritical]];
		[statusCriticalLabel setStringValue:[NSString stringWithFormat:@"%d sensors CRITICAL", totalCritical]];
	}
	if(totalOK) {
		stats = [stats stringByAppendingString:[NSString stringWithFormat:@"%d sensors are OK.\n", totalOK]];
		[statusOkLabel setStringValue:[NSString stringWithFormat:@"%d sensors OK", totalOK]];
	}
	
	// Redraw parent gradient
	[[statusOkLabel superview] setNeedsDisplay:YES];
		
	// Growl a report event
	if([stats length])
		[self growlString:@"PortSensor Report" description:stats];
}

// ****************

-(NSDictionary *) registrationDictionaryForGrowl {
	NSArray *notifications = [NSArray arrayWithObjects:@"Sensor Report",@"Warnings",@"Critical Errors",nil];
	
	NSDictionary *dict;
	dict = [NSDictionary dictionaryWithObjectsAndKeys:
			notifications, GROWL_NOTIFICATIONS_ALL,
			notifications, GROWL_NOTIFICATIONS_DEFAULT,
			nil];
	
	return dict;
}

-(void) growlString:(NSString*)title description:(NSString*)description {
	[GrowlApplicationBridge
	 notifyWithTitle:title
	 description:description
	 notificationName:@"Sensor Report"
	 iconData:nil
	 priority:0
	 isSticky:NO
	 clickContext:nil
	 ];
}

// ****************

-(BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
	if([item isMemberOfClass:[ServerModel class]])
		return YES;
	
	return NO;
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	// Opportunity to draw a group full width
	if(nil == tableColumn && [item isMemberOfClass:[ServerModel class]]) {
		return [[outlineView tableColumnWithIdentifier:@"title"] dataCell];
	}
	
	return nil;
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
//	NSLog(@"numberOfChildrenOfItem: %@", item);
	
	if(nil == item) {
		//return [serverList count];
//		NSLog(@"Root count %d", [serverMap count]);
		return [serverMap count];
	}
	
//	if([item isMemberOfClass:[serverList class]])
//		return [serverList count];
	
	if([item isMemberOfClass:[ServerModel class]])  {
		return [[item sensors] count];
	}
		
    return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {	
	if(nil == item)
		return YES;
	
//	NSLog(@"Expandable: %@", item);
	
//	if([item isMemberOfClass:[serverList class]])
//		return [serverList count] ? YES : NO;
	
	if([item isMemberOfClass:[ServerModel class]]) {
//		NSLog(@"%@", [item sensors]);
		return [[item sensors] count] ? YES : NO;
	}
	
	return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView
			child:(int)index
		   ofItem:(id)item {
	
//	NSLog(@"childOfItem");
	
	if(nil == item) {
		// [TODO] We really don't want to have to sort this every time, do we?
		return [serverMap objectForKey:[[[serverMap allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:index]];
	}
	
//	if(nil == item)
//		return [serverList objectAtIndex:index];
	
//	if([item isMemberOfClass:[serverList class]])
//		return [serverList objectAtIndex:index];
	
	if([item isMemberOfClass:[ServerModel class]]) 
		return [[item sensors] objectAtIndex:index];
	
	return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
		   byItem:(id)item {
		
	NSString *colName = [tableColumn identifier];
	
	// Root
//	if([item isMemberOfClass:[serverList class]]) {
//		// Columns
//		if([colName isEqualToString:@"title"]) {
//			NSMutableAttributedString *out = [[NSMutableAttributedString alloc] autorelease];
//			
//			NSTextAttachment *attach = [[[NSTextAttachment alloc] init] autorelease];
//			NSCell *cell = (NSTextAttachmentCell *)[attach attachmentCell];
//			[cell setImage:feedIcon];
//			
//			out = (id)[NSMutableAttributedString attributedStringWithAttachment:attach];
//			[out appendAttributedString:[[[NSAttributedString alloc] initWithString:@" Feed"] autorelease]];
//			
//			return out;
//		}
//		
//		return @"";
//	}
	
	if([item isMemberOfClass:[ServerModel class]]) {
		// ...
		ServerModel *server = item;

		if(nil == colName || [colName isEqualToString:@"title"]) {
			NSMutableAttributedString *out = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];

			// Server Icon
			NSTextAttachment *attach = [[[NSTextAttachment alloc] init] autorelease];
			NSCell *cell = (NSTextAttachmentCell *)[attach attachmentCell];
			[cell setImage:serverIcon];
			[out appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];			
			
			// If we have a warning or critical count on this server, show an icon in the heading.
			// This allows people to keep the entire tree collapsed and spot problems quickly.
			if([[server numCritical] isGreaterThan:[NSNumber numberWithInt:0]]) {
				// Critical Icon
				NSTextAttachment *attachCrit = [[[NSTextAttachment alloc] init] autorelease];
				NSCell *critCell = (NSTextAttachmentCell *)[attachCrit attachmentCell];
				[critCell setImage:ledRedIcon];
				[out appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachCrit]];	
				
			} else if([[server numWarning] isGreaterThan:[NSNumber numberWithInt:0]]) {
				// Warn Icon
				NSTextAttachment *attachWarn = [[[NSTextAttachment alloc] init] autorelease];
				NSCell *warnCell = (NSTextAttachmentCell *)[attachWarn attachmentCell];
				[warnCell setImage:ledYellowIcon];
				[out appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachWarn]];
				
			} else {
				// OK Icon
				NSTextAttachment *attachOK = [[[NSTextAttachment alloc] init] autorelease];
				NSCell *okCell = (NSTextAttachmentCell *)[attachOK attachmentCell];
				[okCell setImage:ledGreenIcon];
				[out appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachOK]];
				
			}
						
			// Server Name
			NSString *serverTitle = [NSString stringWithFormat:@" %@  ", [server title]];
			[out appendAttributedString:[[[NSAttributedString alloc] initWithString:serverTitle] autorelease]];
			
			return out;
		}
		
	} else { // sensor
		// ...
		SensorModel *sensor = item;
		BOOL isWarning=NO, isCritical=NO;
		
		if([[sensor status] isEqualToString:@"1"]) { // warning
			isWarning = YES;
		} else if([[sensor status] isEqualToString:@"2"]) { // critical
			isCritical = YES;
		} else { // ok
			// do nothing
		}
		
		if([colName isEqualToString:@"title"]) {
			NSString *str = [NSString stringWithFormat:@" %@", [sensor title]];
			NSMutableAttributedString *out;
			
			// prepend an icon
			NSTextAttachment *attach = [[[NSTextAttachment alloc] init] autorelease];
			NSCell *cell = (NSTextAttachmentCell *)[attach attachmentCell];
			
			if(isWarning)
				[cell setImage:ledYellowIcon];
			else if(isCritical)
				[cell setImage:ledRedIcon];
			else
				[cell setImage:ledGreenIcon];
			
			out = (id)[NSMutableAttributedString attributedStringWithAttachment:attach];
			NSAttributedString *aText = [[[NSAttributedString alloc] initWithString:str] autorelease];
			[out appendAttributedString:aText];
			
			return out;
			
		} else if([colName isEqualToString:@"output"]) {
			NSString *str = [sensor output];
			NSDictionary *a;
			
			// Color the output text
			if(isWarning)
				a = attrYell;
			else if(isCritical)
				a = attrRed;
			else
				a = attrGreen;
			
			NSAttributedString *out = [[[NSAttributedString alloc] initWithString:str attributes:a] autorelease];
			return out;
			
		} else if([colName isEqualToString:@"lastRan"]) {
			NSCalendarDate *date = [NSCalendarDate dateWithTimeIntervalSince1970:[[sensor lastRan] intValue]];
			[date setCalendarFormat:@"%I:%M %p"];
			return [NSString stringWithFormat:@"%@", date];
			
		} else {
			return @"";
		}	
	}
	
	return @"";
}

// ****************

//-(void)tableViewSelectionDidChange:(NSNotification *)notification {
//	//NSLog(@"SelDidCh");
//	int row = [tableView selectedRow];
//	
//	if(row == -1) {
//		return;
//	}
//}

@end
