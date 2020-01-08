//------------------------------------------
// cycloid profile generator
// dan@marginallyclever.com 2020-01-08
// CC-BY-NC-SA
// Based on https://github.com/mawildoer/cycloidal_generator
//------------------------------------------

class Point2D {
  public float x,y;
  
  public Point2D() {}
  public Point2D(float x0,float y0) {
    x=x0;
    y=y0;
  }
}


Point2D getPoint(float t, float R, float Rr, float E, float N) {
    //psi = -atan(sin((1 - N) * theta) / ((R / (E * N)) - cos((1 - N) * theta)))
    //x = R * cos(theta) - Rr * cos(theta - psi) - E * cos(N * theta)
    //y =  - R * sin(theta) + Rr * sin(theta - psi) + E * cos(N * theta)
    float psi = atan2(sin((1-N)*t), ((R/(E*N))-cos((1-N)*t)));

    float x = (R*cos(t))-(Rr*cos(t+psi))-(E*cos(N*t));
    float y = (-R*sin(t))+(Rr*sin(t+psi))+(E*sin(N*t));
    //x = (10*cos(t))-(1.5*cos(t+atan(sin(-9*t)/((4/3)-cos(-9*t)))))-(0.75*cos(10*t))
    //y = (-10*sin(t))+(1.5*sin(t+atan(sin(-9*t)/((4/3)-cos(-9*t)))))+(0.75*sin(10*t))
    return new Point2D(x,y);
}


float getDist(float xa, float ya, float xb, float yb) {
    return sqrt(sq(xa-xb) + sq(ya-yb));
}
  
  
//####   CHANGE THE VALUES BELOW FOR DIMENSIONS #####
float R = 300; //rotor radius (mm)
float N = 50; //number of rollers

float OutputPinRadius = 30; //output pin radius
float Ro = 200;  // output pin orbit radius (mm)
float No = 8;  // number of output pins
float Cr = 100;  // Eccentric Cam radius (mm)
//###################################################


//other constants based on the original inputs
float housing_cir = 2 * R * PI;
float Rr = housing_cir / (4 * N); //roller radius
float E = 0.5 * Rr; //eccentricity
float maxDist = 0.25 * Rr; //maximum allowed distance between points
float minDist = 0.5 * maxDist; //the minimum allowed distance between points
float RADIANS_PER_TOOTH=2*PI/(N-1);

boolean pictureExpired=true;


void setup() {
  size(800,800);  // new window
  scale(60);
  //strokeWeight(0.05);
  
  //println("Ratio will be " + (1/N) + ".");
}


void updateGearParameters() {
  //other constants based on the original inputs
  housing_cir = 2 * R * PI;
  Rr = housing_cir / (4 * N); //roller radius
  E = 0.5 * Rr; //eccentricity
  maxDist = 0.25 * Rr; //maximum allowed distance between points
  minDist = 0.5 * maxDist; //the minimum allowed distance between points
}

void keyReleased() {
  switch(key) {
    case '1': N++;  break;
    case '2': N--;  break;
    case '3': No++;  break;
    case '4': No--;  break;
    default: break;
  }
  println("N="+N+" No="+No);
  pictureExpired=true;
}


void draw() {
  if(pictureExpired) {
    drawEverything();
    pictureExpired=false;
  }
}


void drawEverything() {
  background(0);
  translate(width/2,height/2);
  noFill();

  updateGearParameters();
  
  // world origin
  stroke(255);
  point(0,0);
  point(0,0);
  // eccentricity point
  //stroke(255,255,0);
  //point(E,0);
  
  // gear 1 cam
  stroke(  0,  0,255);
  circle(-E,0,Cr/2);
  // gear 2 cam
  stroke(255,  0,  0);
  circle(E,0,Cr/2);
  
  // rollers
  stroke(  0,255,  0);  
  drawRollers();
  // gear 1 output pins
  stroke(  0,  0,255);
  translate(-E,0);
  drawOutputPins();
  // gear 2 output pins
  stroke(255,  0,  0);
  translate(E*2,0);
  drawOutputPins();
  // recenter
  translate(-E,0);
  
  // gear 2
  translate(Rr/2,0);
  stroke(255,  0,  0);  drawGear();

  // gear 1
  rotate(RADIANS_PER_TOOTH/2);
  translate(-Rr,0);
  stroke(  0,  0,255);  drawGear();
}


void drawGear() {  
  RADIANS_PER_TOOTH=2*PI/(N-1);
  for(int i=0;i<N-1;++i) {
    rotate(RADIANS_PER_TOOTH);
    beginShape();
    drawOneTooth();
    endShape();
  }
}


void drawOutputPins() {
  float outputCir = 2 * Ro * PI;
  
  for(int i=0;i<No;++i) {
    circle(
      cos(i*(PI*2/No))*Ro,
      sin(i*(PI*2/No))*Ro,
      OutputPinRadius*2+Rr);
  }
  drawDottedCircle(Ro);
}

void drawDottedCircle(float Rro) {
  float hits=floor(Rro);
  
  for(float i=0;i<hits;i+=4) {
    float a=i*(PI*2/hits);
    float b=(i+1)*(PI*2/hits);
    line(
      cos(a)*Rro,
      sin(a)*Rro,
      cos(b)*Rro,
      sin(b)*Rro);
  }
}


void drawRollers() {
  for(int i=0;i<N;++i) {
    circle(
      cos(i*(PI*2/N))*(R),
      sin(i*(PI*2/N))*(R),
      Rr*2);
  }
}

void drawOneTooth() {
  // start
  Point2D s = getPoint(0, R, Rr, E, N);
  vertex(s.x,s.y);

  // end
  float et = 2 * PI / (N-1);
  Point2D e = getPoint(et, R, Rr, E, N);

  // the middle bits
  float x = s.x;
  float y = s.y;
  float dist = 0;
  float ct = 0;
  float dt = PI / N;
  float numPoints = 0;

  while ((sqrt(sq(x-e.x) + sq(y-e.y)) > maxDist || ct < et/2) && ct < et) { //close enough to the end to call it, but over half way
  //while (ct < et/80) { //close enough to the end to call it, but over half way
      Point2D t = getPoint(ct+dt, R, Rr, E, N);
      dist = getDist(x, y, t.x, t.y);

      float ddt = dt/2;
      boolean lastTooBig = false;
      boolean lastTooSmall = false;

      while (dist > maxDist || dist < minDist) {
          if (dist > maxDist) {
              if (lastTooSmall) {
                  ddt /= 2;
              }
              lastTooSmall = false;
              lastTooBig = true;

              if (ddt > dt/2) {
                  ddt = dt/2;
              }
              dt -= ddt;
          } else if(dist < minDist) {
              if (lastTooBig) {
                  ddt /= 2;
              }
              lastTooSmall = true;
              lastTooBig = false;
              dt += ddt;
          }
          t = getPoint(ct+dt, R, Rr, E, N);
          dist = getDist(x, y, t.x, t.y);
      }
      x = t.x;
      y = t.y;
      vertex(x,y);
      numPoints += 1;
      ct += dt;
  }
  
  vertex(e.x,e.y);

}
