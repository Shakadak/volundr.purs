export function loadJsModule(path) {
  return () => import(path)
}
