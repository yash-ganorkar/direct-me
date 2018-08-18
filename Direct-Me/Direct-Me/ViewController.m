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
    routeOverlaySet = NO;
}

-(void) configureLocationServices{
    locationManager.delegate = self;
    self.mapKit.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    
    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    [locationManager startUpdatingLocation];
    
    self.mapKit.showsUserLocation = YES;
}

- (void)zoomToLatestLocation:(MKUserLocation *)sourceLocation{
    MKCoordinateRegion zoomRegion;
    
    zoomRegion = MKCoordinateRegionMakeWithDistance(sourceLocation.coordinate, 100000, 100000);
    
    [self.mapKit setRegion:zoomRegion animated:YES];
    
}
- (void) constructRoute:(MKUserLocation *)destinationLocation{
    
    NSLog(@"Source Latitude Coordinates -> %@", [NSString stringWithFormat:@"%f", sourceLocation.coordinate.latitude]);
    NSLog(@"Source Longitude Coordinates -> %@", [NSString stringWithFormat:@"%f", sourceLocation.coordinate.longitude]);
    NSLog(@"Destination Latitude Coordinates -> %@", [NSString stringWithFormat:@"%f", destinationLocation.coordinate.latitude]);
    NSLog(@"Destination Latitude Coordinates -> %@", [NSString stringWithFormat:@"%f", destinationLocation.coordinate.longitude]);

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    AddressViewController *avc = [segue destinationViewController];
    ViewController *vc = [segue sourceViewController];
    
    avc.delegate = vc;
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
@end
