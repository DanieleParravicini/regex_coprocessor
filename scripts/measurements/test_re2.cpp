#include <iostream>
#include <string>
#include <re2/re2.h>
#include <vector>
#include <cassert>
#include <chrono>
#include <list>
#include <math.h>
using namespace std;

int main(int argc, char** argv){
    if (argc < 3 ){
        cout << "arguments: regex string [num of repeats]" << std::endl;
        return 2;
    }
   
    
    int     num_of_repeats = (argc >= 4 ? atoi(argv[3]): 1000000);
    int     matchResult;
    int     expectedResult; 
    string  regex(argv[1]);
    string  str(argv[2]);

	RE2 obj(regex);
	assert(obj.ok());	
    
    for(int i=0; i<num_of_repeats; i++){
	
        
        
		matchResult = RE2::PartialMatch(str, obj);
		if(i==0)
			expectedResult = matchResult;
		assert(expectedResult == matchResult);
        
        

    }

    exit(!matchResult);
}