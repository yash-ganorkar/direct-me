//
//  AddressViewController.h
//  Direct-Me
//
//  Created by Yash Ganorkar on 8/17/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@class ViewController;

@interface AddressViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *selectedAddress;
- (IBAction)cancelButtonTouched:(id)sender;

@property (nonatomic, weak) id <DestinationAddressDelegate> delegate;

@end
