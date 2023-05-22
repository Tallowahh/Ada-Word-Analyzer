with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_Io; use Ada.Float_Text_Io;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.strings; use Ada.strings;
with Ada.strings.fixed; use ada.strings.fixed;
with Ada.Strings.unbounded; use Ada.Strings.unbounded;
with Ada.Strings.unbounded.Text_IO; use Ada.Strings.unbounded.Text_IO;
with Ada.directories; use Ada.directories;
with Ada.Characters.Conversions;
with Ada.Characters.Handling;

procedure textyzer is
file: File_type;
nameOk : boolean := false;
type arrayType is array(1..20) of integer;

procedure getFileName(filename: in out unbounded_string) is -- Procedure to get the file's name
file_check: integer;
fileline: unbounded_string;
begin
    file_check := 0;
while(file_check = 0) loop
    loop
        exit when nameOk;
        put("Please enter the name of the file: ");
        get_line(filename);
        nameOk := exists(to_string(filename)); -- Check to see if the file exists and reprompts if not found
        if (nameOk = false) then
            put_line("File not found.");
        end if;
    end loop;
        file_check := 1;
   end loop;
end getFileName;

procedure isWord (word: in unbounded_string; wcount: in out integer) is -- Procedure to check if the set of characters makes a word
i : integer;
numbercheck: integer;
begin
numbercheck := 0;
i := 1;
for i in 1..length(word) loop
    if (not Ada.Characters.Handling.is_letter(element(word,i))
    or element(word,i) = ' ') then
        numbercheck := 1;
    end if;        
end loop;

if (numbercheck /= 1) then
    wcount := wcount + 1;  
end if;
end isWord;

procedure isNumber(word: in unbounded_string; numbercount: in out integer; wordcount: in out integer) is -- Procedure to check if the set of characters makes a number
i: integer;
wordcheck: integer;
begin
wordcheck := 0;
i := 1; 
    for i in 1..length(word) loop
        if (Ada.Characters.Handling.is_letter(element(word,i)) 
        and not Ada.Characters.Handling.is_digit(element(word,i))) then
            wordcheck := 1;
        end if;
    end loop;
    if (wordcheck /= 1) then
        numbercount := numbercount + 1;
    end if;
end isNumber;

procedure printHist (incarray: in out arrayType) is -- Procedure to print the histogram
i : integer;
j : integer;
begin
i := 1;
j := 1;
    for i in 1..20 loop
        put(i, width => 0);
        if (i < 10) then
            put("  ");
        else 
            put(" ");
        end if;
        for j in 1..incarray(i) loop
            put("*");
        end loop;
        new_line;
    end loop;
end printHist;

procedure initializeArray(incomingarray: in out arrayType) is -- Loop to intiialize the loop with 0s in each area
i : integer;
begin
i := 1;
for i in 1..20 loop
incomingarray(i) := 0;
end loop;

end initializeArray;

procedure AnalyzeText(f: unbounded_string) is
fileline: unbounded_string;
wordcheck: unbounded_string;
i: integer;
charcount: integer;
punctcount: integer;
wordcount: integer;
sentencecount: integer;
wtype: integer;
numcount: integer;
charpword: float;
wordpsentence: float;
indcharcount: integer;
wlengthdist: arrayType;
k: integer;
begin
k := 0;
i := 1;
charcount := 0;
punctcount := 0;
wordcount := 0;
sentencecount := 0;
numcount := 0;
indcharcount := 0;
wtype := 0;
open(file, in_file, to_string(f));
initializeArray(wlengthdist);
loop    
    exit when end_of_file(file);
    get_line(file, fileline);
    if (Ada.Characters.Handling.is_letter(element(fileline, length(fileline)))) then -- Increase the Word count when a letter is found
        wordcount := wordcount + 1;
    else if (Ada.Characters.Handling.is_digit(element(fileline, length(fileline)))) then -- Increase the Number count when a number is found
        numcount := numcount + 1;
    end if;
    end if;
    
    for i in 1..length(fileline) loop
        if (Ada.Characters.Handling.is_Alphanumeric(element(fileline,i))) then -- Increase the Character count when a character(number or letteR) is found
            charcount := charcount + 1;
        end if;     

        if (element(fileline, i) = '.' or element(fileline, i) = ',' -- Increase the Punctuation count when a punctuation character is found
        or element(fileline, i) = '"' or element(fileline, i) = '''
        or element(fileline, i) = ':' or element(fileline, i) = ';'
        or element(fileline, i) = '?' or element(fileline, i) = '!'
        or element(fileline, i) = '/') then
            punctcount := punctcount + 1;
        end if;

        if (element(fileline, i) = '.' or element(fileline, i) = '!' -- Increase the Sentence count when an ending character is found
        or element(fileline, i) = '?') then
            sentencecount := sentencecount + 1;
        end if;
        if (Ada.Characters.Handling.is_Alphanumeric(element(fileline,i))) then 
            wordcheck := wordcheck & element(fileline, i); -- Concatanate letters to a word to process
            indcharcount := indcharcount + 1; -- Increase the count of characters within the word to track it
        end if;
        begin
            if ((not Ada.Characters.Handling.is_Alphanumeric(element(wordcheck, 1)))) then
                wordcheck := to_unbounded_string("");
            end if;

            if (Ada.Characters.Handling.is_Alphanumeric(element(fileline, i)) and i = length(fileline)) then
              wordcheck := to_unbounded_string("");
                indcharcount := 0;
            end if;
            Exception
            when index_error => k := 1;
            end;        

        if (element(fileline, i) = ' ' or (element(fileline, i) = ',')
        or element(fileline, i) = '.' or element(fileline, i) = ':'
        or element(fileline, i) = ';') then
            if (wordcheck /= to_unbounded_string("")) then
                wlengthdist(indcharcount) := wlengthdist(indcharcount) + 1;
                indcharcount := 0;
                isWord(wordcheck, wordcount); -- Check to see if the word processed is a word
                isNumber(wordcheck, numcount, wordcount); -- Check to see if the number processed is a number
            end if;
        wordcheck := to_unbounded_string("");
        end if;
    end loop;
end loop;
    charpword := float(charcount) / float(wordcount);
    wordpsentence := (float(wordcount) + float(numcount)) / float(sentencecount);
    new_line;
    put_line("Character Count (a-z)         : " & charcount'image);
    put_line("Word Count                    : " & wordcount'image);    
    put_line("Sentence Count                : " & sentencecount'image);
    put_line("Number Count                  : " & numcount'image);
    put_line("Punctuation Count             : " & punctcount'image);
    put("Characters per word           : ");
    put(charpword, Aft => 1, Exp => 0);
    new_line;
    put("Words per sentence            :  ");
    put(wordpsentence, Aft => 1, Exp => 0);
    new_line;
    new_line;
    put_line("------------Histogram------------");
    printHist(wlengthdist); -- Print the Histogram of the word distribution
close(file);
end AnalyzeText;
fname: unbounded_string;
begin
    put_line("------------Text Statistics------------");
    new_line;
    getFileName(fname);
    put("File chosen is: ");
    put(fname);
    new_line;
    AnalyzeText(fname);
    new_line;
end textyzer;