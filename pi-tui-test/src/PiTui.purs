module PiTui
  ( Component
  , EditorTheme
  , ProcessTerminal
  , Tui
  , processTerminal
  , tui
  , addChild
  , text
  , editor
  , onSubmit
  , setFocus
  , addInputListener
  , matchesKey
  , stop
  , start
  , exit
  , defaultEditorTheme
  ) where

import Data.Function.Uncurried (Fn2, runFn2)
import Data.Unit (Unit)
import Effect (Effect)

foreign import data ProcessTerminal :: Type
foreign import data Tui :: Type
foreign import data Component :: Type
foreign import data EditorTheme :: Type

foreign import processTerminalImpl :: Effect ProcessTerminal
processTerminal :: Effect ProcessTerminal
processTerminal = processTerminalImpl

foreign import tuiImpl :: ProcessTerminal -> Effect Tui
tui :: ProcessTerminal -> Effect Tui
tui terminal = tuiImpl terminal

foreign import addChildImpl :: Fn2 Tui Component (Effect Unit)
addChild :: Tui -> Component -> Effect Unit
addChild tuiInstance component = runFn2 addChildImpl tuiInstance component

foreign import textImpl :: String -> Effect Component
text :: String -> Effect Component
text txt = textImpl txt

foreign import editorImpl :: Fn2 Tui EditorTheme (Effect Component)
editor :: Tui -> EditorTheme -> Effect Component
editor tuiInstance editorTheme = runFn2 editorImpl tuiInstance editorTheme

foreign import onSubmitImpl :: Fn2 Component (String -> Effect Unit) (Effect Unit)
onSubmit :: Component -> (String -> Effect Unit) -> Effect Unit
onSubmit cmpnt cb = runFn2 onSubmitImpl cmpnt cb

foreign import setFocusImpl :: Fn2 Tui Component (Effect Unit)
setFocus :: Tui -> Component -> Effect Unit
setFocus tuiInstance component = runFn2 setFocusImpl tuiInstance component

foreign import addInputListenerImpl :: Fn2 Tui (String -> Effect Unit) (Effect (Effect Unit))
-- | Returns the action needed to remove the callback from the listeners.
addInputListener :: Tui -> (String -> Effect Unit) -> Effect (Effect Unit)
addInputListener tuiInstance cb = runFn2 addInputListenerImpl tuiInstance cb

foreign import matchesKeyImpl :: Fn2 String String Boolean
matchesKey :: String -> String -> Boolean
matchesKey data' keyId = runFn2 matchesKeyImpl data' keyId

foreign import stopImpl :: Tui -> Effect Unit
stop :: Tui -> Effect Unit
stop tuiInstance = stopImpl tuiInstance

foreign import exitImpl :: Int -> Effect Unit
exit :: Int -> Effect Unit
exit code = exitImpl code

foreign import startImpl :: Tui -> Effect Unit
start :: Tui -> Effect Unit
start tuiInstance = startImpl tuiInstance

foreign import defaultEditorTheme :: EditorTheme
