//
//  ViewController.h
//  Direct-Me
//
//  Created by Yash Ganorkar on 8/17/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapKit;

- (IBAction)standard:(id)sender;
- (IBAction)satellite:(id)sender;
- (IBAction)hybrid:(id)sender;
- (IBAction)locate:(id)sender;



- (IBAction)directions:(id)sender;

@end

