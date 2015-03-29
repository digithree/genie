/* Genetic Creature Sonfier
 *
 * 
 *
 * by Simon Kenny
 */
int WORLD_WIDTH = 2000;
int WORLD_HEIGHT = 2000;
int VIEW_WIDTH = 600;
int VIEW_HEIGHT = 600;
float viewFactor = 1.f;
float MOUSE_SCALE_VIEW_FACTOR = 0.001;
PVector mouseStart = new PVector();
float startViewFactor = 1.0f;
PVector viewPoint = new PVector();

int INITIAL_SPAWN_MIN = 50;
int INITIAL_SPAWN_MAX = 100;
int ACTORS_MIN = 10;
int ACTORS_MAX = 500;

ArrayList<Actor> actors = new ArrayList<Actor>();
ArrayList<Food> foods = new ArrayList<Food>();
float newFoodWaitTime;
float newFoodMinTime = 0.05;
float newFoodMaxTime = 0.2;
float FOOD_CHANCE_OF_SPAWNING = 0.8;

float lastTime;
float messageWait = 1.f;

boolean debugOn = true;
boolean stopMating = false;
boolean holdMaxPopulation = false;
int maxPopulation = ACTORS_MAX;

float timeSpeedFactor = 1.f;

// stats
int deathByStarvation = 0;
int deathByAging = 0;
int deathByChildbirth = 0;
int deathByBumping = 0;
int births = 0;
int mutations = 0;
int foodMade = 0;

// god controls
int GOD_NEUTRAL = 0;
int GOD_DESTROY = 1;
int GOD_MUSIC = 2;
int numGodStates = 3;
int godState = GOD_NEUTRAL;
float activeCircleSize = 300.f;

// music circle
boolean musicOn;
float nextNoteWait = 0.f;
int lastActorIdx = -1;
PVector lastNotePlace = new PVector();
// music defines
float MUSIC_MAX_NOTE_LENGTH = 2.0f;
float MUSIC_LOWEST_PITCH = 220.f;
float MUSIC_HIGHEST_PITCH = 880.f;


void setup() {
  size( VIEW_WIDTH, VIEW_HEIGHT, P3D );
  ellipseMode(CENTER);
  strokeCap(ROUND);
  strokeJoin(ROUND);
  smooth();
  
  //int spawnAmount = (int)random(INITIAL_SPAWN_MAX-INITIAL_SPAWN_MIN)+INITIAL_SPAWN_MIN;
  int spawnAmount = 100;
  for( int i = 0 ; i < spawnAmount ; i++ ) {
    actors.add( new Actor() );
  }
  for( int i = 0 ; i < 20 ; i++ ) {
    foods.add( new Food() );
  }
  foodMade = 20;
  newFoodWaitTime = random(newFoodMaxTime-newFoodMinTime)+newFoodMinTime;
  
  lastTime = (float)millis()/1000.f;
}


void draw() {
  background(0);
  
  float curTime = (float)millis()/1000.f;
  float ellapsedTime = (curTime - lastTime)*timeSpeedFactor;
  
  scale( viewFactor );
  translate( viewPoint.x, viewPoint.y );
  
  newFoodWaitTime -= ellapsedTime;
  if( newFoodWaitTime <= 0.f ) {
    newFoodWaitTime = random(newFoodMaxTime-newFoodMinTime)+newFoodMinTime;
    if( random(1) < FOOD_CHANCE_OF_SPAWNING ) {
      foods.add( new Food() );
      foodMade++;
    }
  }
  for( Food f : foods ) {
    f.draw();
  }
  
  if( actors.size() < ACTORS_MIN ) {
    actors.add( new Actor() );
  }
  
  for( int i = 0 ; i < actors.size() ; i++ ) {
    Actor actor = actors.get(i);
    actor.draw();
    if( actor.update(actors,foods,ellapsedTime) ) {
      foods.add( new Food( actor.pos, actor.genome.normal[GENOME_SIZE] ) );
      actors.remove(i);
    }
  }
  
  stroke(255);
  noFill();
  
  rect(-1,-1,WORLD_WIDTH+2,WORLD_HEIGHT+2);
  
  messageWait -= (curTime - lastTime);
  if( messageWait <= 0.f ) {
    println( "Actors:"+actors.size()+", food:"+foods.size()+", births:"+births+", mut:"+mutations+", starv:"+deathByStarvation+", aged:"+deathByAging+
              ", childB:"+deathByChildbirth+", bumps:"+deathByBumping);
    messageWait = 1.f;
  }
  
  if( godState == GOD_NEUTRAL ) {
    stroke(128);
  } else if( godState == GOD_DESTROY ) {
    stroke(255,0,0);
  } else if( godState == GOD_MUSIC ) {
    if( musicOn ) {
      // also do music check
      nextNoteWait -= (curTime - lastTime);
      if( nextNoteWait <= 0.f ) {
        ArrayList<Actor> actorsInCircle = new ArrayList<Actor>();
        for( Actor actor : actors ) {
          if( dist(actor.pos.x,actor.pos.y,-viewPoint.x+(mouseX/viewFactor),-viewPoint.y+(mouseY/viewFactor)) < (activeCircleSize/viewFactor)*0.5 ) {
            actorsInCircle.add(actor);
          }
        }
        if( actorsInCircle.size() > 0 ) {
          lastActorIdx = (int)random( ((float)actorsInCircle.size())-0.01 );
          Actor pickedActor = actorsInCircle.get(lastActorIdx);
          lastNotePlace = new PVector( pickedActor.pos.x, pickedActor.pos.y );
          //nextNoteWait = 0.3f;
          nextNoteWait = (((1.f - pickedActor.genome.normal[GENOME_SPEED])*0.8)+0.1) * MUSIC_MAX_NOTE_LENGTH;
          //cs.setChn("amp",0.1);
          //cs.setChn("dur",pickedActor.genome.normal[GENOME_SIZE]);
          //cs.setChn("pitch", MUSIC_LOWEST_PITCH + ((1.f-pickedActor.genome.normal[GENOME_SIZE])*(MUSIC_HIGHEST_PITCH-MUSIC_LOWEST_PITCH)) );
          float pitch = MUSIC_LOWEST_PITCH + ((1.f-pickedActor.genome.normal[GENOME_SIZE])*(MUSIC_HIGHEST_PITCH-MUSIC_LOWEST_PITCH));
          //cs.event( "i 10 0 "+nextNoteWait+" 0.1 "+pitch+" "+ pickedActor.genome.normal[GENOME_SHAPE]+" "+pickedActor.genome.normal[GENOME_VISION]+" "+pickedActor.genome.normal[GENOME_EDGECOL]);
        }
      }
      stroke(100,255,100);
      ellipse(lastNotePlace.x,lastNotePlace.y,30/viewFactor,30/viewFactor);
    } else {
      stroke(0,100,0);
    }
  }
  noFill();
  ellipse(-viewPoint.x+(mouseX/viewFactor),-viewPoint.y+(mouseY/viewFactor),(activeCircleSize/viewFactor),(activeCircleSize/viewFactor));
  
  lastTime = curTime;
}

void keyPressed() {
  // turn off music if on
  if( godState == GOD_MUSIC ) {
    //cs.setChn("amp",0.f);
  }
  
  if( key == ' ' ) {
    debugOn = !debugOn;
  } else if( key == 'd' ) {
    WORLD_WIDTH *= 2;
    WORLD_HEIGHT *= 2;
    newFoodMinTime /= 2;
    newFoodMaxTime /= 2;
  } else if( key == 's' ) {
    stopMating = !stopMating;
  } else if( key == 'p' ) {
    if( !holdMaxPopulation ) {
      holdMaxPopulation = true;
      maxPopulation = actors.size();
    } else {
      holdMaxPopulation = false;
      maxPopulation = ACTORS_MAX;
    }
  } else if( key == '-' || key == '_' ) {
    timeSpeedFactor -= 0.1f;
    if( timeSpeedFactor < 0.1f ) {
      timeSpeedFactor = 0.1f;
    }
  } else if( key == '+' || key == '=' ) {
    timeSpeedFactor += 0.1f;
    if( timeSpeedFactor > 2.0f ) {
      timeSpeedFactor = 2.0f;
    }
  } else if( key == 'g' || key == 'G' ) {
    godState++;
    if( godState >= numGodStates ) {
      godState = 0;
    }
  }
}

void mousePressed() {
  if( godState == GOD_DESTROY ) {
    for( int i = 0 ; i < actors.size() ; i++ ) {
      Actor actor = actors.get(i);
      if( dist(-viewPoint.x+(mouseX/viewFactor),-viewPoint.y+(mouseY/viewFactor),actor.pos.x,actor.pos.y) < (activeCircleSize/viewFactor)*0.5 ) {
        foods.add( new Food( actor.pos, actor.genome.normal[GENOME_SIZE] ) );
        actors.remove(i);
      }
    }
  } else if( godState == GOD_MUSIC && mouseButton == LEFT ) {
    musicOn = !musicOn;
    if( !musicOn ) {
      //cs.setChn("amp",0.f);
    }
  }
  mouseStart = new PVector( (float)mouseX, (float)mouseY );
  startViewFactor = viewFactor;
}

void mouseDragged() {
  if( mouseButton == LEFT ) {
    PVector moveBy = new PVector( mouseX - pmouseX, mouseY - pmouseY );
    moveBy.mult( 1.f/viewFactor );
    viewPoint.add( moveBy );
  }
  if( mouseButton == RIGHT ) {
    if( mouseX > mouseStart.x ) {
      viewFactor = startViewFactor + dist(mouseX,mouseY,mouseStart.x,mouseStart.y) * MOUSE_SCALE_VIEW_FACTOR;
    } else {
      viewFactor = startViewFactor - (dist(mouseX,mouseY,mouseStart.x,mouseStart.y) * MOUSE_SCALE_VIEW_FACTOR);
      if( viewFactor < 0.01f ) {
        viewFactor = 0.4f;
      }
    }
  }
}
