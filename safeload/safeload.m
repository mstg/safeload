//
//  safeload.m
//  safeload
//
//  Created by Mustafa Gezen on 25.07.2015.
//  Copyright © 2015 Mustafa Gezen. All rights reserved.
//
@import Foundation;
@import Opee;
#import <dlfcn.h>

NSString *appSupport;
NSString *execPath;
NSString *blocksFile;
NSMutableArray *blocks;
NSMutableDictionary *execs;

static void writePlist() {
	NSMutableDictionary *writePlist = [[NSMutableDictionary alloc] init];
	NSArray *writeArray = blocks;
	[writePlist setObject:writeArray forKey:@"execs"];
	[writePlist writeToFile:blocksFile atomically:YES];
}

void *dlopen(const char *path, int mode);
OPHook2(void*, dlopen, const char*, _path, int, _mode) {
	if (_path) {
		NSString *path = [NSString stringWithUTF8String:_path];
		if ([path containsString:@"/Library/Opee/Extensions"]) {
			if ([blocks containsObject:execPath]) {
				[blocks removeObject:execPath];
				writePlist();
				return 0;
			}
		}
	}
	return OPOldCall(_path, _mode);
}

static void signalHandler(int signal_number) {
	[blocks addObject:execPath];
	writePlist();
}

OPInitialize {
	appSupport = @"/usr/local";
	execPath = NSProcessInfo.processInfo.arguments[0];
	blocksFile = [appSupport stringByAppendingPathComponent:@"blocks.plist"];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:appSupport isDirectory:nil]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:appSupport withIntermediateDirectories:true attributes:nil error:nil];
	}
	
	NSMutableDictionary *execs = [NSMutableDictionary dictionaryWithContentsOfFile:[appSupport stringByAppendingPathComponent:@"blocks.plist"]];
	blocks = [execs objectForKey:@"execs"] ? [[execs objectForKey:@"execs"] mutableCopy] : [[NSMutableArray alloc] init];
	[execs writeToFile:blocksFile atomically:YES];
	
	OPHookFunction(dlopen);
	signal(SIGABRT, signalHandler);
	signal(SIGILL, signalHandler);
	signal(SIGSEGV, signalHandler);
	signal(SIGFPE, signalHandler);
	signal(SIGBUS, signalHandler);
	signal(SIGTRAP, signalHandler);
}