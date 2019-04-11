public class Button {
  private boolean click = false;
  private float rectX, rectY;     
  private float rectSize;   
  private color rectColor;
  private color rectHighlight;
  private boolean rectOver = false;
  public Button(float rectX, float rectY, float rectSize, color rectColor, color rectHighlight ) {
    this.rectX = rectX;
    this.rectY = rectY;
    this.rectSize = rectSize;
    this.rectColor = rectColor;
    this.rectHighlight = rectHighlight;
  }
  public void drawButton() {
    update();
    fill(rectColor);
    stroke(255);
    rect(rectX, rectY, rectSize, rectSize*9.0/16.0);
  }
  private void update() {
    if ( overRect(rectX, rectY, rectSize) ) {
      rectOver = true;
    } else {
      rectOver = false;
    }
  }
  public boolean buttonPressed() {
    if (rectOver)
      click=!click;
    return click;
  }
  private boolean overRect(float x, float y, float rectSize) {
    float dim2 = rectSize * 9.0/16.0;
    if (mouseX >= x && mouseX <= x+rectSize && 
      mouseY >= y && mouseY <= y+dim2) {
      return true;
    } else {
      return false;
    }
  }
}