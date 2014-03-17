//
//  AIQueue.h
//  Combox
//
//  Created by Andrés Ibañez on 9/4/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AIQueueDelegate <NSObject>

@optional
-(void)objectHasBeenAdded:(id)object;
-(void)objectHasBeenRemoved;

@end

@interface AIQueue : NSObject
{
    NSMutableArray *queue;
    BOOL shouldProcess;
}
@property(nonatomic, assign) BOOL shouldProcess;
@property(nonatomic, retain) id<AIQueueDelegate> delegate;

-(void)addObject:(id)object;
-(void)removeFirstObject;
-(NSInteger)count;
-(id)nextObject;
@end
