CXX = g++
CFLAGS = -Wall -O2 -std=c++11
LIBS = -lboost_system -lboost_thread -lpthread
SRCS = $(wildcard *.cpp */*.cpp */*/*.cpp)
OBJS = $(patsubst %.cpp, %.o, $(SRCS))

TARGET = target

$(TARGET) : $(OBJS)
		$(CXX) -o $(TARGET) $^ $(LIBS)

#all:$(OBJS)
$(OBJS): %.o : %.cpp
		$(CXX) -fPIC -c $< -o $@ $(CFLAGS)

clean:
		rm $(TARGET) $(OBJS) -rf
