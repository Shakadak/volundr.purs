module Read where

import Prelude

import Data.Argonaut.Parser (jsonParser)
import Data.Bifunctor (lmap)
import Data.Codec.Argonaut (JsonCodec, array, decode, string)
import Data.Codec.Argonaut.Record as CAR
import Data.Either (either)
import DynamicLoader (loadModuleAff)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Console (log, logShow)
import Fetch (fetch)
import Node.ReadLine (Interface, close, prompt)

affLog :: String -> Aff Unit
affLog = liftEffect <<< log

affPrompt :: Interface -> Aff Unit
affPrompt = liftEffect <<< prompt

codecResponse :: JsonCodec { object :: String, data :: Array { id :: String }}
codecResponse = CAR.object "model response"
  {
    object: string,
    data: array (CAR.object "Model" {id: string})
  }

queryModels :: Aff Unit
queryModels = do
  res <- fetch "http://localhost:8080/v1/models" {}
  txt <- res.text
  affLog $ either identity (show <<< (_.data)) $ (lmap show <<< decode codecResponse) =<< jsonParser txt

data Loop = Continue | Stop

lineHandler :: String -> Interface -> String -> Aff Unit
lineHandler _ interface "/exit" = liftEffect do
  log "bye bye !"
  close interface 
lineHandler cwd interface "/module" = do
  mod <- loadModuleAff $ cwd <> "/module.js"
  liftEffect do
    logShow mod.v
    prompt interface
lineHandler _ interface "/models" = do
  queryModels
  affPrompt interface
lineHandler _ interface _ = liftEffect do
  log "I didn't understand"
  prompt interface
