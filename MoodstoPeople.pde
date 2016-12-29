/* Note Following code translates my feelings when I am speaking
to a person into a graph.
For More details, look at A1a.
*/

FloatTable data;//class
float dataMin, dataMax; // set constraints

float plotX1, plotY1;// Setting the graph constraints
float plotX2, plotY2;
float labelX, labelY;

int rowCount;
int columnCount;
int currentColumn = 0;

int personMin, personMax;//Each person has a assigned number
int[] people;

int personInterval = 1;
int volumeInterval = 1;
float volumeIntervalMinor = .5;

float[] tabLeft, tabRight;
float tabTop, tabBottom;
float tabPad = 1;

Integrator[] interpolators; // Class Integrator

PFont plotFont;

void setup() {
  size(800, 505); //Canvas size
  data = new FloatTable("MoodstoPeople.tsv"); //Data from the tsv file
  rowCount = data.getRowCount(); //Variables
  columnCount = data.getColumnCount();

  people = int(data.getRowNames());
  personMin = people[0];
  personMax = people[people.length-1];//Difference of 1 in between each person
  
   dataMin = 0;
  dataMax = ceil(data.getTableMax() / volumeInterval) * volumeInterval;
  
   interpolators = new Integrator[rowCount];
  for (int row = 0; row<rowCount; row++) {
    float initialValue = data.getFloat(row, 0);
    interpolators[row] = new Integrator(initialValue);
    interpolators[row].attraction = .01;
  }

plotX1 = 60; //Setting the boundaries for the plot location
  plotX2 = width-40;
  labelX = 25;
  plotY1 = 30;
  plotY2 = height - 35;
  labelY = height-12.5;
  
   plotFont = createFont("SansSerif", 18); //Font declatration
  textFont(plotFont);

  smooth();
}

void draw() {
  background(64, 224, 208);
  //show the plot area as colored box
  fill(255, 250, 205);
  rectMode(CORNERS); // Varible
  noStroke();
  rect(plotX1, plotY1, plotX2, plotY2);

  drawTitleTabs();
  drawAxisLabels();

  for (int row = 0; row<rowCount; row++) {
    interpolators[row].update();
  }
  
  drawPersonLabels();
  drawVolumeLabels();

  noStroke(); //Draw the data for the first column
  fill(255, 62, 150);
  drawDataArea(currentColumn);
}

void drawTitleTabs() {
  rectMode(CORNERS);
  noStroke();
  textSize(18);
  textAlign(LEFT);
  //onthe first use of this method allocate space for an array
  //to store the values for the left and right edges of the tabs
  if (tabLeft == null) {
    tabLeft = new float[columnCount];
    tabRight = new float[columnCount];
  }
  float runningX = plotX1;
  tabTop = plotY1 - textAscent() - 10;
  tabBottom = plotY1;

  for (int col = 0; col<columnCount; col++) {
    String title = data.getColumnName(col);
    tabLeft[col] = runningX;
    float titleWidth = textWidth(title);
    tabRight[col] = tabLeft[col] + tabPad +titleWidth + tabPad;

    // if the current tab sets its bg white, otherwise use grey
    fill(col ==currentColumn ? 255:224);
    rect(tabLeft[col], tabTop, tabRight[col], tabBottom);
    //if the current tab, use black for the text, otherwise grey
    fill(col == currentColumn?0:64);
    text(title, runningX+tabPad, plotY1-10);
    runningX = tabRight[col];
  }
}

void mousePressed() { //controlling the data in tsv file
  if (mouseY>tabTop && mouseY<tabBottom) {
    for (int col = 0; col<columnCount; col++) {
      if (mouseX>tabLeft[col] && mouseX<tabRight[col]) {
        setColumn(col);
      }
    }
  }
}

void setColumn(int col) {
  currentColumn = col;
  for (int row = 0; row<rowCount; row++) {
    interpolators[row].target(data.getFloat(row, col));
  }
}

void drawAxisLabels() {
  fill(0);
  textSize(10);
  textLeading(20);
  
  textAlign(CENTER, CENTER);
  text("Mood Level", labelX, (plotY1+plotY2)/2);
  textAlign(CENTER);
  text("Person", (plotX1+plotX2)/2, labelY);
}

  void drawPersonLabels() {
  fill(0);
  textSize(10);
  textAlign(CENTER);

  //grid
  stroke(224);
  strokeWeight(1);

  for (int row = 0; row<rowCount; row++) {
    //if (people[row]% personInterval ==0) {
      float x = map(people[row], personMin, personMax, plotX1, plotX2);
      text(people[row],x, plotY2+textAscent()+10);
      line(x, plotY1, x, plotY2);
    //}
  }
}

void drawVolumeLabels() {
  fill(0);
  textSize(5);
  textAlign(RIGHT);

  stroke(128);
  strokeWeight(1);
  
  for (float v = dataMin; v<dataMax; v+= volumeIntervalMinor) {
    if (v%volumeIntervalMinor ==0) {
      float y = map(v, dataMin, dataMax, plotY2, plotY1);
      if (v%volumeInterval == 0) {
        float textOffset = textAscent()/2;
        if (v == dataMin) {
          textOffset = 0;
        } else if (v == dataMax) {
          textOffset = textAscent();
        }
        text(floor(v), plotX1-10, y+textOffset);
        line(plotX1-4, y, plotX1, y);
      } else {
        //line...
      }
    }
  }
}

void drawDataArea(int col) {
  beginShape();
  for (int row=0; row<rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = interpolators[row].value;
      float x = map(people[row], personMin, personMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      vertex(x, y);
    }
  }
  vertex(plotX2, plotY2);
  vertex(plotX1, plotY2);
  endShape(CLOSE);
}


  
  
  


  
  