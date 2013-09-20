//TODOs:
//Add a scale to the axes
//Add a control panel

//Import libraries to handle sql databases
import de.bezier.data.sql.*;
import de.bezier.data.sql.mapper.*;

//Create object to hold mysql database
MySQL mysql;
//Create an array of DataPoint objects
DataPoint[] dp;
//Create a Pfont object so we can use fonts later on
PFont f;
//Create a PGraphics object to buffer the drawing of the datapoints
PGraphics dpb;
//Determines whether to redraw the datapoints
boolean reDraw = true;
//Create a PGraphics object to overlay the selected dot and data box
PGraphics overlay;
PImage img;
//Create a boolean to determine whether to use the overlay. 
boolean useOverlay = false;
//The overlayKey is to set which datapoint is to be displayed
int overlayKey = 0;

//Set whether to use a linear scale or logarithmic
boolean useLogScale = false;

//Screen Variables
int screenWidth = 1000;
int screenHeight = 700;
//xScale is the length of the x axis in pixels
int xScale = 900;
//yScale is the length of the y axis in pixels
int yScale = 600;
//dpSizeScale determines the max dpSize of the datapoints. It is measured in the diameter of the points
int dpSizeScale = 10;
//Create margins for the axis
int xMargin = 50;
int yMargin = 50;
//Number of tick for each axis
int xTicks = 10;
int yTicks = 10;
int tickLength = 10;
//Initialize variables to hold various maximum values. We will get these values from the database
int maxWords;
int maxViews;
int maxKey;
int maxLikes;

//Axis Variables
//Stores the position of the origin
int[] origin = {xMargin,screenHeight - yMargin};

void setup() {
    size(screenWidth,screenHeight,P3D);
    frameRate(30);
    //Initialize the datapoint buffer
    dpb = createGraphics(screenWidth, screenHeight, P3D);
    overlay = createGraphics(screenWidth, screenHeight, P3D);
    //Creates the font used for the data box
    f = createFont("Courier", 14, true);
   
    //Sets the username and password for the mysql database
    String user = "fimfic";
    String pass = "lyra04";
    //Sets the name of the database to use
    String database = "test05";
    //Creates a new mysql database
    mysql = new MySQL( this, "localhost", database, user, pass );
    mysql.connect();
    //Gets max values
    maxWords = getMaxWords();
    maxViews = getMaxViews();
    maxLikes = getMaxLikes();
    maxKey = getMaxKey();
    //Creates a set of new DataPoint objects equal to the number of entries in the database
    dp = new DataPoint[maxKey];
    //Queries the database for values
    mysql.query("SELECT Prime_Key, Words, Views, Likes, Content_Rating, Title, Author_Name FROM Stories");
    
    //Puts the data recieved from the mysql query into datapoint objects
    for (int i = 0; i < maxKey; i++) {
        mysql.next();
        dp[i] = new DataPoint(mysql.getInt("Prime_Key"), mysql.getFloat("Words"), mysql.getFloat("Views"), mysql.getFloat("Likes"), mysql.getInt("Content_Rating"), mysql.getString("Title"),mysql.getString("Author_Name"), i);
    }
}

void drawAxes() {
    //Set the stroke settings
    strokeWeight(2);
    stroke(1);

    //Draw the X axis
    line(origin[0],origin[1],screenWidth-50,origin[1]);
    
    //Draw the Y axis
    line(origin[0],origin[1],origin[0],50);

    //Draw the white coverup
    //The coverup is needed because some datapoints might bleed outside of the axis otherwise
    fill(255);
    noStroke();
    rect(0,0,50,screenHeight);
    rect(0,origin[1]+1,screenWidth,50);

    //Draw the ticks
    strokeWeight(2);
    stroke(1);
    //X axis
    for (int i = 0; i<=screenWidth - 50 - origin[0]; i += (screenWidth - 50 - origin[0]) / (xTicks-1)){
        line(origin[0] + i, origin[1], origin[0] + i, origin[1] + tickLength);
    }
    //Y axis
    for (int i = 0; i<=screenHeight - 50 - yMargin; i += (screenHeight - 50 - yMargin) / (yTicks-1)){
        line(origin[0], origin[1] - i, origin[0] - tickLength, origin[1] - i);
    }
}

//Get the number of words in the entry with the most words. Used to normalize values
int getMaxWords() {
        mysql.query("SELECT MAX(Words) AS Words FROM Stories;");
        mysql.next();
        return mysql.getInt(1);
}

int getTickValue(int position, boolean isX) {
    if (isX){
        return position/screenWidth*maxWords;
    }
    else {
        return position/screenHeight*maxViews;
    }
}

//Get the maximum view value. Used to normalize values
int getMaxViews() {
    if (mysql.connect()) {
        mysql.query("SELECT MAX(Views) AS Views FROM Stories;");
        mysql.next();
        return mysql.getInt(1);
    }
    else {
        return 0;
    }
}

//Get the maximum like value. Used to normalize values
int getMaxLikes() {
    if (mysql.connect()) {
        mysql.query("SELECT MAX(Likes) AS Likes FROM Stories;");
        mysql.next();
        return mysql.getInt(1);
    }
    else {
        return 0;
    }
}

//Get the total number of entries. Used to determine how many datapoint objects to create
int getMaxKey() {
    if (mysql.connect()) {
        mysql.query("SELECT MAX(Prime_Key) AS Prime_Key FROM Stories;");
        mysql.next();
        return mysql.getInt(1);
    }
    else {
        return 0;
    }
}

//Creates a data box when the user mouses over a datapoint
//
//The function takes a title string "t", an author string, "a", a word count, "w",
//a view count, "v", and a like count, "l"
void drawDataBox(String t, String a, float w, float v, float l) {
    //Prepares to create the data box by setting the fill color, 
    //the stroke color, and the stroke width
    String boxText = "";
    overlay.fill(255,255,204);
    overlay.stroke(0);
    overlay.strokeWeight(1);
    //Sets the draw position of the box
    int xPos = screenWidth - 500;
    int yPos = 100;
    //Sets the draw position of the box
    int textX = xPos+10;
    int textY = yPos+20;
    //Draws the box
    overlay.rect(xPos,yPos,400,200);
    //Sets the font
    overlay.textFont(f);
    //Sets the font color
    overlay.fill(0);
    //Draws the text
    boxText = "Title: "+t+"\nAuthor: "+a+"\nWords: "+w+"\nViews: "+v+"\nLikes: "+l;
    overlay.text(boxText, textX, textY, 380, 200);
    // overlay.text("Title: "+t, textX,textY);
    // overlay.text("Author: "+a, textX, textY + 20);
    // overlay.text("Words: "+(int)w, textX, textY + 40);
    // overlay.text("Views: "+(int)v, textX, textY + 60);
    // overlay.text("Likes: "+(int)l, textX, textY + 80);
}

void drawOverlay(int k) {
    overlay.beginDraw();
    dp[k].updateOverlay();
    overlay.endDraw();
}

void draw() {
    //Draw the background again to reset the stage
    background(255);
    //Update all the data points
    if (reDraw){
        dpb.beginDraw();
        dpb.background(255,255,255);
        for (int i = 0; i < maxKey; i++) {
            dp[i].update();
        }
        dpb.endDraw();
        image(dpb, 0,0);
        reDraw = false;  
    }
    else {
        image(dpb, 0, 0);
    }
    //Draw the buffered image
    //image(dpb, 0,0);
    //Set the frame rate as the title of the sketch
    frame.setTitle(int(frameRate) + " fps");

    for (int i = 0; i<maxKey; i++){
        dp[i].checkDistance();
    }

    if (useOverlay) {
        drawOverlay(overlayKey);
        useOverlay = false;
        image(overlay,0,0);
    }
    
    //Change the stroke settings for the axis, then draw axis
    drawAxes();
}

//Class for the data point object
class DataPoint {
    //Initialize variables
    float xPos, yPos, dpSize, baseSize, words, views, likes, distance;
    int contentRating, primeKey, pointKey;
    String title, author;
    
    //Constructor
    //Takes variables for the database key, word count, view count, like count, content rating,
    //title, and author
    DataPoint (int prime, float w, float v, float l, int cr, String t, String a, int k) {
        primeKey = prime;
        words = w;
        views = v;
        likes = l;
        contentRating = cr;
        title = t;
        author = a;
        pointKey = k;
        findSize();
    }
    
    //Sets the x position of the datapoint
    void findX() {
        if (useLogScale){
            xPos = origin[0]+(log(words)/log(10)) / (log(maxWords)/log(10))*xScale;
            //This log scale uses log base 10
        }
        else {
            xPos = origin[0]+words/maxWords*xScale;
        }
        //xPos = origin[0]+log(words)/log(maxWords)*xScale;
        //This log scale uses a natural log
    }
    
    //Sets the y position of the datapoint
    void findY() {
        if (useLogScale){
            yPos = origin[1]-(log(views)/log(10)) / (log(maxViews)/log(10))*yScale;
        }
        else {
            yPos = origin[1]-views/maxViews*yScale;
            //This log scale uses log base 10
        }
        //yPos = origin[1]-log(views)/log(maxViews)*yScale;
        //This log scale uses a natural log
        
    }
    
    //Sets the diameter of the datapoint
    void findSize() {
        dpSize = likes/maxLikes*dpSizeScale+1;
//        dpSize = 4;
//        dpSize = (log(likes)/log(maxLikes)*dpSizeScale)+1;
        baseSize = dpSize;
    }
    
    //Sets the color of the datapoint based on the content rating of the entry
    void dpFindColor() {
        switch(contentRating) {
            case 0:
                dpb.fill(0,255,0);
                break;
            case 1:
                dpb.fill(0,0,255);
                break;
            case 2:
                dpb.fill(255,0,0);
                break;
        }
    }
    
    void overlayFindColor() {
        switch(contentRating) {
            case 0:
                overlay.fill(0,255,0);
                break;
            case 1:
                overlay.fill(0,0,255);
                break;
            case 2:
                overlay.fill(255,0,0);
                break;
        }
    }

    //Draws the datapoint
    void update() {
        //dpb.beginDraw();
        dpb.ellipseMode(RADIUS);
        dpFindColor();                                        //Find the color
        dpb.noStroke();                                     //Don't give it a stroke
        findX();                                            //Find the x position
        findY();                                            //Find the y position
        findSize();
        dpb.ellipse(xPos,yPos,dpSize,dpSize);                   //Draw the datapoint
        //dpb.endDraw();
    }

    void updateOverlay() {
        overlay.ellipseMode(RADIUS);
        overlayFindColor();
        findSize();
        dpSize = baseSize + 3;
        overlay.stroke(100);
        overlay.strokeWeight(1);
        overlay.background(0,0);
        overlay.ellipse(xPos, yPos, dpSize, dpSize);
        drawDataBox(title, author, words, views, likes);
    }

    void checkDistance() {
        //Gets the distance from the mouse to the datapoint
        distance = dist(mouseX,mouseY,xPos,yPos);
        if (distance < dpSize) {                                  //If the mouse is directly over the datapoint:
            useOverlay = true;
            overlayKey = pointKey;
            // dpSize = baseSize + 3;                                //Make it bigger
            // //drawDataBox(title, author, words, views, likes);    //Draw a databox with the datapoint's information
            // dpFindColor();                                        //Set the fill color based on the datapoint's content rating
            // dpb.stroke(100);                                        //Give the datapoint a black highlight
            // dpb.strokeWeight(1);
        }
        else {                                                  //Else just:
            // dpFindColor();                                        //Find the color
            // dpb.noStroke();                                         //Don't give it a stroke
            // findX();                                            //Find the x position
            // findY();                                            //Find the y position
            // findSize();                                         //Find the datapoint's dpSize
        }
    }
}