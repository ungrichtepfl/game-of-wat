const { readFileSync } = require("fs");

let wasm;
async function setup() {
  const buffer = readFileSync("./main.wasm");
  const wasm_module = await WebAssembly.compile(buffer);
  const instance = await WebAssembly.instantiate(wasm_module);
  wasm = instance.exports;
}

function run() {
  const cellArray = new Uint32Array(wasm.mem.buffer, 0, wasm.arrayLength());
  console.log(wasm.index(3, 5));
  console.log(wasm.setCell(3, 5, 10));
  console.log(wasm.getCell(3, 5));
  console.log(cellArray[wasm.index(3, 5)]);
}

setup().then(() => run());
