//
//  ViewController.h
//  Direct-Me
//
//  Created by Yash Ganorkar on 8/17/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "HandleRoutes.h"

@protocol HandleMapSearch
- (void) dropPinZoomIn:(MKPlacemark *)placeMark;
@end


@interface ViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate, HandleMapSearch> {
    
    CLLocationManager *locationManager;
    
    MKUserLocation *sourceLocation;
    MKUserLocation *destinationLocation;
    NSArray *array;
    
    UISearchController *resultSearchController;
    
    MKPlacemark *selectedPin;
}
@property (weak, nonatomic) IBOutlet MKMapView *mapKit;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControll;

//- (IBAction)standard:(id)sender;
//- (IBAction)satellite:(id)sender;
//- (IBAction)hybrid:(id)sender;
//
//
//- (IBAction)directions:(id)sender;
//- (IBAction)test:(id)sender;

- (IBAction)mapViewTypeChanged:(id)sender;

@property(nonatomic, strong) id <HandleRoutes> handleRoutesDelegate;


@end

