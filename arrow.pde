public class Arrow {
 
 private int x1, y1, x2, y2; 
  
 Arrow() {}

 public void setData(int x1, int y1, int x2, int y2) {
   this.x1 = x1;
   this.y1 = y1;
   this.x2 = x2;
   this.y2 = y2;
 } 
  
 public void draw() {
    strokeWeight(3);
    line(x1, y1, x2, y2);
    pushMatrix();
    translate(x2, y2);
    float a = atan2(x1-x2, y2-y1);
    rotate(a);
    line(0, 0, -10, -10);
    line(0, 0, 10, -10);
    popMatrix();
    strokeWeight(1);
  } 
}
