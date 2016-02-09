public class Atom {
  private String abbreviation;
  private String netCharge;
  private int deltaCharge;
  private PVector clr;
  private PVector pos;
  private int numValenceElectrons = 0;
  private Electron[] valenceElectrons;
  private float size = windowDiagonal / 25 + 10;
  private float electronRing = size*2;
  private float textRing = size * 1.07; 
  private int textSize = (int)size/3;
  private float speed = 0;
  private PVector direction;
  private Electron[] electrons = new Electron[8];  
  private final String[][] valenceRef = {{"Na", "K"}, {"Mg", "Ca"}, {},{},{"N"},{"O","S"},{"F","Cl","Br","I"}};
  private int abbrevLen;
  private float collisionDuration = 1.20;
  private float eExchangeDur = 3.0;
  private boolean eExchange = false;
  private float eDisplayTime = 0.0;
  private float eExchangeTime = 0.0;
  private float eTransDelay = 1.0;
  private float eTransDur = eExchangeDur - eTransDelay;
  private float eTransTime = 0.0;
  private boolean eTransferring = false;
  private float otherAtomDistance;
  private PVector eTransVec;


  
  private float fps = frameRate;
  private float numBounces = 2.5;
  private float colAnimOffset = (ceil(numBounces) - numBounces) * 2 * PI;
  
  private boolean collided; 
  private float intervalTime;
  private float collisionAmplitude;
  private float collisionTime;
  private PVector collisionDirection;
  private float rotation;
  private float rotationAdjust;
  private Atom toExchangeWith;
  private EDisplay eExchangeInfo;
  
  // Atom Constructor
  Atom(String abbrev, int r, int g, int b, float xCoord, float yCoord) {
      abbreviation = abbrev;
      abbrevLen = abbrev.length();
      pos = new PVector(xCoord, yCoord);
      clr = new PVector(r,g,b);
      direction = new PVector(0,0,0);   
      collided = false;
      netCharge = "";
      deltaCharge = 0;
      eExchangeInfo = new EDisplay();
  }
      
  // Assign number of valence electrons and add to atoms ArrayList        
  public void setup() {    
    calcValenceElectrons();
    atoms.add(this);
    
    if ( numValenceElectrons <= 2 ) {
      valenceElectrons = new Electron[2];
    } else {
      valenceElectrons = new Electron[8];
    }
    
    for (int i = 0; i < numValenceElectrons; i++) {
      valenceElectrons[i] = new Electron(clr);
    }  
  }      
  
  // Reference valenceRef to determine number of valence Electrons 
  private void calcValenceElectrons() {       
    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < valenceRef[i].length; j++) {
        if (valenceRef[i][j].equals(this.abbreviation)) {
          numValenceElectrons = i + 1;          
        }  
      }
    }
    
    if (numValenceElectrons == 0) {
      System.out.println("Unable to determine # of valence electrons for " + abbreviation);
    }   
  }
  
  public void update() {
    if (collided) {
     
      // Do bounce stuff   
      shiftPosition(this.collisionDirection.x*this.collisionAmplitude*sin(collisionTime + colAnimOffset),
                    this.collisionDirection.y*this.collisionAmplitude*sin(collisionTime + colAnimOffset));
        
      collisionTime -= (numBounces * 2 * PI)/(collisionDuration * fps);
           
      if (intervalTime - collisionTime >= 2 * PI) {
        this.collisionAmplitude /= 1.6;
        intervalTime -= 2*PI;
        
      }  
           
      // Do rotation stuff
      rotation += rotationAdjust;
      
      if (collisionTime < 0) {
        collided = false;
        rotationAdjust = 0.0;
        this.collisionAmplitude = 0.0;
        this.collisionDirection = null;
        
        
        
        if (toExchangeWith != null) {
          //otherAtomDistance = calcDistance(this.pos, toExchangeWith.getPosition())- size*2;;
          PVector myElectronVec = scaleVec(getVecForElectron(), size);
          PVector otherElectronVec = scaleVec(toExchangeWith.getVecForElectron(), size);
          
          eTransVec = subVecs(addVecs(toExchangeWith.getPosition(), otherElectronVec), addVecs(this.pos, myElectronVec));
          setToDisplayEnergy();
          setToDisplayEnergy();
        }
      }
      
    } else if (eExchange) {
      eDisplayTime -= 1.0;
      
         
      if (!eTransferring && numValenceElectrons < 4 && eExchangeDur - eDisplayTime/fps >= eTransDelay) {
        eTransferring = true;
        eTransTime = eTransDur*fps;
      }
            
      if (eDisplayTime < 0) {
        eExchange = false; 
        eTransferring = false;
        
        if (this.toExchangeWith != null) {
          exchange(this.toExchangeWith);
          this.toExchangeWith.cancelExchange();
          this.toExchangeWith = null;
        }
        
      }
      
      if (eTransferring) {
        eTransTime -= 1.0;
      }
    } else if (speed > 0) {
      // adjust position
      shiftPosition(this.direction.x * this.speed, this.direction.y * this.speed);
      // reduce speed
      speed -= .1;   
      // check collision
      checkCollisions();
     
      if (outsideScreen()) {
        removeAtom();
      }   
    }
  }
  
  public void draw(){
    pushMatrix();
      translate(pos.x, pos.y);
      
      //noStroke();
      noFill();
      arc(0, 0, electronRing, electronRing, 0, TWO_PI);
       
      fill(clr.x, clr.y, clr.z);
      ellipse(0, 0, size, size); 
     
      pushMatrix();
        textSize(windowDiagonal/60);
        textAlign(CENTER, CENTER);
        fill(0);
        text(abbreviation, abbrevLen*(-windowDiagonal/300), 0);
        textSize(windowDiagonal/100);
        textAlign(LEFT, CENTER);
        text(netCharge, abbrevLen*(windowDiagonal/375), (-windowDiagonal/300)); 
       
     popMatrix();
     
     if (this.eExchange) { eExchangeInfo.draw(); }
    
  // We must keep track of our position along the curve
  //float arclength = electronRing * (HALF_PI + PI/16);
  float arclength = electronRing * HALF_PI;
  
  int numElectrons = numValenceElectrons;
  
  // Don't draw last electron on ring if it is moving to another atom
  if ( numValenceElectrons < 4 && eTransferring ) {
    numElectrons--;
  } 
  
  for (int i = 0; i < numElectrons; i++) {
    
    PVector c = this.valenceElectrons[i].getColor();
    
    float theta = arclength / electronRing;     
     
     if (i == 3) {
       arclength -= PI/16 * electronRing;
     }
     
     arclength -= HALF_PI * electronRing;
     
    pushMatrix();
    // Polar to cartesian coordinate conversion
    translate(textRing*cos(theta + rotation), textRing*sin(theta + rotation));
    
    rotate(theta + HALF_PI + rotation);         // Rotate the electron
    textSize(textSize);
    textAlign(CENTER, CENTER);
    fill(c.x, c.y, c.z);
    text("x", 0, 0);
      
    popMatrix();
    
  }    

  if (eTransferring) {
    
      float u = 1 - (eTransTime / (eTransDur*fps)); 
      
      PVector pv = getVecForElectron();
      float theta = getAngleForElectron();
      if ( toExchangeWith == null) {
      System.out.println("No Exchange With!");
      }
     
      
      pushMatrix();
      
    
      translate(pv.x*size + u*eTransVec.x, pv.y*size +  u*eTransVec.y);
      rotate(theta+HALF_PI);
      fill(clr.x, clr.y, clr.z);
      text("x", 0, 0);
      popMatrix();
  }
    
    popMatrix();
  }
  
  public void setPosition(float x, float y) {
    pos.x = x;
    pos.y = y;
  }
  
  public PVector getPosition() {
    return pos.get();
  }
  
  public void shiftPosition(float x, float y) {
    pos.x += x;
    pos.y += y;
  }
  
  public boolean outsideScreen() { 
    return pos.y - size > height || pos.y + size < 0 || pos.x - size > width || pos.x + size < 0;
  }
  
  public float getSize() {
    return size;
  }
  
  public void printValence() {
    System.out.println(numValenceElectrons);
  }
  
  public boolean inside(float x, float y) {
    return pow(x - pos.x, 2) + pow(y - pos.y, 2)  <= pow(electronRing/2, 2); 
  }
  
  public String abbrev() {
    return this.abbreviation;
  }
  
  public void setDirection(float x, float y) {
    this.direction.x = x;
    this.direction.y = y;
  }
  
  public void setSpeed(float speed) {
     this.speed = speed;
  }
  
  public void setSlide(PVector direction, float speed) {
    this.direction = direction;
    this.speed = speed;
  }
  
  public void checkCollisions() {
    for(int i = 0; i < atoms.size(); i++) {
      if(!this.equals(atoms.get(i))) {
        
        Atom a = atoms.get(i);
        if(checkCollision(a.getPosition())){
          collisionRecorrect(a.getPosition());
          
          if (this.speed > 7.5) {
            
            if(bondable(a) && !a.isColliding()) {
              a.setupExchange(this);
              this.toExchangeWith = a;
              setRotationAnimation(a.getPosition().get());
              a.setRotationAnimation(this.pos.get());
            }
          }       
          
          a.setCollisionAnimation(this.speed,  new PVector(-this.direction.x, -this.direction.y));
          setCollisionAnimation(this.speed, this.direction);
          
        }
      }
    }
  }
  
  public void setupExchange(Atom a) {
    this.toExchangeWith = a;
  }  
   
  public void cancelExchange() {
    this.toExchangeWith = null;
  }    
  
  public Atom getExchangeAtom() {
    return this.toExchangeWith;
  }
  
  public void setRotationAnimation(PVector atomPos) {
    atomPos.sub(this.pos);
    atomPos.normalize();
  
    PVector electronRay = getVecForElectron(); 
    PVector cross = atomPos.cross(electronRay);
    PVector normal = new PVector(0,0, -1);
    float a = PVector.angleBetween(atomPos, electronRay);
          
    if (normal.dot(cross) < 0) { a = -a; }
    
    this.rotationAdjust = a/(collisionDuration * fps); 
  }
  
  public void setCollisionAnimation(float speed, PVector direction) { 
     this.collided = true;
     this.speed = 0.0;         
     this.collisionTime = numBounces * 2 * PI;
     this.collisionAmplitude = min(speed, 9.0)*(windowDiagonal/1500.0);
     this.collisionDirection = direction;
     this.intervalTime = collisionTime;
    
     PVector p = direction;
     p.normalize();
     
     // Info for arrows when electron exchange
     float p1 = size * 1.1;
     float p2 = size * 2.1;
     float txt = size * 2.4 + p.y * 2 + abs(p.x) * 50;  
    
     if ((abbreviation == "O" || abbreviation == "S" ) && numValenceElectrons == 7) {
        eExchangeInfo.setInfo(ioEnergies.get(abbreviation).getEnergy(1),
                             txt * -p.x, txt * -p.y, p2 * -p.x, p2 * -p.y, p1 * -p.x, p1 * -p.y);
     } else if (numValenceElectrons > 4) {
        eExchangeInfo.setInfo(ioEnergies.get(abbreviation).getEnergy(0), 
                             txt * -p.x, txt * -p.y, p1 * -p.x, p1 * -p.y, p2 * -p.x, p2 * -p.y);
     } else {
       eExchangeInfo.setInfo(ioEnergies.get(abbreviation).getEnergy(2-numValenceElectrons),
                             txt * -p.x, txt * -p.y, p2 * -p.x, p2 * -p.y, p1 * -p.x, p1 * -p.y);
     }         
  }

  public float getAngleForElectron() {
    
    float arclength = electronRing * HALF_PI;
    
    int electronNdx;
    
    if (this.numValenceElectrons <= 2) {
      // Electron to lose location 
      electronNdx = this.numValenceElectrons-1;
    } else {
    // New electron location
      electronNdx = this.numValenceElectrons;
    }
    
    for (int i = 0; i < electronNdx; i++) {
      if (i==3) {
        arclength -= PI/16 * electronRing;
      }
        arclength -= HALF_PI * electronRing;
    }
   
    return arclength / electronRing + this.rotation;  
  }
  
  public PVector getVecForElectron() {
    
    float arclength = electronRing * HALF_PI;
    
    int electronNdx;
    
    if (this.numValenceElectrons <= 2) {
      // Electron to lose location 
      electronNdx = this.numValenceElectrons-1;
    } else {
    // New electron location
      electronNdx = this.numValenceElectrons;
    }
    
    for (int i = 0; i < electronNdx; i++) {
      if (i==3) {
        arclength -= PI/16 * electronRing;
      }
        arclength -= HALF_PI * electronRing;
    }
   
    float theta = arclength / electronRing;  
    
    return new PVector(cos(theta + this.rotation), sin(theta + this.rotation));    
  }
  
  // Check if collision between this atom and the parameter
  public boolean checkCollision(PVector otherPos) {
    return calcDistance(this.pos, otherPos) <= this.electronRing;
  }
  
   // rotation of atom during collision cycle
   public void setRotationAdjust(float adjust) {
     this.rotationAdjust = adjust;
   }
    
   public void setCollide(boolean b) { 
      this.collided = b;
   }
   
  // Recorrection of atom to surface of other atom as soon as collision detected  
  private void collisionRecorrect(PVector collidedPos) {
    PVector connection = new PVector();
    connection.x = this.pos.x;
    connection.y = this.pos.y;
    connection.sub(collidedPos);
    connection.normalize();
    connection.mult(electronRing);    
    this.setPosition(collidedPos.x + connection.x, collidedPos.y + connection.y);   
  }
  
  public boolean bondable(Atom a) {
    int numElectrons = a.getValenceCount();
    
    return numElectrons < 8 && this.numValenceElectrons < 8 
           && numElectrons > 0 && this.numValenceElectrons > 0 
           && numElectrons + this.numValenceElectrons >= 6
           && numElectrons + this.numValenceElectrons < 10;
  }
  
  public void exchange(Atom a) {
    
    if(this.numValenceElectrons <= 2) {
      removeElectron();
      a.addElectron(new Electron(this.clr));
    } else {
      a.removeElectron();
      this.addElectron(new Electron(a.getColor()));  
    }
  }
  
  public void setToDisplayEnergy() {
    // set eExchange
    eExchange = true;
    eDisplayTime = eExchangeDur * fps;
  }
  
  public void setCollisionTime(float time) {
    this.collisionTime = time;
  }
  
  public void collisionInterfere() {
    this.speed = this.collisionAmplitude;
    this.direction = this.collisionDirection;
    this.collisionTime = 0;
    this.collided = false;
  }
  
  public int getValenceCount() {
    return this.numValenceElectrons;
  }
  
  public PVector getColor() {
    return this.clr;
  }
  
  public void removeElectron(){
    this.valenceElectrons[--this.numValenceElectrons] = null;
    this.deltaCharge++;
    if (this.deltaCharge > 1) {
      this.netCharge = this.deltaCharge + "+";
    } else {
      this.netCharge = "+";
    } 
  }   
 
  public void addElectron(Electron e) {
    this.valenceElectrons[this.numValenceElectrons++] = e;
    this.deltaCharge++;
    
    if (this.deltaCharge > 1) {
      this.netCharge = this.deltaCharge + "-";
    } else {
      this.netCharge = "-";
    } 
  }
   
  public void removeAtom(){
    for(int i = 0; i < atoms.size(); i++) {
      if (atoms.get(i).equals(this)) {
        atoms.remove(i);
        break;
      }
    }
  } 
  
  public boolean isColliding() {
    return this.collided;
  }
  
  public boolean isExchanging() {
    return this.eExchange;
  }
  
  public PVector addVecs(PVector pv1, PVector pv2) {
    return new PVector(pv1.x + pv2.x, pv1.y + pv2.y);
  }
  
  public PVector subVecs(PVector pv1, PVector pv2) {
    return new PVector(pv1.x - pv2.x, pv1.y - pv2.y);
  }
  
  public PVector scaleVec(PVector p, float scale) {
    return new PVector(p.x*scale, p.y*scale);
  }

}
  
