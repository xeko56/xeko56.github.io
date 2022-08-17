> module Sudoku where
> import Data.Char
> import Data.List

> type Sudoku a = [[a]]

SudokuPuzzle = Sudoku Options = [[[Int]]] 

> type Options= [Int]
> type SudokuPuzzle = Sudoku Options


> unsovable :: SudokuPuzzle -> Bool
> unsovable = or.map (elem []) 


> sc4 =
>    "....6..8.\n\
>    \.2.......\n\
>    \..1......\n\
>    \.7....1.2\n\
>    \5...3....\n\
>    \......4..\n\
>    \..42.1...\n\
>    \3..7..6..\n\
>    \.......5." 


> split :: Eq a => a -> [a] -> [[a]]
> split d [] = []
> split d s = x : split d (drop 1 y) where (x,y) = span (/= d) s


> sudokuConvert :: Char -> Options
> sudokuConvert c
>   | (fromIntegral dec::Word) <= 9 = [dec]
>   | c == '\\' || c == 'n' = []
>   | otherwise = [1..9]
>   where 
>     dec = ord c - ord '0'


> readSudoku :: String -> SudokuPuzzle
> readSudoku xs = ls
>   where
>     ls = map (map sudokuConvert) $lines $filter (not . (`elem` "\\")) xs 

> {- readSudoku :: String -> SudokuPuzzle
> readSudoku xs = [eval r | r <- words xs]
>    where
>        eval r = [if c == '.' then [1..9] else [digitToInt c] | c <- r] -}


> printSudoku :: (Show a) => [a] -> String
> printSudoku [] = ""
> printSudoku [x] = "|" ++ (show x)
> printSudoku (x:xs) = "|" ++ (show x) ++ printSudoku xs


> toLaTeX :: SudokuPuzzle -> String
> toLaTeX xss = "\\begin{sudoku} " ++ (intercalate "" $ foldl (++) [] c) ++ " \\end{sudoku}"
>   where
>     b = map (map (\x -> if length x > 1 then "| " else printSudoku x) ) xss
>     c = [x ++ ["|. "] | x <- b] 


> columns, rows :: Sudoku a -> Sudoku a
> rows    = id
> columns = transpose


> groupBy3 :: [a] -> [[a]]
> groupBy3 []         = [] 
> groupBy3 (a:b:c:ds) = [a,b,c] : groupBy3 ds


> groupBy9 :: [a] -> [[a]]
> groupBy9 (a:b:c:d:e:f:g:h:i:ds) = [a,b,c,d,e,f,g,h,i] : groupBy9 ds
> groupBy9 []         = []


> cols :: Sudoku a -> Sudoku a
> cols [xs] = [[x] | x <- xs]
> cols (xs:xss) = zipWith (:) xs (cols xss)


> groupB3 :: [a] -> [[a]]
> groupB3 [] = []
> groupB3 xs = take 3 xs : groupB3 (drop 3 xs)


> ungroup :: [[a]] -> [a]
> ungroup = concat


> boxes :: Sudoku a -> Sudoku a
> boxes = map ungroup . ungroup . map cols . groupB3 . map groupB3


> correct:: Eq a => [a]->Bool
> correct xs = 9 == length (nub xs)


> solved xss = okay (rows xss) && okay (columns xss) && okay (boxes xss)
>  where okay = and.(map correct)


> removeFromList :: Eq a => [a] -> [a] -> [a]
> removeFromList toRemove list = filter (\element -> shouldBeKept element) list
>   where
>     shouldBeKept element = element `notElem` toRemove


> limitLine:: [Options] -> [Options]
> limitLine lss = map (\ls -> if length ls == 1 && (ls `elem` zss) then [] else ls) yss
>   where 
>     ys = concat (filter (\ls -> length ls == 1) lss)
>     yss = [if length ls > 1 then filter (`notElem` ys) ls else ls | ls <- lss]
>     zss = yss \\ nub yss 


> limitation :: SudokuPuzzle -> SudokuPuzzle 
> limitation
>  = columns.boxes
>     .map limitLine.boxes
>     .map limitLine.columns
>     .map limitLine.rows


> versions :: SudokuPuzzle -> Integer
> versions = (product.map (toInteger.length).concat)


> limitations lls
>   |versions lls' == versions lls = lls
>   |otherwise = limitations lls'
>     where
>       lls' = limitation lls


> sc3 =
>    ".26...81.\n\
>    \3..7.8..6\n\
>    \4...5...7\n\
>    \.5.1.7.9.\n\
>    \..39.51..\n\
>    \.4.3.2.5.\n\
>    \1...3...2\n\
>    \5..2.4..9\n\
>    \.38...46."


> single :: [a] -> Bool
> single [_] = True
> single _ = False


> firstFillings :: SudokuPuzzle -> [SudokuPuzzle]
> firstFillings [] = []
> firstFillings rows = [rows1 ++ [row1 ++ [c]:row2] ++ rows2 | c <- cs]
>   where
>     (rows1, row:rows2) = break (any (not . single)) rows
>     (row1, cs:row2) = break (not . single) row 


> solve xs
>   |vs==0 = []
>   |vs==1 && solved lxs = [lxs]
>   |otherwise = concat$map solve$firstFillings lxs
>     where
>       lxs = limitations xs
>       vs = versions lxs


> sc2 =
>    "8156....4\n\
>    \6...75.8.\n\
>    \....9....\n\
>    \9...417..\n\
>    \.4.....2.\n\
>    \..623...8\n\
>    \....5....\n\
>    \.5.91...6\n\ 
>    \1....7895";


> sc5 =
>    ".5..6...1\n\
>    \..48...7.\n\
>    \8......52\n\
>    \2...57.3.\n\
>    \.........\n\
>    \.3.69...5\n\
>    \79......8\n\
>    \.1...65..\n\
>    \5...3..6."


> sctest =
>    "..74916.5\n\
>    \2...6.3.9\n\
>    \.....7.1.\n\
>    \.586....4\n\
>    \..3....9.\n\
>    \..62..187\n\
>    \9.4.7...2\n\
>    \67.83....\n\
>    \81..45..."


> {- main = do
>  print $solve $readSudoku sc2
>  print $solve $readSudoku sc3
>  print $solve $readSudoku sc4
>  print $solve $readSudoku sc5 -}

