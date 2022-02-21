
// Mini Jimmy by Aliyah Owens
// 1 level with parallax
// move using arrow keys
// space bar to throw a book
// defeat the bully

//////////////////////////
//    Object Classes    //
// (Jimmy, Mike, Book) //
//////////////////////////

class MiniJimmy {
  constructor() {
   this.locationX = 100; 
   this.speed = 50; 
  }
  
  moveRight() {
    faceRight = true;
    this.locationX += this.speed;
    if (this.locationX > 2000) {
       this.locationX = 2000;
    }
  }
  
   moveLeft() {
    faceRight = false;
    this.locationX -= this.speed;
    if (this.locationX < 50) {
       this.locationX = 50;
    }
  }
      
  getPosition() {
     return this.locationX; 
  } 
}

class MonsterMike {
  constructor() {
     this.locationX = 2050;
     this.locationY = 750;
     this.speed = 10;
  }
  
  move() {
     this.locationX -= this.speed;
     image(walkMike[mike_count], this.locationX, this.locationY);
     mike_count++; 
  
    // reset walk animation at end of array
    if (mike_count > 5) {
      mike_count = 1; 
     }
  }
  
  getPosition() {
   return this.locationX; 
  }
  
  hit() {
   this.locationX = this.getPosition();
   image(idleMike, this.locationX, this.locationY);
  }
  
  dead() {
    var mikeX = map(jimmy.getPosition(), -25, 2000, 2100, 0);
    image(deadMike, mikeX, this.locationY, 475, 475);
  }
}

class Book {
 constructor() {
   this.locationX = -1000;
   this.locationY = 800;
   this.speed = 150;
   this.isUnloaded = false;
 }
  
 throwBook(jimmy) {
   if (!this.isUnloaded) {
     this.setLocation(jimmy);
     this.isUnloaded = true;
     books_left -= 1;
   }

   this.locationX += this.speed;
   image(bookThrow[b_count], this.locationX, this.locationY, 75, 75);
   b_count++;
   
   // reset book animation at end of array
   if (b_count >4) {
    b_count = 1; 
   }
 } 
 
 setLocation(jimmy) {
   this.locationX = jimmy.getPosition();
 }
 
 getPosition() {
  return this.locationX; 
 }
}


var faceRight = true;
var book_num = 0;          // counter for array of books being thrown
var x = 1;                 // counter for Jimmy animations
var b_count = 1;           // counter for book animations
var mike_count = 1;        // counter for mike walk animations
var jimmyY = 800;          // jimmy Y position
var pause_count = 0;       // counter for pause animation when Mike is hit


// image arrays for animation
var runLeft = new Array(7);
var runRight = new Array(7);
var walkMike = new Array(6);
var bookThrow = new Array(5);

// single images
let idleRight;
let idleLeft;
let hallway;
let startScreen;
let idleMike;
let deadMike;

var isThrowing = new Array(10);
var right, left, space = false;
var gameLossSoundPlayed, gameWonSoundPlayed = false;

let jimmy = new MiniJimmy();
let mike = new MonsterMike();
var books = new Array(5);           // array for all books

//sound files
let wisp, music, hit, lose, victory;

// game trackers
var bully_life = 100;
var books_left = books.length;
var startScreenShowing = true;
var gameOverWin, gameOverLoss = false;

function preload() {
	// load sounds
  hit = loadSound("bark.wav");
  wisp = loadSound("throw.wav");
  music = loadSound("music.wav");
  lose = loadSound("lose.wav");
  victory = loadSound("victory.wav");
  
  // load animation images
  for(var i=1; i<7; i++) {
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
}

function setup() {
  createCanvas(2000,1000);
  smooth();
  frameRate(10);
  
  // generate books (out of view)
  for (let i=0; i<books.length; i++) { 
    books[i] = new Book();
  }
  
  // set motion to false for all books
  for (let i=0; i<isThrowing.length; i++) {
   isThrowing[i] = false; 
  }
}

function draw() {
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
    background('#000000');
    fill('#FFFFFF');
    textAlign(CENTER);
    textSize(100);
    text("YOU LOST", 1000, 500);
  }
  
  //game over state winner
  else if (gameOverWin) {
    background('#AFE0B2');
    fill('#FFFFFF');
    textAlign(CENTER);
    textSize(100);
    text("YOU WON", 1000, 500);
    
  } else {
      // draw background
      var hallwayx = map(jimmy.getPosition(), -25, 2000, 2100, 0);
      image(hallway, hallwayx, 500, 4000, 1000);

      // HUD
      //
      // books left
      for (var i=0; i<books_left; i++) {
        image(bookThrow[1], i*50 + 100, 120, 50, 50);
      }
      
      // Mike life bar
      fill(0,0,0);
      rect(1495, 75, 310, 60);
      fill('#1C75BC');
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
    if (!right && !left) {
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
// Key stroke functions //
//////////////////////////

function keyPressed() {
  if (keyCode === RIGHT_ARROW) {
       right = true; 
    }
  if (keyCode === LEFT_ARROW) {
       left = true; 
    }
  if (keyCode === 32) {
       space = true; 
    }
  if (keyCode == 83) {
    music.loop(); 
    startScreenShowing = false;
  }
}

function keyReleased() {
  if (keyCode === RIGHT_ARROW) {
       right = false; 
    }
  if (keyCode === LEFT_ARROW) {
       left = false; 
    }
  if (keyCode === 32) {
        space = false; 
    }
  }
