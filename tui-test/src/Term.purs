module Term where

import Prelude

import Data.Function.Uncurried (Fn2, runFn2)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Debug (class DebugWarning)
import Effect (Effect)

type Size =
  { rows :: Int
  , cols :: Int
  }

type Key =
  { sequence :: String
  , name :: Maybe String
  , ctrl :: Boolean
  , meta :: Boolean
  , shift :: Boolean
  }

type KeyImpl =
  { sequence :: String
  , name :: Nullable String
  , ctrl :: Boolean
  , meta :: Boolean
  , shift :: Boolean
  }

foreign import write :: String -> Effect Unit
foreign import setRawMode :: Boolean -> Effect Unit
foreign import resumeStdin :: Effect Unit
foreign import getSize :: Effect Size
foreign import onInput :: (String -> Effect Unit) -> Effect (Effect Unit)
foreign import onResize :: (Size -> Effect Unit) -> Effect (Effect Unit)
foreign import exit :: Int -> Effect Unit
foreign import emitKeyPressEvents :: Effect Unit
foreign import onKeyPressImpl :: (KeyImpl -> Effect Unit) -> Effect (Effect Unit)

onKeyPress :: (Key -> Effect Unit) -> Effect (Effect Unit)
onKeyPress cb = onKeyPressImpl $ (cb <<< modifyRecord)
  where
    modifyRecord :: KeyImpl -> Key
    modifyRecord r1 = r1 {name = toMaybe r1.name}

clearScreen :: String
clearScreen = "\x1b[2J"

clearLine :: String
clearLine = "\x1b[2K"

previousLine :: Int -> String
previousLine n = "\x1b[" <> show n <> "F"

home :: String
home = "\x1b[H"

hideCursor :: String
hideCursor = "\x1b[?25l"

showCursor :: String
showCursor = "\x1b[?25h"

alternateScreen :: String
alternateScreen = "\x1b[?1049h"

normalScreen :: String
normalScreen = "\x1b[?1049l"

resetStyle :: String
resetStyle = "\x1b[0m"

inverse :: String -> String
inverse s = "\x1b[7m" <> s <> resetStyle

-------------------------------------------------

foreign import traceLogImpl :: forall a b. Fn2 a (Unit -> b) b

traceLog :: forall a b. DebugWarning => a -> (Unit -> b) -> b
traceLog a k = runFn2 traceLogImpl a k

traceLogM :: forall m a. DebugWarning => Monad m => a -> m Unit
traceLogM s = do
  pure unit
  traceLog s \_ -> pure unit
