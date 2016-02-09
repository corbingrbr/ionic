public class EDisplay {
 
 private String energy;
 private Arrow arrow;
 private String ext = " kJ/mol";
 private int xpos;
 private int ypos;
  
 EDisplay() {
     arrow = new Arrow();
 }
 
 public void setInfo(int energy, float xpos, float ypos, float x1, float y1, float x2, float y2) {
   this.energy = str(energy);
   this.xpos = (int) xpos;
   this.ypos = (int) ypos;
   arrow.setData((int)x1, (int)y1, (int)x2, (int)y2);
   
 }
 
 public void draw() {
   pushMatrix();
     translate(xpos, ypos);
     textSize(windowDiagonal/60);
     textAlign(CENTER, CENTER);
     fill(0);
     text(energy + ext, 0, 0);
   popMatrix();   
   
   arrow.draw();
 }
  
}
