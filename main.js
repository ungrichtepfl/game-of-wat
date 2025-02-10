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
  console.log(wasm.setCell(2, 2, wasm.alive()));
  console.log(wasm.setCell(2, 1, wasm.alive()));
  console.log(wasm.setCell(2, 0, wasm.alive()));
  console.log(wasm.setCell(1, 2, wasm.alive()));
  console.log(wasm.setCell(1, 0, wasm.alive()));
  console.log(wasm.setCell(0, 2, wasm.alive()));
  console.log(wasm.setCell(0, 1, wasm.alive()));
  console.log(wasm.setCell(0, 0, wasm.alive()));
  console.log(wasm.test(1, 1));

}

setup().then(() => run());
