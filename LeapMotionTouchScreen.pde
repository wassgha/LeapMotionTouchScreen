
/**
 * MirrorOS Controller (Leap Motion Touch Screen)
 * 
 * @author Wassim Gharbi
 */
import de.voidplus.leapmotion.*;


int x=0, y=0, w=0, h=0;
ArrayList<PVector> corners;
PVector[] plane;
LeapMotion leap;

void setup() {
  fullScreen(2);
  ellipseMode(CENTER);
  x = 0;
  y = 0;
  w = width;
  h = height;
  corners = new ArrayList<PVector>();
  leap = new LeapMotion(this);
}

void draw() {
  background(255);
  
  // Draw the touch area (black rectangle)
  fill(0);
  rect(x, y, w, h);
  
  if(!calibrated()) {
    calibrate();
  } else {
    moveMouse();
  }
}

boolean calibrated() {
  return corners.size()>=4;
}

void calibrate() {
  
  // Draw touch indicators for calibration
  noFill();
  stroke(255, 0, 0);
  strokeWeight(10);
  switch (corners.size()){
    case 0:
      ellipse(x, y, 50, 50);
      break;
    case 1:
      ellipse(x + w, y, 50, 50);
      break;
    case 2:
      ellipse(x, y + h, 50, 50);
      break;
    case 3:
      ellipse(x + w, y + h, 50, 50);
      break;
  }
  noStroke();
  
  fill(255);
  textAlign(CENTER);
  text("Touch and hold the red marker and press 'Space'", x + w/2, y + h/2);
  if (leap.getHands() != null && leap.getHands().size()>0)
    text("Right hand : " + leap.getHands().get(0),  x + w/2, y + h/2 + 30);
  if (leap.getHands() != null && leap.getHands().size()>0 &&  leap.getHands().get(0).getIndexFinger() != null)
    text("Index finger : " + leap.getHands().get(0).getIndexFinger(),  x + w/2, y + h/2 + 60);
  // If space is pressed then register corner
  if (keyPressed && key == ' ' && leap.getHands() != null && leap.getHands().size() > 0 &&  leap.getHands().get(0).getIndexFinger() != null) {
    Finger fingerIndex = leap.getHands().get(0).getIndexFinger();
    delay(500);
    corners.add(fingerIndex.getPosition());
  }
  
  // If all corners are registered then create calibration matrix
  if (calibrated()) {
    plane = makePlane();
  }
}

PVector[] makePlane() {
  // Vector horizontal = topright - topleft;
  PVector horizontal = new PVector(corners.get(1).x - corners.get(0).x,
                            corners.get(1).y - corners.get(0).y,
                            corners.get(1).z - corners.get(0).z);
  // Vector vertical = bottomleft - topleft;
  PVector vertical = new PVector(corners.get(2).x - corners.get(0).x,
                            corners.get(2).y - corners.get(0).y,
                            corners.get(2).z - corners.get(0).z);
  
                           
  // A point in the plane
  PVector u = new PVector(corners.get(2).x,
                  corners.get(2).y,
                  corners.get(2).z);
  
  // The normal vector of the plane
  PVector normal = horizontal.cross(vertical);
  
  // return new plane
  return new PVector[]{ u, normal };
}

// Intersection between a plane and a line
// Both plane and line are defined by a point and a vector
// Formulas here : http://www.ambrsoft.com/TrigoCalc/Plan3D/PlaneLineIntersection_.htm
PVector intersection(PVector[] plane, PVector[] line){
  float d = - (plane[0].x*plane[1].x + plane[0].y*plane[1].y + plane[0].z*plane[1].z);
  float xi = line[0].x - ((line[1].x*(plane[1].x*line[0].x + plane[0].y*line[1].y + plane[0].z*line[1].z + d))/(plane[1].x*line[1].x + plane[1].y*line[1].y + plane[1].z*line[1].z));
  float yi = line[0].y - ((line[1].x*(plane[1].x*line[0].x + plane[0].y*line[1].y + plane[0].z*line[1].z + d))/(plane[1].x*line[1].x + plane[1].y*line[1].y + plane[1].z*line[1].z));
  float zi = line[0].z - ((line[1].x*(plane[1].x*line[0].x + plane[0].y*line[1].y + plane[0].z*line[1].z + d))/(plane[1].x*line[1].x + plane[1].y*line[1].y + plane[1].z*line[1].z));
  return new PVector(xi, yi, zi);
}

void moveMouse() {
  if (leap.getHands() != null && leap.getHands().size() > 0 &&  leap.getHands().get(0).getIndexFinger() != null) {
    Finger fingerIndex = leap.getHands().get(0).getIndexFinger();
    
    PVector[] line = new PVector[]{fingerIndex.getPosition(), fingerIndex.getDirection()};
    PVector intersectionPoint = intersection(plane, line);
    PVector relativeTouchPoint = new PVector((intersectionPoint.x - corners.get(0).x)/(corners.get(1).x - corners.get(0).x),
                                             1 - (intersectionPoint.y - corners.get(2).y)/(corners.get(0).y - corners.get(2 ).y));
    fill(255);
    ellipse(x + relativeTouchPoint.x * w, y + relativeTouchPoint.y * h, 10, 10);
  }
}