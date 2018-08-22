//
//  ViewController.m
//  Direct-Me
//
//  Created by Yash Ganorkar on 8/17/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

#import "ViewController.h"
#import "MapPin.h"
#import "AddressViewController.h"
#import "TableViewController.h"
#import "LocationSearchTable.h"

@interface ViewController () <MKMapViewDelegate> {
    MKPolyline *routeOverlay;
    
    BOOL routeOverlaySet;
}
    @property (weak, nonatomic) NSString *data;
@end

@implementation ViewController
MKPointAnnotation *destination;
MKRoute *route;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self configureLocationServices];
    destination = [[MKPointAnnotation alloc] init];
//    routeOverlaySet = NO;
    
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
    
}

-(void) configureLocationServices{
    locationManager.delegate = self;
    self.mapKit.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    
    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    [locationManager startUpdatingLocation];
    
    //self.mapKit.showsUserLocation = YES;
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
    
    routeOverlaySet = YES;
    
    for (MKRoute * singleRoute in route) {
        routeOverlay = singleRoute.polyline;
        [self.mapKit addOverlay:routeOverlay];
    }
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
-(void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    sourceLocation = userLocation;
    [self zoomToLatestLocation:sourceLocation];
    
}
- (IBAction)directions:(id)sender {
    
    [self performSegueWithIdentifier:@"addressSelector" sender:self];
    
}

- (IBAction)test:(id)sender {
    [self performSegueWithIdentifier:@"testIdentifier" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ViewController *vc = [segue sourceViewController];

    if([segue.identifier  isEqual: @"addressSelector"]){
        AddressViewController *avc = [segue destinationViewController];
        
        avc.delegate = vc;
    }
    
    else if([segue.identifier  isEqual: @"testIdentifier"]){
        TableViewController *tvc = [segue destinationViewController];
    }
}

- (void)didFinishEnteringItem:(NSString *)item
{
    NSLog(@"This was returned from ViewControllerB %@",item);
    
    
    for (id<MKAnnotation> annotation in self.mapKit.annotations)
    {
        [self.mapKit removeAnnotation:annotation];
    }

    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    
    CLLocationCoordinate2D location;
    
    NSArray *loc = [[NSArray alloc]init];
    
    loc = [item componentsSeparatedByString:@","];
    
    location.latitude = [loc[0] doubleValue];
    location.longitude = [loc[1] doubleValue];
    
    region.span = span;
    region.center = location;
    
    [self.mapKit setRegion:region animated:YES];
    
    MapPin *ann = [[MapPin alloc] init];
    ann.coordinate = location;
    
    [destination setCoordinate:location];
    [self.mapKit addAnnotation:ann];
    
    MKUserLocation *destinationLoc = [[MKUserLocation alloc] init];
    
    [destinationLoc setCoordinate:ann.coordinate];
    destinationLocation = destinationLoc;
    
    [self constructRoute:destinationLocation];
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
    
    NSString *city = placeMark.locality;
    NSString *state = placeMark.administrativeArea;
    if(city && state){
        [annotation setSubtitle:[NSString stringWithFormat:@"%@ %@", city, state]];
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
    MKCoordinateSpan span = MKCoordinateSpanMake(1, 1);
    MKCoordinateRegion region = MKCoordinateRegionMake(destinationLocation.coordinate, span);
    
    [self.mapKit setRegion:region animated:YES];

}

@end
