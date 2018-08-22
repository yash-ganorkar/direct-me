//
//  TableViewController.h
//  Direct-Me
//
//  Created by Yash Ganorkar on 8/19/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
