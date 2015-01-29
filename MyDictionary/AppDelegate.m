//
//  AppDelegate.m
//  MyDictionary
//
//  Created by Mads Ynddal on 25/12/14.
//  Copyright (c) 2014 MyDictionary. All rights reserved.
//

#import "AppDelegate.h"
//#import <WebKit/WebKit.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [NSApp activateIgnoringOtherApps:YES];
    [_window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];//NSWindowCollectionBehaviorTransient];
    [_window setLevel:NSPopUpMenuWindowLevel];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString *inputWord = [[[[event paramDescriptorForKeyword:keyDirectObject] stringValue] substringFromIndex:11] stringByRemovingPercentEncoding];
//    [_searchWord.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]
    NSLog(@"%@",inputWord);
    [_searchWord setStringValue:inputWord];
    [self searchForWord];
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (BOOL)canBecomeMainWindow
{
    return YES;
}

- (void)awakeFromNib{
    self.searchWord.delegate = self;

    
    [_mainWebView setFrameLoadDelegate:self];
//    [_mainWebView setPolicyDelegate:self];
    [_auxWebView setFrameLoadDelegate:self];
    [_auxWebView setPolicyDelegate:self];
//    [[[_mainWebView mainFrame] frameView] setAllowsScrolling:NO];
//    [[[_auxWebView mainFrame] frameView] set];
//    [_mainWebView setCustomUserAgent:@"Mozilla/5.0 (iPhone; CPU iPhone OS 8_1   like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12B411 Safari/600.1.4"];

//    NSURL *url = [NSURL URLWithString:@"http://ordnet.dk/ddo/ordbog?query=ko"];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
//    [[_mainWebView mainFrame] loadRequest:urlRequest];
//    [self searchForWord];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) { //Do something against ENTER key
        [self searchForWord];
        return YES;
    }
//    }
    return NO;
}

- (void)searchForWord{
    NSString *newURLString = [NSString stringWithFormat:@"%@%@",@"http://ordnet.dk/ddo/ordbog?query=",[_searchWord.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    [self searchForURL:newURLString];
}

- (void)searchForURL:(NSString *)newURLString{
    NSURL *url = [NSURL URLWithString:newURLString];
    NSURL *invalidurl = [NSURL URLWithString:@"Invalid url"];
    //    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    //    [[_mainWebView mainFrame] loadRequest:urlRequest];
    NSData *URLContents = [NSData dataWithContentsOfURL:url];
    [[_mainWebView mainFrame] loadData:URLContents MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:invalidurl];
    [[_auxWebView mainFrame] loadData:URLContents MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:invalidurl];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    NSString *identifier = sender.identifier;
    if ([identifier isEqualToString:@"MainWebView"]){
        [_urltextfield setStringValue:sender.mainFrameURL];
        DOMDocument* domDocument=[sender mainFrameDocument];
        
        DOMElement* styleElement=[domDocument createElement:@"style"];
        [styleElement setAttribute:@"type" value:@"text/css"];
        
        NSArray *cleanRules = @[@"div#portal-top{;display:None;}",
                                @"div#portal-globalnav{;margin-top: 0em;}",
                                @"td#portal-column-two{;display:None;}",
                                @"td#portal-column-one{;display:None;}",
                                @"div#viewlet-above-content{;display:None;}",
                                @"div.topWarning{;display:None;}",
                                @"div.instrumentPanel{;display:None;}",
                                @"dl#portlet-search{display:None;}",
                                @"div#cookieInformerBooklet{;display:None;}",
                                @"div#visual-portal-wrapper{;min-width:0}", //;max-width:None;
                                @"a.kildepop .popup{;display:None;width:0px;height:0px;}",
                                @"div.documentActions{;display:None;}"
                                ];
        
        for (NSString *rule in cleanRules) {
            [styleElement appendChild:[domDocument createTextNode:rule]];
            DOMElement* headElement=(DOMElement*)[[domDocument getElementsByTagName:@"head"] item:0];
            [headElement appendChild:styleElement];
        }

        NSScrollView *mainScrollView = sender.mainFrame.frameView.documentView.enclosingScrollView;
        [mainScrollView setHorizontalScrollElasticity:NSScrollElasticityNone];

        [[mainScrollView contentView] scrollToPoint:NSMakePoint(0, 0)];
        [mainScrollView reflectScrolledClipView: [mainScrollView contentView]];
//        mainScrollView.contentSize = CGSizeMake(, 480);
        
        return;
    }
    else if ([identifier isEqualToString:@"AuxWebView"]) {
        [_urltextfield setStringValue:sender.mainFrameURL];
        DOMDocument* domDocument=[sender mainFrameDocument];
        
        DOMElement* styleElement=[domDocument createElement:@"style"];
        [styleElement setAttribute:@"type" value:@"text/css"];
        
        NSArray *cleanRules = @[@"div#portal-top{;display:None;}",
                                @"td#portal-column-one{;display:None;}",
//                                @"td#portal-column-two{;width:200px;}",
                                @"td#portal-column-content{;display:None;}",
                                @"div#viewlet-above-content{;display:None;}",
                                @"div.topWarning{;display:None;}",
                                @"div.instrumentPanel{;display:None;}",
                                @"dl#portlet-search{display:None;}",
                                @"div#cookieInformerBooklet{;display:None;}",
                                @"div#visual-portal-wrapper{;min-width:0px;}",
                                @"div#portal-footer{;display:None;}",
                                @"div.tabs-portlet-nav{;display:None;}",
                                @"div.rulOp{;display:None;}",
                                @"div.rulNed{;display:None;}",
                                ];
        
        for (NSString *rule in cleanRules) {
            [styleElement appendChild:[domDocument createTextNode:rule]];
            DOMElement* headElement=(DOMElement*)[[domDocument getElementsByTagName:@"head"] item:0];
            [headElement appendChild:styleElement];
        }
        return;
    }
    
    [NSException raise:@"Invalid WebView!" format:@"Invalid WebView in viewView:didFinishLoadForFrame: for sender: %@", sender.identifier];
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request
          frame:(WebFrame *)frame
decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSString *url = [[actionInformation objectForKey:WebActionOriginalURLKey] absoluteString];
    if (![url isEqualToString:@"about:blank"]){
        [self searchForURL:url];
    }
    else{
        [listener use];
    }
}

@end
