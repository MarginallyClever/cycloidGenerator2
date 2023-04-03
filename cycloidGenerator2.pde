//------------------------------------------
// cycloid profile generator
// dan@marginallyclever.com 2020-01-08
// CC-BY-NC-SA
// Based on https://github.com/mawildoer/cycloidal_generator
// and special thanks to http://paulbourke.net/dataformats/dxf/min3d.html
//------------------------------------------


Point2D getPoint(float t, float R, float Rr, float E, float N) {
  //psi = -atan(sin((1 - N) * theta) / ((R / (E * N)) - cos((1 - N) * theta)))
  //x = R * cos(theta) - Rr * cos(theta - psi) - E * cos(N * theta)
  //y =  - R * sin(theta) + Rr * sin(theta - psi) + E * cos(N * theta)
  float psi = atan2(sin((1-N)*t), ((R/(E*N))-cos((1-N)*t)));

  float x = (R*cos(t))-(Rr*cos(t+psi))-(E*cos(N*t));
  float y = (-R*sin(t))+(Rr*sin(t+psi))+(E*sin(N*t));
  //x = (10*cos(t))-(1.5*cos(t+atan(sin(-9*t)/((4/3)-cos(-9*t)))))-(0.75*cos(10*t))
  //y = (-10*sin(t))+(1.5*sin(t+atan(sin(-9*t)/((4/3)-cos(-9*t)))))+(0.75*sin(10*t))
  return new Point2D(x, y);
}


float getDist(float xa, float ya, float xb, float yb) {
  return sqrt(sq(xa-xb) + sq(ya-yb));
}


//####   CHANGE THE VALUES BELOW FOR DIMENSIONS #####
float R = (88.9-6.0)/2; //rotor radius (mm)
float N = 43; //number of rollers

float EccentricCamRadius = 20;  // Eccentric Cam radius (mm)

float OutputPinCount = 8;  // number of output pins
float OutputPinRadius = 3; //mm
float OutputPinOrbitRadius = (R+EccentricCamRadius)/2;  //mm

int circleQuality=36;  // >3.  whole number.  bigger number, more refinement on circles.
  
//###################################################


//other constants based on the original inputs
float housing_cir = 2 * R * PI;
float Rr = housing_cir / (4 * N); //roller radius
float E = 0.5 * Rr; //eccentricity
float maxDist = 0.25 * Rr; //maximum allowed distance between points
float minDist = 0.5 * maxDist; //the minimum allowed distance between points
float RADIANS_PER_TOOTH=2*PI/(N-1);

boolean pictureExpired=true;

boolean first=true;
float oldX=0,oldY=0;
float firstX=0,firstY=0;

PrintWriter fRed,fGreen,fBlue;

void setup() {
  size(800, 800);  // new window
  scale(60);
  //strokeWeight(0.05);

  println("Ratio will be " + (1/N));
  println("roller pin radius="+Rr);
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
  case '1':     N++;    break;
  case '2':     N--;    break;
  case '3':     OutputPinCount++;   break;
  case '4':     OutputPinCount--;   break;
  default:     break;
  }
  println("N="+N+" OutputPinCount="+OutputPinCount);
  pictureExpired=true;
}


void draw() {
  if (pictureExpired) {
    drawEverything();
    pictureExpired=false;
  }
}


PrintWriter deleteAndRecreateFile(String filename) {
  File f=new File(dataPath(filename));
  if(f.exists()) f.delete();
  PrintWriter pw = createWriter(dataPath(filename));
  // DXF header
  pw.print(
    "999\n"+    "DXF created from cycloidGenerator2\n"+
    "0\n"+    "SECTION\n"+
    "2\n"+    "HEADER\n"+
    "9\n"+    "$ACADVER\n"+
    "1\n"+    "AC1006\n"+
    "9\n"+    "$INSBASE\n"+
    "10\n"+    "0.0\n"+
    "20\n"+    "0.0\n"+
    "30\n"+    "0.0\n"+
    "9\n"+    "$INSUNITS\n"+
    "70\n"+   "4\n"+
    "9\n"+    "$EXTMIN\n"+
    "10\n"+    (-width/2)+"\n"+
    "20\n"+    (-height/2)+"\n"+
    "9\n"+    "$EXTMAX\n"+
    "10\n"+    width/2+"\n"+
    "20\n"+    (height/2)+"\n"+
    "0\n"+    "ENDSEC\n"+
    // tables section
    "0\n"+    "SECTION\n"+
    "2\n"+    "TABLES\n"+
    "0\n"+    "TABLE\n" +
    "2\n"+    "LTYPE\n" +
    "70\n"+    "1\n" +
    "0\n"+    "LTYPE\n" +
    "2\n" +    "CONTINUOUS\n" +
    "70\n" +    "64\n" +
    "3\n" +    "Solid line\n" +
    "72\n" +    "65\n" +
    "73\n" +    "0\n" +
    "40\n" +    "0.000000\n" +
    "0\n" +    "ENDTAB\n" +
    "0\n" +    "TABLE\n" +
    "2\n" +    "LAYER\n" +
    "70\n" +    "6\n" +
    "0\n" +    "LAYER\n" +
    "2\n" +    "1\n" +
    "70\n" +    "64\n" +
    "62\n" +    "0\n" +
    "6\n" +    "CONTINUOUS\n" +
    "0\n" +    "LAYER\n" +
    "2\n" +    "2\n" +
    "70\n" +    "64\n" +
    "62\n" +    "0\n" +
    "6\n" +    "CONTINUOUS\n" +
    "0\n" +    "ENDTAB\n" +
    "0\n" +    "TABLE\n" +
    "2\n" +    "STYLE\n" +
    "70\n" +    "0\n" +
    "0\n" +    "ENDTAB\n" +
    "0\n" +    "ENDSEC\n" +
    // blocks section
    "0\n" +    "SECTION\n" +
    "2\n" +    "BLOCKS\n" +
    "0\n" +    "ENDSEC\n" +
    // entities section
    "0\n" +    "SECTION\n" +
    "2\n" +    "ENTITIES\n"
  );

  // return to add unique content
  return pw;
}


void lineSegment(float x0,float y0,float x1,float y1,PrintWriter pw) {
  line(x0,y0,x1,y1);
  pw.print(
    "0\nLINE\n"+
    "8\n2\n"+
    "62\n0\n"+
    "10\n"+nf(x0,0,3)+"\n"+
    "20\n"+nf(y0,0,3)+"\n"+
    "30\n0\n"+
    "11\n"+nf(x1,0,3)+"\n"+
    "21\n"+nf(y1,0,3)+"\n"+
    "31\n0\n"
  );
}


void finishFile(PrintWriter f) {
  // end DXF file
  f.print(
    "0\nENDSEC\n" +
    "0\nEOF\n"
  );

  // finally
  f.flush();
  f.close();
  f=null;
}


void drawEverything() {
  background(0);
  translate(width/2, height/2);
  scale(8);
  noFill();

  updateGearParameters();

  fRed=deleteAndRecreateFile("red.dxf");
  fGreen=deleteAndRecreateFile("green.dxf");
  fBlue=deleteAndRecreateFile("blue.dxf");

  // world origin (all colors)
  stroke(255);
  lineSegment(-10,  0,10, 0,fRed);
  lineSegment(  0,-10, 0,10,fRed);
  lineSegment(-10,  0,10, 0,fGreen);
  lineSegment(  0,-10, 0,10,fGreen);
  lineSegment(-10,  0,10, 0,fBlue);
  lineSegment(  0,-10, 0,10,fBlue);
  
  // eccentricity point
  //stroke(255,255,0);
  //point(E,0);

  // rollers (green)
  stroke(  0, 255, 0);  
  drawRollers();
  drawOutputPins();

  // gear 1 (blue)
  stroke(  0, 0, 255);
  drawGear(-E,RADIANS_PER_TOOTH/2,fBlue);

  // gear 2 (red)
  stroke(255, 0, 0);
  drawGear(E,0,fRed);
  
  finishFile(fRed);
  finishFile(fGreen);
  finishFile(fBlue);
}


void drawDottedCircle(float Rro) {
  float hits=floor(Rro);

  for (float i=0; i<hits; i+=4) {
    float a=i*(PI*2/hits);
    float b=(i+1)*(PI*2/hits);
    line(
      cos(a)*Rro, 
      sin(a)*Rro, 
      cos(b)*Rro, 
      sin(b)*Rro);
  }
}


void drawCircle(float cx,float cy,float r,PrintWriter pw) {
  float stepSize = PI*2/(circleQuality);

  pw.print("0\nLWPOLYLINE\n"+
    "5\n101\n"+
    "100\nAcDbEntity\n"+
    "8\n2\n"+
    "62\n7\n"+
    "100\nAcDbPolyline\n"+
    "90\n38\n"+
    "70\n1\n"
  );
  beginShape();
  for (float j=0; j<PI*2; j+=stepSize) {
    float x = cx + cos(j)*r;
    float y = cy + sin(j)*r;
    pw.print(
      "10\n"+x+"\n"+
      "20\n"+y+"\n"+
      "30\n0\n"
    );
    vertex(x,y);
  }
  
  endShape(CLOSE);
}

void drawGear(float translateXmm,float rotateRad,PrintWriter pw) {
  drawCircle(translateXmm,0,EccentricCamRadius,pw);
  drawRotorOutputGuides(translateXmm,pw);
  
  pw.print("0\nLWPOLYLINE\n"+
    "5\n101\n"+
    "100\nAcDbEntity\n"+
    "8\n2\n"+
    "62\n7\n"+
    "100\nAcDbPolyline\n"+
    "90\n38\n"+
    "70\n1\n"
  );
  beginShape();
  
  first=true;
  RADIANS_PER_TOOTH=2*PI/(N-1);
  for (int i=0; i<N-1; ++i) {
    drawOneTooth(translateXmm,rotateRad+RADIANS_PER_TOOTH*i,pw);
  }
  //lineSegment(oldX,oldY,firstX,firstY,pw);
  endShape(CLOSE);
}


void drawRotorOutputGuides(float translateXmm,PrintWriter pw) {
  for (float i=0; i<OutputPinCount; ++i) {
    float cx=cos(i*(PI*2/OutputPinCount))*OutputPinOrbitRadius+translateXmm;
    float cy=sin(i*(PI*2/OutputPinCount))*OutputPinOrbitRadius;
    drawCircle(cx,cy,OutputPinRadius+Rr/2,pw);
  }
  //drawDottedCircle(OutputPinOrbitRadius);
}


void drawOutputPins() {
  for (float i=0; i<PI*2; i+=(PI*2/OutputPinCount)) {
    float cx=cos(i)*OutputPinOrbitRadius;
    float cy=sin(i)*OutputPinOrbitRadius;
    drawCircle(cx,cy,OutputPinRadius,fGreen);
  }
  //drawDottedCircle(OutputPinOrbitRadius);
}


void drawRollers() {
  for (float i=0; i<PI*2; i+=(PI*2/N)) {
    float cx=cos(i)*R;
    float cy=sin(i)*R;
    drawCircle(cx,cy,Rr,fGreen);
  }
}



void drawOneTooth(float translateXmm,float rotateRad,PrintWriter pw) {
  float rotc = cos(rotateRad);
  float rots = sin(rotateRad);
  
  // start
  Point2D s = getPoint(0, R, Rr, E, N);

  // end
  float et = 2 * PI / (N-1);
  Point2D e = getPoint(et, R, Rr, E, N);

  // the middle bits
  float x = s.x;
  float y = s.y;
  float dist = 0;
  float ct = 0;
  float dt = PI / N;

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
      } else if (dist < minDist) {
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
    
    if(first) {
      firstX=oldX= rotc*x + rots*y + translateXmm;;
      firstY=oldY=-rots*x + rotc*y;
    }
    first=false;

    x = t.x;
    y = t.y;
    
    float x1= rotc*x + rots*y + translateXmm;
    float y1=-rots*x + rotc*y;
    
    pw.print(
      "10\n"+x1+"\n"+
      "20\n"+y1+"\n"+
      "30\n0\n"
    );
    vertex(x1,y1);
    //lineSegment(oldX,oldY,x1,y1,pw);
    oldX=x1;
    oldY=y1;
    
    ct += dt;
  }
  
/*
  float x0= rotc*x + rots*y + translateXmm;
  float y0=-rots*x + rotc*y;
  x=e.x;
  y=e.y;
  float x1= rotc*x + rots*y + translateXmm;
  float y1=-rots*x + rotc*y;
  lineSegment(x0,y0,x1,y1,pw);*/
}
