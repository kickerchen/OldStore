//
//  FavoriteViewController.m
//  OldStore
//
//  Created by KICKERCHEN on 13/6/27.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import "FavoriteViewController.h"

@interface FavoriteViewController ()

@end

@implementation FavoriteViewController

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
    // Set background image of view.
    self.view.backgroundColor = [ UIColor colorWithPatternImage: [UIImage imageNamed:@"Paper_texture_v5_by_bashcorpo.jpeg"] ];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
