//
//  HandleRoutes.h
//  Direct-Me
//
//  Created by Yash Ganorkar on 8/28/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HandleRoutes <NSObject>
-(void) listRoutes:(NSArray<MKRoute *>*) routes;
-(void) listRoute;
@end
