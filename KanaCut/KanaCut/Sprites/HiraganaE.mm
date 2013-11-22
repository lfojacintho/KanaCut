//
//  HiraganaE.m
//  KanaCut
//
//  Created by Luis Jacintho on 11/22/13.
//  Copyright (c) 2013 Publius Tecnologia. All rights reserved.
//

#import "HiraganaE.h"

@implementation HiraganaE

- (instancetype) initWithWorld: (b2World *) world
{
    int32 count = 6;
    NSString *imageName = @"hiragana-e.png";
    b2Vec2 vertices[] = {
        b2Vec2(14.f / PTM_RATIO, 59.f / PTM_RATIO),
        b2Vec2(8.f / PTM_RATIO, 6.f / PTM_RATIO),
        b2Vec2(13.f / PTM_RATIO, 4.f / PTM_RATIO),
        b2Vec2(58.f / PTM_RATIO, 6.f / PTM_RATIO),
        b2Vec2(58.f / PTM_RATIO, 12.f / PTM_RATIO),
        b2Vec2(46.f / PTM_RATIO, 58.f / PTM_RATIO)
    };
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    b2Body *body = [self createBodyForWorld: world
                                   position: b2Vec2 (screen.width / 2 / PTM_RATIO,
                                                     screen.height / 2 / PTM_RATIO)
                                   rotation: 0.f
                                   vertices: vertices
                                vertexCount: count
                                    density: 5.f
                                   friction: 0.2f
                                restitution: 0.2f];
    
    self = [super initWithFile: imageName body: body original: YES];
    
    if (self)
    {
        self.type = kPolygonTypeHiraganaE;
    }
    
    return self;
}

@end
