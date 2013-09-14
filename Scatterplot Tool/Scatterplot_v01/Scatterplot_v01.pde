//TODOs:
//Make the scale easily switchable between linear and logarithmic

//Import libraries to handle sql databases
import de.bezier.data.sql.*;
import de.bezier.data.sql.mapper.*;

//Create object to hold mysql database
MySQL mysql;
//Create an array of DataPoint objects
DataPoint[] dp;
//Create a Pfont object so we can use fonts later on
PFont f;

//Screen Variables
int screenWidth = 1000;
int screenHeight = 700;
//xScale is the length of the x axis in pixels
int xScale = 900;
//yScale is the length of the y axis in pixels
int yScale = 600;
//sizeScale determines the max size of the datapoints. It is measured in the diameter of the points
int sizeScale = 10;
//Initialize variables to hold various maximum values. We will get these values from the database
int maxWords;
int maxViews;
int maxKey;
int maxLikes;

//Axis Variables
//Stores the position of the origin
int[] origin = {50,screenHeight - 50};

void setup() {
    size(screenWidth,screenHeight);
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
        dp[i] = new DataPoint(mysql.getInt("Prime_Key"), mysql.getFloat("Words"), mysql.getFloat("Views"), mysql.getFloat("Likes"), mysql.getInt("Content_Rating"), mysql.getString("Title"),mysql.getString("Author_Name"));
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
}

//Get the number of words in the entry with the most words. Used to normalize values
int getMaxWords() {
        mysql.query("SELECT MAX(Words) AS Words FROM Stories;");
        mysql.next();
        return mysql.getInt(1);
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
    fill(255,255,204);
    stroke(0);
    strokeWeight(1);
    //Sets the draw position of the box
    int xPos = screenWidth - 500;
    int yPos = 100;
    //Sets the draw position of the box
    int textX = xPos+10;
    int textY = yPos+20;
    //Draws the box
    rect(xPos,yPos,400,200);
    //Sets the font
    textFont(f);
    //Sets the font color
    fill(0);
    //Draws the text
    text("Title: "+t, textX,textY);
    text("Author: "+a, textX, textY + 20);
    text("Words: "+(int)w, textX, textY + 40);
    text("Views: "+(int)v, textX, textY + 60);
    text("Likes: "+(int)l, textX, textY + 80);
}

void draw() {
    //Draw the background again to reset the stage
    background(255);
    //Update all the data points
    for (int i = 0; i < maxKey; i++) {
        dp[i].update();
    }
    //Change the stroke settings for the axis, then draw axis
    drawAxes();
}

//Class for the data point object
class DataPoint {
    //Initialize variables
    float xPos, yPos, size, baseSize, words, views, likes, distance;
    int contentRating, primeKey;
    String title, author;
    
    //Constructor
    //Takes variables for the database key, word count, view count, like count, content rating,
    //title, and author
    DataPoint (int prime, float w, float v, float l, int cr, String t, String a) {
        primeKey = prime;
        words = w;
        views = v;
        likes = l;
        contentRating = cr;
        title = t;
        author = a;
    }
    
    //Sets the x position of the datapoint
    void findX() {
//        xPos = origin[0]+log(words)/log(maxWords)*xScale;
//        xPos = origin[0]+words/maxWords*xScale;
        xPos = origin[0]+(log(words)/log(10)) / (log(maxWords)/log(10))*xScale;
    }
    
    //Sets the y position of the datapoint
    void findY() {
//        yPos = origin[1]-log(views)/log(maxViews)*yScale;
//        yPos = origin[1]-views/maxViews*yScale;
        yPos = origin[1]-(log(views)/log(10)) / (log(maxViews)/log(10))*yScale;
    }
    
    //Sets the diameter of the datapoint
    void findSize() {
        size = likes/maxLikes*sizeScale+1;
//        size = 4;
//        size = (log(likes)/log(maxLikes)*sizeScale)+1;
        baseSize = size;
    }
    
    //Sets the color of the datapoint based on the content rating of the entry
    void findColor() {
        switch(contentRating) {
            case 0:
                fill(0,255,0);
                break;
            case 1:
                fill(0,0,255);
                break;
            case 2:
                fill(255,0,0);
                break;
        }
    }
    
    //Draws the datapoint
    void update() {
        ellipseMode(RADIUS);
        //Gets the distance from the mouse to the datapoint
        distance = dist(mouseX,mouseY,xPos,yPos);
        if (distance < size) {                                  //If the mouse is directly over the datapoint:
            size = baseSize + 3;                                //Make it bigger
            drawDataBox(title, author, words, views, likes);    //Draw a databox with the datapoint's information
            findColor();                                        //Set the fill color based on the datapoint's content rating
            stroke(100);                                        //Give the datapoint a black highlight
            strokeWeight(1);
        }
        else {                                                  //Else just:
            findColor();                                        //Find the color
            noStroke();                                         //Don't give it a stroke
            findX();                                            //Find the x position
            findY();                                            //Find the y position
            findSize();                                         //Find the datapoint's size
        }
        ellipse(xPos,yPos,size,size);                           //Draw the datapoint
    }
}
