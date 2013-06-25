//
//  UrlImageView.m
//  OldStore
//
//  Created by KICKERCHEN on 13/6/23.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import "UrlImageView.h"

@implementation UrlImageView

@synthesize fitFrame;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        activityIndicator = [ [UIActivityIndicatorView alloc] initWithFrame: CGRectMake( (frame.size.width-20)/2, (frame.size.height-20)/2, 20, 20 ) ];
        [ activityIndicator setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleGray ];
        [ activityIndicator setHidesWhenStopped: YES ];
        [ activityIndicator startAnimating ];
        [ self addSubview: activityIndicator ];
    }
    return self;
}

- (void)loadImageFromURL:(NSString *)url
{    
    if ( connection ) {
        [ connection cancel ];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL: [ NSURL URLWithString: url ] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 60.0 ];
    connection = [ [NSURLConnection alloc] initWithRequest: request delegate: self ];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if ( downloadData == nil )
        downloadData = [ [NSMutableData alloc] initWithCapacity: 2048 ];
    
    [ downloadData appendData: data ];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    [ activityIndicator stopAnimating ];
    connection = nil;
    if ( [self.subviews count] > 0 ) {
        [ [self.subviews objectAtIndex: 0] removeFromSuperview ];
    }
    
    UIImageView *imageView = [ [UIImageView alloc] initWithFrame: CGRectMake( 0, 0, self.frame.size.width, self.frame.size.height ) ];
    imageView.image = [ UIImage imageWithData: downloadData ];
    imageView.contentMode = ( YES == fitFrame ) ? UIViewContentModeScaleAspectFit : UIViewContentModeScaleAspectFill;
    
    [ self addSubview: imageView ];
    
    downloadData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [ activityIndicator stopAnimating ];
}

- (UIImage *)getUIImage
{
    UIImageView *imageView = [self.subviews objectAtIndex: 0];
    return [ imageView image ];
}

@end
