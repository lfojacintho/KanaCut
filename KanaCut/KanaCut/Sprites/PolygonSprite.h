//
//  PolygonSprite.h
//  KanaCut
//
//  Created by Luis Jacintho on 11/18/13.
//  Copyright 2013 Publius Tecnologia. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "PRFilledPolygon.h"

#define PTM_RATIO   32

typedef enum _PolygonState
{
    kPolygonStateIdle = 0,
    kPolygonStateTossed
} PolygonState;

typedef enum _PolygonType
{
    kPolygonTypeHiraganaA = 0,
    kPolygonTypeHiraganaI,
    kPolygonTypeHiraganaU,
    kPolygonTypeHiraganaE,
    kPolygonTypeHiraganaO
} PolygonType;

@interface PolygonSprite : PRFilledPolygon

@property (nonatomic, assign) b2Body *body;
@property (nonatomic, readwrite) BOOL original;
@property (nonatomic, readwrite) b2Vec2 centroid;

@property (nonatomic, readwrite) PolygonState state;
@property (nonatomic, readwrite) PolygonType type;

@property (nonatomic, readwrite) BOOL sliceEntered;
@property (nonatomic, readwrite) BOOL sliceExited;
@property (nonatomic, readwrite) b2Vec2 entryPoint;
@property (nonatomic, readwrite) b2Vec2 exitPoint;
@property (nonatomic, readwrite) double sliceEntryTime;

- (id) initWithTexture: (CCTexture2D *) texture body: (b2Body *) body original: (BOOL) original;
- (id) initWithFile: (NSString *) filename body: (b2Body *) body original: (BOOL) original;
+ (id) spriteWithFile: (NSString *) filename body: (b2Body *) body original: (BOOL) original;
+ (id) spriteWithTexture: (CCTexture2D *) texture body: (b2Body *) body original: (BOOL) original;
- (id) initWithWorld: (b2World *) world;
+ (id) spriteWithWorld: (b2World *) world;
- (b2Body *) createBodyForWorld: (b2World *) world position: (b2Vec2) position rotation: (float) rotation vertices: (b2Vec2 *) vertices vertexCount: (int32) count density: (float) density friction: (float) friction restitution: (float) restitution;
- (void) activateCollisions;
- (void) deactivateCollisions;

@end
