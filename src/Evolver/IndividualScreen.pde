class IndividualScreen {
   
  float x, y, w, h;
  
  TreeVis treeVis;
  Individual individual;
  
  LeftTab leftTab;
  
  IndividualScreen(LeftTab _leftTab){
    leftTab = _leftTab;
    
    x = columns[2].x;
    y = border;
    w = (width - border) - x;
    h = height - (border * 2);
  }
  
  void show(){
    if(leftTab.getBack()){
      individual = null;
      treeVis = null;
      screen = 2;
      return;
    }
    
    Boolean[] layout = leftTab.getLayout();
    
    if(layout[0]) showImage(!(layout[0] == layout[1]));
    if(layout[1]) showTree(!(layout[0] == layout[1]));
  }
  
  void showImage(boolean _full){
    setInputImage();
    float externalValue = getExternalValue();
    float[] audioSpectrum = getAudioSpectrum();
    
    if(_full){
      image(individual.getPhenotype(w, h, externalValue, audioSpectrum), x, y, w, h);
    } else {
      float imageW = columns[5].y - x;
      image(individual.getPhenotype(imageW, h, externalValue, audioSpectrum), x, y, imageW, h);
    }
  }
  
  void showTree(boolean _full){
    pushMatrix();
    
    if(_full){
      treeVis.setDimensions(columns[columns.length-1].y - columns[2].x, height - border*2);
      translate(x,y);
    } else {
      treeVis.setDimensions(columns[columns.length-1].y - columns[6].x, height - border*2);
      translate(columns[6].x,y);
    }
    
    treeVis.showTree();
    
    popMatrix();
  }
  
  void setIndividual(Individual _individual){
    individual = _individual;
    treeVis = new TreeVis(individual);
  }
}