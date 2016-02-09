public class IonizationEnergy {
  
  private int first;
  private int second;
  
  IonizationEnergy(int first, int second) {
    this.first = first;
    this.second = second;
  }
  
  public int getEnergy(int which) {
    if (which == 0) {
      return first;
    } else {
      return second;
    }
  }
}
