class Node {

  float mathType; //0-1

  int nodeIndex;
  int depth;
  int breadth;

  int visX; //location of node in tree visualization horizontally. vertical is depth

  Node[] childrenNodes;

  //Node aNode = null;
  //Node bNode = null;

  String[] terminalSet = {"x", "y"};

  float[] scalar = new float[3]; //scalar terminal

  Node() {
    randomizeNode(false);
  }

  Node(int _depth) {
    depth = _depth;
  }

  Node(boolean _toRandomize, boolean _tocreateChildren) {
    if (_toRandomize) randomizeNode(_tocreateChildren);
  }

  Node(float _mathType, Node[] _childrenNodes, float [] _scalar, int _nodeIndex, int _depth, int _breadth) {
    mathType = _mathType;
    childrenNodes = _childrenNodes;
    scalar = _scalar;
    nodeIndex = _nodeIndex;
    depth = _depth;
    breadth = _breadth;
  }

  /*
  //under maintnance
   Node(String _expression) {
   setupNodeFromExpression(_expression);
   }*/

  void randomizeNode(boolean _tocreateChildren) {
    mathType = random(1);

    //decide if node will have children or not
    if (random(1) > .45 && depth < maxDepth - 1 && _tocreateChildren) {
      mathType = random(1);
    } else {
      mathType = -1;
      childrenNodes = new Node[0];
      scalar = getRandomScalar();
      return;
    }

    int requiredArguments =  getOperation().getNumberArgumentsNeeded();

    childrenNodes = new Node[requiredArguments];

    for (int i = 0; i < requiredArguments; i ++) {
      childrenNodes[i] = new Node(depth + 1);
      childrenNodes[i].randomizeNode(true);
    }
  }

  int identify(Individual _indiv, int _depth) {
    depth = _depth;
    visX = 0;

    nodeIndex = _indiv.getIndex();

    breadth = _indiv.getBreadth(depth);
    int childDepth = _depth + 1;

    if (childrenNodes.length > 0) {
      _indiv.addOperation(getOperator());
    } else {
      visX = breadth;
      _indiv.addBreadth();
    }

    for (int i = 0; i < childrenNodes.length; i++) {
      if (i == 0) visX = childrenNodes[i].identify(_indiv, childDepth);
      else childrenNodes[i].identify(_indiv, childDepth);
    }

    return visX;
  }

  void mutate() {
    float toAdd = random(-.1, .1);
    mathType = constrain(mathType + toAdd, 0, 1);

    for (int i = 0; i < scalar.length; i++) {
      if (random(1) > mutationRate) continue;
      toAdd = random(-.1, .1);
      scalar[i] = constrain(scalar[i] + toAdd, 0, 1);
    }

    checkNecessaryChildrenNodes();
  }

  Node getCopy() {
    Node[] childrenNodesCopy = new Node[childrenNodes.length];

    for (int i = 0; i < childrenNodes.length; i++) {
      childrenNodesCopy[i] = childrenNodes[i].getCopy();
    }

    return new Node(mathType, childrenNodesCopy, scalar.clone(), nodeIndex, depth, breadth);
  }

  Node getNode(int _index) {
    if (nodeIndex == _index) return this;

    for (int i = 0; i < childrenNodes.length; i++) {
      Node potentialNode = childrenNodes[i].getNode(_index);
      if (potentialNode != null) return potentialNode;
    }

    return null;
  }

  Node getNodeVis(PVector _visLocation) { //gets node based on depth and visX
    if (depth > _visLocation.y || visX > _visLocation.x) return null;

    if (depth == int(_visLocation.y) && visX == int(_visLocation.x)) return this;

    for (int i = 0; i < childrenNodes.length; i ++) {
      Node potentialNode = childrenNodes[i].getNodeVis(_visLocation);
      if (potentialNode != null) return potentialNode;
    }

    return null;
  }

  boolean replaceNode(int _index, Node _newNode) {

    for (int i = 0; i < childrenNodes.length; i ++) {
      if (childrenNodes[i].nodeIndex == _index) {
        childrenNodes[i] = _newNode;
        return true;
      }
    }

    for (int i = 0; i < childrenNodes.length; i ++) {
      if (childrenNodes[i].replaceNode(_index, _newNode)) return true;
    }

    return false;
  }

  //scalar index is related to selected expression string (0-R, 1-G, 2-B);
  String getFunctionString(int _scalarIndex) {
    String finalString = "";


    if (childrenNodes.length < 1) {
      finalString += getScalarValueString(_scalarIndex, false);
      return finalString;
    }

    Operation operation = getOperation();

    //if operation if of type opt(xxxxxx)
    if (operation.type != 0) {
      finalString += enabledOperations[getMathType(mathType)].operator;
    }

    finalString += "(";

    for (int i = 0; i < childrenNodes.length; i ++) {
      finalString += childrenNodes[i].getFunctionString(_scalarIndex);

      if (i < childrenNodes.length - 1) {
        //if operation of type x + y
        if (operation.type == 0) finalString += operation.operator;
        else finalString += ",";
      }
    }

    finalString += ")";
    return finalString;

    ///// REDOING CHILDREN LOGIC
    /*
    if (aNode == null) {
     finalString += getScalarValueString(_scalarIndex, false);
     return finalString;
     }
     //
     if (operation.type != 0) {
     finalString += enabledOperations[getMathType(mathType)].operator;
     }
     //
     finalString += "(";
     
     if (aNode != null) {
     finalString += aNode.getFunctionString(_scalarIndex);
     }
     
     if (operation.type == 0) {
     finalString += enabledOperations[getMathType(mathType)].operator;
     } else if (operation.type == 2) {
     finalString += ",";
     } else {
     finalString += ")";
     return finalString;
     }
     
     if (bNode != null) {
     finalString += bNode.getFunctionString(_scalarIndex);
     } else {
     finalString += getScalarValueString(_scalarIndex, false);
     }
     
     finalString += ")";
     return finalString;*/
  }


  String[] getExpressions() {//get 3 expressions (R, G and B)
    String[] expressions = new String[3];

    for (int i = 0; i < expressions.length; i++) {
      expressions[i] = getFunctionString(i);
    }

    return expressions;
  }

  String getNodeText() {//for tree visualization
    String toReturn = "";


    if (childrenNodes.length < 1) {
      toReturn += "(";
      for (int i = 0; i < scalar.length; i++) {
        toReturn += getScalarValueString(i, true);
        if (i < scalar.length - 1) toReturn += ", ";
      }
      toReturn += ")";
    } else {
      toReturn += getOperator();
    }
    return toReturn;
  }

  /*
  void setupNodeFromExpression(String _expression) {
   
   if (_expression.length() <= 0) println("invalid expression: too short");
   _expression = removeStartAndEndParenthesis(_expression);
   println("\n" + _expression + "_NEW EXPRESSION");
   
   mathType = -1;
   aValType = -1;
   bValType = -1;
   Operation operation = null;
   
   for(int i = 0; i < valTypes.length; i++){
   if(_expression.equals(valTypes[i])){
   aValType = map(i, 0, valTypes.length, 0, 1);
   mathType = random(1);
   bValType = random(1);
   return;
   }
   }
   
   int mainOperatorIndex = getMainSimpleOperatorIndex(_expression);
   //operation is of type 0_ x $ x
   if(mainOperatorIndex >= 0){
   String operatorString = String.valueOf(_expression.charAt(mainOperatorIndex));
   
   for (int i = 0; i < operations.length; i ++) {
   if (operations[i].operator.equals(operatorString)) {
   operation = operations[i];
   mathType = mathTypeFromOperatorIndex(i);
   }
   }
   
   String[] expressionHalves = splitStringAtIndex(_expression, mainOperatorIndex);
   
   setupNodeFromExpressionHalves(expressionHalves);
   return;
   }
   
   //check for type 1 or 2 - expression must start with "operator("
   for (int i = 0; i < operations.length; i ++) {
   
   //operation of type 1 or 2 must end in ')'
   if (_expression.charAt(_expression.length()-1) != ')') break;
   if (operations[i].type > 0) {
   
   String operator = operations[i].operator;
   int operatorLength = operator.length();
   
   //if start of expression is operator
   if (_expression.length() < operatorLength) continue;
   if (_expression.substring(0, operatorLength).equals(operations[i].operator)) {
   operation = operations[i];
   mathType = mathTypeFromOperatorIndex(i);
   
   //remove operator and parenthesis(start and end)
   println("operator is: " + operator);
   _expression = _expression.substring(operatorLength + 1, _expression.length() - 1);
   println(_expression + "_ cut expression");
   break;
   }
   }
   }
   
   if (operation.type == 1) { //operation is of type 1_ $(x)
   println("\nExpression is of type 1");
   
   for (int i = 0; i < valTypes.length; i++) {
   if (valTypes[i].equals(_expression))
   {
   aValType = map(i, 0, valTypes.length, 0, 1);
   bValType = random(1);
   return;
   }
   }
   
   aNode = new Node(_expression);
   aValType = random(1);
   bValType = random(1);
   return;
   }
   
   if (operation.type == 2) { //operation is of type 2_ $(x, x)
   println("\nExpression is of type 2");
   
   int mainCommaIndex = getMainCommaIndex(_expression);
   
   String[] expressionHalves = splitStringAtIndex(_expression, mainCommaIndex);
   println(_expression);
   println(expressionHalves);
   
   setupNodeFromExpressionHalves(expressionHalves);
   return;
   }
   
   println("ERROR: no operation found");
   }
   
   void setupNodeFromExpressionHalves(String[] _expressionHalves) {
   _expressionHalves[0] = removeStartAndEndParenthesis(_expressionHalves[0]);
   _expressionHalves[1] = removeStartAndEndParenthesis(_expressionHalves[1]);
   
   for (int i = 0; i < valTypes.length; i++) { //left side of expression is a single value
   if (valTypes[i].equals(_expressionHalves[0]))
   {
   aNode = null;
   aValType = map(i, 0, valTypes.length, 0, 1);
   break;
   }
   }
   
   if (aValType < 0)
   {
   aValType = random(1);
   aNode = new Node(_expressionHalves[0]);
   }
   
   for (int i = 0; i < valTypes.length; i++) { //right side of expression is a single value
   if (valTypes[i].equals(_expressionHalves[1]))
   {
   bNode = null;
   bValType = map(i, 0, valTypes.length, 0, 1);
   break;
   }
   }
   
   if (bValType < 0)
   {
   bValType = random(1);
   bNode = new Node(_expressionHalves[1]);
   }
   
   }*/

  void checkNecessaryChildrenNodes() {
    int requiredArguments =  enabledOperations[getMathType(mathType)].getNumberArgumentsNeeded();

    if (requiredArguments == childrenNodes.length) return;

    if (requiredArguments < childrenNodes.length) {
      Node[] correctChildrenNodes = new Node[requiredArguments];
      for (int i = 0; i < requiredArguments; i ++) {
        correctChildrenNodes[i] = childrenNodes[i].getCopy();
      }
      childrenNodes = correctChildrenNodes;
      return;
    }

    if (requiredArguments > childrenNodes.length) {
      Node[] correctChildrenNodes = new Node[requiredArguments];

      for (int i = 0; i < childrenNodes.length; i ++) {
        correctChildrenNodes[i] = childrenNodes[i].getCopy();
      }

      for (int i = childrenNodes.length; i < requiredArguments; i++) {
        correctChildrenNodes[i] = new Node();
      }
      childrenNodes = correctChildrenNodes;
    }
  }

  void removeTooDeep() {
    if (depth == maxDepth) {
      childrenNodes = new Node[0];
      mathType = -1;
    } else {
      for (int i = 0; i < childrenNodes.length; i++) {
        childrenNodes[i].removeTooDeep();
      }
    }
  }

  String getScalarValueString(int _scalarIndex, boolean _cropped) { //retrieves string from normalized scalar values, from terminal set or value 0-1
    float scalarValue = scalar[_scalarIndex];

    int nOptions = terminalSet.length + 1;

    float converter = scalarValue * nOptions;

    if (converter > 1) { //if > 1 then we choose from terminal set
      int terminalSetIndex = constrain(floor(converter - 1), 0, terminalSet.length -1);
      return terminalSet[terminalSetIndex];
    } else { //else scalar is a value (0-1)
      if (_cropped) {
        return nf(converter, 0, 2);
      } else {
        return String.valueOf(converter);
      }
    }
  }

  int getMathType(float _type) {
    int value = floor(map(_type, 0, 1, 0, enabledOperations.length));
    value = constrain(value, 0, enabledOperations.length - 1);
    return value;
  }

  float mathTypeFromOperatorIndex(int _operatorIndex) {
    return map(_operatorIndex, 0, enabledOperations.length, 0, 1 -0.001);
  }

  String removeStartAndEndParenthesis(String _string) {
    if (_string.length() <= 0) {
      println("string at removeStartAndEndParenthesis is too short " + _string);
      return _string;
    }
    if (!_string.contains("(")) return _string;

    int openedParenthesis = 0;
    int openedAtIndex = -1; //to check if first parenthesis closes before finish
    for (int i = 0; i < _string.length(); i++) {
      char c = _string.charAt(i);
      if (c == '(') {
        openedParenthesis += 1;
        if (openedParenthesis == 1) openedAtIndex = i;
      } else if (c == ')') {
        openedParenthesis -= 1;
      }
    }

    if (_string.charAt(0) == '(' && _string.charAt(_string.length() - 1) == ')' && openedAtIndex == 0) {
      _string = _string.substring(1, _string.length() - 1);
    }

    return _string;
  }

  int getMainCommaIndex(String _string) { // (((,),))','(,)(,) returns highlighted comma index
    int openedParenthesis = 0;

    if (!_string.contains(",")) {
      println("No commas found at getMainCommaIndex(" + _string + ")");
      return 0;
    }

    for (int i = 0; i < _string.length(); i++) {
      char c = _string.charAt(i);
      if (c == '(') openedParenthesis += 1;
      else if (c == ')') openedParenthesis -= 1;
      else if (c == ',' && openedParenthesis == 0) return i;

      if (openedParenthesis < 0) {
        println("Negative openedParenthesis at getMainCommaIndex(" + _string + ")");
        return 0;
      }
    }

    println("No acceptable comma at getMainCommaIndex(" + _string + ")");
    return -1;
  }

  int getMainSimpleOperatorIndex(String _string) { // (((,),))'*'(,)(,) returns highlighted operator index
    int openedParenthesis = 0;

    String allSimpleOperators = "";

    for (Operation o : operations) {
      if (o.type != 0) continue;
      allSimpleOperators += o.operator;
    }

    for (int i = 0; i < _string.length(); i++) {
      char c = _string.charAt(i);
      if (c == '(') openedParenthesis += 1;
      else if (c == ')') openedParenthesis -= 1;
      else if (allSimpleOperators.contains(String.valueOf(c)) && openedParenthesis == 0) return i;

      if (openedParenthesis < 0) {
        println("Negative openedParenthesis at getMainSimpleOperatorIndex(" + _string + ")");
        return 0;
      }
    }

    println("No acceptable simple operator at getMainSimpleOperatorIndex(" + _string + ")");
    return -1;
  }

  boolean isTerminal() {
    return (childrenNodes.length == 0);
  }

  PVector getVisLocation() {
    return new PVector(visX, depth);
  }

  float[] getRandomScalar() {
    float[] toReturn = new float[3];
    for (int i = 0; i < 3; i++) {
      toReturn[i] = random(1);
    }
    return toReturn;
  }

  Operation getOperation() {
    return enabledOperations[getMathType(mathType)];
  }

  String getOperator() {
    return getOperation().operator;
  }
}
