module Data.Expenses.Types
  ( Entry(..)
  , Model
  , Money(..)
  , QueryAttribute(..)
  , SimpleTransaction(..)
  , entriesFromModel
  , modelFromEntries
  )
where

import qualified Data.Decimal                  as D



-- ~ 1234.12 CUR
data Money = Amount
  { moneyAmount   :: D.Decimal
  , moneyCurrency :: Maybe String
  , moneyIsApprox :: Bool
  } deriving (Show, Eq)



data Entry = Entry
  { entryDate       :: (Int, Int, Int)    -- (y,m,d)
  , entryPrice      :: (D.Decimal, String) -- (dlr,cents,cur)
  , entryRemark     :: String
  , entryComment    :: Maybe String
  } deriving (Show, Eq)



newtype Model = Model [Entry]



modelFromEntries :: [Entry] -> Model
modelFromEntries = Model



entriesFromModel :: Model -> [Entry]
entriesFromModel (Model entries) = entries



data QueryAttribute
  = Earliest
  | Latest
  deriving (Show, Eq)



data SimpleTransaction = SimpleTransaction
  { transactionDescription :: String
  , transactionAmount :: Money
  , transactionDebittedAccount :: String
  , transactionCredittedAccount :: String
  } deriving (Show, Eq)

instance Ord SimpleTransaction where
  compare SimpleTransaction { transactionDescription = a } SimpleTransaction { transactionDescription = b }
    = compare a b
