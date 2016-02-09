import java.util.Map;

// Settings
int width = 1200;
int height = 900;

// Mouse global 
PVector oldMouse = new PVector();
PVector deltaMouse = new PVector();
PVector atomPos;

Atom tempAtom;

ArrayList<Atom> atoms;
ArrayList<Atom> dragAtoms;

Elements elements;

HashMap<String, IonizationEnergy> ioEnergies;

float windowDiagonal; 

void setup() {
  size(width, height);    // Sketch dimensions
  windowDiagonal = sqrt(width*width + height*height); // Ratio for sizing
  
  atoms = new ArrayList<Atom>();                     // Holds all atoms
  dragAtoms = new ArrayList<Atom>();                 // Holds dragged atoms
  elements = new Elements();
  elements.setup();
  ioEnergies = new HashMap<String, IonizationEnergy>();
  setupioEnergies();
 
}

void draw() {

  background(255);
  
  // Check for collisions, etc.  
  update();  
  
  elements.draw();
  
  textAlign(CENTER, TOP);
  textSize(windowDiagonal/50);
  text("press 'c' to clear atoms", width/2, 10);
  
  // Update & draw atoms
  for (int i = 0; i < atoms.size(); i++) {
    atoms.get(i).draw();
  }
}

void mousePressed() { 
  oldMouse.set(mouseX, mouseY);
  
  
  
  for (int i = 0; i < atoms.size(); i++) {
    Atom a = atoms.get(i);
      
    if (a.inside(mouseX, mouseY) && !a.isColliding() && !a.isExchanging()) {
      a.setSpeed(0.0);
      a.setRotationAdjust(0.0);
      a.setCollide(false);
      if( a.getExchangeAtom() != null) {
        a.getExchangeAtom().collisionInterfere();
        a.setCollisionTime(0.0);
        a.getExchangeAtom().setRotationAdjust(0.0);
        a.getExchangeAtom().cancelExchange();
      }
      a.cancelExchange();
      dragAtoms.add(a);
    }
  } 
  
  
  // If no elements being dragged then check to see if click intention is to create new atom
  if (dragAtoms.size() == 0) {
    elements.mouseClick(); 
  }
}

void mouseDragged() { 
  
 int x = mouseX;
 int y = mouseY;
  
 deltaMouse.x = x - oldMouse.x;
 deltaMouse.y = y - oldMouse.y;  
    
  for(int i = 0; i < dragAtoms.size(); i++) {
      dragAtoms.get(i).shiftPosition(x-oldMouse.x, y-oldMouse.y);    // Move atom by cursor delta
      
      if(dragAtoms.get(i).outsideScreen()) {
        dragAtoms.get(i).removeAtom();
        dragAtoms.remove(i);  
      }    
  }
  
  oldMouse.set(x, y);     // Update oldMouse position   
}

void mouseReleased() {
 
  PVector direction = new PVector(deltaMouse.x, deltaMouse.y);
  float speed = direction.mag()/1.5;
  direction.normalize();  
    
  for(int i = 0; i < dragAtoms.size(); i++) {
    dragAtoms.get(i).setSlide(direction, speed);   
  }
    
  dragAtoms.clear();
}

void update() {
  for (int i = 0; i < atoms.size(); i++) {
    atoms.get(i).update();
  }
}

void setupioEnergies() {
  ioEnergies.put("Na", new IonizationEnergy(490, 0));
  ioEnergies.put("K", new IonizationEnergy(420, 0));
  ioEnergies.put("Mg", new IonizationEnergy(730, 1450));
  ioEnergies.put("Ca", new IonizationEnergy(590, 1145));
  
  ioEnergies.put("N", new IonizationEnergy(0, 0));
  ioEnergies.put("O", new IonizationEnergy(141, 844));
  ioEnergies.put("S", new IonizationEnergy(20, 532));
  ioEnergies.put("F", new IonizationEnergy(322, 0));
  ioEnergies.put("Cl", new IonizationEnergy(348, 0));
  ioEnergies.put("Br", new IonizationEnergy(324, 0));
  ioEnergies.put("I", new IonizationEnergy(295, 0));
}

float calcDistanceSqrd(PVector a, PVector b) {
  return pow(a.x - b.x, 2) + pow(a.y - b.y, 2); 
}

float calcDistance(PVector a, PVector b) {
  return sqrt(calcDistanceSqrd(a,b));  
}

void removeAtoms() {
  dragAtoms.clear();
  atoms.clear();
}

void keyPressed() {
  switch(key) {
   case 'c' : removeAtoms();
              break;
   default :   
  }  
}
