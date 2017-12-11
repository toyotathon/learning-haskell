module Lib
    ( formatGrid
    , outputGrid
    , findWord
    , findWords
    , findWordInLine
    , getLines
    , skew
    , zipOverGrid
    , zipOverGridWith
    , gridWithCoords
    , cell2char
    , findWordInCellLinePrefix
    , Cell(Cell, Indent)
    , Game(Game)
    ) where
import Data.List (isInfixOf, transpose)
import Data.Maybe (catMaybes, listToMaybe)
import qualified Data.Map as M

data Game = Game (Grid Cell) (M.Map String (Maybe [Cell])) 

data Cell = Cell (Integer, Integer) Char 
          | Indent 
            deriving (Eq, Ord, Show) 

-- makeGame :: Grid Char -> 

type Grid a = [[a]]

zipOverGrid :: Grid a -> Grid b -> Grid(a,b)
zipOverGrid = zipWith zip

zipOverGridWith :: (a -> b -> c) -> Grid a -> Grid b -> Grid c
zipOverGridWith = zipWith . zipWith

mapOverGrid :: (a -> b) -> Grid a -> Grid b
mapOverGrid = map . map

coordsGrid :: Grid (Integer, Integer)
coordsGrid = 
 let rows = map repeat [0..]
     cols = repeat [0..]
 in zipOverGrid rows cols

gridWithCoords :: Grid Char -> Grid Cell
gridWithCoords grid = zipOverGridWith Cell coordsGrid grid

outputGrid :: Grid Cell -> IO ()
outputGrid grid = putStrLn (formatGrid grid)

formatGrid :: Grid Cell -> String
formatGrid =  unlines . mapOverGrid cell2char

cell2char :: Cell -> Char
cell2char (Cell _ c) = c 
cell2char Indent = '?'

getLines :: Grid Cell -> [[Cell]]
getLines grid = 
 let horizontal = grid 
     vertical = transpose grid 
     diagonal1 = diagonalize grid
     diagonal2 = diagonalize (map reverse grid)
     lines = horizontal ++ vertical ++ diagonal1 ++ diagonal2
 in lines ++ (map reverse lines) 

diagonalize :: Grid Cell -> Grid Cell
diagonalize = transpose . skew

skew :: Grid Cell-> Grid Cell
skew [] = []
skew (l:ls) = l : skew (map indent ls)
 where indent line = Indent : line

findWord :: Grid Cell -> String -> Maybe [Cell]
findWord grid word = 
 let lines = getLines grid
     foundWords = map (findWordInLine word) lines
 in listToMaybe (catMaybes foundWords)
-- let lines = getLines grid
--     found = or $ map (findWordInLine word) lines
-- in if found then Just word else Nothing

findWords :: Grid Cell -> [String] -> [[Cell]]
findWords grid words =
 let foundWords = map (findWord grid) words
 in catMaybes foundWords

findWordInLine :: String -> [Cell] -> Maybe [Cell]
findWordInLine _ [] = Nothing
findWordInLine word line = 
 let found = findWordInCellLinePrefix [] word line 
 in case found of 
  Nothing -> findWordInLine word (tail line)
  cs@(Just _) -> cs

findWordInCellLinePrefix :: [Cell] ->  String -> [Cell] -> Maybe [Cell]
findWordInCellLinePrefix acc (x:xs) (c:cs) | x == cell2char c  
 = findWordInCellLinePrefix (c:acc) xs cs
findWordInCellLinePrefix acc [] _ = Just $ reverse acc
findWordInCellLinePrefix _ _ _ = Nothing


