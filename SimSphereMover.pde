class SimSphereMover extends SimSphere {
  
  public Mover physics;
  
  public SimSphereMover(PVector cen, float rad) {
    init(vec(0, 0, 0), rad);
    physics = new Mover();
    setTransformAbs(1, 0,0,0, cen);
    physics.location = this.getOrigin();
  }
  
  public void drawMe() {
    physics.update();
    setTransformAbs(1, 0, 0, 0, physics.location);
    super.drawMe();
  }
  
}
