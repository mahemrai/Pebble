import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

import fisica.*;

FWorld world;
PostFX fx;

boolean render = true;
boolean regenerating = false;

ArrayList<FCircle> centroids = new ArrayList<FCircle>();
ArrayList<FCircle> particles = new ArrayList<FCircle>();

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
  size(800, 800, P2D);
  smooth(8);
  
  fx = new PostFX(this);
  
  Fisica.init(this);
  world = new FWorld();
  
  // switch off gravity
  world.setGravity(0,0);
  
  // no effect on velocity of moving objects
  world.setEdgesFriction(0);
  world.setEdgesRestitution(0);
  world.setEdges();
  
  addCentroids();
  addParticles();
  //noLoop();
}

void draw() {
  background(0);
  
  int seconds = millis()/1000;
  
  if (seconds % 30 == 0) {
    regenerate();
  }
  
  world.step();
  world.draw();
  track();
  
  // apply post processor effects to the sketch
  fx.render()
    .bloom(0.3, 20, 30)
    .blur(2, 2)
    .compose();
}

/**
 * Add centroids randomly in the canvas.
 */
void addCentroids() {
  for (int i=0; i < 7; i++) {    
    FCircle c = new FCircle(60);
    
    c.setName("Centroid");
    
    float posX = random(120, 680);
    float posY = random(120, 680);
    
    c.setPosition(posX, posY);
    
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
  int numOfParticles = (int) random(100, 450);
  
  for (int i=0; i < numOfParticles; i++) {
    int radius = (int) random(2, 15);
    FCircle c = new FCircle(radius);
    
    c.setName("Particle");
    
    float posX = random(20, 780);
    float posY = random(20, 780);
    
    c.setPosition(posX, posY);
    
    c.setGrabbable(false);
    
    // generate random movement speed for each particle
    int indexX = int(random(velocityValues.length));
    int indexY = int(random(velocityValues.length));
    
    c.setVelocity(velocityValues[indexX], velocityValues[indexY]);
     
    c.setFriction(0);
    c.setRestitution(0);
    c.setDamping(0);
    c.setAngularDamping(0);
    c.setStrokeWeight(1);
    c.setStrokeColor(0);
    c.setFillColor(0);
    
    world.add(c);
    particles.add(c);
  }
  
  regenerating = false;
}

void regenerate() {
  world.clear();
  world.setEdges();
  particles.clear();
  centroids.clear();
  addParticles();
  addCentroids();
  
  delay(1000);
}

/**
 * Calculate distance of each particle with each centroid and update
 * particle's colour depending on what centroid it is closer to.
 */
void track() {
  FCircle centroid, particle;
  
  for (int i=0; i < particles.size(); i++) {
    int closestCentroidIndex = -1;
    float closestDistance = 180;
        
    particle = particles.get(i);
    
    for (int j=0; j < centroids.size(); j++) {
      centroid = centroids.get(j);
      
      float distance = dist(particle.getX(), particle.getY(), centroid.getX(), centroid.getY());
      
      distance = distance - (centroid.getSize() + particle.getSize());
      
      if (distance < closestDistance) {
        closestCentroidIndex = j;
        closestDistance = distance;
      }
    }
    
    if (closestCentroidIndex > -1) {
      //particle.setStrokeColor(centroids.get(closestCentroidIndex).getFillColor());
      particle.setFillColor(centroids.get(closestCentroidIndex).getFillColor());
    } else {
      //particle.setStrokeColor(0);
      particle.setFillColor(0);
    }
  }
}

/**
 * Handle collision with edges to workout how each body should deflect.
 */
void contactStarted(FContact contact) {
  FBody body1 = contact.getBody1();
  FBody body2 = contact.getBody2();
  
  // check to ensure the collision is with edges
  if (body1.getName() != "Centroid" && body1.getName() != "Particle") {
    float contactX = contact.getX();
    float contactY = contact.getY();
        
    float newVelX = body2.getVelocityX();
    float newVelY = body2.getVelocityY();
    
    if (contactX >= 795 || contactX <= 5) {
      newVelX = -newVelX;
    }
    
    if (contactY >= 795 || contactY <= 5) {
      newVelY = -newVelY;
    }
    
    body2.setVelocity(newVelX, newVelY);
  }
  
  // check to ensure collision is with edges
  if (body2.getName() != "Centroid" && body2.getName() != "Particle") {
    float contactX = contact.getX();
    float contactY = contact.getY();
        
    float newVelX = body1.getVelocityX();
    float newVelY = body1.getVelocityY();
    
    if (contactX >= 795 || contactX <= 5) {
      newVelX = -newVelX;
    }
    
    if (contactY >= 795 || contactY <= 5) {
      newVelY = -newVelY;
    }
    
    body1.setVelocity(newVelX, newVelY);
  }
}
