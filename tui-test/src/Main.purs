module Main where

import Prelude

import Data.Maybe (Maybe(..))
import Data.String as Data.String
import Debug (traceM)
import Effect (Effect)
import Effect.Ref as Ref
import Term as Term

data Key
  = Backspace
  | Up
  | Down
  | Left
  | Right
  | Enter
  | CtrlC
  | Unknown String

type Model =
  { selected :: Int
  , buffer :: String
  , size :: Term.Size
  }

decodeKey :: Term.Key -> Key
decodeKey {name: Just "backspace"} = Backspace
decodeKey {name: Just "up"} = Up
decodeKey {name: Just "down"} = Down
decodeKey {name: Just "left"} = Left
decodeKey {name: Just "right"} = Right
decodeKey {name: Just "return"} = Enter
decodeKey {sequence: "\x03"} = CtrlC
decodeKey s = Unknown s.sequence

-- clamp :: Int -> Int -> Int -> Int
-- clamp lo hi n = max lo (min hi n)

update :: Key -> Model -> Model

update (Unknown s) model = 
  model { buffer = model.buffer <> s }

update Backspace model =
  model { buffer = Data.String.take (Data.String.length model.buffer - 1) model.buffer }

update Enter model =
  model { buffer = model.buffer <> "\n" }

update _ model =
  model

render :: Model -> String
render model =
  "\r"
    <> model.buffer

draw :: Model -> Effect Unit
draw model =
  Term.write (render model)

cleanup :: Effect Unit
cleanup =
  -- Term.write (Term.showCursor <> Term.normalScreen)
    {- *> -} Term.setRawMode false

main :: Effect Unit
main = do
  size <- Term.getSize

  ref <- Ref.new
    { selected: 0
    , buffer: ""
    , size
    }

  -- Term.write (Term.alternateScreen <> Term.hideCursor)
  -- traceM "before emitKeyPressEvents"
  Term.emitKeyPressEvents
  Term.setRawMode true
  Term.resumeStdin

  draw =<< Ref.read ref

  _ <- Term.onResize \newSize -> do
    Ref.modify_ (_ { size = newSize }) ref
    draw =<< Ref.read ref

  -- pos <- Term.cursorPos
  -- traceM pos
  _ <- Term.onKeyPress \key -> do
    pos <- Term.cursorPos
    traceM pos
    -- traceM $ "before decodeKey: " <> show key
    case decodeKey key of
      CtrlC -> do
        cleanup
        Term.exit 130 -- Ctrl-C exit code

      key -> do
        -- traceM key
        Ref.modify_ (update key) ref
        draw =<< Ref.read ref

  pure unit
