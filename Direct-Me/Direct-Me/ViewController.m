//
//  ViewController.m
//  Direct-Me
//
//  Created by Yash Ganorkar on 8/17/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

#import "ViewController.h"
#import "LocationSearchTable.h"
#import "BottomSheetViewController.h"

@interface ViewController () <MKMapViewDelegate> {
    MKPolyline *routeOverlay;
    
    BOOL routeOverlaySet;
}
    @property (weak, nonatomic) NSString *data;
@property (weak,nonatomic) NSString *destinationCity;
@property (weak,nonatomic) NSString *destinationName;
@property (weak,nonatomic) NSString *destinationState;
@end

@implementation ViewController
MKPointAnnotation *destination;
MKRoute *route;

- (void)viewDidAppear:(BOOL)animated{
    [self viewDidLoad];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureLocationServices];
    destination = [[MKPointAnnotation alloc] init];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LocationSearchTable *locationSearchTable = [storyboard instantiateViewControllerWithIdentifier:@"LocationSearchTable"];
    
    resultSearchController = [[UISearchController alloc] initWithSearchResultsController:locationSearchTable];
    
    resultSearchController.searchResultsUpdater = locationSearchTable;
    
    UISearchBar *searchBar = resultSearchController.searchBar;
    [searchBar sizeToFit];
    [searchBar setPlaceholder:@"Search For Places"];
    
    [self.navigationItem setTitleView:resultSearchController.searchBar];
    resultSearchController.hidesNavigationBarDuringPresentation=NO;
    resultSearchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;
    
    locationSearchTable.mapView = self.mapKit;
    
    locationSearchTable.handleMapSearchDelegate = self;
    
    BottomSheetViewController *bvc = [[BottomSheetViewController alloc] init];
    
    [self setHandleRoutesDelegate:bvc];
}

-(void) configureLocationServices{
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //user needs to press for 2 seconds
    [self.mapKit addGestureRecognizer:lpgr];
    
    locationManager.delegate = self;
    self.mapKit.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    
    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    [locationManager startUpdatingLocation];
}

- (void)zoomToLatestLocation:(MKUserLocation *)sourceLocation{
    MKCoordinateRegion zoomRegion;
    
    zoomRegion = MKCoordinateRegionMakeWithDistance(sourceLocation.coordinate, 100000, 100000);
    
    [self.mapKit setRegion:zoomRegion animated:YES];
    
}
- (void) constructRoute:(MKUserLocation *)destinationLocation{
    
    MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
    
    // Make the source
    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:sourceLocation.coordinate addressDictionary:nil];
    MKMapItem *source = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    
    // Make the destination
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destinationLocation.coordinate addressDictionary:nil];
    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    // Set the source and destination on the request
    [directionsRequest setSource:source];
    [directionsRequest setDestination:destination];
    directionsRequest.requestsAlternateRoutes = YES;
    directionsRequest.transportType = MKDirectionsTransportTypeAny;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"There was an error getting your directions");
            return;
        }
        
        for (MKRoute *routes in response.routes) {
            NSLog(@"%@", [NSString stringWithFormat:@"%f", routes.distance]);
        }
        
        [self plotRouteOnMap:response.routes];
        [self addBottomSheetView];
    }];
}

- (void)plotRouteOnMap:(NSArray<MKRoute *>*)route
{
    if(routeOverlaySet) {
        for (id<MKOverlay> overlay in self.mapKit.overlays)
        {
            [self.mapKit removeOverlay:overlay];
        }
    }
    
    [self.handleRoutesDelegate listRoutes:route];

    NSLog(@"%@",[NSString stringWithFormat:@"Smallest Distnace -> %f", route[0].distance]);
            routeOverlay = route[0].polyline;
            [self.mapKit addOverlay:routeOverlay];

}


-(void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    sourceLocation = userLocation;
    [self zoomToLatestLocation:sourceLocation];
}

- (IBAction)mapViewTypeChanged:(id)sender {
    if(self.segmentControll.selectedSegmentIndex == 0) {
        self.mapKit.mapType = MKMapTypeStandard;
    }else if (self.segmentControll.selectedSegmentIndex == 1) {
        self.mapKit.mapType = MKMapTypeSatellite;
    }else if (self.segmentControll.selectedSegmentIndex == 2){
        self.mapKit.mapType = MKMapTypeHybrid;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 4.0;
    return  renderer;
    
}
- (void)dropPinZoomIn:(MKPlacemark *)placeMark {
    selectedPin = placeMark;
    [self.mapKit removeAnnotations:self.mapKit.annotations];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    
    [annotation setCoordinate:placeMark.coordinate];
    [annotation setTitle:placeMark.name];
    
    self.destinationName = placeMark.name;
    self.destinationCity = placeMark.locality;
    self.destinationState = placeMark.administrativeArea;
    if(self.destinationCity && self.destinationState){
        [annotation setSubtitle:[NSString stringWithFormat:@"%@ %@", self.destinationCity, self.destinationState]];
    }
    
    [self.mapKit addAnnotation:annotation];
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    MKCoordinateRegion region = MKCoordinateRegionMake(placeMark.coordinate, span);
    
    [self.mapKit setRegion:region animated:YES];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if([annotation isKindOfClass:MKUserLocation.class]) {
        return nil;
    }
    
    NSString *reuseId = @"pin";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView  dequeueReusableAnnotationViewWithIdentifier:reuseId];
    
    if (!pinView) {
        pinView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:reuseId];
    }
    
    [pinView setPinTintColor:[UIColor orangeColor]];
    pinView.canShowCallout = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(CGPointZero.x, CGPointZero.y, 30, 30)];
    [button setBackgroundImage:[UIImage imageNamed:@"car"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(getDirections) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    
    [pinView setLeftCalloutAccessoryView:button];
    return pinView;
}

-(void)getDirections{
    if (selectedPin) {
        MKUserLocation *destinationLoc = [[MKUserLocation alloc] init];
        
        [destinationLoc setCoordinate:selectedPin.coordinate];
        destinationLocation = destinationLoc;
        
        [self constructRoute:destinationLocation];
        [self zoomOutToViewRoute];
    }
}

-(void) zoomOutToViewRoute{
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    MKCoordinateRegion region = MKCoordinateRegionMake(destinationLocation.coordinate, span);
    
    UISearchBar *searchBar = resultSearchController.searchBar;
    [searchBar setText:@""];
    
    [self.mapKit setRegion:region animated:YES];
    
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapKit];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapKit convertPoint:touchPoint toCoordinateFromView:self.mapKit];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!placemarks) {
             // handle error
         }
         else {
             if(placemarks && placemarks.count > 0)
             {
                 CLPlacemark *placemark= [placemarks objectAtIndex:0];
                 
                 MKPlacemark *placeMark = [[MKPlacemark alloc] initWithPlacemark:placemark];
                 
                 [self dropPinZoomIn:placeMark];
             }
             
         }
     }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"touches began");
    UITouch *touch = [touches anyObject];
    if(![touch.view isKindOfClass:[self.mapKit class]])
    {
        if(self.segmentControll.hidden)
            [self.segmentControll setHidden:NO];
        else if(!self.segmentControll.hidden) [self.segmentControll setHidden:YES];
    }
}

- (void) addBottomSheetView{
    BottomSheetViewController *bottomSheetVC = [[BottomSheetViewController alloc] init];
    
    bottomSheetVC.currentLocation = destinationLocation;
    bottomSheetVC.destinationName = self.destinationName;
    bottomSheetVC.destinationCity = self.destinationCity;
    bottomSheetVC.destinationState = self.destinationState;
    
    [self addChildViewController:bottomSheetVC];
    [self.view addSubview:bottomSheetVC.view];
    [bottomSheetVC didMoveToParentViewController:self];
    
    double height = self.view.frame.size.height;
    double width = self.view.frame.size.width;
    
    [bottomSheetVC.view setFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame), width, height)];
}

@end

