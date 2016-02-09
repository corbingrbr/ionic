public class Element {
  
  private String abbrev;
  private PVector position;
  private PVector clr;
  private int dim = (int) windowDiagonal / 20;
  private int radii = 7;

  public Element(String str, int row, int col, ColorBox clrbx) {
    abbrev = str;
    clr = clrbx.getColor();
    positionMe(row, col, clrbx.getHeight());
  } 
  
  public void mouseClick() {
    if (isInside()) {
      Atom a = new Atom(abbrev, (int)clr.x, (int)clr.y, (int)clr.z, mouseX, mouseY);
      a.setup();
      dragAtoms.add(a); 
    }  
  }
 
  public void draw() {
    pushMatrix();
      translate(position.x, position.y);
      fill(255);
      rect(0, 0, dim, dim, radii);
      pushMatrix();
        textSize(windowDiagonal/50);
        textAlign(CENTER, CENTER);
        fill(0);
        text(abbrev, dim/2, dim/2);
     popMatrix();    
    popMatrix();  
  }
  
  private void positionMe(int row, int col, int offset) {   
    if (col <= 3) { 
      position = new PVector(col * dim, row * dim+offset);
    } else {
      position = new PVector(width - ((8-col)*dim), row * dim + offset);      
    }
  }
    
  
  private boolean isInside() {
    return mouseX >= position.x && mouseX <= position.x + dim && mouseY >= position.y && mouseY <= position.y + dim;
  }
}
