sBC: sAB
	sed 's/AB/BC/g' sAB > sBC
	chmod u+x sBC
sCD: sAB
	sed 's/AB/CD/g' sAB > sCD
	chmod u+x sCD
prog.cpp: t1 t2
	cp t1 prog.cpp
	cat t2 >> prog.cpp
progBC.cpp: progAB.cpp
	sed 's/AB/BC/g' progAB.cpp > progBC.cpp
progCD.cpp: progAB.cpp
	sed 's/AB/CD/g' progAB.cpp > progCD.cpp
progAB.o: progAB.cpp
	g++ -c progAB.cpp
progBC.o: progBC.cpp
	g++ -c progBC.cpp
progCD.o: progCD.cpp
	g++ -c progCD.cpp
mAB: prog.cpp progAB.o sAB
	./sAB
mBC: prog.cpp progBC.o sBC
	./sBC
mCD: prog.cpp progCD.o sCD
	./sCD
m1: prog.cpp
	g++ -o m1 prog.cpp -D_d1
m2: prog.cpp
	g++ -o m2 prog.cpp -D_d2
m3: prog.cpp
	g++ -o m3 prog.cpp
all: mAB mBC mCD m1	m2	m3
clean:
	rm mAB
	rm mBC
	rm mCD
	rm m1
	rm m2
	rm m3
	rm progAB.o
	rm progBC.cpp
	rm progBC.o
	rm progCD.cpp
	rm progCD.o
	rm sBC
	rm sCD
	rm prog.cpp
