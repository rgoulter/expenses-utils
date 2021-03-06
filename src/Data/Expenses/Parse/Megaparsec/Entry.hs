module Data.Expenses.Parse.Megaparsec.Entry
  ( Entry(..)
  , entryFromExpense
  )
where

import           Data.Maybe                     ( fromMaybe )

import qualified Data.Expenses.Types           as E
import           Data.Expenses.Types            ( Entry(..) )
import qualified Data.Expenses.Parse.Megaparsec.Types
                                               as PE
import           Data.Expenses.Parse.Megaparsec.Types
                                                ( Direction(..)
                                                , Expense(..)
                                                )



entryFromExpense :: (Int, Int, Int) -> String -> Expense -> Entry
entryFromExpense (y, m, d) cur expense = Entry
  { entryDate    = (y, m, d)
  , entryPrice   = (value, cur')
  , entryRemark  = PE.expenseRemark expense
  , entryComment = PE.expenseComment expense
  }
 where
  amount = PE.expenseAmount expense

  mult   = case PE.expenseDirection expense of
    Spent    -> (1 *)
    Received -> ((-1) *)
  value = mult $ E.moneyAmount amount

  cur'  = fromMaybe cur (E.moneyCurrency amount)
