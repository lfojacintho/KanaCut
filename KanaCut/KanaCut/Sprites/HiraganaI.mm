//
//  HiraganaI.m
//  KanaCut
//
//  Created by Luis Jacintho on 11/22/13.
//  Copyright (c) 2013 Publius Tecnologia. All rights reserved.
//

#import "HiraganaI.h"

@implementation HiraganaI

- (instancetype) initWithWorld: (b2World *) world
{
    int32 count = 8;
    NSString *imageName = @"hiragana-i.png";
    b2Vec2 vertices[] = {
        b2Vec2(56.f / PTM_RATIO, 18.f / PTM_RATIO),
        b2Vec2(56.f / PTM_RATIO, 36.f / PTM_RATIO),
        b2Vec2(46.f / PTM_RATIO, 51.f / PTM_RATIO),
        b2Vec2(14.f / PTM_RATIO, 55.f / PTM_RATIO),
        b2Vec2(8.f / PTM_RATIO, 42.f / PTM_RATIO),
        b2Vec2(8.f / PTM_RATIO, 24.f / PTM_RATIO),
        b2Vec2(13.f / PTM_RATIO, 13.f / PTM_RATIO),
        b2Vec2(22.f / PTM_RATIO, 8.f / PTM_RATIO)
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
        self.type = kPolygonTypeHiraganaI;
    }
    
    return self;
}

@end
