{-# LANGUAGE OverloadedStrings #-}

module PostFinance.Convert
  ( convert,
  )
where

import qualified Codec.Text.Detect as Detect
import qualified Data.Text.Encoding as TE
import qualified Data.Text.IO as TIO
import PostFinance.Builder
import PostFinance.Parser
import PostFinance.Types
import RIO
import qualified RIO.ByteString.Lazy as L
import qualified Text.Megaparsec as Megaparsec

convert :: String -> IO ()
convert filename =
  do
    fileData <- readAndDecodeFile filename
    case toEntries filename fileData of
      Right entries ->
        TIO.putStr $ build entries
      Left err ->
        putStrLn err

readAndDecodeFile :: String -> IO Text
readAndDecodeFile filename =
  do
    bs <- L.readFile filename
    case Detect.detectEncodingName bs of
      Just "windows-1252" ->
        pure $ TE.decodeLatin1 (L.toStrict bs)
      Just "ASCII" ->
        pure $ TE.decodeUtf8 (L.toStrict bs)
      Just "UTF-8" ->
        pure $ TE.decodeUtf8 (L.toStrict bs)
      Just encoding ->
        error $ "Unknown file encoding " <> encoding
      Nothing ->
        error "Can't detect file encoding"

toEntries :: String -> Text -> Either String [Entry]
toEntries filename text =
  Megaparsec.runParser parser filename text
    & first Megaparsec.errorBundlePretty
