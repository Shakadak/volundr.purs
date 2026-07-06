module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import PiTui (matchesKey)
import PiTui as PiTui

main :: Effect Unit
main = do
  terminal <- PiTui.processTerminal
  tui <- PiTui.tui terminal
  PiTui.addChild tui =<< PiTui.text "Welcome to my app!"
  editor <- PiTui.editor tui PiTui.defaultEditorTheme
  PiTui.onSubmit editor \text -> do
    log text
    PiTui.addChild tui =<< PiTui.text ("You said: " <> text)

  PiTui.addChild tui editor

  PiTui.setFocus tui editor

  PiTui.addInputListener tui \data' ->
    when (matchesKey data' "ctrl+c") do
      PiTui.stop tui
      PiTui.exit 130

  PiTui.start tui
