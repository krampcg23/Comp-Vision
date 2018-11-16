g++ = g++
CFLAGS = -std=c++11
choice = -O3
main = main.cpp
quote = `pkg-config --cflags --libs tesseract opencv`
all: main_exe

main_exe:$(main)
	$(g++)	$(choice)	$(CFLAGS)	$(main)	$(quote)	-o	$@

clean:
	rm *_exe
