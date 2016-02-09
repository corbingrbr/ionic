public class Elements {
  private ArrayList<Element> elems;
  private ArrayList<ColorBox> clrBoxes;
  private int clrBxHght = (int)windowDiagonal / 60;
  private int clrBxWdth = (int)windowDiagonal / 20;
  
  public Elements() {}
  
  public void setup() {
    
    clrBoxes = new ArrayList<ColorBox>();
    clrBoxes.add(new ColorBox(0, clrBxWdth, clrBxHght, new PVector(255,0,0)));
    clrBoxes.add(new ColorBox(1, clrBxWdth, clrBxHght, new PVector(0, 255, 0)));
    clrBoxes.add(new ColorBox(5, clrBxWdth, clrBxHght, new PVector(0, 0, 255)));
    clrBoxes.add(new ColorBox(6, clrBxWdth, clrBxHght, new PVector(255, 0, 255)));
    clrBoxes.add(new ColorBox(7, clrBxWdth, clrBxHght, new PVector(0, 255, 255)));
   
    
    
    elems = new ArrayList<Element>();
    elems.add(new Element("Na", 0, 0, clrBoxes.get(0))); 
    elems.add(new Element("K",  1, 0, clrBoxes.get(0))); 
    
    elems.add(new Element("Mg", 0, 1, clrBoxes.get(1))); 
    elems.add(new Element("Ca", 1, 1, clrBoxes.get(1))); 
    
    elems.add(new Element("N", 0, 5, clrBoxes.get(2))); 
    
    elems.add(new Element("O", 0, 6, clrBoxes.get(3))); 
    elems.add(new Element("S", 1, 6, clrBoxes.get(3))); 
    
    elems.add(new Element("F", 0, 7, clrBoxes.get(4))); 
    elems.add(new Element("Cl", 1, 7, clrBoxes.get(4))); 
    elems.add(new Element("Br", 2, 7, clrBoxes.get(4))); 
    elems.add(new Element("I",  3, 7, clrBoxes.get(4)));
  
  
  }
  
  public void mouseClick(){
    for (int i = 0; i < elems.size(); i++) {
        elems.get(i).mouseClick();
    }
  }
  
  // Draw all element boxes
  public void draw(){
    for(int i = 0; i < clrBoxes.size(); i++) {
       clrBoxes.get(i).draw();
    } 
    for(int i = 0; i < elems.size(); i++) {
        elems.get(i).draw();
    }
  }
}

