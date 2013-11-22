//
//  HelloWorldLayer.mm
//  KanaCut
//
//  Created by Luis Jacintho on 11/18/13.
//  Copyright Publius Tecnologia 2013. All rights reserved.
//

#import "AppDelegate.h"
#import "HelloWorldLayer.h"
#import "RayCastCallback.h"
#import "CCBlade.h"

#import "PolygonSprite.h"
#import "HiraganaA.h"
#import "HiraganaI.h"
#import "HiraganaU.h"
#import "HiraganaE.h"
#import "HiraganaO.h"


enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
{
    CGPoint _startPoint;
    CGPoint _endPoint;
    
    RayCastCallback *_raycastCallback;
    
    CCBlade *_blade;
    float _deltaRemainder;
    
    double _nextTossTime;
    double _tossInterval;
    int _queuedForToss;
    TossType _currentTossType;
}

@property (nonatomic, strong) CCArray *cache;
@property (nonatomic, strong) CCArray *blades;

-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) createMenu;
@end

@implementation HelloWorldLayer

+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init
{
    self = [super init];
    
	if (self)
    {
		
		// enable events
		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
		CGSize s = [CCDirector sharedDirector].winSize;
		
        [self initBackground];
		[self initPhysics];
        [self initSprites];
        
        _raycastCallback = new RayCastCallback ();
        _deltaRemainder = 0;
        _blades = [[CCArray alloc] initWithCapacity: 3];
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage: @"streak.png"];
        
        for (int i = 0; i < 3; ++i)
        {
            CCBlade *blade = [CCBlade bladeWithMaximumPoint: 50];
            blade.autoDim = NO;
            blade.texture = texture;
            
            [self addChild: blade z: 2];
            [_blades addObject: blade];
        }
        
        _nextTossTime = CACurrentMediaTime () + 1;
        _queuedForToss = 0;
		
		[self scheduleUpdate];
	}
    
	return self;
}

- (void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
	[super dealloc];
}	

- (void) createMenu
{
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
	
	// Reset Button
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Reset" block:^(id sender){
		[[CCDirector sharedDirector] replaceScene: [HelloWorldLayer scene]];
	}];

	// to avoid a retain-cycle with the menuitem and blocks
	__block id copy_self = self;

	// Achievement Menu Item using blocks
	CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
		
		
		GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
		achivementViewController.achievementDelegate = copy_self;
		
		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
		[[app navController] presentModalViewController:achivementViewController animated:YES];
		
		[achivementViewController release];
	}];
	
	// Leaderboard Menu Item using blocks
	CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
		
		
		GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
		leaderboardViewController.leaderboardDelegate = copy_self;
		
		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
		[[app navController] presentModalViewController:leaderboardViewController animated:YES];
		
		[leaderboardViewController release];
	}];
	
	CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, reset, nil];
	
	[menu alignItemsVertically];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, size.height/2)];
	
	
	[self addChild: menu z:-1];	
}

- (void) initBackground
{
    CGSize screen = [[CCDirector sharedDirector] winSize];
    CCSprite *background = [CCSprite spriteWithFile: @"bg.png"];
    background.position = ccp (screen.width / 2, screen.height / 2);
    [self addChild: background z: 0];
}

-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -4.25f);
	world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);		
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;
}

- (void) initSprites
{
    _cache = [[CCArray alloc] initWithCapacity: 50];
    
    for (int i = 0; i < 10; ++i)
    {
        PolygonSprite *sprite = [[HiraganaA alloc] initWithWorld: world];
        sprite.position = ccp (-64 * (i+1), -64);
        [self addChild: sprite z: 1];
        [sprite activateCollisions];
        [_cache addObject: sprite];
    }
    
    for (int i = 0; i < 10; ++i)
    {
        PolygonSprite *sprite = [[HiraganaI alloc] initWithWorld: world];
        sprite.position = ccp (-64 * (i+1), -64);
        [self addChild: sprite z: 1];
        [sprite activateCollisions];
        [_cache addObject: sprite];
    }
    
    for (int i = 0; i < 10; ++i)
    {
        PolygonSprite *sprite = [[HiraganaU alloc] initWithWorld: world];
        sprite.position = ccp (-64 * (i+1), -64);
        [self addChild: sprite z: 1];
        [sprite activateCollisions];
        [_cache addObject: sprite];
    }
    
    for (int i = 0; i < 10; ++i)
    {
        PolygonSprite *sprite = [[HiraganaE alloc] initWithWorld: world];
        sprite.position = ccp (-64 * (i+1), -64);
        [self addChild: sprite z: 1];
        [sprite activateCollisions];
        [_cache addObject: sprite];
    }
    
    for (int i = 0; i < 10; ++i)
    {
        PolygonSprite *sprite = [[HiraganaO alloc] initWithWorld: world];
        sprite.position = ccp (-64 * (i+1), -64);
        [self addChild: sprite z: 1];
        [sprite activateCollisions];
        [_cache addObject: sprite];
    }
}

- (void) checkAndSliceObjects
{
    double curTime = CACurrentMediaTime ();
    
    for (b2Body *b = world->GetBodyList (); b; b = b->GetNext ())
    {
        if (b->GetUserData () != NULL)
        {
            PolygonSprite *sprite = (PolygonSprite *) b->GetUserData ();
            
            if (sprite.sliceEntered && curTime > sprite.sliceEntryTime)
            {
                sprite.sliceEntered = NO;
            }
            else if (sprite.sliceEntered && sprite.sliceExited)
            {
                [self splitPolygonSprite: sprite];
            }
        }
    }
}

- (void) clearSlices
{
    for (b2Body *b = world->GetBodyList (); b; b = b->GetNext ())
    {
        if (b->GetUserData () != NULL)
        {
            PolygonSprite *sprite = (PolygonSprite *) b->GetUserData ();
            sprite.sliceEntered = NO;
            sprite.sliceExited = NO;
        }
    }
}

- (void) cleanSprites
{
    PolygonSprite *sprite;
    
    CCARRAY_FOREACH (_cache, sprite)
    {
        if (sprite.state == kPolygonStateTossed)
        {
            CGPoint spritePosition = ccp (sprite.body->GetPosition ().x * PTM_RATIO,
                                          sprite.body->GetPosition ().y * PTM_RATIO);
            float yVelocity = sprite.body->GetLinearVelocity ().y;
            
            if (spritePosition.y < -64 && yVelocity < 0)
            {
                sprite.state = kPolygonStateIdle;
                sprite.sliceEntered = NO;
                sprite.sliceExited = NO;
                sprite.entryPoint.SetZero ();
                sprite.exitPoint.SetZero ();
                sprite.position = ccp (-64, -64);
                sprite.body->SetLinearVelocity (b2Vec2 (0.f, 0.f));
                sprite.body->SetAngularVelocity (0.f);
                [sprite deactivateCollisions];
            }
        }
    }
    
    CGSize screen = [[CCDirector sharedDirector] winSize];
    for (b2Body *b = world->GetBodyList (); b; b = b->GetNext ())
    {
        if (b->GetUserData () != NULL)
        {
            PolygonSprite *sprite = (PolygonSprite *) b->GetUserData ();
            CGPoint position = ccp (b->GetPosition ().x * PTM_RATIO, b->GetPosition ().y * PTM_RATIO);
            if (position.x < -64 || position.x > screen.width || position.y < -64)
            {
                if (!sprite.original)
                {
                    world->DestroyBody (sprite.body);
                    [self removeChild: sprite cleanup: YES];
                }
            }
        }
    }
}

- (void) splitPolygonSprite: (PolygonSprite *) sprite
{
    PolygonSprite *newSprite1, *newSprite2;
    
    b2Fixture *originalFixture = sprite.body->GetFixtureList();
    b2PolygonShape *originalPolygon = (b2PolygonShape *) originalFixture->GetShape ();
    int vertexCount = originalPolygon->GetVertexCount ();
    
    float determinant;
    int i;
    
    b2Vec2 *sprite1Vertices = (b2Vec2 *) calloc (24, sizeof (b2Vec2));
    b2Vec2 *sprite2Vertices = (b2Vec2 *) calloc (24, sizeof (b2Vec2));
    b2Vec2 *sprite1VerticesSorted, *sprite2VerticesSorted;
    
    int sprite1VertexCount = 0;
    int sprite2VertexCount = 0;
    
    sprite1Vertices[sprite1VertexCount++] = sprite.entryPoint;
    sprite1Vertices[sprite1VertexCount++] = sprite.exitPoint;
    sprite2Vertices[sprite2VertexCount++] = sprite.entryPoint;
    sprite2Vertices[sprite2VertexCount++] = sprite.exitPoint;
    
    for (i = 0; i < vertexCount; ++i)
    {
        b2Vec2 point = originalPolygon->GetVertex (i);
        
        b2Vec2 diffFromEntryPoint = point - sprite.entryPoint;
        b2Vec2 diffFromExitPoint = point - sprite.exitPoint;
        
        if ((diffFromEntryPoint.x == 0 && diffFromEntryPoint.y == 0) || (diffFromExitPoint.x == 0 && diffFromExitPoint.y == 0))
        {
            
        }
        else
        {
            determinant = calculate_determinant_2x3 (sprite.entryPoint.x, sprite.entryPoint.y,
                                                     sprite.exitPoint.x, sprite.exitPoint.y,
                                                     point.x, point.y);
            
            if (determinant > 0)
            {
                sprite1Vertices[sprite1VertexCount++] = point;
            }
            else
            {
                sprite2Vertices[sprite2VertexCount++] = point;
            }
        }
    }
    
    sprite1VerticesSorted = [self arrangeVertices: sprite1Vertices count: sprite1VertexCount];
    sprite2VerticesSorted = [self arrangeVertices: sprite2Vertices count: sprite2VertexCount];
    
    BOOL sprite1VerticesAreAcceptable = [self areVerticesAcceptable: sprite1VerticesSorted count: sprite1VertexCount];
    BOOL sprite2VerticesAreAcceptable = [self areVerticesAcceptable: sprite2VerticesSorted count: sprite2VertexCount];
    
    if (sprite1VerticesAreAcceptable && sprite2VerticesAreAcceptable)
    {
        b2Vec2 worldEntry = sprite.body->GetWorldPoint (sprite.entryPoint);
        b2Vec2 worldExit = sprite.body->GetWorldPoint (sprite.exitPoint);
        float angle = ccpToAngle (ccpSub (ccp (worldExit.x, worldExit.y), ccp (worldEntry.x, worldExit.y)));
        CGPoint vector1 = ccpForAngle (angle + 1.570796);
        CGPoint vector2 = ccpForAngle (angle - 1.570796);
        float midX = midpoint (worldEntry.x, worldExit.x);
        float midY = midpoint (worldEntry.y, worldExit.y);
        
        b2Body *body1 = [self createBodyWithPosition: sprite.body->GetPosition ()
                                            rotation: sprite.body->GetAngle ()
                                            vertices: sprite1VerticesSorted
                                         vertexCount: sprite1VertexCount
                                             density: originalFixture->GetDensity ()
                                            friction: originalFixture->GetFriction ()
                                         restitution: originalFixture->GetRestitution ()];
        newSprite1 = [PolygonSprite spriteWithTexture: sprite.texture body: body1 original: NO];
        [self addChild: newSprite1 z:1];
        newSprite1.body->ApplyLinearImpulse (b2Vec2 (2 * body1->GetMass () * vector1.x,
                                                     2 * body1->GetMass () * vector1.y),
                                             b2Vec2 (midX, midY));
        
        b2Body *body2 = [self createBodyWithPosition: sprite.body->GetPosition ()
                                            rotation: sprite.body->GetAngle ()
                                            vertices: sprite2VerticesSorted
                                         vertexCount: sprite2VertexCount
                                             density: originalFixture->GetDensity ()
                                            friction: originalFixture->GetFriction ()
                                         restitution: originalFixture->GetRestitution()];
        newSprite2 = [PolygonSprite spriteWithTexture: sprite.texture body: body2 original: NO];
        [self addChild: newSprite2 z: 1];
        newSprite2.body->ApplyLinearImpulse (b2Vec2 (2 * body2->GetMass () * vector2.x,
                                                     2 * body2->GetMass () * vector2.y),
                                             b2Vec2 (midX, midY));
        
        if (sprite.original)
        {
            sprite.state = kPolygonStateIdle;
            [sprite deactivateCollisions];
            sprite.position = ccp (-256, -256);
            sprite.sliceEntered = NO;
            sprite.sliceExited = NO;
            sprite.entryPoint.SetZero ();
            sprite.exitPoint.SetZero ();
        }
        else
        {
            world->DestroyBody (sprite.body);
            [self removeChild: sprite cleanup: YES];
        }
    }
    else
    {
        sprite.sliceEntered = NO;
        sprite.sliceExited = NO;
    }
    
    free (sprite1VerticesSorted);
    free (sprite2VerticesSorted);
    free (sprite1Vertices);
    free (sprite2Vertices);
}

int comparator (const void *a, const void *b)
{
    const b2Vec2 *va = (const b2Vec2 *) a;
    const b2Vec2 *vb = (const b2Vec2 *) b;
    
    if (va->x > vb->x)
    {
        return 1;
    }
    else if (va->x < vb->x)
    {
        return -1;
    }
    
    return 0;
}

- (void) tossSprite: (PolygonSprite *) sprite
{
    CGSize screen = [[CCDirector sharedDirector] winSize];
    CGPoint randomPosition = ccp (frandom_range (100, screen.width - 164), -64);
    float randomAngularVelocity = frandom_range (-1, 1);
    
    float xModifier = 50 * (randomPosition.x - 100) / (screen.width - 264);
    float min = -25.f - xModifier;
    float max = 75.f - xModifier;
    
    float randomXVelocity = frandom_range (min, max);
    float randomYVelocity = frandom_range (250, 300);
    
    sprite.state = kPolygonStateTossed;
    sprite.position = randomPosition;
    [sprite activateCollisions];
    sprite.body->SetLinearVelocity (b2Vec2 (randomXVelocity / PTM_RATIO, randomYVelocity / PTM_RATIO));
    sprite.body->SetAngularVelocity (randomAngularVelocity);
}

- (void) spriteLoop
{
    double curTime = CACurrentMediaTime ();
    
    if (curTime > _nextTossTime)
    {
        PolygonSprite *sprite;
        
        int random = random_range (0, 4);
        PolygonType type = (PolygonType) random;
        if (_currentTossType == kTossTypeConsecutive && _queuedForToss > 0)
        {
            CCARRAY_FOREACH (_cache, sprite)
            {
                if (sprite.state == kPolygonStateIdle && sprite.type == type)
                {
                    [self tossSprite: sprite];
                    _queuedForToss--;
                    break;
                }
            }
        }
        else
        {
            _queuedForToss = random_range (3, 8);
            int tossType = random_range (0, 1);
            
            _currentTossType = (TossType) tossType;
            if (_currentTossType == kTossTypeSimultaneous)
            {
                CCARRAY_FOREACH (_cache, sprite)
                {
                    if (sprite.state == kPolygonStateIdle && sprite.type == type)
                    {
                        [self tossSprite: sprite];
                        _queuedForToss--;
                        random = random_range (0, 4);
                        type = (PolygonType) random;
                        
                        if (_queuedForToss == 0)
                        {
                            break;
                        }
                    }
                }
            }
            else if (_currentTossType == kTossTypeConsecutive)
            {
                CCARRAY_FOREACH (_cache, sprite)
                {
                    if (sprite.state == kPolygonStateIdle && sprite.type == type)
                    {
                        [self tossSprite: sprite];
                        _queuedForToss--;
                        break;
                    }
                }
            }
        }
        
        if (_queuedForToss == 0)
        {
            _tossInterval = frandom_range (2, 3);
            _nextTossTime = curTime + _tossInterval;
        }
        else
        {
            _tossInterval = frandom_range (0.3, 0.8);
            _nextTossTime = curTime + _tossInterval;
        }
    }
}

- (b2Body *) createBodyWithPosition: (b2Vec2) position rotation: (float) rotation vertices: (b2Vec2 *) vertices vertexCount: (int32) count density: (float) density friction: (float) friction restitution: (float) restitution
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = position;
    bodyDef.angle = rotation;
    b2Body *body = world->CreateBody (&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = density;
    fixtureDef.friction = friction;
    fixtureDef.restitution = restitution;
    
    b2PolygonShape shape;
    shape.Set (vertices, count);
    fixtureDef.shape = &shape;
    body->CreateFixture (&fixtureDef);
    
    return body;
}

- (b2Vec2 *) arrangeVertices: (b2Vec2 *) vertices count: (int) count
{
    float determinant;
    int iCounterClockwise = 1;
    int iClockwise = count - 1;
    int i;
    
    b2Vec2 referencePointA, referencePointB;
    b2Vec2 *sortedVertices = (b2Vec2 *) calloc (count, sizeof (b2Vec2));
    
    qsort (vertices, count, sizeof (b2Vec2), comparator);
    
    sortedVertices[0] = vertices[0];
    referencePointA = vertices[0];
    referencePointB = vertices[count - 1];
    
    for (i = 1; i < count - 1; ++i)
    {
        determinant = calculate_determinant_2x3 (referencePointA.x, referencePointA.y,
                                                 referencePointB.x, referencePointB.y,
                                                 vertices[i].x, vertices[i].y);
        
        if (determinant < 0)
        {
            sortedVertices[iCounterClockwise++] = vertices[i];
        }
        else
        {
            sortedVertices[iClockwise--] = vertices[i];
        }
    }
    
    sortedVertices[iCounterClockwise] = vertices[count - 1];
    
    return sortedVertices;
}

- (BOOL) areVerticesAcceptable: (b2Vec2 *) vertices count: (int) count
{
    if (count < 3)
    {
        NSLog (@"Not Acceptable: count < 3");
        return NO;
    }
    
    if (count > b2_maxPolygonVertices)
    {
        NSLog (@"Not Acceptable: count > maxVertices");
        return NO;
    }
    
    int32 i;
    for (i = 0; i < count; ++i)
    {
        int32 i1 = i;
        int32 i2 = i + 1 < count ? i + 1 : 0;
        b2Vec2 edge = vertices[i2] - vertices[i1];
        
        if (edge.LengthSquared() <= b2_epsilon * b2_epsilon)
        {
            NSLog (@"Not Acceptable: edge.LengthSquared <= b2_epsilon * b2_epsilon");
            return NO;
        }
    }
    
    float32 area = 0.f;
    b2Vec2 pRef(0.f, 0.f);
    
    for (i = 0; i < count; ++i)
    {
        b2Vec2 p1 = pRef;
        b2Vec2 p2 = vertices[i];
        b2Vec2 p3 = i + 1 < count ? vertices[i+1] : vertices[0];
        
        b2Vec2 e1 = p2 - p1;
        b2Vec2 e2 = p3 - p1;
        
        float32  D = b2Cross (e1, e2);
        
        float32 triangleArea = 0.5f * D;
        area += triangleArea;
    }
    
    if (area <= 0.0001)
    {
        NSLog (@"Not Acceptable: area <= 0.0001");
        return NO;
    }
    
    float determinant;
    float referenceDeterminant;
    b2Vec2 v1 = vertices[0] - vertices[count - 1];
    b2Vec2 v2 = vertices[1] - vertices[0];
    referenceDeterminant = calculate_determinant_2x2(v1.x, v1.y, v2.x, v2.y);
    
    for (i = 1; i < count - 1; ++i)
    {
        v1 = v2;
        v2 = vertices[i + 1] - vertices[i];
        determinant = calculate_determinant_2x2(v1.x, v1.y, v2.x, v2.y);
        
        if (referenceDeterminant * determinant < 0.f)
        {
            NSLog (@"Not Acceptable: not convex");
            return NO;
        }
    }
    
    v1 = v2;
    v2 = vertices[0] - vertices[count - 1];
    determinant = calculate_determinant_2x2(v1.x, v1.y, v2.x, v2.y);
    
    if (referenceDeterminant * determinant < 0.f)
    {
        NSLog (@"Not Acceptable: not convex");
        return NO;
    }
    
    return YES;
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
    
    // DEBUG
    //ccDrawLine (_startPoint, _endPoint);
	//world->DrawDebugData();
	
	kmGLPopMatrix();
}

-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
    
    [self checkAndSliceObjects];
    [self cleanSprites];
    [self spriteLoop];
    
    if ([_blade.path count] > 3)
    {
        _deltaRemainder += dt * 60 * 1.2;
        
        int pop = (int) roundf (_deltaRemainder);
        _deltaRemainder -= pop;
        [_blade pop: pop];
    }
}

- (void) ccTouchesBegan: (NSSet *) touches withEvent: (UIEvent *) event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];
        _startPoint = location;
        _endPoint = location;
        
        CCBlade *blade;
        CCARRAY_FOREACH (_blades, blade)
        {
            if (blade.path.count == 0)
            {
                _blade = blade;
                [_blade push: location];
                break;
            }
        }
    }
}

- (void) ccTouchesMoved: (NSSet *) touches withEvent: (UIEvent *) event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];
        _endPoint = location;
        
        [_blade push: location];
    }
    
    if (ccpLengthSQ (ccpSub (_startPoint, _endPoint)) > 25)
    {
        world->RayCast (_raycastCallback,
                        b2Vec2 (_startPoint.x / PTM_RATIO, _startPoint.y / PTM_RATIO),
                        b2Vec2 (_endPoint.x / PTM_RATIO, _endPoint.y / PTM_RATIO));
        
        world->RayCast (_raycastCallback,
                        b2Vec2 (_endPoint.x / PTM_RATIO, _endPoint.y / PTM_RATIO),
                        b2Vec2 (_startPoint.x / PTM_RATIO, _startPoint.y / PTM_RATIO));
        
        _startPoint = _endPoint;
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
	}
    
    [self clearSlices];
    [_blade dim: YES];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end
