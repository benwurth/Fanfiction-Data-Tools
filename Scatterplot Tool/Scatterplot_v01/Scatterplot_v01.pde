import de.bezier.data.sql.*;
import de.bezier.data.sql.mapper.*;
MySQL mysql;
DataPoint[] dp;
PFont f;

//Screen Variables
int screenWidth = 1000;
int screenHeight = 700;
int xScale = 900;
int yScale = 600;
int sizeScale = 10;
int maxWords;
int maxViews;
int maxKey;
int maxLikes;

//Axis Variables
int[] origin = {50,screenHeight - 50};

void setup() {
    size(screenWidth,screenHeight);
    f = createFont("Courier", 14, true);
   
    String user = "fimfic";
    String pass = "lyra04";
    String database = "test05";
    mysql = new MySQL( this, "localhost", database, user, pass );
    mysql.connect();
    maxWords = getMaxWords();
    maxViews = getMaxViews();
    maxLikes = getMaxLikes();
    maxKey = getMaxKey();
    dp = new DataPoint[maxKey];
    mysql.query("SELECT Prime_Key, Words, Views, Likes, Content_Rating, Title, Author_Name FROM Stories");
    
    for (int i = 0; i < maxKey; i++) {
        mysql.next();
        dp[i] = new DataPoint(mysql.getInt("Prime_Key"), mysql.getFloat("Words"), mysql.getFloat("Views"), mysql.getFloat("Likes"), mysql.getInt("Content_Rating"), mysql.getString("Title"),mysql.getString("Author_Name"));
    }
}



void initializePoints() {
    
}

void drawAxes() {
    //Draw the X axis
    line(origin[0],origin[1],screenWidth-50,origin[1]);
    
    //Draw the Y axis
    line(origin[0],origin[1],origin[0],50);
    
    //Draw the white coverup
    fill(255);
    noStroke();
    rect(0,0,50,screenHeight);
    rect(0,origin[1]+1,screenWidth,50);
}

int getMaxWords() {
        mysql.query("SELECT MAX(Words) AS Words FROM Stories;");
        mysql.next();
        return mysql.getInt(1);
}

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

void drawDataBox(String t, String a, float w, float v, float l) {
    fill(255,255,204);
    stroke(0);
    strokeWeight(1);
    int xPos = screenWidth - 500;
    int yPos = 100;
    int textX = xPos+10;
    int textY = yPos+20;
    rect(xPos,yPos,400,200);
    textFont(f);
    fill(0);
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
    strokeWeight(2);
    stroke(1);
    drawAxes();
}

//Class for the data point object
class DataPoint {
    float xPos, yPos, size, baseSize, words, views, likes, distance;
    int contentRating, primeKey;
    String title, author;
    
    DataPoint (int prime, float w, float v, float l, int cr, String t, String a) {
        primeKey = prime;
        words = w;
        views = v;
        likes = l;
        contentRating = cr;
        title = t;
        author = a;
    }
    
    void findX() {
//        xPos = origin[0]+log(words)/log(maxWords)*xScale;
//        xPos = origin[0]+words/maxWords*xScale;
        xPos = origin[0]+(log(words)/log(10)) / (log(maxWords)/log(10))*xScale;
    }
    
    void findY() {
//        yPos = origin[1]-log(views)/log(maxViews)*yScale;
//        yPos = origin[1]-views/maxViews*yScale;
        yPos = origin[1]-(log(views)/log(10)) / (log(maxViews)/log(10))*yScale;
    }
    
    void findSize() {
        size = likes/maxLikes*sizeScale+1;
//        size = 4;
//        size = (log(likes)/log(maxLikes)*sizeScale)+1;
        baseSize = size;
    }
    
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
    
    void update() {
        ellipseMode(RADIUS);
        distance = dist(mouseX,mouseY,xPos,yPos);
        if (distance < size) {
            size = baseSize + 3;
            drawDataBox(title, author, words, views, likes);
            findColor();
            stroke(100);
            strokeWeight(1);
        }
        else {
            findColor();
            noStroke();
            findX();
            findY();
            findSize();
        }
        ellipse(xPos,yPos,size,size);
    }
}
