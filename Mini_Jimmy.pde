
// Mini Jimmy by Aliyah Owens
// 1 level with parallax
// move using arrow keys
// space bar to throw a book
// defeat the bully

boolean faceRight = true;
int book_num = 0;          // counter for array of books being thrown
int x = 1;                 // counter for Jimmy animations
int b_count = 1;           // counter for book animations
int mike_count = 1;        // counter for mike walk animations
int jimmyY = 800;          // jimmy Y position
int pause_count = 0;       // counter for pause animation when Mike is hit


// image arrays for animation
PImage[] runLeft = new PImage[7];
PImage[] runRight = new PImage[7];
PImage[] walkMike = new PImage[6];
PImage[] bookThrow = new PImage[5];

// single images
PImage idleRight;
PImage idleLeft;
PImage hallway;
PImage startScreen;
PImage idleMike;
PImage deadMike;

boolean[] isThrowing = new boolean[10];
boolean right, left, space = false;
boolean gameLossSoundPlayed = false;
boolean gameWonSoundPlayed = false;

MiniJimmy jimmy = new MiniJimmy();
MonsterMike mike = new MonsterMike();
Book[] books = new Book[5];           // array for all books

//sound files
import processing.sound.*;
SoundFile wisp, music, hit, lose, victory;

// game trackers
int bully_life = 100;
int books_left = books.length;
boolean gameOverWin = false;
boolean gameOverLoss = false;
boolean startScreenShowing = true;

void setup() {
  size(2000,1000);
  smooth();
  frameRate(10);
  
  // load sounds
  hit = new SoundFile(this, "bark.wav");
  wisp = new SoundFile(this, "throw.wav");
  music = new SoundFile(this, "music.wav");
  lose = new SoundFile(this, "lose.wav");
  victory = new SoundFile(this, "victory.wav");
  
  // load animation images
  for(int i=1; i<7; i++) {
    runLeft[i] = loadImage("run-left-"+i+".png");
    runRight[i] = loadImage("run-right-"+i+".png");
    if (i<5) {
      bookThrow[i] = loadImage("book"+i+".png");
    }
    if (i<6) {
      walkMike[i] = loadImage("mike"+i+".png"); 
    }
  }
  
  // load single images
  idleRight = loadImage("idle-right.png");
  idleLeft = loadImage("idle-left.png");
  hallway = loadImage("hallway.png");
  startScreen = loadImage("start-screen.png");
  idleMike = loadImage("idle-mike.png");
  deadMike = loadImage("dead-mike.png");
  
  // generate books (out of view)
  for (int i=0; i<books.length; i++) { 
    books[i] = new Book();
  }
  
  // set motion to false for all books
  for (int i=0; i<isThrowing.length; i++) {
   isThrowing[i] = false; 
  }
}

void draw() {
  imageMode(CENTER);
  
  // start screen state
  if (startScreenShowing) {
    // create start screen
    image(startScreen, 1000, 500, 2000, 1000);
    textAlign(CENTER);
    textSize(50);
    text("Press S to start", 1000, 500);
  }
  
  else if (gameOverLoss) {
    background(#000000);
    fill(#FFFFFF);
    textAlign(CENTER);
    textSize(100);
    text("YOU LOST", 1000, 500);
  }
  
  //game over state winner
  else if (gameOverWin) {
    background(#AFE0B2);
    fill(#FFFFFF);
    textAlign(CENTER);
    textSize(100);
    text("YOU WON", 1000, 500);
    
  } else {
      // draw background
      float hallwayx = map(jimmy.getPosition(), -25, 2000, 2100, 0);
      image(hallway, hallwayx, 500, 4000, 1000);

      // HUD
      //
      // books left
      for (int i=0; i<books_left; i++) {
        image(bookThrow[1], i*50 + 100, 120, 50, 50);
      }
      
      // Mike life bar
      fill(0,0,0);
      rect(1495, 75, 310, 60);
      fill(#1C75BC);
      rect(1500, 80, bully_life * 3, 50);
  
      // end game if Mike hits Jimmy
      if (jimmy.getPosition() + 100 > mike.getPosition() && bully_life > 0) {
       gameOverLoss = true;
       music.stop();
       if (!gameLossSoundPlayed) {
         lose.play();
         gameLossSoundPlayed = true;
       }
      }
  
      // end game when Mike loses all life
      if (bully_life == 0) {
        mike.dead(); 
        music.stop();
        if (jimmy.getPosition() == 2000) {
          gameOverWin = true;
          if (!gameWonSoundPlayed) {
           victory.play();
           gameWonSoundPlayed = true;
          }
        }
      }
      
      // throw a book
      if (space) { 
        if (faceRight) { 
          image(idleRight,jimmy.getPosition(),jimmyY); }
        if (!faceRight) {
          image(idleLeft,jimmy.getPosition(),jimmyY);  
        }
        if (book_num < books.length) {
          isThrowing[book_num] = true;
          wisp.play();
        }
      }
  
      // logic to throw one book at a time
      if (book_num < books.length) {
        if (isThrowing[book_num]) {
         books[book_num].throwBook(jimmy); 
        }
        // stop book when it hits Mike
        if (books[book_num].getPosition() > mike.getPosition() - 50) {
         isThrowing[book_num] = false;
         book_num ++;
         pause_count = 1;
         hit.play();
         bully_life -= 20;
        }
      }
  
      // make Mike pause when he is hit
      if (pause_count > 0 && bully_life > 0) {
        mike.hit();
        pause_count ++;
      }
      
      if (pause_count > 5) {
        pause_count = 0;
      }
  }
  
  // allow Mike to move during the game and after losing the game
  if (!startScreenShowing && !gameOverWin) {
    // move when then he's not paused(hit) nor dead
    if (pause_count == 0 && bully_life > 0) {
       mike.move(); 
    }
  }

  // allow Jimmy to move during the game and after winning
  if (!startScreenShowing && !gameOverLoss) {
    // idle jimmy  
    if (!keyPressed) {
      if (faceRight) { 
        image(idleRight,jimmy.getPosition(),jimmyY); }
      if (!faceRight) {
        image(idleLeft,jimmy.getPosition(),jimmyY);  
      }
    }

    // jimmy move right animation
    if (right) {
     jimmy.moveRight(); 
      if (x>6) {
         x = 1; 
      }
     image(runRight[x],jimmy.getPosition(),jimmyY);
      x++; 
    }

    // jimmy move left animation
    if (left) {
      if (x>6) {
         x = 1; 
      }
      jimmy.moveLeft(); 
      image(runLeft[x],jimmy.getPosition(),jimmyY);
      x++; 
    }
  }
}


//////////////////////////
//    Object Classes    //
// (Jimmy, Mike, Book) //
//////////////////////////

class MiniJimmy {
  int locationX;
  int speed;
  
  MiniJimmy() {
   locationX = 100; 
   speed = 50; 
  }
  
  void moveRight() {
    faceRight = true;
    locationX += speed;
    if (locationX > 2000) {
       locationX = 2000;
    }
  }
  
  void moveLeft() {
    faceRight = false;
    locationX -= speed;
    if (locationX < 50) {
       locationX = 50;
    }
  }
      
  int getPosition() {
     return locationX; 
  } 
}

class MonsterMike {
  int locationX;
  int locationY;
  int speed;
  
  MonsterMike() {
     locationX = 2050;
     locationY = 750;
     speed = 10;
  }
  
  void move() {
     locationX -= speed;
     image(walkMike[mike_count], locationX, locationY);
     mike_count++; 
  
    // reset walk animation at end of array
    if (mike_count > 5) {
      mike_count = 1; 
     }
  }
  
  int getPosition() {
   return locationX; 
  }
  
  void hit() {
   locationX = getPosition();
   image(idleMike, locationX, locationY);
  }
  
  void dead() {
    float mikeX = map(jimmy.getPosition(), -25, 2000, 2100, 0);
    image(deadMike, mikeX, locationY, 475, 475);
  }
}

class Book {
 int locationX;
 int locationY;
 int speed;
 boolean isUnloaded;
 
 Book() {
   locationX = -1000;
   locationY = 800;
   speed = 150;
   isUnloaded = false;
 }
  
 void throwBook(MiniJimmy jimmy) {
   if (!isUnloaded) {
     setLocation(jimmy);
     isUnloaded = true;
     books_left -= 1;
   }

   locationX += speed;
   image(bookThrow[b_count], locationX, locationY, 75, 75);
   b_count++;
   
   // reset book animation at end of array
   if (b_count >4) {
    b_count = 1; 
   }
 } 
 
 void setLocation(MiniJimmy jimmy) {
   locationX = jimmy.getPosition();
 }
 
 int getPosition() {
  return locationX; 
 }
}


//////////////////////////
// Key stroke functions //
//////////////////////////

void keyPressed() {
  if (keyCode == RIGHT) {
       right = true; 
    }
  if (keyCode == LEFT) {
       left = true; 
    }
  if (keyCode == ' ') {
       space = true; 
    }
  if (keyCode == 'S') {
    music.loop(); 
    startScreenShowing = false;
  }
}

void keyReleased() {
  if (keyCode == RIGHT) {
       right = false; 
    }
  if (keyCode == LEFT) {
       left = false; 
    }
  if (keyCode == ' ') {
        space = false; 
    }
  }