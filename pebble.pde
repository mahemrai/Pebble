import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

import fisica.*; 

FWorld world;
PostFX fx;

ArrayList<FCircle> centroids = new ArrayList<FCircle>();
ArrayList<FCircle> particles = new ArrayList<FCircle>();

// color palette for centroids
color[] colors = {
  #fde039,
  #6dd171,
  #f78944,
  #298ebb,
  #f53336
}; 

void setup() {
  size(800, 800, P2D);
  smooth();
  
  fx = new PostFX(this);
  
  Fisica.init(this);
  world = new FWorld();
  
  // switch off gravity
  world.setGravity(0,0);
  // objects cannot be grabbed
  world.setGrabbable(false);
  
  // no effect on velocity of moving objects
  world.setEdgesFriction(0);
  world.setEdgesRestitution(0);
  world.setEdges();
  
  addCentroids();
  addParticles();
}

void draw() {
  background(0);
  
  world.step();
  world.draw();
  
  track();
  
  fx.render()
    .bloom(0.3, 20, 30)
    .compose();
}

void addCentroids() {
  for (int i=0; i < 5; i++) {    
    FCircle c = new FCircle(40);
    
    c.setName("Centroid");
    
    // place centroids randomly in the canvas
    float posX = random(120, 680);
    float posY = random(120, 680);
    
    c.setPosition(posX, posY);
        
    c.setFriction(0);
    c.setRestitution(0);
    c.setDamping(0);
    c.setAngularDamping(0);
    
    c.setStrokeColor(colors[i]);
    c.setStrokeWeight(5);
    c.setFillColor(colors[i]);
    
    world.add(c);
    centroids.add(c);
  }
}

void addParticles() {
  int[] velocityValues = {0, 12, -12, 15, -15, 8, -8};
  
  for (int i=0; i < 100; i++) {
    FCircle c = new FCircle(10);
    
    c.setName("Particle");
    
    float posX = random(20, 780);
    float posY = random(20, 780);
    
    c.setPosition(posX, posY);
        
    int indexX = int(random(velocityValues.length));
    int indexY = int(random(velocityValues.length));
    
    c.setVelocity(velocityValues[indexX], velocityValues[indexY]);
     
    c.setFriction(0);
    c.setRestitution(0);
    c.setDamping(0);
    c.setAngularDamping(0);
    c.setNoStroke();
    c.setFillColor(0);
    
    world.add(c);
    particles.add(c);
  }
}

void track() {
  FCircle centroid, particle;
  
  for (int i=0; i < particles.size(); i++) {
    int closestCentroidIndex = -1;
    float closestDistance = 100;
        
    particle = particles.get(i);
    
    for (int j=0; j < centroids.size(); j++) {
      centroid = centroids.get(j);
      
      float distance = dist(particle.getX(), particle.getY(), centroid.getX(), centroid.getY());
      
      distance = distance - (40 + 10);
      
      if (distance < closestDistance) {
        closestCentroidIndex = j;
        closestDistance = distance;
      }
    }
    
    if (closestCentroidIndex > -1) {
      particle.setFillColor(centroids.get(closestCentroidIndex).getFillColor());
    } else {
      particle.setFillColor(0);
    }
  }
}

void contactStarted(FContact contact) {
  FBody body1 = contact.getBody1();
  FBody body2 = contact.getBody2();
  
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
  
  if (body2.getName() != "Centroid" && body2.getName() != "Particle") {
  }
}
