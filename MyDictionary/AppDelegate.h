//
//  AppDelegate.h
//  MyDictionary
//
//  Created by Mads Ynddal on 25/12/14.
//  Copyright (c) 2014 MyDictionary. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate>
@property (assign) IBOutlet WebView *mainWebView;
@property (assign) IBOutlet WebView *auxWebView;
@property (assign) IBOutlet NSTextField *searchWord;
@property (assign) IBOutlet NSTextField *urltextfield;
@end

