//
//  ScrollableImageViewController.m
//  OldStore
//
//  Created by KICKERCHEN on 13/6/25.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import "ScrollableImageViewController.h"
#import "UrlImageView.h"
#import "Common.h"

@interface ScrollableImageViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation ScrollableImageViewController

@synthesize urlList;

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
    // Do any additional setup after loading the view from its nib.
    NSInteger numberPages = [self.urlList count];
    
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake( self.scrollView.frame.size.width * numberPages, self.scrollView.frame.size.height );
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.delegate = self;
    
    self.pageControl.backgroundColor = [UIColor blackColor];
    self.pageControl.numberOfPages = numberPages;
    self.pageControl.currentPage = self.currentPage;
    
    for ( int i = 0; i < numberPages; ++i ) {
        UrlImageView *imageView = [[UrlImageView alloc]initWithFrame: CGRectMake( self.scrollView.frame.size.width * i, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height )];
        [ imageView setContentMode: UIViewContentModeScaleAspectFit ];
        [ imageView loadImageFromURL: [urlList objectAtIndex: i] ];
        [self.scrollView addSubview: imageView];
    }
    
    [ self gotoPage: NO ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = (NSInteger)(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    self.currentPage = page;
    self.pageControl.currentPage = page;
}

- (void)gotoPage:(BOOL)animated
{
    // update scroll view to the appropriate page.
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * self.pageControl.currentPage;
    [ self.scrollView scrollRectToVisible: frame animated: animated ];
}

- (IBAction)changePage:(UIPageControl *)sender
{
    [ self gotoPage: YES ];
}

@end
