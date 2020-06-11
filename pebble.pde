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
  #f53336,
  #ce558a,
  #9e9881
};

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
}

void draw() {
  background(0);
  
  world.step();
  world.draw();
    
  track();
  
  fx.render()
    .bloom(0.3, 20, 30)
    .blur(2, 2)
    .compose();
}

void addCentroids() {
  for (int i=0; i < 7; i++) {    
    FCircle c = new FCircle(40);
    
    c.setName("Centroid");
    
    // place centroids randomly in the canvas
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

void addParticles() {
  for (int i=0; i < 2000; i++) {
    FCircle c = new FCircle(6);
    
    c.setName("Particle");
    
    float posX = random(20, 780);
    float posY = random(20, 780);
    
    c.setPosition(posX, posY);
    
    c.setGrabbable(false);
        
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
}

void track() {
  FCircle centroid, particle;
  
  for (int i=0; i < particles.size(); i++) {
    int closestCentroidIndex = -1;
    float closestDistance = 150;
        
    particle = particles.get(i);
    
    for (int j=0; j < centroids.size(); j++) {
      centroid = centroids.get(j);
      
      float distance = dist(particle.getX(), particle.getY(), centroid.getX(), centroid.getY());
      
      distance = distance - (40 + 6);
      
      if (distance < closestDistance) {
        closestCentroidIndex = j;
        closestDistance = distance;
      }
    }
    
    if (closestCentroidIndex > -1) {
      particle.setStrokeColor(centroids.get(closestCentroidIndex).getFillColor());
    } else {
      particle.setStrokeColor(0);
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
