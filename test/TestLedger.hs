{-# LANGUAGE QuasiQuotes #-}

module TestLedger (ledgerSpec) where

import Test.Hspec (Spec, describe, it, shouldBe)

import Data.String.Interpolate (i)
import Data.String.Interpolate.Util (unindent)

import qualified Data.Text as T

import qualified Data.Time.Calendar as DT

import Hledger.Read (readJournal')

import qualified Data.Expenses.Expense as E
import qualified Data.Expenses.Ledger as L
import Data.Expenses.Types (Money(Amount), Entry(..), SimpleTransaction(..))



sampleEntry :: Entry
sampleEntry =
  Entry (2018, 01, 01) (fromIntegral 5, "SGD") "on McDonalds" Nothing



sampleTransaction :: String
sampleTransaction =
  unindent [i|
  # Spent 5 SGD on McDonalds
  2018-01-01 on McDonalds
    Undescribed  5.00 SGD
    Assets:Cash:SGD|]



sampleJournalWithTransactions :: String
sampleJournalWithTransactions =
  unindent [i|
  2018-01-01 on McDonalds
    Expenses:Food  5.0 SGD
    Assets:Cash:SGD

  2018-01-02 at Guardian
    Expenses:Toiletries  5.0 SGD
    Assets:Cash:SGD|]



entryWithComment :: Entry
entryWithComment =
  Entry (2018, 01, 01) (fromIntegral 5, "SGD") "on McDonalds" (Just "# comment")



transactionWithComment :: String
transactionWithComment =
  unindent [i|
  # Spent 5 SGD on McDonalds
  2018-01-01 on McDonalds
    Undescribed  5.00 SGD
    Assets:Cash:SGD
  # comment|]



entryWithMultilineComment :: Entry
entryWithMultilineComment =
  Entry (2018, 01, 01)
        (fromIntegral 5, "SGD")
        "on McDonalds"
        (Just "# comment1\n# comment2")



transactionWithMultilineComment :: String
transactionWithMultilineComment =
  unindent [i|
  # Spent 5 SGD on McDonalds
  2018-01-01 on McDonalds
    Undescribed  5.00 SGD
    Assets:Cash:SGD
  # comment1
  # comment2|]



ledgerSpec :: Spec
ledgerSpec =
  describe "Data.Expenses.Ledger" $ do
    describe "showCommaSeparatedNumber" $ do
      it "should show numbers with commas (e.g. 1000 -> 1,000)" $ do
        L.showCommaSeparatedNumber 1 `shouldBe` "1"
        L.showCommaSeparatedNumber 1000 `shouldBe` "1,000"
        L.showCommaSeparatedNumber 1234567 `shouldBe` "1,234,567"
    describe "showHumanReadableMoney" $
      describe "should output numbers in a human readable format (e.g. 5 SGD, 3.1m VND)" $ do
        let shouldShowAsHumanReadable input expectedOutput =
              let message = [i|should show #{input} as '#{expectedOutput}'"|]
              in it message $
                   L.showHumanReadableMoney input `shouldBe` expectedOutput
        (fromIntegral 5, "SGD") `shouldShowAsHumanReadable` "5 SGD"
        (fromRational 5.05, "SGD") `shouldShowAsHumanReadable` "5.05 SGD"
        (fromRational 1.25, "SGD") `shouldShowAsHumanReadable` "1.25 SGD"
        (fromRational 1.50, "SGD") `shouldShowAsHumanReadable` "1.50 SGD"
        (fromIntegral 2000, "SGD") `shouldShowAsHumanReadable` "2k SGD"
        (fromIntegral 65000, "VND") `shouldShowAsHumanReadable` "65k VND"
        (fromIntegral 10500, "VND") `shouldShowAsHumanReadable` "10.5k VND"
        (fromIntegral 10035, "VND") `shouldShowAsHumanReadable` "10,035 VND"
        (fromIntegral 3000000, "VND") `shouldShowAsHumanReadable` "3m VND"
        (fromIntegral 3100000, "VND") `shouldShowAsHumanReadable` "3.1m VND"
        (fromIntegral 3100005, "VND")
          `shouldShowAsHumanReadable`
            "3,100,005 VND"
    describe "showMoney" $ do
      let shouldShowAsMoney input expectedOutput =
            let message = [i|should show #{input} as '#{expectedOutput}'"|]
            in it message $ L.showMoney input `shouldBe` expectedOutput
      (fromIntegral 1, "SGD") `shouldShowAsMoney` "1.00 SGD"
      (fromRational 1.05, "SGD") `shouldShowAsMoney` "1.05 SGD"
      (fromRational 1.25, "SGD") `shouldShowAsMoney` "1.25 SGD"
      (fromIntegral 1000, "SGD") `shouldShowAsMoney` "1,000.00 SGD"
      (fromRational 1234567.89, "SGD") `shouldShowAsMoney` "1,234,567.89 SGD"
    describe "simpleTransactionsInJournal" $
      it "should get a SimpleTransaction from a sample ledger journal" $ do
        journal <- readJournal' $ T.pack $ unindent [i|
          2018/01/01 on McDonalds
            Expenses:Food  5.0 SGD
            Assets:Cash:SGD
          |]
        let actualTransactions = L.simpleTransactionsInJournal journal
        actualTransactions
          `shouldBe`
            [ SimpleTransaction "on McDonalds"
                                (Amount (fromIntegral 5) (Just "SGD") False)
                                "Expenses:Food"
                                "Assets:Cash:SGD"
            ]
    describe "showLedgerTransactionFromEntry" $ do
      it "should show a simple Ledger transaction for an Entry" $
        L.showLedgerTransactionFromEntry sampleEntry
          `shouldBe`
            sampleTransaction
      it "should show a simple Ledger transaction for an Entry with a comment" $
        L.showLedgerTransactionFromEntry entryWithComment
          `shouldBe`
            transactionWithComment
      it "should show a simple Ledger transaction for an Entry with a multiline comment" $
        L.showLedgerTransactionFromEntry entryWithMultilineComment
          `shouldBe`
            transactionWithMultilineComment

    describe "showLedgerJournalFromEntries" $ do
      it "should show a Ledger journal with multiple transactions" $ do
        let inputEntries =
              [ Entry (2018, 01, 01)
                      (fromIntegral 5, "SGD")
                      "on McDonalds"
                      Nothing
              , Entry (2018, 01, 03)
                      (fromIntegral 2000, "SGD")
                      "on new computer"
                      Nothing
              ]
            expectedJournal =
              unindent [i|
              # 2018-01-01 Monday
              # Spent 5 SGD on McDonalds
              2018-01-01 on McDonalds
                Undescribed  5.00 SGD
                Assets:Cash:SGD

              # 2018-01-03 Wednesday
              # Spent 2k SGD on new computer
              2018-01-03 on new computer
                Undescribed  2,000.00 SGD
                Assets:Cash:SGD
              |]
        L.showLedgerJournalFromEntries inputEntries `shouldBe` expectedJournal
