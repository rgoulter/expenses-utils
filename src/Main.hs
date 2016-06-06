module Main where

import System.Environment (getArgs)
import Text.CSV (printCSV)

import Text.Megaparsec
import Text.Megaparsec.String -- input stream is of type ‘String’

import ParseExpensesDoc



main :: IO ()
main = do
  args <- getArgs
  if length args == 2 then
    let [inputF, outputF] = args in
    process inputF outputF
  else
    putStrLn "Please run with <input.txt> <output.csv>"



process :: String -> String -> IO ()
process inputF outputF = do
  -- Parse the input file to list of [DateDir | ExpDir]
  result <- runParser (parseExpensesFile <* eof) inputF <$> readFile inputF

  case result of
    Left err ->
      putStrLn $ parseErrorPretty err
    Right directives ->
      let rows = recordsFromDirectives directives
          outp = printCSV rows
      in  writeFile outputF outp
