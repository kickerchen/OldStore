//
//  WebViewController.m
//  OldStore
//
//  Created by KICKERCHEN on 13/6/21.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation WebViewController
@synthesize urlString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect webFrame = self.view.frame;
    webFrame.origin.y = 0;
    webFrame.size.height = 568;
    self.webView = [ [ UIWebView alloc ] initWithFrame: webFrame ];
    [ self.webView setScalesPageToFit: YES];
    //[[ UIApplication sharedApplication ] openURL:[NSURL URLWithString: self.urlString] ];
    [ self.view addSubview: self.webView ];
    
    [ self.webView loadRequest: [ NSURLRequest requestWithURL: [NSURL URLWithString: self.urlString] ] ];
}

- (void)viewWillAppear:(BOOL)animated
{
    UITabBarController *nav = (UITabBarController *)[[ [ UIApplication sharedApplication ] keyWindow ] rootViewController ];
    nav.tabBar.hidden = YES;
    [ super viewWillAppear: animated ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
