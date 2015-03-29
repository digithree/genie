  
float MOVE_WAIT_MIN = 0.4;
float MOVE_WAIT_MAX = 1.5f;

float ACTOR_HEALTH_DRAIN_RATE = 0.1f;   // per second for largest, i.e. for size 1 will die in 10 seconds
float ACTOR_HEALTH_MIN_TO_MATE = 0.4f;

float ACTOR_MATE_AGE = 5.0f;
float ACTOR_MATE_WAIT_TIME_MIN = 1.0f;
float ACTOR_MATE_WAIT_TIME_MAX = 3.0f;

final int ACTOR_STATE_STAY_ALOOF = 0;
final int ACTOR_STATE_FIND_FOOD = 1;
final int ACTOR_STATE_FIND_MATE = 2;

float ACTOR_MUTATION_WAIT = 1.0f;
float ACTOR_MUTATION_CHANCE = 0.01;

int ACTOR_MAX_BUMPS_IN_ONE_SECOND = 80;
float ACTOR_MAX_CONTINUOUS_BUMPING_TIME = 0.3f;

class Actor {
  Genome genome;
  PVector pos;
  PVector mov;
  PVector moveAwayFromOverlap;
  float stateChangeWait;
  float mateWait;
  float mutationWait;
  float bumpClearWait;
  int bumps;
  float bumpCounter;
  boolean isBumping;
  //
  float health;
  float age;
  int babiesHad;
  int state;
  // 
  boolean die;
  
  Actor() {
    genome = new Genome(GENOME_MAKE_RANDOM);
    pos = new PVector( random(WORLD_WIDTH), random(WORLD_HEIGHT) );
    init();
  }
  
  Actor( Actor parentA, Actor parentB ) {
    genome = new Genome(parentA.genome,parentB.genome);
    pos = PVector.sub(parentA.pos,parentB.pos);
    pos.add(parentB.pos);
    init();
  }
  
  void init() {
    mov = new PVector( random(1), random(1) );
    moveAwayFromOverlap = new PVector();
    mov.normalize();
    stateChangeWait = random(MOVE_WAIT_MAX-MOVE_WAIT_MIN)+MOVE_WAIT_MIN;
    state = genome.getRandomState( age >= ACTOR_MATE_AGE );
    health = 1.f;
    mateWait = 0.f;
    babiesHad = 0;
    mutationWait = ACTOR_MUTATION_WAIT;
    die = false;
    bumps = 0;
    bumpClearWait = 1.f;
    bumpCounter = 0.f;
    isBumping = false;
  }
  
  void draw() {
    /*
    if( debugOn ) {
      // draw movement vectors, debug
      // main movement
      stroke(255);
      line(pos.x,pos.y,pos.x+(mov.x*genome.getRealSize()),pos.y+(mov.y*genome.getRealSize()));
      // avoid movement
      stroke(255,0,0);
      line(pos.x,pos.y,pos.x+(moveAwayFromOverlap.x*genome.getRealSize()),pos.y+(moveAwayFromOverlap.y*genome.getRealSize()));
      // sight dist
      stroke( 100, 100, 100 );
      noFill();
      ellipse(pos.x,pos.y,genome.getSightDist(),genome.getSightDist());
    }
    */
    
    stroke( getColour(genome.normal[GENOME_EDGECOL]) );
    //fill( getColour(genome.bodyCol) );
    fill(0);
    drawShape( genome, pos.x, pos.y, mov );
    
    if( debugOn ) {
      fill( 255 );
      text( health, pos.x, pos.y );
      switch( state ) {
        case ACTOR_STATE_STAY_ALOOF:
          text( "Aloof", pos.x, pos.y+10 );
          break;
        case ACTOR_STATE_FIND_FOOD:
          text( "Food", pos.x, pos.y+10 );
          break;
        case ACTOR_STATE_FIND_MATE:
          text( "Mate", pos.x, pos.y+10 );
          break;
      }
      noFill();
    }
  }

  // return true kills this actor  
  boolean update( ArrayList<Actor> actors, ArrayList<Food> foods, float deltaTime ) {
    // update age
    age += deltaTime;
    if( age > genome.getMaxLife() ) {
      die = true;
      //println( "Died from old age");
      deathByAging++;
    }
    
    // decrease mate wait
    mateWait -= deltaTime;
    
    // update health
    //   drains depending on size
    health -= ACTOR_HEALTH_DRAIN_RATE * deltaTime * genome.normal[GENOME_SIZE];
    if( health <= 0.f ) {
      die = true;
      //println( "Died from starvation");
      deathByStarvation++;
    }
    
    // chance of mutation
    mutationWait -= deltaTime;
    if( mutationWait <= 0.f ) {
      mutationWait = ACTOR_MUTATION_WAIT;
      if( random(1) < ACTOR_MUTATION_CHANCE ) {
        genome.mutate();
        //println( "Mutated");
        mutations++;
      }
    }
    
    //bumps (counting)
    /*
    if( bumps > (ACTOR_MAX_BUMPS_IN_ONE_SECOND/timeSpeedFactor) ) {
      die = true;
      //println( "Death by bumping");
      deathByBumping++;
    }
    bumpClearWait -= deltaTime;
    if( bumpClearWait <= 0.f ) {
      bumpClearWait = 1.f;
      bumps = 0;
    }
    */
    // bumping (continuous)
    if( isBumping ) {
      bumpCounter -= deltaTime;
      if( bumpCounter <= 0.f ) {
        die = true;
        deathByBumping++;
      }
    }
    
    // move
    PVector totalMovement = PVector.add(mov,moveAwayFromOverlap);
    totalMovement.mult(genome.getSpeed() * deltaTime);
    pos.add( totalMovement );
    
    // wrap around edges
    if( pos.x < 0 ) {
      pos.x += WORLD_WIDTH;
    } else if( pos.x >= WORLD_WIDTH ) {
      pos.x -= WORLD_WIDTH;
    }
    if( pos.y < 0 ) {
      pos.y += WORLD_HEIGHT;
    } else if( pos.y >= WORLD_HEIGHT ) {
      pos.y -= WORLD_HEIGHT;
    }
    
    // --- adjust movement vector ---
    // most important! move away from overlapping actors
    moveAwayFromOverlap = handleCollision(actors,foods);
    
    // do after random wait
    stateChangeWait -= deltaTime;
    if( stateChangeWait <= 0.f ) {
      stateChangeWait = random(MOVE_WAIT_MAX-MOVE_WAIT_MIN)+MOVE_WAIT_MIN;
      state = genome.getRandomState( age >= ACTOR_MATE_AGE );
      switch( state ) {
        case ACTOR_STATE_STAY_ALOOF:
          mov = getAloofVector( actors );
          break;
        case ACTOR_STATE_FIND_FOOD:
          mov = getNearestFoodVector( foods );
          break;
        case ACTOR_STATE_FIND_MATE:
          mov = getAttractVector( actors );
          break;
      }
    }
    
    return die;
  }
  
  PVector handleCollision( ArrayList<Actor> actors, ArrayList<Food> foods ) {
    // with food
    for( int i = 0 ; i < foods.size() ; i++ ) {
      Food f = foods.get(i);
      if( dist(f.pos.x,f.pos.y,pos.x,pos.y) < genome.getRealSize() ) {
        health += f.getRealValue();
        if( health > 1.f ) {
          health = 1.f;
        }
        foods.remove(i);
      }
    }
    // with other actors
    PVector v = new PVector();
    int count = 0;
    boolean noBumps = true;
    for( int i = 0 ; i < actors.size() ; i++ ) {
      Actor a = actors.get(i);
      if( dist(pos.x,pos.y,a.pos.x,a.pos.y) < (genome.getRealSize() + a.genome.getRealSize()) && a != this ) {
        bumps++;
        //a.bumps++;
        noBumps = false;
        if( !isBumping ) {
          isBumping = true;
          bumpCounter = ACTOR_MAX_CONTINUOUS_BUMPING_TIME;
        } 
        v.add( PVector.sub(a.pos,pos) );
        // and also, if we're looking to mate, mate!
        if( state == ACTOR_STATE_FIND_MATE && a.age >= ACTOR_MATE_AGE && mateWait <= 0.f && !genome.equals(a.genome)
              && !stopMating && a.state == ACTOR_STATE_FIND_MATE && actors.size() <= maxPopulation
              && health >= ACTOR_HEALTH_MIN_TO_MATE) {
          mateWait = random(ACTOR_MATE_WAIT_TIME_MAX-ACTOR_MATE_WAIT_TIME_MIN)+ACTOR_MATE_WAIT_TIME_MIN;
          //println( "New Actor");
          births++;
          actors.add( new Actor(this,a) );
          babiesHad++;
          if( babiesHad > genome.getMaxBabies() ) {
            die = true;
            //println( "Died from child-birth");
            deathByChildbirth++;
          }
          /*
          a.babiesHad++;
          if( a.babiesHad > a.genome.getMaxBabies() ) {
            a.die = true;
            messageLog.add("Died from child-birth");
            println( "Died from child-birth");
          }
          */
        }
        count++;
      }
    }
    if( noBumps ) {
      isBumping = false;
    }
    if( count > 0 ) {
      v.div(count);
      v.mult(-1); // reverse
      v.normalize();
    }
    return v;
  }
  
  PVector getNearestFoodVector( ArrayList<Food> foods ) {
    for( Food f : foods ) {
      if( dist(f.pos.x,f.pos.y,pos.x,pos.y) < genome.getSightDist() ) {
        PVector v = PVector.sub(f.pos,pos);
        v.normalize();
        if( debugOn ) {
          stroke(255,255,0);
          ellipse(pos.x,pos.y,20,20);
        }
        return v;
      }
    }
    PVector v = new PVector(random(1),random(1));
    v.normalize();
    return v;
  }
  
  PVector getAloofVector( ArrayList<Actor> actors ) {
    PVector v = getMovementVector(actors);
    if( debugOn ) {
      stroke(0,0,255);
      ellipse(pos.x,pos.y,20,20);
    }
    v.mult(-1);   // reverse, away from nearby actors
    v.normalize();
    return v;
  }
  
  PVector getAttractVector( ArrayList<Actor> actors ) {
    // first find vector _towards_ other actors we can see
    float sightDist = genome.getSightDist();
    PVector v = new PVector();
    int count = 0;
    for( Actor a : actors ) {
      if( dist(pos.x,pos.y,a.pos.x,a.pos.y) < sightDist && a != this && !genome.equals(a.genome) ) {
        v.add( PVector.sub(a.pos,pos) );
        count++;
      }
    }
    if( count > 0 ) {
      v.div(count);
    } else {
      v.x = random(1);
      v.y = random(1);
    }
    if( debugOn ) {
      stroke(0,0,255);
      ellipse(pos.x,pos.y,20,20);
    }
    v.normalize();
    return v;
  }
  
  PVector getMovementVector( ArrayList<Actor> actors ) {
    // first find vector _towards_ other actors we can see
    float sightDist = genome.getSightDist();
    PVector v = new PVector();
    int count = 0;
    for( Actor a : actors ) {
      if( dist(pos.x,pos.y,a.pos.x,a.pos.y) < sightDist && a != this ) {
        v.add( PVector.sub(a.pos,pos) );
        count++;
      }
    }
    if( count > 0 ) {
      v.div(count);
    } else {
      v.x = random(1);
      v.y = random(1);
    }
    return v;
  }
}
