//
//  AIQueue.m
//  Combox
//
//  Created by Andrés Ibañez on 9/4/12.
//  Copyright (c) 2012 Andrés Ibañez. All rights reserved.
//

#import "AIQueue.h"

@implementation AIQueue
@synthesize shouldProcess;
@synthesize delegate;

-(AIQueue *)init
{
    if((self = [super init]))
    {
        queue = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addObject:(id)object
{
    [queue insertObject:object atIndex:queue.count];
    if([delegate respondsToSelector:@selector(objectHasBeenAdded:)])
    {
        [delegate objectHasBeenAdded:object];
    }
}

-(void)removeFirstObject
{
    if(queue.count > 0)
    {
        [queue removeObjectAtIndex:0];
        if(queue.count == 0)
        {
            shouldProcess = NO;
        }
    }
    if([delegate respondsToSelector:@selector(objectHasBeenRemoved)])
    {
        [delegate objectHasBeenRemoved];
    }
}

-(NSInteger)count
{
    return queue.count;
}

-(id)nextObject
{
    if(queue.count > 0)
    {
        return [queue objectAtIndex:0];
    }
    return nil;
}

@end
