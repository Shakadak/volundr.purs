module Main where

import Prelude

import Data.Array (replicate)
import Data.Foldable (intercalate, sum)
import Data.Int (quot)
import Data.Maybe (Maybe(..))
import Data.String (length)
import Data.String as Data.String
import Data.String.Utils (lines)
import Effect (Effect)
import Effect.Ref as Ref
import Term (traceLogM)
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
  model.input

draw :: Model -> Model -> Effect Unit
draw prev model = Term.write (cleanUp <> out)
  where
    prevExpectedLines = sum $ map (countOverflow model.size.cols) $ lines prevOut
    cleanUp =
      intercalate (Term.previousLine 1)
      $ replicate prevExpectedLines ("\r" <> Term.clearLine)

    _expectedLines = sum $ map (countOverflow model.size.cols) $ lines out
    prevOut = render prev
    out = render model
    countOverflow cols =
      (_ + 1)
      <<< (_ `quot` cols)
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

  _ <- Term.onResize \newSize -> do
    model <- Ref.modify (_ { size = newSize }) ref
    traceLogM model
    draw model model

  _ <- Term.onKeyPress \key -> do
    traceLogM $ "before decodeKey: " <> show key
    case decodeKey key of
      CtrlC -> do
        cleanup
        Term.exit 130 -- Ctrl-C exit code

      key -> do
        traceLogM key
        prevModel <- Ref.read ref
        draw prevModel =<< Ref.modify (update key) ref

  pure unit
