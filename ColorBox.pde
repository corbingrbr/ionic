public class ColorBox {
  private PVector clr;
  private int wdth;
  private int hght;
  private PVector pos;
  private int radii;
  
  ColorBox(int col, int wdth, int hght, PVector clr) {
    this.clr = clr;
    this.wdth = wdth;
    this.hght = hght;
    this.radii = 7;
    positionMe(col);
  }
  
  public PVector getColor() {
    return clr;
  }
  
  public int getHeight() {
    return hght;
  }
  
  private void positionMe(int col) {   
    if (col <= 3) { 
      pos = new PVector(col * this.wdth, 0);
    } else {
      pos = new PVector(width - ((8-col)*this.wdth), 0);      
    }
  }
  
  public void draw() {
    pushMatrix();
      translate(this.pos.x, this.pos.y);
      fill(this.clr.x, this.clr.y, this.clr.z);
      rect(0, 0, this.wdth, this.hght, radii);
    popMatrix();  
  }
}
