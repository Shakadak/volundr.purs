export function loadJsModule(path) {
  // Minimal cache-busting.
  return () => import(`${path}#${Date.now()}`)
}
