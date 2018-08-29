//
//  LocationSearchTable.m
//  Direct-Me
//
//  Created by Yash Ganorkar on 8/19/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

#import "LocationSearchTable.h"

@interface LocationSearchTable ()

@end

@implementation LocationSearchTable

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    MKPlacemark *selectedItem = self.mapItems[indexPath.row].placemark;
    [cell.textLabel setText:selectedItem.name];
    [cell.detailTextLabel setText:[self parseAddress:selectedItem]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mapItems.count;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    MKMapView *mView = self.mapView;
    NSString *searchBarText = searchController.searchBar.text;
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    [request setNaturalLanguageQuery:searchBarText];
    [request setRegion:mView.region];
    
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        self.mapItems = response.mapItems;
        [self.tableView reloadData];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MKPlacemark *placeMark = self.mapItems[indexPath.row].placemark;
    [self.handleMapSearchDelegate dropPinZoomIn:placeMark];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)parseAddress:(MKPlacemark *)selectedItem{
    // put a space between "4" and "Melrose Place"
    NSString* firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? @" " : @"";
    // put a comma between street and city/state
    NSString* comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? @", " : @"";
    
    // put a space between "Washington" and "DC"
    NSString* secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? @" " : @"";
    NSString* addressLine = [[NSString alloc] initWithFormat:@"%@%@%@%@%@%@%@",selectedItem.subThoroughfare?selectedItem.subThoroughfare : @"",firstSpace, selectedItem.thoroughfare?selectedItem.thoroughfare:@"",comma, selectedItem.locality?selectedItem.locality:@"",secondSpace, selectedItem.administrativeArea?selectedItem.administrativeArea:@""];
    
    return addressLine;
}

@end
