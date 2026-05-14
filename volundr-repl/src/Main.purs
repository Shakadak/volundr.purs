module Main where

import Prelude

import Effect (Effect)
import Node.EventEmitter (on_)
import Node.ReadLine (createConsoleInterface, lineH, noCompletion, prompt, setPrompt)
import Read (lineHandler)

main :: Effect Unit
main = do
  interface <- createConsoleInterface noCompletion
  setPrompt "> " interface
  prompt interface
  interface # on_ lineH (lineHandler interface)
