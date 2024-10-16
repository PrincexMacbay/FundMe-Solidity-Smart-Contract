// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;



    uint256 public constant MINIMUM_USD = 5e18;
    // 21,415 gas - constant
    // 23,515 gas - non-constant
    // 21, 415 * 141000000000 = $9.058545
    // 23,515 *  141000000000 = $9.946845


    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;
    // 21,508 gas - immutable
    // 23,644 gas - non-immutable

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable{
    // Allow users to send $
    // Have a minimum $ sent $5
    // 1. How do we send  ETH to this contract

    //Get the ETH to USD conversion rate for the amount of ETH sent
    uint256 ethAmountInUsd = msg.value.getConversionRate();
    require(ethAmountInUsd >= MINIMUM_USD, "Didn't send enough ETH"); // 1e18 = 1 ETH = 1000000000000000000 = 1 * 10 ** 18
    funders.push(msg.sender);
    addressToAmountFunded[msg.sender] += msg.value;
    }

    
    //What is a revert
    // Undo any actions that have been done and send the remaining gas back

    // function withdraw() public {}

    function withdraw() public onlyOwner {

        // for loop
        // [1, 2, 3, 4]  elements
        //  0, 1, 2, 3 - Indexes
        // for (/* starting index, ending index, step amount */)
        // 0, 10, 1)
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;

        }

        // reset the array
        // withdraw the funds   
        funders = new address [] (0);

        // transfer
        // msg.sender = address
        // payable(msg.sender).transfer(address(this).balance)
        // payable(msg.sender).transfer(address(this).balance);

        // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");

    }

    modifier onlyOwner () {
        // require(msg.sender == i_owner, "Sender is not owner!");
        if (msg.sender != i_owner) { revert NotOwner(); }
        _;
    }

    // What happens if someone sends this contract ETH without calling the fund  function

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

}