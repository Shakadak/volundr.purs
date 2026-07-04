module Main where

import Prelude

import Data.Array (replicate)
import Data.Foldable (class Foldable, intercalate, sum)
import Data.Int (quot)
import Data.Maybe (Maybe(..))
import Data.String (length, splitAt)
import Data.String as Data.String
import Data.String.Utils (lines)
import Effect (Effect)
import Effect.Ref as Ref
import Term as Term

data Key
  = AltBackspace
  | AltDelete
  | Backspace
  | CtrlC
  | Delete
  | Down
  | Enter
  | Ignore String
  | Left
  | PasteEnd
  | PasteStart
  | Return
  | Right
  | Up
  | Unknown String

data PasteState = Normal | Pasting

type Model =
  { cursorPos :: Int
  , input :: String
  , pasteState :: PasteState
  , size :: Term.Size
  }

decodeKey :: Term.Key -> Key
decodeKey {meta: true, name: Just "backspace"} = AltBackspace
decodeKey {meta: true, name: Just "delete"} = AltDelete
decodeKey {name: Just "backspace"} = Backspace
decodeKey {name: Just "delete"} = Delete
decodeKey {name: Just "down"} = Down
decodeKey {name: Just "enter"} = Enter
decodeKey {name: Just "left"} = Left
decodeKey {name: Just "paste-end"} = PasteEnd
decodeKey {name: Just "paste-start"} = PasteStart
decodeKey {name: Just "return"} = Return
decodeKey {name: Just "right"} = Right
decodeKey {name: Just "up"} = Up
decodeKey {sequence: "\x03"} = CtrlC
decodeKey {ctrl: true, sequence} = Ignore sequence
decodeKey {meta: true, sequence} = Ignore sequence
decodeKey s = Unknown s.sequence

update :: Key -> Model -> Model

update PasteStart model =
  model { pasteState = Pasting }

update PasteEnd model =
  model { pasteState = Normal }

update (Unknown s) model = 
  model { input = model.input <> s }

update Backspace model =
  model { input = Data.String.take (Data.String.length model.input - 1) model.input }

update Return model@{pasteState: Pasting} =
  model { input = model.input <> "\r" }

update Enter model =
  model { input = model.input <> "\n" }

update _ model =
  model

unlines :: forall f. Foldable f => f String -> String
unlines = intercalate "\n"

chunkEvery :: Int -> String -> Array String
chunkEvery n = go
  where
    go str = case splitAt n str of
      {before, after: ""} -> [before]
      {before, after} -> [before] <> go after

render :: Model -> String
render model = unlines $ chunkEvery model.size.cols =<< lines model.input

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
    countOverflow cols line = (length line - 1) `quot` cols + 1 

init :: Effect Unit
init = do
  Term.setRawMode true
  Term.setBracketedPaste true

cleanup :: Effect Unit
cleanup = do
  Term.setBracketedPaste false
  Term.setRawMode false

main :: Effect Unit
main = do
  size <- Term.getSize

  ref <- Ref.new
    { cursorPos: 0
    , input: ""
    , pasteState: Normal
    , size
    }

  init
  Term.emitKeyPressEvents
  Term.resumeStdin

  -- draw =<< Ref.read ref

  _ <- Term.onResize \newSize -> do
    model <- Ref.modify (_ { size = newSize }) ref
    Term.traceLogM model
    draw model model

  _ <- Term.onKeyPress \key -> do
    Term.traceLogM $ "before decodeKey: " <> show key
    case decodeKey key of
      CtrlC -> do
        cleanup
        Term.exit 130 -- Ctrl-C exit code

      key' -> do
        Term.traceLogM key'
        prevModel <- Ref.read ref
        draw prevModel =<< Ref.modify (update key') ref

  pure unit
