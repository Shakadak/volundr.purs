module Main where

import Prelude

import Data.Array (replicate)
import Data.Foldable (any)
import Data.Int (quot)
import Data.Maybe (Maybe(..))
import Data.String (joinWith, length)
import Data.String as Data.String
import Data.String.Utils (lines)
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
  { cursorPos :: Int
  , input :: String
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
  model { input = model.input <> s }

update Backspace model =
  model { input = Data.String.take (Data.String.length model.input - 1) model.input }

update Enter model =
  model { input = model.input <> "\n" }

update _ model =
  model

render :: Model -> String
render model =
  Term.clearLine <> "\r" <> model.input

draw :: Model -> Model -> Effect Unit
draw prev model = Term.write (prevCmd <> out)
  where
    prevOut = render prev
    prevRows = lines prevOut
    prevCmd  = joinWith "" $ mkCmd =<< prevRows
    out = render model
    rows = lines out
    -- banana = any ((_ > model.size.cols) <<< length) rows
    _cmd = joinWith "" $ mkCmd =<< rows
    mkCmd =
      (_ `replicate` (Term.clearLine <> Term.previousLine 1))
      <<< (_ `quot` model.size.cols)
      <<< (_ - 1)
      <<< length
      

cleanup :: Effect Unit
cleanup =
  -- Term.write (Term.showCursor <> Term.normalScreen)
    {- *> -} Term.setRawMode false

main :: Effect Unit
main = do
  size <- Term.getSize

  ref <- Ref.new
    { cursorPos: 0
    , input: ""
    , size
    }

  Term.emitKeyPressEvents
  Term.setRawMode true
  Term.resumeStdin

  -- draw =<< Ref.read ref

  _ <- Term.onResize \newSize ->
    Ref.modify_ (_ { size = newSize }) ref

  _ <- Term.onKeyPress \key -> do
    -- traceM $ "before decodeKey: " <> show key
    case decodeKey key of
      CtrlC -> do
        cleanup
        Term.exit 130 -- Ctrl-C exit code

      key -> do
        -- traceM key
        prevModel <- Ref.read ref
        draw prevModel =<< Ref.modify (update key) ref

  pure unit
