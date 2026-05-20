module DynamicLoader where

import Effect.Aff (Aff)
import Prelude ((<<<))

import Effect (Effect)
import Promise (Promise)
import Promise.Aff (toAffE)

type Module =
  { v :: Int
  }

foreign import loadJsModule :: String -> Effect (Promise Module)

loadModuleAff :: String -> Aff Module
loadModuleAff = toAffE <<< loadJsModule
