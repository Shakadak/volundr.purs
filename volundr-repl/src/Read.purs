module Read where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Node.ReadLine (Interface, close, prompt)

lineHandler :: Interface -> String -> Effect Unit
lineHandler interface "/exit" = do
  log "bye bye !"
  close interface 
lineHandler interface _ = do
  log "I didn't understand"
  prompt interface
