{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module PostFinance.Builder (build) where

import PostFinance.Types (Entry (..))
import RIO
import qualified RIO.Text as T
import qualified RIO.Time as Time

build :: [Entry] -> Text
build entries =
  entries <&> entryToRow & T.unlines

entryToRow :: Entry -> Text
entryToRow Entry {date, credit, debit, details} =
  T.intercalate
    ","
    [ T.pack $ Time.formatTime Time.defaultTimeLocale "%d/%m/%Y" date,
      T.pack $ show $ credit - debit,
      "\"" <> details <> "\""
    ]