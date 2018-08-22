//
//  LocationSearchTable.h
//  Direct-Me
//
//  Created by Yash Ganorkar on 8/19/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ViewController.h"
@interface LocationSearchTable : UITableViewController <UISearchResultsUpdating>

@property(nonatomic, strong) NSArray<MKMapItem *> *mapItems;
@property(nonatomic, strong) MKMapView *mapView;
@property(nonatomic, weak) id <HandleMapSearch> handleMapSearchDelegate;
@end
