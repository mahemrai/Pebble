import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

import fisica.*; 

FWorld world;
PostFX fx;

color[] colors = {
  #1a429b,
  #ed3d51,
  #ce558a,
  #6cc96d,
  #ff8943,
  #ffc13b,
  #fe5244,
  #288651,
  #2c93bb,
  #a6bcce,
  #121e34,
  #ab4343,
  #545970
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
  
  fx.render()
    .bloom(0.5, 20, 30)
    .compose();
}

void addCentroids() {
  for (int i=0; i < 5; i++) {
    int random = (int) random(colors.length);
    
    FCircle c = new FCircle(40);
    float posX = random(160, 640);
    float posY = random(160, 640);
    c.setName("Centroid");
    c.setPosition(posX, posY);
    
    c.setStatic(true);
    
    c.setFriction(0);
    c.setRestitution(0);
    c.setDamping(0);
    c.setAngularDamping(0);
    c.setNoStroke();
    
    c.setFillColor(colors[random]);
    
    world.add(c);
  }
}

void addParticles() {
  int[] velocityValues = {0, 12, -12, 15, -15, 8, -8};
  
  for (int i=0; i < 100; i++) {
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
