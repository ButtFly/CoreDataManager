//
//  SLYViewController.m
//  CoreDataManager
//
//  Created by 余河川 on 14-5-27.
//  Copyright (c) 2014年 com.315585758.www. All rights reserved.
//

#import "SLYViewController.h"
#import "SLYCoreDataManager.h"
#import "SLYTest.h"

@interface SLYViewController ()

@end

@implementation SLYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    SLYCoreDataManager * manager = [SLYCoreDataManager managerWithManagedObjectModelResource:@"Model"];
    NSError * error;
    [manager prepare:&error];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
