import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

import fisica.*;

FWorld world;
PostFX fx;

ArrayList<FCircle> centroids = new ArrayList<FCircle>();
ArrayList<FCircle> particles = new ArrayList<FCircle>();

int ticker = 0;

// Restart once per cycle. Second 0 is the opening frame, and the
// seconds check stays true for every frame of the trigger second.
int regenInterval = 30;
int lastRegenSecond = -1;

// Particles inside this gap take colour from nearby centroids.
float influenceRadius = 180;
float influenceSoftness = 12;
float particleLighten = 0.15;
int farGrey = 120;

//float simWidth  = 800;
//float simHeight = 800;

// color palette for centroids
color[] colors = {
  #fde039,
  #6dd171,
  #f78944,
  #298ebb,
  #f53336,
  #ce558a,
  #9e9881
};

// range of velocity values that can be randomly selected and applied
int[] velocityValues = {0, 2, -2, 4, -4, 6, -6};

void setup() {
  fullScreen(P2D);
  //size(800, 480, P2D);
  smooth(8);
  
  pixelDensity(1);
  
  fx = new PostFX(this);
  
  Fisica.init(this);
  world = new FWorld();
  
  // switch off gravity
  world.setGravity(0,0);
  
  populateWorld();
}

void draw() {
  background(0);
  
  int seconds = millis()/1000;
  
  // in every 30 seconds restart the visualisation, once
  if (seconds > 0 && seconds % regenInterval == 0 && seconds != lastRegenSecond) {
    lastRegenSecond = seconds;
    regenerate();
  }
  
  world.step();
  
  for (FCircle p : particles) {
    float vx = p.getVelocityX();
    float vy = p.getVelocityY();
    float speed = sqrt(vx*vx + vy*vy);
    float maxSpeed = 14;
    if (speed > maxSpeed) {
      p.setVelocity(vx/speed * maxSpeed, vy/speed * maxSpeed);
    }
  }
  
  hoverCentroids();
  track();
  world.draw();
  
  // apply post processor effects to the sketch
  fx.render()
    .bloom(0.3, 20, 30)
    .blur(2, 2)
    .compose();
}

/**
 * Fill the world with the same walls, centroids, and particles used at launch.
 */
void populateWorld() {
  addWalls();
  addCentroids();
  addParticles();
}

/**
 * Invisible bounds. Rebuild these after every clear so a restart
 * keeps the same bounce as the opening frame.
 */
void addWalls() {
  float wallThickness = 20;
  float w = width;
  float h = height;

  addWall(wallThickness, h + wallThickness * 2, -wallThickness / 2, h / 2);
  addWall(wallThickness, h + wallThickness * 2, w + wallThickness / 2, h / 2);
  addWall(w + wallThickness * 2, wallThickness, w / 2, -wallThickness / 2);
  addWall(w + wallThickness * 2, wallThickness, w / 2, h + wallThickness / 2);
}

void addWall(float wallWidth, float wallHeight, float x, float y) {
  FBox wall = new FBox(wallWidth, wallHeight);
  wall.setPosition(x, y);
  wall.setName("Wall");
  wall.setStatic(true);
  wall.setFriction(0);
  wall.setRestitution(1.0);
  wall.setNoStroke();
  wall.setFill(0, 0);
  world.add(wall);
}

/**
 * Add centroids randomly in the canvas.
 */
void addCentroids() {
  int[] centroidVelocity = {2, -2};
  
  for (int i=0; i < 7; i++) {    
    FCircle c = new FCircle(60);
    
    c.setName("Centroid");
    
    float posX = random(120, width - 120);
    float posY = random(120, height - 120);
    
    c.setPosition(posX, posY);
    
    // generate random movement speed for each particle
    //int indexX = int(random(velocityValues.length));
    int indexY = int(random(centroidVelocity.length));
    
    c.setVelocity(0, centroidVelocity[indexY]);
    
    c.setGrabbable(false);
    c.setRotatable(false);
        
    c.setFriction(0);
    c.setRestitution(0);
    c.setDamping(0);
    c.setAngularDamping(0);
    
    c.setNoStroke();
    c.setFillColor(colors[i]);
    
    world.add(c);
    centroids.add(c);
  }
}

/**
 * Add particles randomly in the canvas
 */
void addParticles() {
  int numOfParticles = (int) random(400, 1000);
  
  for (int i=0; i < numOfParticles; i++) {
    int radius = (int) random(2, 15);
    FCircle c = new FCircle(radius);
    
    c.setName("Particle");
    
    float posX = random(20, width - 20);
    float posY = random(20, height - 20);
    
    c.setPosition(posX, posY);
    
    c.setGrabbable(false);
    
    // generate random movement speed for each particle
    int indexX = int(random(velocityValues.length));
    int indexY = int(random(velocityValues.length));
    
    c.setVelocity(velocityValues[indexX], velocityValues[indexY]);
     
    c.setFriction(0);
    c.setRestitution(0.95);
    c.setDamping(0);
    c.setAngularDamping(0);
    c.setStrokeWeight(1);
    c.setStrokeColor(0);
    c.setFillColor(0);
    
    world.add(c);
    particles.add(c);
  }
}

void hoverCentroids() {
  for (int i = 0; i < centroids.size(); i++) {
    FCircle centroid = centroids.get(i);
    
    float x = 0;
    float y = 0;
    
    // generate random movement speed for each particle
    //int indexX = int(random(velocityValues.length));
    //int indexY = int(random(velocityValues.length));
    
    //centroid.setVelocity(velocityValues[indexX], velocityValues[indexY]);
    
    if (ticker % 150 == 0) {
      if (centroid.getVelocityY() < 0) {
        y = -(centroid.getVelocityY());
      }
      
      if (centroid.getVelocityY() > 0) {
        y = -centroid.getVelocityY();
      }
      
      centroid.setVelocity(x, y);
    }
  }
  
  ticker++;
}

/**
 * Regenerate sketch by removing everything and adding them back again.
 */
void regenerate() {
  world.clear();
  particles.clear();
  centroids.clear();
  populateWorld();
}

/**
 * Colour each particle from the centroids within range.
 * Inverse distance mixes centroids that share a particle, and the
 * mix fades toward grey at the edge of the field.
 */
void track() {
  FCircle centroid, particle;
  
  for (int i=0; i < particles.size(); i++) {
    particle = particles.get(i);
    
    float redSum = 0;
    float greenSum = 0;
    float blueSum = 0;
    float totalWeight = 0;
    float fieldStrength = 0;
    
    for (int j=0; j < centroids.size(); j++) {
      centroid = centroids.get(j);
      
      float distance = dist(particle.getX(), particle.getY(), centroid.getX(), centroid.getY());
      
      // take size of each bodies into factor when measuring distance
      distance = distance - (centroid.getSize() + particle.getSize());
      
      if (distance < influenceRadius) {
        float gap = max(distance, 0);
        float weight = 1.0 / (gap + influenceSoftness);
        color col = centroid.getFillColor();
        
        redSum += red(col) * weight;
        greenSum += green(col) * weight;
        blueSum += blue(col) * weight;
        totalWeight += weight;
        
        float falloff = 1.0 - (gap / influenceRadius);
        if (falloff > fieldStrength) {
          fieldStrength = falloff;
        }
      }
    }
    
    if (totalWeight > 0) {
      color mixed = color(redSum / totalWeight, greenSum / totalWeight, blueSum / totalWeight);
      color lightened = lerpColor(mixed, color(255), particleLighten);
      particle.setFillColor(lerpColor(color(farGrey), lightened, fieldStrength));
    } else {
      particle.setFillColor(farGrey);
    }
  }
}

/**
 * Handle collision with edges to workout how each body should deflect.
 */
void contactStarted(FContact contact) {
  FBody body1 = contact.getBody1();
  FBody body2 = contact.getBody2();
  
  if (isWall(body1)) {
    reflectFromWall(body2, contact.getX(), contact.getY());
  }
  
  if (isWall(body2)) {
    reflectFromWall(body1, contact.getX(), contact.getY());
  }
}

boolean isWall(FBody body) {
  return "Wall".equals(body.getName());
}

void reflectFromWall(FBody body, float contactX, float contactY) {
  float edgeLeft   = 5;
  float edgeRight  = width - 5;
  float edgeTop    = 5;
  float edgeBottom = height - 5;
  
  float newVelX = body.getVelocityX();
  float newVelY = body.getVelocityY();
  
  if (contactX >= edgeRight || contactX <= edgeLeft) {
    newVelX = -newVelX;
  }
  
  if (contactY >= edgeBottom || contactY <= edgeTop) {
    newVelY = -newVelY;
  }
  
  body.setVelocity(newVelX, newVelY);
}
