class Individual {

  private Node tree;
  PShader shader;
  ArrayList<Integer> breadthTracker = new ArrayList<Integer>();
  int highestVisX = 0;

  int nChildNodes = 0;

  int individualID;

  private float fitness;

  Individual() {
    fitness = 0;

    tree = new Node(0);
    tree.randomizeNode(true);
    cleanUp();
    
    generateID();
  }

  Individual(Node _tree, float _fitness) {
    tree = _tree;
    fitness = _fitness;
    cleanUp();
    generateID();
  }
  
  /*
  //under maintnance
  Individual(String[] _expressions, float _fitness){
    for (int i = 0; i < nodes.length; i++) {
      nodes[i] = new Node(_expressions[i]);
    }
    
    fitness = _fitness;
  }*/
  
  void cleanUp(){
     tree.removeUnusedNodes();
     identifyNodes(); 
  }

  void identifyNodes() {
    nChildNodes = 0;
    breadthTracker = new ArrayList<Integer>();
    tree.identify(this, 0);
  }

  void doShader(int _index) {
    String [] shaderLines = getShaderTextLines(tree);

    String shaderPath = sketchPath("shaders\\individuals\\shader" + _index + ".glsl");

    saveStrings(shaderPath, shaderLines);

    shader = loadShader(shaderPath);
  }

  int getBreadth(int _depth) {
    if(_depth < breadthTracker.size()){
       breadthTracker.set(_depth,breadthTracker.get(_depth) + 1);
    } else if (_depth == breadthTracker.size()){
      breadthTracker.add(0);
    } else {
     print("ERROR"); 
    }

    return breadthTracker.get(_depth);
  }

  int getIndex() {
    nChildNodes ++;
    return nChildNodes - 1;
  }

  Individual crossover(Individual _partner) {
    Individual child = getCopy();
    
    Node partnerNodeCopy = _partner.getRandomNode(true);
    
    child.replaceRandomNode(partnerNodeCopy);

    return child;
  }

  void mutate() {

    for (int i = 0; i < nChildNodes; i++) {
      if (random(1) > mutationRate) continue;
      Node toMutate = tree.getNode(i);
      if(toMutate == null) continue;
      toMutate.mutate();
    }
    
    identifyNodes();
    
    if (random(1) < mutationRate) replaceRandomNode(createRandomNode());
    
    generateID();
  }

  Node getRandomNode(boolean _isCopy) {

    int randomNodeIndex = floor(random(nChildNodes));

    Node randomNode = tree.getNode(randomNodeIndex);

    return _isCopy ? randomNode.getCopy() : randomNode;
  }
  
  Node createRandomNode() {
    Node randomNode = new Node(0);
    randomNode.randomizeNode(true);
    
    return randomNode;
    
  }

  void replaceRandomNode(Node _newNode) {
    int randomNodeIndex = floor(random(nChildNodes));

    tree.replaceNode(randomNodeIndex, _newNode);
  }

  void setFitness(float _fitness) {
    fitness = _fitness;
  }

  float getFitness() {
    return fitness;
  }
  
  void removeFitness() {
     if(fitness <= 0) return;
     fitness -= .2;
     if(fitness < 0) fitness = 0;
  }

  void giveFitness() {
    if (fitness >= 1) return;
    fitness += .1;
  }

  Individual getCopy() {
    Node copiedTree = tree.getCopy();

    return new Individual(copiedTree, fitness);
  }

  void render(PGraphics _canvas, int _w, int _h) {
    PImage image = new PImage(_w, _h, RGB);
    
    _canvas.shader(shader);
    _canvas.image(image, 0, 0);
  }

  

  int getNChildNodes() {
    return nChildNodes;
  }
  
  PVector getVisDimensions(){
    return new PVector(breadthTracker.get(breadthTracker.size() - 1) + 1, breadthTracker.size());
  }
  
  Node getTreeCopy() {
    return tree.getCopy();
  }

  void generateID() {
    individualID = floor(random(10000000));
  }

  int getID() {
    return individualID;
  }
  
  PShader getShader(){
  return shader;
  }
}
