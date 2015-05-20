# ***** this makefile will only work properly with gnu make *****

CXX = g++
CPPFLAGS = -Wall -pedantic -g


# C++SRC should contain all the .cpp files
C++SRC = parser.cpp error.cpp

# create a list of object files by substituting the .cpp in above list with .o
C++OBJ = $(C++SRC:%.cpp=%.o)

parser: y.tab.o lex.yy.o $(C++OBJ)
	g++ -g -o parser y.tab.o lex.yy.o $(C++OBJ) $(LIBDIRS) $(LIBS)

y.tab.c y.tab.h: record.y parser.h error.h
	bison -vyd record.y

y.tab.o: y.tab.c 
	$(CXX) $(CPPFLAGS) -c y.tab.c

lex.yy.c: record.l parser.h y.tab.h error.h
	flex record.l

lex.yy.o: lex.yy.c y.tab.h 
	$(CXX) -g -c lex.yy.c


clean:
	rm -f $(C++OBJ) parser lex.yy.c lex.yy.o \
	y.output y.tab.h y.tab.c y.tab.o 


# dependencies
error.o: error.cpp error.h
parser.o: parser.h record.y error.h
