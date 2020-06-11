import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

import fisica.*; 

FWorld world;
PostFX fx;

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
  
  world.setGrabbable(false);
  
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
  
  /*fx.render()
    .bloom(0.3, 20, 20)
    .compose();*/
}

void addCentroids() {
  for (int i=0; i < 5; i++) {
    //int random = (int) random(colors.length);
    
    FCircle c = new FCircle(40);
    float posX = random(120, 680);
    float posY = random(120, 680);
    c.setName("Centroid");
    c.setPosition(posX, posY);
        
    c.setFriction(0);
    c.setRestitution(0);
    c.setDamping(0);
    c.setAngularDamping(0);
    
    c.setStrokeColor(colors[i]);
    c.setStrokeWeight(5);
    c.setFillColor(colors[i]);
    
    world.add(c);
  }
}

void addParticles() {
  int[] velocityValues = {0, 12, -12, 15, -15, 8, -8};
  
  for (int i=0; i < 200; i++) {
    FCircle c = new FCircle(10);
    
    float posX = random(20, 780);
    float posY = random(20, 780);
    c.setPosition(posX, posY);
    c.setRotatable(true);
    c.setName("Particle");
    
    int indexX = int(random(velocityValues.length));
    int indexY = int(random(velocityValues.length));
    
    c.setVelocity(velocityValues[indexX], velocityValues[indexY]);
     
    c.setFriction(0);
    c.setRestitution(0);
    c.setDamping(0);
    c.setAngularDamping(0);
    c.setNoStroke();
    
    world.add(c);
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
