import { TUI, Text, Editor, ProcessTerminal, matchesKey } from "@earendil-works/pi-tui"

export { defaultEditorTheme } from '@local/pi-tui-theme-test'

export const processTerminalImpl = () => new ProcessTerminal()

export const tuiImpl = (terminal) => () => new TUI(terminal)

export const addChildImpl = (tui, child) => () => tui.addChild(child)

export const textImpl = (text) => () => new Text(text)

export const editorImpl = (tui, editorTheme) => () => new Editor(tui, editorTheme)

export const onSubmitImpl = (cmpnt, onSubmit) => () => {
  cmpnt.onSubmit = (data) => onSubmit(data)()
}

export const setFocusImpl = (tui, cmpnt) => () => tui.setFocus(cmpnt)

export const addInputListenerImpl = (tui, cb) => () => tui.addInputListener((data) => cb(data)())

export const matchesKeyImpl = matchesKey

export const stopImpl = (tui) => () => tui.stop()

export const exitImpl = (code) => () => process.exit(code)

export const startImpl = (tui) => () => tui.start()
