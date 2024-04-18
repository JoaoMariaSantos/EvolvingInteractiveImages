class Slider {

  float x, y, w;
  float value = 0.5;
  float lineWeight = 12;
  boolean enabled = true;

  Slider(float _w) {
    w =_w;
  }

  Slider(float _x, float _y, float _w) {
    x = _x;
    y = _y;
    w = _w - lineWeight;
  }

  void update() {
    if(!enabled) return;
    
    if (mousePressed && detectHover()) {
      float inputValue =  map(mouseX, screenX(x, y), screenX(w, 0), 0, 1);
      value = constrain(inputValue, 0, 1);
    }
  }

  void show() {
    update();

    strokeWeight(12);

    stroke(colors.get("surfacevariant"));
    
    line(x+lineWeight/2, y, x+w, y);

    if (!enabled) {
      stroke(colors.get("primaryopacity"));
    } else if (detectHover()) {
      stroke(colors.get("secondary"));
    } else {
      stroke(colors.get("primary"));
    }
    
    float visualW = map(value, 0, 1, lineWeight/2, w);

    line(x+lineWeight/2, y, x+visualW, y);
  }

  boolean detectHover() {
    if (mouseX < screenX(x - lineWeight, y))return false; //screenX and screenY because of translations
    if (mouseX > screenX(w+x + lineWeight, y))return false;
    if (mouseY < screenY(x, y - lineWeight)) return false;
    if (mouseY > screenY(x, y + lineWeight)) return false;

    return true;
  }

  void setValue(float _value) {
    value = _value;
  }
  
  void setEnabled(boolean _state){
    enabled = _state; 
  }
}
