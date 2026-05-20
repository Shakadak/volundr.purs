module Main where

import Prelude

import Data.Either (either)
import Effect (Effect)
import Effect.Aff (Aff, runAff_)
import Effect.Console (logShow)
import Node.EventEmitter (on_)
import Node.Process (cwd)
import Node.ReadLine (createConsoleInterface, lineH, noCompletion, prompt, setPrompt)
import Read (lineHandler)

lineHandlerEffect :: Aff Unit -> Effect Unit
lineHandlerEffect handler =
  -- TODO: handle error and close appropriately.
  runAff_ (either logShow pure) handler

main :: Effect Unit
main = do
  cwd <- cwd
  interface <- createConsoleInterface noCompletion
  setPrompt "> " interface
  prompt interface
  interface # on_ lineH (lineHandlerEffect <<< lineHandler cwd interface)
