// Dress Up Game — Web version
// Controls:
//   T = switch to tops mode
//   B = switch to bottoms mode
//   Left Arrow = previous item
//   Right Arrow = next item
//   Click anywhere = play music

// music
let music;
let musicWindow;

// images
let backImg;
let windowImg;
let avatarImg;
let titleImg;

let tops = [];
let bottoms = [];

let topIndex = 0;
let bottomIndex = 0;

let mode = "tops";

let uiScale = 0.8;

function preload() {
  backImg = loadImage("back.jpeg");
  windowImg = loadImage("window.jpeg");
  avatarImg = loadImage("avatar.png");
  titleImg = loadImage("title.png");
  music = loadSound("GB Zelda.m4a");
  musicWindow = loadImage("playmusic.png");

  tops[0] = loadImage("top1.png");
  tops[1] = loadImage("top2.png");
  tops[2] = loadImage("top3.png");

  bottoms[0] = loadImage("bot1.png");
  bottoms[1] = loadImage("bot2.png");
  bottoms[2] = loadImage("bot3.png");
}

function setup() {
  createCanvas(windowWidth, windowHeight);
}

function draw() {
  background(255);

  push();
  scale(uiScale);

  // desktop background
  image(backImg, 0, 0, width / uiScale, height / uiScale);

  // center window
  let winW = 600;
  let winH = 450;
  let winX = width / (2 * uiScale) - winW / 2 - 20;
  let winY = height / (2 * uiScale) - winH / 2 + 50;

  image(windowImg, winX, winY, winW, winH);

  // avatar size
  let avatarW = 360;
  let avatarH = avatarW * (avatarImg.height / avatarImg.width);

  let avatarX = winX + winW / 2 - avatarW / 2 + 30;
  let avatarY = winY + 40;

  image(avatarImg, avatarX, avatarY, avatarW, avatarH);

  // clothing worn
  image(tops[topIndex], avatarX, avatarY, avatarW, avatarH);
  image(bottoms[bottomIndex], avatarX, avatarY, avatarW, avatarH);

  // carousel sizes
  let previewW = avatarW * 0.6;
  let previewH = avatarH * 0.6;
  let previewY = avatarY + (avatarH - previewH) / 2;

  // carousel
  let overlap = 150;

  if (mode == "tops") {
    let prev = (topIndex - 1 + tops.length) % tops.length;
    let next = (topIndex + 1) % tops.length;

    let leftX = avatarX - previewW + overlap;
    let rightX = avatarX + avatarW - overlap;

    image(tops[prev], leftX, previewY, previewW, previewH);
    image(tops[next], rightX, previewY, previewW, previewH);
  }

  if (mode == "bottoms") {
    let prev = (bottomIndex - 1 + bottoms.length) % bottoms.length;
    let next = (bottomIndex + 1) % bottoms.length;

    let leftX = avatarX - previewW + overlap;
    let rightX = avatarX + avatarW - overlap;

    image(bottoms[prev], leftX, previewY, previewW, previewH);
    image(bottoms[next], rightX, previewY, previewW, previewH);
  }

  pop();

  // title window
  let titleX = width - titleImg.width - 20;
  let titleY = 20;
  image(titleImg, titleX, titleY);

  // music window
  let musicScale = 0.2;
  let musicW = musicWindow.width * musicScale;
  let musicH = musicWindow.height * musicScale;
  let musicX = width - musicW - 90;
  let musicY = height - musicH - 50;
  image(musicWindow, musicX, musicY, musicW, musicH);
}

// --- Keyboard controls (replaces Arduino serial) ---
function keyPressed() {
  // Switch mode
  if (key === "t" || key === "T") {
    mode = "tops";
  }
  if (key === "b" || key === "B") {
    mode = "bottoms";
  }

  // Cycle through items
  if (keyCode === LEFT_ARROW) {
    if (mode === "tops") {
      topIndex = (topIndex - 1 + tops.length) % tops.length;
    } else {
      bottomIndex = (bottomIndex - 1 + bottoms.length) % bottoms.length;
    }
  }

  if (keyCode === RIGHT_ARROW) {
    if (mode === "tops") {
      topIndex = (topIndex + 1) % tops.length;
    } else {
      bottomIndex = (bottomIndex + 1) % bottoms.length;
    }
  }
}

// Click to play music
function mousePressed() {
  if (!music.isPlaying()) {
    music.loop();
  }
}
