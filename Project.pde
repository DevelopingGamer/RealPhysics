SimpleUI ui;
TextDisplayBox gravityLabel;
TextDisplayBox ballMassLabel;
TextDisplayBox ballVelLabel;
SimpleButton resetButton;
Slider gravSlider;
Slider ballMassSlider;
Slider ballVelSlider;

SimSurfaceMesh tableTop;
SimSphereMover ball;
SimSurfaceMesh target; //<>//

SimCamera myCam;

float gravMag = 0.7;
PVector gravity;

float ballMass = 0.5;

float ballForce = 0.2;

boolean moving = false; //<>//

float tableTopX = 300;
float tableTopY = 450;
float tableTopZ = -130;

int targetLeftX = 300;
int targetRightX = 600;
int targetTopY = 300;
int targetBottomY = 450;
int targetZ = -100;

boolean ballExists = false;
boolean forwards;
boolean initial = false;


void setup(){
  size(950, 700, P3D);
  myCam = new SimCamera();
  tableTop = new SimSurfaceMesh(20, 35, 17);
  
  ui = new SimpleUI();
  gravityLabel = ui.addLabel("Gravity", 140, 20, str(gravMag));
  ballMassLabel = ui.addLabel("Ball Mass", 140, 40, str(ballMass));
  ballVelLabel = ui.addLabel("Ball Force", 140, 60, str(ballForce));
  
  gravSlider = ui.addSlider("Gravity", 20, 20);
  ballMassSlider = ui.addSlider("Ball Mass", 20, 50);
  ballVelSlider = ui.addSlider("Ball Force", 20, 80);
  
  resetButton = ui.addSimpleButton("Start/Reset", 20, 200);
  
  
  PVector tableTopVec = new PVector(tableTopX, tableTopY, tableTopZ);
  tableTop.setTransformAbs( 1, 0, 0, 0, tableTopVec);
  
  forwards = true;
  
  String p = sketchPath();
  println(p);
  
  int targetPolyX = 40;
  int targetPolyY = 20;
  
  target = new SimSurfaceMesh(targetPolyX, targetPolyY, 1);
  
  PVector targetVec = new PVector(targetLeftX, targetTopY, targetZ); //<>//
  target.setTransformAbs(8.5, 80, 0, 0, targetVec); //<>//
}

void setBallAtStartPos(){
  float ballX = 500;
  float ballY = 300;
  float ballZ = 300;
  int ballRad = 5;
  
  PVector ballVec = new PVector(ballX, ballY, ballZ);
  
  ball = new SimSphereMover(ballVec, ballRad);
  gravity = new PVector(0,gravMag * 10000,0);
  ball.physics.setMass(ballMass * 10);
  moving = true;
}

void draw(){
  background(0);
  lights();
  
  myCam.update();
  myCam.isMoving = false;
  
  pushStyle();
  noStroke();
  fill(255, 0, 0);
  target.drawMe();
  popStyle();
  
  pushStyle();
  fill(70,127, 70 );
  noStroke();
  tableTop.drawMe();
  popStyle();
  
  PVector ballMove;
  
  if (forwards) {
    ballMove = new PVector(0, 0, -(ballForce * 1000000));
  } else {
    ballMove = new PVector(0, 0, ballForce * 1000000);
  }
  
  if (initial == true) {
    //reset();
    ball.physics.addForce(ballMove);
    initial = false;
  }
    
  updateBallBounce();
  
  if (ballExists == true) {
    pushStyle();
    fill(255,150,0);
    //stroke(255);
    noStroke();
    ball.drawMe();
    popStyle();
  }
  
  myCam.startDrawHUD();
      gravityLabel.setText(str(gravMag));
      ballMassLabel.setText(str(ballMass));
      ballVelLabel.setText(str(ballForce));
    ui.update();
  myCam.endDrawHUD();
}


void updateBallBounce(){
  if (ballExists == true) {
    moving = true;
    // move the ball in the current ball direction
    if(moving) ball.physics.addForce(gravity);
    
    if(ball.physics.location.y >= tableTopY && (ball.physics.location.z <= tableTopZ || ball.physics.location.z >= tableTopZ + 15) && (ball.physics.location.x <= tableTopX || ball.physics.location.x >= tableTopX + 20)) {
    //if (ball.collidesWith(tableTop)) {
      float mag = ball.physics.velocity.mag();
      PVector bounceVector = reflectOffSurface(ball.physics.velocity, new PVector(0,-1,0));
      ball.physics.velocity = bounceVector.mult(mag);
    }
  
    if (ball.physics.location.z <= targetZ && (ball.physics.location.x >= targetLeftX && ball.physics.location.x <= targetRightX) && (ball.physics.location.y >= targetTopY && ball.physics.location.y <= targetBottomY)) {
      forwards = false;
      float mag = ball.physics.velocity.mag();
      PVector bounceVector = reflectOffSurface(ball.physics.velocity, new PVector(0,0,-1));
      ball.physics.velocity = bounceVector.mult(mag);
    }
    
    if (ball.physics.location.z >= 500) {
      forwards = true;
      float mag = ball.physics.velocity.mag();
      PVector bounceVector = reflectOffSurface(ball.physics.velocity, new PVector(0,0,1));
      ball.physics.velocity = bounceVector.mult(mag);
    }
  }
}


PVector reflectOffSurface(PVector incident, PVector surfaceNormal){
  // Using Fermat's Principle: the formula R = 2(N.I)N-I, where N is the surface normal,
  // I is the vector of the incident ray, and R is the resultant reflection.
  // First make sure you are working on copies only so changes are not propagated outside the method,
  // and that the incident and surfaceNormal vectors are normalized
  
  
  PVector i = incident.copy();
  i.normalize();
  
  PVector n = surfaceNormal.copy();
  n.normalize();
  
  // do the vector maths
  float n_dot_i_x2 = n.dot(i)*2;
  
  PVector n_dot_i_x2_xn = PVector.mult(n, n_dot_i_x2);
  
  PVector reflection =  PVector.sub(n_dot_i_x2_xn,i);
  // need to do this to create a reflection "this side" of the surface, not the ray on the other side
  reflection.mult(-1);
  //println("reflect I,SN,R ", i, n, reflection);
  return reflection;
}

void handleUIEvent(UIEventData uied){
  if (uied.eventIsFromWidget("Start/Reset")) {
   reset(); 
  }
  
  if (uied.eventIsFromWidget("Gravity")) {
    gravMag = gravSlider.getSliderValue();
  }
  
  if (uied.eventIsFromWidget("Ball Mass")) {
    ballMass = ballMassSlider.getSliderValue();
  }

  if (uied.eventIsFromWidget("Ball Force")) {
    ballForce = ballVelSlider.getSliderValue(); 
  } 
  
  // here we just get the event to print its self
  // with "verbosity" set to 1, (1 = low, 3 = high, 0 = do not print anything)
  uied.print(2);
}

void reset () {
  setBallAtStartPos();
  initial = true;
  forwards = true;
  ballExists = true;
}
