
let game;
let cellArray;

const importObject = {
  console: {
    log(arg) {
      console.log(arg);
    },
  },
};

async function setup() {
  const obj = await WebAssembly.instantiateStreaming(fetch("game_of_life.wasm"), importObject);
  game = obj.instance.exports;
  cellArray = new Uint32Array(game.mem.buffer, 0, game.arrayLength());
}

function initRandom() {
  const offset = 10;
  for (let x = offset; x < game.size() - offset; ++x) {
    for (let y = offset; y < game.size() - offset; ++y) {
      cellArray[game.indexUnsafe(x, y)] = Math.random() > 0.5 ? game.alive() : game.dead();
    }
  }
}

function render() {
  const canvas = document.getElementById("canvas-game-of-life");
  const ctx = canvas.getContext("2d");
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.fillStyle = "white";
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  ctx.fillStyle = "black";

  const width = canvas.width / game.size();
  const height = canvas.height / game.size();
  for (let x = 0; x < game.size(); ++x) {
    for (let y = 0; y < game.size(); ++y) {
      if (cellArray[game.indexUnsafe(x, y)] === game.alive()) {
        ctx.fillRect(x * width, y * height, width, height);
      }
    }
  }
}

const UPDATE_SEC = 0.5;

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function run() {
  initRandom();
  render();
  renderLoop();
}

function renderLoop() {
  sleep(1000 * UPDATE_SEC).then(() => {
    game.updateCells();
    render();
    renderLoop();
  });
}

setup().then(() => run());
