module Term where

import Prelude
import Effect (Effect)

type Size =
  { rows :: Int
  , cols :: Int
  }

type KeyPress =
  { sequence :: String
  , name :: String
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
foreign import onKeyPress :: (KeyPress -> Effect Unit) -> Effect (Effect Unit)

clearScreen :: String
clearScreen = "\x1b[2J"

clearLine :: String
clearLine = "\x1b[2K"

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
