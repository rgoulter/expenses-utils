{-# LANGUAGE QuasiQuotes #-}

module TestExpenseDocParser where

import Data.List.NonEmpty (NonEmpty (..))
import Test.Hspec
import Test.Hspec.Megaparsec
import Text.Megaparsec
import Text.Megaparsec.String
import qualified Data.Set as E
import Text.Heredoc (here)

import ParseDateDirective as D
import ParseExpenseDirective as E
import ParseExpensesDoc as ED



goodExpensesDoc :: String
goodExpensesDoc = [here|
2016-01-01 MON
Spent 1 on stuff

TUE
Spent 2 on thing
|]



goodExpensesDocWithCmts :: String
goodExpensesDocWithCmts = [here|
# Comment
2016-01-01 MON
Spent 1 on stuff

# Comment
TUE
Spent 2 on thing
# Comment
|]



badExpensesDoc :: String
badExpensesDoc = [here|
2016-01-01 MON
Spent 1 on stuff
Sent 1.5 on stuff

TUE
Spent 2 on thing
|]



-- XXX do a couple of working examples,
-- XXX and, like. do some 'failed' examples, which prev. failed.
parseExpensesFileSpec :: Spec
parseExpensesFileSpec =
  describe "Parse Expenses File" $ do
    -- direction Spent/Rcv
    it "should parse well-formed doc" $ do
      parse docParser "" `shouldSucceedOn` goodExpensesDoc
      parse docParser "" `shouldSucceedOn` goodExpensesDocWithCmts
    it "should not parse malformed doc" $ do
      parse docParser "" `shouldFailOn` badExpensesDoc
  where
    docParser = ED.parseExpensesFile <* eof

