import readline from "node:readline"

export const write = s => () => {
  process.stdout.write(s);
};

export const setRawMode = enabled => () => {
  if (process.stdin.isTTY && process.stdin.setRawMode) {
    process.stdin.setRawMode(enabled);
  }
};

export const resumeStdin = () => {
  process.stdin.resume();
};

export const getSize = () => ({
  rows: process.stdout.rows || 24,
  cols: process.stdout.columns || 80
});

export const onInput = handler => () => {
  const h = buf => handler(buf.toString("utf8"))();
  process.stdin.on("data", h);
  return () => process.stdin.off("data", h);
};

export const onResize = handler => () => {
  const h = () => handler({
    rows: process.stdout.rows || 24,
    cols: process.stdout.columns || 80
  })();

  process.stdout.on("resize", h);
  return () => process.stdout.off("resize", h);
};

export const exit = code => () => {
  process.exit(code);
};

export const emitKeyPressEvents = () => {
  readline.emitKeypressEvents(process.stdin)
}

export const onKeyPressImpl = handler => () => {
  // process.stdin.on("keypress", console.log)
  const h = (_str, key) => handler(key)()
  process.stdin.on("keypress", h)
  return () => process.stdin.off("keypress", handler)
}

const rl = readline.createInterface(process.stdin)
export const cursorPos = () => {
  return rl.getCursorPos()
}
