echo "*****Normal cases"
./lynarr a
./lynarr abc
./lynarr abcdefghijklmnopqrst
echo "*****DONE Normal cases"
echo "*****ERROR cases"
./lynarr 
./lynarr abc adf
./lynarr aBcD
./lynarr A
./lynarr a%b0d
./lynarr abcdefghijklmnopqrstu
echo "*****Done with ERROR cases"
echo " "
./lynarr aabaabbababb 
./lynarr abcdefgh 
./lynarr abababb 
./lynarr abbababaaaba
