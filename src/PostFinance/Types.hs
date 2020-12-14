module PostFinance.Types (Entry (..)) where

import RIO
import RIO.Time (Day)

data Entry = Entry
  { date :: Day,
    credit :: Float,
    debit :: Float,
    details :: Text
  }
  deriving (Show)