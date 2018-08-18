//
//  ViewController.h
//  Direct-Me
//
//  Created by Yash Ganorkar on 8/17/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol DestinationAddressDelegate <NSObject>

- (void) didFinishEnteringItem:(NSString *)item;

@end


@interface ViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate, DestinationAddressDelegate> {
    
    CLLocationManager *locationManager;
    
    MKUserLocation *sourceLocation;
    MKUserLocation *destinationLocation;
    NSArray *array;
}
@property (weak, nonatomic) IBOutlet MKMapView *mapKit;

- (IBAction)standard:(id)sender;
- (IBAction)satellite:(id)sender;
- (IBAction)hybrid:(id)sender;


- (IBAction)directions:(id)sender;

@end

