{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Main (main) where

import Options.Applicative.Simple
import qualified Paths_postfinance_freeagent
import RIO
import RIO.Process
import Run
import Types

main :: IO ()
main = do
  (options, ()) <-
    simpleOptions
      $(simpleVersion Paths_postfinance_freeagent.version)
      "Convert exports from PostFinance eFinance into FreeAgent's import format"
      "Given a CSV file exported from PostFinance's eFinance, this converts the file into a format that can be imported into FreeAgent's banking using the 'Upload statement' button in bank accounts."
      (Options <$> verboseInput <*> filenameInput)
      empty
  lo <- logOptionsHandle stderr (optionsVerbose options)
  pc <- mkDefaultProcessContext
  withLogFunc lo $ \lf ->
    let app =
          App
            { appLogFunc = lf,
              appProcessContext = pc,
              appOptions = options
            }
     in runRIO app run

verboseInput :: Parser Bool
verboseInput =
  switch
    ( long "verbose"
        <> short 'v'
        <> help "Verbose output?"
    )

filenameInput :: Parser String
filenameInput =
  strOption
    ( long "filename"
        <> short 'f'
        <> help "The CSV file exported from EFinance"
    )