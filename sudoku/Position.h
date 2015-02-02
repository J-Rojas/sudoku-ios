//
// Created by Jose Rojas on 2/1/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Position : NSObject<NSCopying>

@property NSNumber * value;
@property int x, y;
@property NSMutableArray* possibleValues;

- (instancetype) initWithX: (int) x Y: (int) y;
- (NSMutableArray*) shuffleSet: (NSMutableArray*) arr;
- (void) remove: (id) value;

@end
