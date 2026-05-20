module Read where

import Prelude

import DynamicLoader (loadModuleAff)

import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Console (log, logShow)
import Node.ReadLine (Interface, close, prompt)

lineHandler :: String -> Interface -> String -> Aff Unit
lineHandler _ interface "/exit" = liftEffect do
  log "bye bye !"
  close interface 
lineHandler cwd interface "/module" = do
  mod <- loadModuleAff $ cwd <> "/module.js"
  liftEffect do
    logShow mod.v
    prompt interface
lineHandler _ interface _ = liftEffect do
  log "I didn't understand"
  prompt interface
