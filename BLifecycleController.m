//
//  BLifecycleController.m
//  BLifecycle
//
//  Created by Jesse Grosjean on 8/23/07.
//  Copyright 2007 Blocks. All rights reserved.
//

#import "BLifecycleController.h"
#import <objc/runtime.h>


@interface NSApplication (BLifecycleControllerMethodReplacements)
- (void)BLifecycleController_terminate:(id)sender;
- (void)BLifecycleController_replyToApplicationShouldTerminate:(BOOL)shouldTerminate;
@end

@implementation BLifecycleController

#pragma mark Class Methods

+ (id)sharedInstance {
	static id sharedInstance = nil;
    if (sharedInstance == nil) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

#pragma mark Init

- (id)init {
	if (self = [super init]) {
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserver:self selector:@selector(applicationWillFinishLaunchingNotification:) name:NSApplicationWillFinishLaunchingNotification object:nil];
		[center addObserver:self selector:@selector(applicationDidFinishLaunchingNotification:) name:NSApplicationDidFinishLaunchingNotification object:nil];
		[center addObserver:self selector:@selector(applicationMayTerminateNotification:) name:BApplicationMayTerminateNotification object:nil];
		[center addObserver:self selector:@selector(applicationCancledTerminateNotification:) name:BApplicationCancledTerminateNotification object:nil];		
		[center addObserver:self selector:@selector(applicationWillTerminateNotification:) name:NSApplicationWillTerminateNotification object:nil];
		[self performSelector:@selector(applicationLaunching)];
	}
	return self;
}

#pragma mark Notifications

- (void)notifyLifecycleExtensionObserversForSelector:(SEL)selector {
	NSString *configurationElementName = NSStringFromSelector(selector);
	NSArray *selectors = [NSArray arrayWithObject:[NSValue valueWithPointer:selector]];
	BExtensionPoint *extensionPoint = [[BExtensionRegistry sharedInstance] extensionPointFor:@"com.blocks.BLifecycle.lifecycle"];
	
	for (BConfigurationElement *each in [extensionPoint configurationElementsNamed:configurationElementName]) {
		id extensionCallbackObject = [each createExecutableExtensionFromAttribute:@"class" conformingToClass:nil conformingToProtocol:nil respondingToSelectors:selectors];
		[extensionCallbackObject performSelector:selector];
	}
}

- (void)applicationLaunching {
	[self notifyLifecycleExtensionObserversForSelector:@selector(applicationLaunching)];
}

- (void)applicationWillFinishLaunchingNotification:(NSNotification *)notification {
	[self notifyLifecycleExtensionObserversForSelector:@selector(applicationWillFinishLaunching)];
}

- (void)applicationDidFinishLaunchingNotification:(NSNotification *)notification {
	[self notifyLifecycleExtensionObserversForSelector:@selector(applicationDidFinishLaunching)];
}

- (void)applicationMayTerminateNotification:(NSNotification *)notification {
	[self notifyLifecycleExtensionObserversForSelector:@selector(applicationMayTerminateNotification)];
}

- (void)applicationCancledTerminateNotification:(NSNotification *)notification {
	[self notifyLifecycleExtensionObserversForSelector:@selector(applicationCancledTerminateNotification)];
}

- (void)applicationWillTerminateNotification:(NSNotification *)notification {
	[self notifyLifecycleExtensionObserversForSelector:@selector(applicationWillTerminate)];
}

@end

@implementation NSApplication (BLifecycleControllerMethodReplacements)

+ (void)load {
    if (self == [NSApplication class]) {
		[NSApplication replaceMethod:@selector(terminate:) withMethod:@selector(BLifecycleController_terminate:)];
		[NSApplication replaceMethod:@selector(replyToApplicationShouldTerminate:) withMethod:@selector(BLifecycleController_replyToApplicationShouldTerminate:)];
    }
}

- (void)BLifecycleController_terminate:(id)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:BApplicationMayTerminateNotification object:self];
	[self BLifecycleController_terminate:sender];
}

- (void)BLifecycleController_replyToApplicationShouldTerminate:(BOOL)shouldTerminate {
	if (!shouldTerminate) {
		[[NSNotificationCenter defaultCenter] postNotificationName:BApplicationCancledTerminateNotification object:self];
	}
	[self BLifecycleController_replyToApplicationShouldTerminate:shouldTerminate];
}

@end

NSString *BApplicationMayTerminateNotification = @"BApplicationMayTerminateNotification";
NSString *BApplicationCancledTerminateNotification = @"BApplicationCancledTerminateNotification";
