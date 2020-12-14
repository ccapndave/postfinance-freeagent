{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module PostFinance.Parser (parser) where

import PostFinance.Types
import RIO hiding (many, try)
import qualified RIO.List as List
import qualified RIO.Text as T
import RIO.Time (Day)
import qualified RIO.Time as Time
import Text.Megaparsec
import Text.Megaparsec.Char hiding (newline)

type Parser = Parsec Void Text

parser :: Parser [Entry]
parser =
  do
    header <- rowParser `skipManyTill` headerParser
    entries <- entryParser header `manyTill` footerParser
    pure $ catMaybes entries

headerParser :: Parser [Text]
headerParser =
  do
    x <- try $ (string "Booking date" <|> string "Date") <* string ";"
    xs <- rowParser
    pure $ x : xs

rowParser :: Parser [Text]
rowParser =
  do
    row <- sepEndBy1 cellParser ";" <* newline
    pure $ T.pack <$> row
  where
    contentsParser :: Parser String
    contentsParser = many $ noneOf [';', '\n', '\r', '"']

    cellParser :: Parser String
    cellParser = between (single '"') (single '"') contentsParser <|> contentsParser

entryParser :: [Text] -> Parser (Maybe Entry)
entryParser header =
  let findEntry :: [Text] -> Text -> Maybe Text
      findEntry row headerName =
        (row !!) <$> List.elemIndex headerName header

      toDate :: Text -> Maybe Day
      toDate = T.unpack >>> Time.parseTimeM True Time.defaultTimeLocale "%Y-%m-%d"

      toFloat :: Text -> Maybe Float
      toFloat text =
        case T.unpack text of
          "" -> Just 0.0
          value -> readMaybe value <&> abs

      mkEntry :: [Text] -> Maybe Entry
      mkEntry row =
        Entry
          <$> ((findEntry row "Date" <|> findEntry row "Booking date") >>= toDate)
          <*> (findEntry row "Credit in CHF" >>= toFloat)
          <*> (findEntry row "Debit in CHF" >>= toFloat)
          <*> (findEntry row "Notification text" <|> findEntry row "Category")
   in do
        row <- rowParser
        case mkEntry row of
          Just Entry {details} | details == "Balance brought forward" -> pure Nothing
          Just Entry {credit, debit} | credit == 0 && debit == 0 -> pure Nothing
          Just entry -> pure $ Just entry
          Nothing -> fail "Unable to create this entry"

footerParser :: Parser ()
footerParser =
  newline
    *> string "Disclaimer:"
    *> takeRest
    *> eof

newline :: Parser Text
newline = string "\r\n" <|> string "\n"
