// SPDX-License-Identifier: GPL-3.0

//Set the compiler versions
pragma solidity >=0.8.0 <0.9.0;

//Writing the contract "HelloWorld"
contract HelloWorld {
    // Declaring a state variable as unsigned integer
    uint256 myInteger;

    // Defining a function for storing the unsigned integer "myInteger"
    function storeNumber(uint256 x) public {
        //Accepts new data and stores it in "myInteger"
        myInteger = x;
    }

    // Defining a function for retrieving the stored number
    function retrieveNumber() public view returns (uint256) {
        //Return the current value of "myInteger"
        return myInteger;
    }
}
