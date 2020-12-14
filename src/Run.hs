{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Run
  ( run,
  )
where

import qualified PostFinance.Convert as Convert
import RIO
import Types

run :: RIO App ()
run = do
  App {appOptions = Options {optionsFilename}} <- ask
  liftIO $ Convert.convert optionsFilename
