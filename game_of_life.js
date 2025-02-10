
let wasm;
let cellArray;

const importObject = {
  console: {
    log(arg) {
      console.log(arg);
    },
  },
};

async function setup() {
  const response = await fetch("game_of_life.wasm");
  const buffer = await response.arrayBuffer();
  const wasm_module = await WebAssembly.compile(buffer);
  const instance = await WebAssembly.instantiate(wasm_module, importObject);
  wasm = instance.exports;
  cellArray = new Uint32Array(wasm.mem.buffer, 0, wasm.arrayLength());
}

function initRandom() {
  for (let x = 0; x < wasm.size() - 30; ++x) {
    for (let y = 0; y < wasm.size() - 30; ++y) {
      cellArray[wasm.indexUnsafe(x, y)] = Math.random() > 0.5 ? wasm.alive() : wasm.dead();
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

  const width = canvas.width / wasm.size();
  const height = canvas.height / wasm.size();
  for (let x = 0; x < wasm.size(); ++x) {
    for (let y = 0; y < wasm.size(); ++y) {
      if (cellArray[wasm.indexUnsafe(x, y)] === wasm.alive()) {
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
    wasm.updateCells();
    render();
    renderLoop();
  });
}

setup().then(() => run());
