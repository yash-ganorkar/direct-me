//
//  ViewController.m
//  Direct-Me
//
//  Created by Yash Ganorkar on 8/17/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)standard:(id)sender {
    
    self.mapKit.mapType = MKMapTypeStandard;
}

- (IBAction)satellite:(id)sender {
    self.mapKit.mapType = MKMapTypeSatellite;
}

- (IBAction)hybrid:(id)sender {
    self.mapKit.mapType = MKMapTypeHybrid;
}

- (IBAction)locate:(id)sender {
}

- (IBAction)directions:(id)sender {
}
@end
