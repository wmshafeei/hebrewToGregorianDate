# ---------------------------------------------------------------module  hebrew to gregorian date
def MonSinceFirstMolad(nYearH)
    #below formula is shortcut or  
    # (((235 * nYearH) - 234) / 19).floor(0)

    # // A shortcut to this function can simply be the following formula
    # //   return Math.floor(((235 * nYearH) - 234) / 19)
    # // This formula is found in Remy Landau's website and he
    # // attributes it to Wolfgang Alexander Shochen. I will use a less
    # // optimized function which I believe shows the underlying logic better.

    # // count how many months there has been in all years up to last
    # // year. The months of this year hasn't happened yet.
    nYearH --

    # // In the 19 year cycle, there will always be 235 months. That
    # // would be 19 years times 12 months plus 7 extra month for the
    # // leap years. (19 * 12) + 7 = 235.

    # // Get how many 19 year cycles there has been and multiply it by 235
    nMonSinceFirstMolad = (nYearH / 19).floor(0) * 235
    # // Get the remaining years after the last complete 19 year cycle
    nYearH = nYearH % 19
    # // Add 12 months for each of those years
    nMonSinceFirstMolad += 12 * nYearH
    # // Add the extra months to account for the leap years
    if (nYearH >= 17) 
      nMonSinceFirstMolad += 6
    elsif  (nYearH >= 14)
      nMonSinceFirstMolad += 5
    elsif  (nYearH >= 11)
      nMonSinceFirstMolad += 4
    elsif  (nYearH >= 8)
      nMonSinceFirstMolad += 3
    elsif  (nYearH >= 6)
      nMonSinceFirstMolad += 2
    elsif  (nYearH >= 3)
      nMonSinceFirstMolad += 1
    end
    return nMonSinceFirstMolad
end

def IsLeapYear(nYearH)
  nYearInCycle = nYearH % 19
  ( nYearInCycle ==  3 ||
    nYearInCycle ==  6 ||
    nYearInCycle ==  8 ||
    nYearInCycle == 11 ||
    nYearInCycle == 14 ||
    nYearInCycle == 17 ||
    nYearInCycle == 0)
end

def Tishrei1(nYearH)
  nMonthsSinceFirstMolad = MonSinceFirstMolad(nYearH)
  nChalakim = 793 * nMonthsSinceFirstMolad
  nChalakim += 204
  nHours = (nChalakim / 1080).floor(0)
  nChalakim = nChalakim % 1080

  nHours += nMonthsSinceFirstMolad * 12
  nHours += 5

  # // carry the excess hours over to the days
  nDays = (nHours / 24).floor(0)
  nHours = nHours % 24

  nDays += 29 * nMonthsSinceFirstMolad
  nDays += 2

  # // figure out which day of the week the molad occurs.
  # // Sunday = 1, Moday = 2 ..., Shabbos = 0
  nDayOfWeek = nDays % 7

  # // In a perfect world, Rosh Hashanah would be on the day of the
  # // molad. The Hebrew calendar makes four exceptions where we
  # // push off Rosh Hashanah one or two days. This is done to
  # // prevent three situation. Without explaining why, the three
  # // situations are:
  # //   1) We don't want Rosh Hashanah to come out on Sunday,
  # //      Wednesday or Friday
  # //   2) We don't want Rosh Hashanah to be on the day of the
  # //      molad if the molad occurs after the beginning of 18th
  # //      hour.
  # //   3) We want to limit years to specific lengths.  For non-leap
  # //      years, we limit it to either 353, 354 or 355 days.  For
  # //      leap years, we limit it to either 383, 384 or 385 days.
  # //      If setting Rosh Hashanah to the day of the molad will
  # //      cause this year, or the previous year to fall outside
  # //      these lengths, we push off Rosh Hashanah to get the year
  # //      back to a valid length.
  # // This code handles these exceptions.
  if(!IsLeapYear(nYearH) && nDayOfWeek == 3 && (nHours * 1080) + nChalakim >= (9 * 1080) + 204)
    # // This prevents the year from being 356 days. We have to push
    # // Rosh Hashanah off two days because if we pushed it off only
    # // one day, Rosh Hashanah would comes out on a Wednesday. Check
    # // the Hebrew year 5745 for an example.
    nDayOfWeek = 5
    nDays += 2
  elsif( IsLeapYear(nYearH - 1) && nDayOfWeek == 2 && (nHours * 1080) + nChalakim >= (15 * 1080) + 589 ) 
    # // This prevents the previous year from being 382 days. Check
    # // the Hebrew Year 5766 for an example. If Rosh Hashanah was not
    # // pushed off a day then 5765 would be 382 days
    nDayOfWeek = 3
    nDays += 1
  else
    # // see rule 2 above. Check the Hebrew year 5765 for an example
    if (nHours >= 18) 
      nDayOfWeek += 1
      nDayOfWeek = nDayOfWeek % 7
      nDays += 1
    end
    # // see rule 1 above. Check the Hebrew year 5765 for an example
    if (nDayOfWeek == 1 || nDayOfWeek == 4 ||nDayOfWeek == 6) 
      nDayOfWeek += 1
      nDayOfWeek = nDayOfWeek % 7
      nDays += 1
    end
  end

  # // Here we want to add nDays to creation dTishrie1 = creation + nDays
  # // Unfortunately, Many languages do not handle negative years very
  # // well. I therefore picked a Random date (1/1/1900) and figured out
  # // how many days it is after the creation (2067025). Then I
  # // subtracted 2067025 from nDays.
  nDays -= 2067025
  dTishrei1 = Date.new(1900,1,1) #// 2067025 days after creation
  dTishrei1 = (dTishrei1 + nDays.days)
  return dTishrei1
end

def LengthOfYear(nYearH)
  # // subtract the date of this year from the date of next year
  dThisTishrei1 = Tishrei1(nYearH)
  dNextTishrei1 = Tishrei1(nYearH + 1)
  # // Java's dates are stored in milliseconds. To convert it into days
  # // we have to divide it by 1000 * 60 * 60 * 24 if ruby no need
  diff = (dNextTishrei1 - dThisTishrei1) #/( 1000 * 60 * 60 * 24)
  return (diff).round()
end

def HebToGreg(nYearH, nMonthH, nDateH)
    bLeap = IsLeapYear(nYearH)
    nLengthOfYear = LengthOfYear(nYearH)
    # // The regular length of a non-leap year is 354 days.
    # // The regular length of a leap year is 384 days.
    # // On regular years, the length of the months are as follows
    # //   Tishrei (1)   30
    # //   Cheshvan(2)   29
    # //   Kislev  (3)   30
    # //   Teves   (4)   29
    # //   Shevat  (5)   30
    # //   Adar A  (6)   30     (only valid on leap years)
    # //   Adar    (7)   29     (Adar B for leap years)
    # //   Nisan   (8)   30
    # //   Iyar    (9)   29
    # //   Sivan   (10)  30
    # //   Tamuz   (11)  29
    # //   Av      (12)  30
    # //   Elul    (13)  29
    # // If the year is shorter by one less day, it is called a haser
    # // year. Kislev on a haser year has 29 days. If the year is longer
    # // by one day, it is called a shalem year. Cheshvan on a shalem year is 30 days.

    bHaser = (nLengthOfYear == 353 || nLengthOfYear == 383)
    bShalem = (nLengthOfYear == 355 || nLengthOfYear == 385)
    # // get the date for Tishrei 1
    dGreg = Tishrei1(nYearH)

    # // Now count up days within the year
    for nMonth in 1..(nMonthH-1) do
    # for (nMonth = 1; nMonth <= nMonthH - 1; nMonth ++)
      if (nMonth == 1 ||
          nMonth == 5 ||
          nMonth == 8 ||
          nMonth == 10 ||
          nMonth == 12 )
        nMonthLen = 30
      elsif (nMonth == 4 ||
                 nMonth == 7 ||
                 nMonth == 9 ||
                 nMonth == 11 ||
                 nMonth == 13 )
          nMonthLen = 29
      elsif (nMonth == 6) 
          nMonthLen = (bLeap ? 30 : 0)
      elsif (nMonth == 2) 
          nMonthLen = (bShalem ? 30 : 29)
      elsif (nMonth == 3) 
          nMonthLen = (bHaser ? 29 : 30 )
      end
      # dGreg.setDate(dGreg.getDate() + nMonthLen)
      dGreg = dGreg + nMonthLen.days
    end
    dGreg = dGreg + nDateH.days - 1 - 1
    # dGreg.setDate(dGreg.getDate() + nDateH - 1 - 1)
    return dGreg
end

# ---------------------------------------------------------------end

#Example to call function to convert date from above functions HebToGreg(year,month,day) -- in hebrew date format
puts(HebToGreg(5783,3,25));
puts(HebToGreg(5784,3,25));
puts(HebToGreg(5785,3,25));
puts(HebToGreg(5786,3,25));
puts(HebToGreg(5787,3,25));
puts(HebToGreg(5788,3,25));
puts(HebToGreg(5789,3,25));
puts(HebToGreg(5790,3,25));
