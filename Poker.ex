defmodule Poker do

	def deal(list) do

		p1 = []
		p1 = p1 ++ [Enum.at(list, 0)]
		p1 = p1 ++ [Enum.at(list, 2)]
		p1 = p1 ++ (Enum.slice(list, 4, 5))

		p2 = []
		p2 = p2 ++ [Enum.at(list, 1)]
		p2 = p2 ++ [Enum.at(list, 3)]
		p2 = p2 ++ (Enum.slice(list, 4, 5))
		
		p1 = player1(p1)
		p1Hand = Enum.slice(p1, 0, 5)
		p2 = player2(p2)
		p2Hand = Enum.slice(p2, 0, 5)

		cond do
			Enum.at(p1, 5) < Enum.at(p2, 5) -> formatOutput(p1Hand)
			Enum.at(p1, 5) > Enum.at(p2, 5) -> formatOutput(p2Hand)
			Enum.at(p1, 5) == Enum.at(p2, 5) -> formatOutput(tieBreaker(p1Hand, p2Hand, Enum.at(p1, 5)))
			true -> "catch-all"
		end

	end



	def tieBreaker(p1Hand, p2Hand, typeOfHand) do

		# get both hands reduced to the lowest ranks
		p1ReducedList = Enum.sort(getReducedList(p1Hand, typeOfHand, []))
		p2ReducedList = Enum.sort(getReducedList(p2Hand, typeOfHand, []))

		cond do

			# typeOfHand is straight or staight flush
			(typeOfHand == 2) || (typeOfHand == 6) ->
				a = Enum.find_value(p1ReducedList, fn(x) -> x == 1 end)
				b = Enum.find_value(p1ReducedList, fn(x) -> x == 2 end)
				c = Enum.find_value(p1ReducedList, fn(x) -> x == 13 end)
				d = Enum.find_value(p2ReducedList, fn(x) -> x == 1 end)
				e = Enum.find_value(p2ReducedList, fn(x) -> x == 2 end)
				f = Enum.find_value(p2ReducedList, fn(x) -> x == 13 end)

				cond do
					(a && b) || (d && f) -> p2Hand
					(a && c) || (d && e) -> p1Hand
					true -> 
						if Enum.reverse(p1ReducedList) > Enum.reverse(p2ReducedList) do
							p1Hand
						else
							p2Hand
						end
				end

			# typeOfHand is flush
			(typeOfHand == 5) ->
				cond do
					Enum.reverse(p1ReducedList) > Enum.reverse(p2ReducedList) -> p1Hand
					Enum.reverse(p1ReducedList) < Enum.reverse(p2ReducedList) -> p2Hand
					true -> "catch all"
				end

			# typeOfHand is four of a kind
			(typeOfHand == 3) ->
				value1 = getNumWithOccuranceN(p1ReducedList, 4)
				value2 = getNumWithOccuranceN(p2ReducedList, 4)
				cond do
					(value1 > value2) -> p1Hand
					(value1 < value2) -> p2Hand
					(value1 == value2) -> 
						Enum.filter(p1ReducedList, fn(x) -> x != value1 end)
						Enum.filter(p2ReducedList, fn(x) -> x != value2 end)
						if (hd p1ReducedList) > (hd p2ReducedList) do
							p1Hand
						else
							p2Hand
						end
					true -> "catch all"
				end

			# typeOfHand is full house
			(typeOfHand == 4) ->
				value1 = getNumWithOccuranceN(p1ReducedList, 3)
				value2 = getNumWithOccuranceN(p2ReducedList, 3)
				cond do
					(value1 > value2) -> p1Hand
					(value1 < value2) -> p2Hand
					(value1 == value2) -> 
						Enum.filter(p1ReducedList, fn(x) -> x != value1 end)
						Enum.filter(p2ReducedList, fn(x) -> x != value2 end)
						if (hd p1ReducedList) > (hd p2ReducedList) do
							p1Hand
						else
							p2Hand
						end
					true -> "catch all"
				end

			# typeOfHand is three of a kind
			(typeOfHand == 7) ->
				value1 = getNumWithOccuranceN(p1ReducedList, 3)
				value2 = getNumWithOccuranceN(p2ReducedList, 3)
				cond do
					(value1 > value2) -> p1Hand
					(value1 < value2) -> p2Hand
					(value1 == value2) -> 
						Enum.filter(p1ReducedList, fn(x) -> x != value1 end)
						Enum.filter(p2ReducedList, fn(x) -> x != value2 end)
						if (hd tl p1ReducedList) > (hd tl p2ReducedList) do
							p1Hand
						else
							p2Hand
						end
					true -> "catch all"
				end

			# typeOfHand is pair
			(typeOfHand == 9) ->
				value1 = getNumWithOccuranceN(p1ReducedList, 2)
				value2 = getNumWithOccuranceN(p2ReducedList, 2)
				cond do
					(value1 > value2) -> p1Hand
					(value1 < value2) -> p2Hand
					(value1 == value2) -> 
						Enum.filter(p1ReducedList, fn(x) -> x != value1 end)
						Enum.filter(p2ReducedList, fn(x) -> x != value2 end)
						if (hd tl tl p1ReducedList) > (hd tl tl p2ReducedList) do
							p1Hand
						else
							p2Hand
						end
					true -> "catch all"
				end

			# typeOfHand is two pair
			(typeOfHand == 8) ->
				valueA1 = getNumWithOccuranceN(p1ReducedList, 2)
				p1ReducedList = Enum.filter(p1ReducedList, fn(x) -> x != valueA1 end)
				valueA2 = getNumWithOccuranceN(p1ReducedList, 2)
				p1ReducedList = Enum.filter(p1ReducedList, fn(x) -> x != valueA2 end)

				valueB1 = getNumWithOccuranceN(p2ReducedList, 2)
				p2ReducedList = Enum.filter(p2ReducedList, fn(x) -> x != valueB1 end)
				valueB2 = getNumWithOccuranceN(p2ReducedList, 2)
				p2ReducedList = Enum.filter(p2ReducedList, fn(x) -> x != valueB2 end)

				cond do
					(valueA2 > valueB2) -> p1Hand
					(valueA2 < valueB2) -> p2Hand
					(valueA2 == valueB2) -> 
						cond do
							(valueA1 > valueB1) -> p1Hand
							(valueA1 < valueB1) -> p2Hand
							(valueA1 == valueB1) -> 
								if (hd p1ReducedList) > (hd p2ReducedList) do
									p1Hand
								else
									p2Hand
								end
							true -> "catch all"
						end
					true -> "catch all"
				end
			
			# typeOfHand is high card
			(typeOfHand == 10) ->
				if Enum.reverse(p1ReducedList) > Enum.reverse(p2ReducedList) do
					p1Hand
				else
					p2Hand
				end
			
			true -> "catch all"
		
		end
	
	end



	def getNumWithOccuranceN(list, occurance) do
		frequencies = Enum.frequencies(list)
		elem(Enum.find(frequencies, fn {_, val} -> val == occurance end), 0)
	end



	def getReducedList([hd|list], typeOfHand, reducedList) do
		if (getRank(hd) == 1) && (typeOfHand != 2) && (typeOfHand != 6) do
			reducedList = reducedList ++ [14]
			getReducedList(list, typeOfHand, reducedList)
		else
			reducedList = reducedList ++ [getRank(hd)]
			getReducedList(list, typeOfHand, reducedList)
		end 
	end

	def getReducedList([], _, reducedList) do
		reducedList
	end



	def formatOutput([hd|hand]) do
		output = []
		rank = to_string(getRank(hd))
		cond do
			(hd > 0) && (hd < 14) -> 
				formatOutput(hand, output ++ [rank <> "C"])
			(hd > 13) && (hd < 27) ->
				formatOutput(hand, output ++ [rank <> "D"])
			(hd > 26) && (hd < 40) ->
				formatOutput(hand, output ++ [rank <> "H"])
			(hd > 39) && (hd < 53) ->
				formatOutput(hand, output ++ [rank <> "S"])
			true -> "catch all"
		end
	end

	def formatOutput([hd|hand], output) do
		rank = to_string(getRank(hd))
		cond do
			(hd > 0) && (hd < 14) -> 
				formatOutput(hand, output ++ [rank <> "C"])
			(hd > 13) && (hd < 27) ->
				formatOutput(hand, output ++ [rank <> "D"])
			(hd > 26) && (hd < 40) ->
				formatOutput(hand, output ++ [rank <> "H"])
			(hd > 39) && (hd < 53) ->
				formatOutput(hand, output ++ [rank <> "S"])
			true -> "catch all"
		end
	end

	def formatOutput([], output) do
		output
	end



	def player1(cardList) do
		cond do
			length(isRoyalFlush(cardList)) == 5 -> isRoyalFlush(cardList) ++ [1]
			length(isStraightFlush(cardList)) == 5 -> isStraightFlush(cardList) ++ [2]
			length(isFourOfAKind(cardList)) == 5 -> isFourOfAKind(cardList) ++ [3]
			length(isFullHouse(cardList)) == 5 -> isFullHouse(cardList) ++ [4]
			length(isFlush(cardList)) == 5 -> isFlush(cardList) ++ [5]
			length(isStraight(cardList)) == 5 -> isStraight(cardList) ++ [6]
			length(isThreeOfAKind(cardList)) == 5 -> isThreeOfAKind(cardList) ++ [7]
			length(isTwoPair(cardList)) == 5 -> isTwoPair(cardList) ++ [8]
			length(isPair(cardList)) == 5 -> isPair(cardList) ++ [9]
			length(isHighCard(cardList)) == 5 -> isHighCard(cardList) ++ [10]
		end
	end

	def player2(cardList) do
		cond do
			length(isRoyalFlush(cardList)) == 5 -> isRoyalFlush(cardList) ++ [1]
			length(isStraightFlush(cardList)) == 5 -> isStraightFlush(cardList) ++ [2]
			length(isFourOfAKind(cardList)) == 5 -> isFourOfAKind(cardList) ++ [3]
			length(isFullHouse(cardList)) == 5 -> isFullHouse(cardList) ++ [4]
			length(isFlush(cardList)) == 5 -> isFlush(cardList) ++ [5]
			length(isStraight(cardList)) == 5 -> isStraight(cardList) ++ [6]
			length(isThreeOfAKind(cardList)) == 5 -> isThreeOfAKind(cardList) ++ [7]
			length(isTwoPair(cardList)) == 5 -> isTwoPair(cardList) ++ [8]
			length(isPair(cardList)) == 5 -> isPair(cardList) ++ [9]
			length(isHighCard(cardList)) == 5 -> isHighCard(cardList) ++ [10]
		end
	end



	def isRoyalFlush(inputCardList) do

		list = Enum.sort(isStraightFlush(inputCardList))
		
		if length(list) == 0 do
			[]
		else
			list = List.to_tuple(list)
			if ( (getRank(elem(list, 0)) == 1) 
				&& (getRank(elem(list, 1)) == 10) 
				&& (getRank(elem(list, 2)) == 11)
				&& (getRank(elem(list, 3)) == 12)
				&& (getRank(elem(list, 4)) == 13) ) do
					Tuple.to_list(list)
			else
				[]
			end
		end

	end



	def isStraightFlush(inputCardList) do

		# check if it's a straight
		list = Enum.sort(isStraight(inputCardList))

		# check if it's a flush
		if length(list) > 0 do 
			Enum.sort(isFlush(list))
		else
			[]
		end

	end



	def isFourOfAKind([hd|inputCardList]) do
		countRankList = Tuple.to_list(countEachRank([hd|inputCardList]))
		handList = []
		if (Enum.max(countRankList) == 4) do

			rankIndex = Enum.find_index(countRankList, fn x -> x == 4 end) + 1
			rank = getRank(hd)

			if (rank == rankIndex) do
				handList = handList ++ [hd]
				isFourOfAKind(inputCardList, [hd|inputCardList], handList, countRankList)
			else

				isFourOfAKind(inputCardList, [hd|inputCardList], handList, countRankList)
			end
		else handList
		end
	end

	defp isFourOfAKind([hd|inputCardList], originalList, handList, countRankList) do

		rankIndex = Enum.find_index(countRankList, fn x -> x == 4 end) + 1
		rank = getRank(hd)

		if (rank == rankIndex) do
			handList = handList ++ [hd]
			isFourOfAKind(inputCardList, originalList, handList, countRankList)
		else
			isFourOfAKind(inputCardList, originalList, handList, countRankList)
		end
	end

	defp isFourOfAKind([], originalList, handList, _) do
		handList = handList ++ getHighestCards(originalList--handList, 1)
		Enum.sort(handList)
	end



	def isFullHouse(inputCardList) do
		
		rankCountTup = countEachRank(inputCardList)
		rankCountList = Tuple.to_list(countEachRank(inputCardList))
		freqMap = Enum.frequencies(rankCountList)
		handList = []

		cond do
			
			# case 1: 3 cards + 3 cards
			freqMap[3] == 2 ->
				rank = Enum.find_index(rankCountList, fn(x) -> x == 3 end) + 1
				if (rank == 1) do
					handList = getNCardsWithRank(inputCardList, 3, 1, handList)
					rankCountTup = put_elem(rankCountTup, 0, 0)
					rankCountList = Tuple.to_list(rankCountTup)
					rank = Enum.find_index(rankCountList, fn(x) -> x == 3 end) + 1
					handList = getNCardsWithRank(inputCardList, 3, rank, handList)
					isFullHouse(handList, 0)
				else
					handList = getNCardsWithRank(inputCardList, 2, rank, handList)
					rankCountTup = put_elem(rankCountTup, rank-1, 0)
					rankCountList = Tuple.to_list(rankCountTup)
					rank = Enum.find_index(rankCountList, fn(x) -> x == 3 end) + 1
					handList = getNCardsWithRank(inputCardList, 3, rank, handList)
					isFullHouse(handList, 0)
				end

			# case 2: 3 cards + 2 cards + 2 cards
			(freqMap[3] == 1) && (freqMap[2] == 2) ->
				rank = Enum.find_index(rankCountList, fn(x) -> x == 3 end) + 1
				handList = getNCardsWithRank(inputCardList, 3, rank, handList)
				rank = Enum.find_index(rankCountList, fn(x) -> x == 2 end) + 1
				if (rank == 1) do
					handList = getNCardsWithRank(inputCardList, 2, rank, handList)
					isFullHouse(handList, 0)
				else
					rankCountTup = put_elem(rankCountTup, rank-1, 0)
					rankCountList = Tuple.to_list(rankCountTup)
					rank = Enum.find_index(rankCountList, fn(x) -> x == 2 end) + 1
					handList = getNCardsWithRank(inputCardList, 2, rank, handList)
					isFullHouse(handList, 0)
				end

			# case 3: 3 cards + 2 cards
			(freqMap[3] == 1) && (freqMap[2] == 1) ->
				rank = Enum.find_index(rankCountList, fn(x) -> x == 3 end) + 1
				handList = getNCardsWithRank(inputCardList, 3, rank, handList)
				rank = Enum.find_index(rankCountList, fn(x) -> x == 2 end) + 1
				handList = getNCardsWithRank(inputCardList, 2, rank, handList)
				isFullHouse(handList, 0)

			true -> handList

		end

	end

	def isFullHouse(handList, _) do
		Enum.sort(handList)
	end



	def getNCardsWithRank([hd|list], n, rank, returnList) do
		if n == 0 do
			returnList
		end
		
		if (getRank(hd) == rank) && (n > 0) do
			returnList = returnList ++ [hd]
			getNCardsWithRank(list, n-1, rank, returnList)
		else
			getNCardsWithRank(list, n, rank, returnList)
		end
	end

	def getNCardsWithRank(_, 0, _, returnList) do
		returnList
	end

	def getNCardsWithRank([], _, _, returnList) do
		returnList
	end



	def isFlush([hd|inputCardList]) do

		clubsList = []
		diamondsList = []
		heartsList = []
		spadesList = []
		suitTup = {0,0,0,0}

		cond do
			(hd > 0) && (hd < 14) -> 
				suitTup = put_elem(suitTup, 0, elem(suitTup, 0) + 1)
				clubsList = clubsList ++ [hd]
				isFlush(inputCardList, suitTup, clubsList, diamondsList, heartsList, spadesList)
			(hd > 13) && (hd < 27) -> 
				suitTup = put_elem(suitTup, 1, elem(suitTup, 1) + 1)
				diamondsList = diamondsList ++ [hd]
				isFlush(inputCardList, suitTup, clubsList, diamondsList, heartsList, spadesList)
			(hd > 26) && (hd < 40) -> 
				suitTup = put_elem(suitTup, 2, elem(suitTup, 2) + 1)
				heartsList = heartsList ++ [hd]
				isFlush(inputCardList, suitTup, clubsList, diamondsList, heartsList, spadesList)
			(hd > 39) && (hd < 53) -> 
				suitTup = put_elem(suitTup, 3, elem(suitTup, 3) + 1)
				spadesList = spadesList ++ [hd]
				isFlush(inputCardList, suitTup, clubsList, diamondsList, heartsList, spadesList)
			true -> IO.puts "catch-all"
		end

	end

	def isFlush([hd|inputCardList], suitTup, clubsList, diamondsList, heartsList, spadesList) do

		cond do
			(hd > 0) && (hd < 14) -> 
				suitTup = put_elem(suitTup, 0, elem(suitTup, 0) + 1)
				clubsList = clubsList ++ [hd]
				isFlush(inputCardList, suitTup, clubsList, diamondsList, heartsList, spadesList)
			(hd > 13) && (hd < 27) -> 
				suitTup = put_elem(suitTup, 1, elem(suitTup, 1) + 1)
				diamondsList = diamondsList ++ [hd]
				isFlush(inputCardList, suitTup, clubsList, diamondsList, heartsList, spadesList)
			(hd > 26) && (hd < 40) -> 
				suitTup = put_elem(suitTup, 2, elem(suitTup, 2) + 1)
				heartsList = heartsList ++ [hd]
				isFlush(inputCardList, suitTup, clubsList, diamondsList, heartsList, spadesList)
			(hd > 39) && (hd < 53) -> 
				suitTup = put_elem(suitTup, 3, elem(suitTup, 3) + 1)
				spadesList = spadesList ++ [hd]
				isFlush(inputCardList, suitTup, clubsList, diamondsList, heartsList, spadesList)
			true -> IO.puts "catch-all"
		end

	end

	def isFlush([], suitTup, clubsList, diamondsList, heartsList, spadesList) do
		max = Enum.max(Tuple.to_list(suitTup))
		handList = []
		if max >= 5 do
			cond do
				(elem(suitTup, 0) == max) -> 
					rankList = Tuple.to_list(sortByRank(clubsList))
					rankList = Enum.reverse(rankList)
					isFlushHelper(rankList, handList)
				(elem(suitTup, 1) == max) -> 
					rankList = Tuple.to_list(sortByRank(diamondsList))
					rankList = Enum.reverse(rankList)
					isFlushHelper(rankList, handList)
				(elem(suitTup, 2) == max) -> 
					rankList = Tuple.to_list(sortByRank(heartsList))
					rankList = Enum.reverse(rankList)
					isFlushHelper(rankList, handList)
				(elem(suitTup, 3) == max) -> 
					rankList = Tuple.to_list(sortByRank(spadesList))
					rankList = Enum.reverse(rankList)
					isFlushHelper(rankList, handList)
			end
		else
			[]
		end
	end

	def isFlushHelper([hd|list], handList) do
		if (hd > 0) && (length(handList)) < 5 do
			handList = handList ++ [hd]
			isFlushHelper(list, handList)
		else
			isFlushHelper(list, handList)
		end
	end

	def isFlushHelper([], handList) do
		handList
	end




	def isStraight(inputCardList) do

		sortedByRankList = Tuple.to_list(sortByRank(inputCardList))
		revList = Enum.reverse(sortedByRankList)
		isStraight(revList, 0)

	end

	def isStraight([hd|revList], 0) do
		returnList = Enum.take_while([hd|revList], fn(x) -> x > 0 end)
		if length(returnList) >= 5 do
			Enum.slice(returnList, 0, 5)
		else
			isStraight(revList, 0)
		end
	end

	def isStraight([], _) do
		[]
	end




	def isThreeOfAKind([hd|inputCardList]) do

		countRankList = Tuple.to_list(countEachRank([hd|inputCardList]))
		handList = []

		if (Enum.max(countRankList) == 3) do
			
			rankIndex = Enum.find_index(countRankList, fn x -> x == 3 end) + 1
			rank = getRank(hd)
			if (rank == rankIndex) do
				handList = handList ++ [hd]
				isThreeOfAKind(inputCardList, [hd|inputCardList], handList, countRankList)
			else
				isThreeOfAKind(inputCardList, [hd|inputCardList], handList, countRankList)
			end
		
		else handList
		
		end

	end

	defp isThreeOfAKind([hd|inputCardList], originalList, handList, countRankList) do

		rankIndex = Enum.find_index(countRankList, fn x -> x == 3 end) + 1
		rank = getRank(hd)

		if (rank == rankIndex) do
			handList = handList ++ [hd]
			isThreeOfAKind(inputCardList, originalList, handList, countRankList)
		else
			isThreeOfAKind(inputCardList, originalList, handList, countRankList)
		end
	end

	defp isThreeOfAKind([], originalList, handList, _) do
		handList = handList ++ getHighestCards(originalList--handList, 2)
		Enum.sort(handList)
	end




	def isTwoPair(inputCardList) do

		rankCountTup = countEachRank(inputCardList)
		rankCountList = Tuple.to_list(countEachRank(inputCardList))
		freqMap = Enum.frequencies(rankCountList)
		handList = []

		cond do
			
			# case 1: 2 cards + 2 cards + 2 cards
			(freqMap[2] == 3) ->
				rank = Enum.find_index(rankCountList, fn(x) -> x == 2 end) + 1
				if (rank == 1) do
					handList = getNCardsWithRank(inputCardList, 2, rank, handList)
					rankCountTup = put_elem(rankCountTup, rank-1, 0)
					rankCountList = Tuple.to_list(rankCountTup)
					rank = Enum.find_index(rankCountList, fn(x) -> x == 2 end) + 1
					rankCountTup = put_elem(rankCountTup, rank-1, 0)
					rankCountList = Tuple.to_list(rankCountTup)
					rank = Enum.find_index(rankCountList, fn(x) -> x == 2 end) + 1
					handList = getNCardsWithRank(inputCardList, 2, rank, handList)
					isTwoPair(handList, inputCardList)
				else
					rankCountTup = put_elem(rankCountTup, rank-1, 0)
					rankCountList = Tuple.to_list(rankCountTup)
					rank = Enum.find_index(rankCountList, fn(x) -> x == 2 end) + 1
					handList = getNCardsWithRank(inputCardList, 2, rank, handList)
					rankCountTup = put_elem(rankCountTup, rank-1, 0)
					rankCountList = Tuple.to_list(rankCountTup)
					rank = Enum.find_index(rankCountList, fn(x) -> x == 2 end) + 1
					handList = getNCardsWithRank(inputCardList, 2, rank, handList)
					isTwoPair(handList, inputCardList)
				end

			# case 2: 2 cards + 2 cards
			(freqMap[2] == 2) ->
				rank = Enum.find_index(rankCountList, fn(x) -> x == 2 end) + 1
				handList = getNCardsWithRank(inputCardList, 2, rank, handList)
				rankCountTup = put_elem(rankCountTup, rank-1, 0)
				rankCountList = Tuple.to_list(rankCountTup)
				rank = Enum.find_index(rankCountList, fn(x) -> x == 2 end) + 1
				handList = getNCardsWithRank(inputCardList, 2, rank, handList)
				isTwoPair(handList, inputCardList)
		
			true -> handList

		end

	end

	def isTwoPair(handList, originalList) do
		handList = handList ++ getHighestCards(originalList--handList, 1)
		Enum.sort(handList)
	end




	def isPair([hd|inputCardList]) do
		countRankList = Tuple.to_list(countEachRank([hd|inputCardList]))
		handList = []
		if (Enum.max(countRankList) == 2) do
			rankIndex = Enum.find_index(countRankList, fn x -> x == 2 end) + 1
			rank = getRank(hd)
			if (rank == rankIndex) do
				handList = handList ++ [hd]
				isPair(inputCardList, [hd|inputCardList], handList, countRankList)
			else
				isPair(inputCardList, [hd|inputCardList], handList, countRankList)
			end
		else handList
		end
	end

	defp isPair([hd|inputCardList], originalList, handList, countRankList) do
		rankIndex = Enum.find_index(countRankList, fn x -> x == 2 end) + 1
		rank = getRank(hd)
		if (rank == rankIndex) do
			handList = handList ++ [hd]
			isPair(inputCardList, originalList, handList, countRankList)
		else
			isPair(inputCardList, originalList, handList, countRankList)
		end
	end

	defp isPair([], originalList, handList, _) do
		handList = handList ++ getHighestCards(originalList--handList, 3)
		Enum.sort(handList)
	end




	def isHighCard(inputCardList) do
		Enum.sort(getHighestCards(inputCardList, 5))
	end




	def getHighestCards(cardList, numOfCards) do

		revRankList = Enum.reverse(Tuple.to_list(sortByRank(cardList)))
		outputList = []

		if (hd revRankList) > 0 do
			outputList = outputList ++ [(hd revRankList)]
			getHighestCards((tl revRankList), numOfCards-1, outputList)
		else
			getHighestCards((tl revRankList), numOfCards, outputList)
		end
	end

	def getHighestCards([hd|list], numOfCards, outputList) do	
		if (hd > 0) && (numOfCards > 0) do
			outputList = outputList ++ [hd]
			getHighestCards(list, numOfCards-1, outputList)
		else
			getHighestCards(list, numOfCards, outputList)
		end
	end

	def getHighestCards(_, 0, outputList) do
		Enum.sort(outputList)
	end

	def getHighestCards([], _, outputList) do
		Enum.sort(outputList)
	end




	def sortByRank([hd|inputCardList]) do

		# index 0 and 13 are both for aces
		rankTup = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0 }
		remainder = rem(hd,13)

		cond do
			remainder == 1 ->
				if (elem(rankTup, 0) < hd) && (elem(rankTup, 13) < hd) do
					rankTup = put_elem(rankTup, 0, hd)
					rankTup = put_elem(rankTup, 13, hd)
					sortByRank(inputCardList, rankTup)
				end
			remainder == 0 ->
				if elem(rankTup, 12) < hd do
					rankTup = put_elem(rankTup, 12, hd)
					sortByRank(inputCardList, rankTup)
				end
			remainder > 1 ->
				value = elem(rankTup, remainder-1)
				if (value < hd) do
					rankTup = put_elem(rankTup, remainder-1, hd)
					sortByRank(inputCardList, rankTup)
				end
			true -> IO.puts "catch-all"
		end
	end

	def sortByRank([hd|inputCardList], rankTup) do

		remainder = rem(hd,13)

		cond do
			remainder == 1 ->
				if (elem(rankTup, 0) < hd) && (elem(rankTup, 13) < hd) do
					rankTup = put_elem(rankTup, 0, hd)
					rankTup = put_elem(rankTup, 13, hd)
					sortByRank(inputCardList, rankTup)
				else
					sortByRank(inputCardList, rankTup)
				end
			remainder == 0 ->
				if elem(rankTup, 12) < hd do
					rankTup = put_elem(rankTup, 12, hd)
					sortByRank(inputCardList, rankTup)
				else
					sortByRank(inputCardList, rankTup)
				end
			remainder > 1 ->
				value = elem(rankTup, remainder-1)
				if (value < hd) do
					rankTup = put_elem(rankTup, remainder-1, hd)
					sortByRank(inputCardList, rankTup)
				else
					sortByRank(inputCardList, rankTup)
				end
			true -> IO.puts "catch-all"
		end

	end

	def sortByRank([], rankTup) do
		rankTup
	end




	defp countEachRank([card|cardList]) do
		countRankTup = { 0,0,0,0,0,0,0,0,0,0,0,0,0 }
		remainder = rem(card, 13)
		if (remainder == 0) do
			countRankTup = put_elem(countRankTup, 12, (elem(countRankTup,12) + 1))
			countEachRank(cardList, countRankTup)
		else
			countRankTup = put_elem(countRankTup, remainder-1, elem(countRankTup,remainder-1) + 1)
			countEachRank(cardList, countRankTup)
		end
	end

	defp countEachRank([card|cardList], countRankTup) do
		remainder = rem(card, 13)
		if (remainder == 0) do
			countRankTup = put_elem(countRankTup, 12, (elem(countRankTup,12) + 1))
			countEachRank(cardList, countRankTup)
		else
			countRankTup = put_elem(countRankTup, remainder-1, elem(countRankTup,remainder-1) + 1)
			countEachRank(cardList, countRankTup)
		end
	end

	defp countEachRank([], countRankTup) do
		countRankTup
	end



	defp getRank(card) do
		#get the rank of given card
		if (rem(card, 13) == 0) do 13
		else rem(card, 13)
		end
	end


end
