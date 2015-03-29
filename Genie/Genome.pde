int GENOME_NUM_MUSIC_DATA = 0;

final int GENOME_MAKE_EMPTY = 0;
final int GENOME_MAKE_RANDOM = 1;

float GENOME_MIN_SPEED = 40;
float GENOME_MAX_SPEED = 350;

float GENOME_MAX_VISION = 500;
float GENOME_MIN_VISION = 50;

float GENOME_MAX_LIFE_MIN = 10.f;
float GENOME_MAX_LIFE_MAX = 30.f;

int GENOME_MAX_BABIES_MIN = 1;
int GENOME_MAX_BABIES_MAX = 6;

float GENOME_CHANCE_OF_INDIVIDUAL_MUTATION = 0.3f;


final int GENOME_EDGECOL = 0;
final int GENOME_SHAPE = 1;
final int GENOME_SIZE = 2;
final int GENOME_VISION = 3;
final int GENOME_SPEED = 4;
final int GENOME_STATEALOOF = 5;
final int GENOME_STATEHUNGRY = 6;
final int GENOME_STATEMATE = 7;
final int GENOME_MAXBABIES = 8;
final int GENOME_MAXLIFE = 9;

int GENOME_NUM_NORMAL_GENES = 10;

class Genome {
  // note, all values between 0.0 and 1.0
  //float[] music = new float[GENOME_NUM_MUSIC_DATA];  //??
  float[] normal = new float[GENOME_NUM_NORMAL_GENES];
  
  Genome( int type ) {
    switch( type ) {
      case GENOME_MAKE_EMPTY:
        clear();
        break;
      case GENOME_MAKE_RANDOM:
        randomize();
        break;
      default:
        break;
    }
  }
  
  Genome( Genome g1, Genome g2 ) {
    int midPoint = (int)random(GENOME_NUM_NORMAL_GENES);
    for( int i = 0 ; i < GENOME_NUM_NORMAL_GENES ; i++ ) {
      if( i < midPoint ) {
        normal[i] = g1.normal[i];
      } else {
        normal[i] = g2.normal[i];
      }
    }
  }
  
  void clear() {
    //for( int i = 0 ; i < GENOME_NUM_MUSIC_DATA ; i++ ) {
    //  music[i] = 0;
    //}
    for( int i = 0 ; i < GENOME_NUM_NORMAL_GENES ; i++ ) {
      normal[i] = 0;
    }
  }
  
  void randomize() {
    //for( int i = 0 ; i < GENOME_NUM_MUSIC_DATA ; i++ ) {
    //  music[i] = random(1);
    //}
    for( int i = 0 ; i < GENOME_NUM_NORMAL_GENES ; i++ ) {
      normal[i] = random(1);
    }
  }
  
  void mutate() {
    for( int i = 0 ; i < GENOME_NUM_NORMAL_GENES ; i++ ) {
      if( random(1) < GENOME_CHANCE_OF_INDIVIDUAL_MUTATION ) {
        normal[i] = random(1);
      }
    }
  }
  
  Genome copy() {
    Genome g = new Genome( GENOME_MAKE_EMPTY );
    //for( int i = 0 ; i < GENOME_NUM_MUSIC_DATA ; i++ ) {
    //  g.music[i] = music[i];
    //}
    for( int i = 0 ; i < GENOME_NUM_NORMAL_GENES ; i++ ) {
      g.normal[i] = normal[i];
    }
    return g;
  }
  
  boolean equals( Genome other ) {
    boolean doesEqual = true;
    for( int i = 0 ; i < GENOME_NUM_NORMAL_GENES ; i++ ) {
      if( other.normal[i] != normal[i] ) {
        doesEqual = false;
      }
    }
    return doesEqual;
  }
  
  // ------------------ Tools
  
  int getRandomState( boolean oldEnoughToMate ) {
    if( oldEnoughToMate ) {
      float totalState = normal[GENOME_STATEALOOF] + normal[GENOME_STATEHUNGRY] + normal[GENOME_STATEMATE];
      float aloof = normal[GENOME_STATEALOOF] / totalState;
      float hungry = normal[GENOME_STATEHUNGRY] / totalState;
      float choice = random(1);
      if( choice < aloof ) {
        return ACTOR_STATE_STAY_ALOOF;
      } else if( choice < (aloof+hungry) ) {
        return ACTOR_STATE_FIND_FOOD;
      }
      // else
      return ACTOR_STATE_FIND_MATE;
    }
    // else
    float totalState = normal[GENOME_STATEALOOF] + normal[GENOME_STATEHUNGRY];
    float aloof = normal[GENOME_STATEALOOF] / totalState;
    //float hungry = stateHungry / totalState;
    float choice = random(1);
    if( choice < aloof ) {
      return ACTOR_STATE_STAY_ALOOF;
    }
    // else
    return ACTOR_STATE_FIND_FOOD;
  }
  
  // ------------------ Conversion
  
  float getSpeed() {
    return (normal[GENOME_SPEED] * (GENOME_MAX_SPEED-GENOME_MIN_SPEED))+GENOME_MIN_SPEED;
  }
  
  float getRealSize() {
    return (normal[GENOME_SIZE] * (SHAPE_MAX_SIZE-SHAPE_MIN_SIZE))+SHAPE_MIN_SIZE;
  }
  
  float getSightDist() {
    return getRealSize() + (normal[GENOME_VISION] * (GENOME_MAX_VISION-GENOME_MIN_VISION))+GENOME_MIN_VISION;
  }
  
  float getMaxLife() {
    return (normal[GENOME_MAXLIFE]* GENOME_MAX_LIFE_MAX-GENOME_MAX_LIFE_MIN) + GENOME_MAX_LIFE_MIN;
  }
  
  int getMaxBabies() {
    return (int)((float)normal[GENOME_MAXBABIES] * GENOME_MAX_BABIES_MAX-GENOME_MAX_BABIES_MIN)+GENOME_MAX_BABIES_MIN;
  }
}
