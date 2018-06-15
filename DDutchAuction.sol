pragma solidity ^0.4.2;

import "./DAuction.sol";

contract DDutchAuction is DAuction {

    address public owner;
    uint256 public reservePrice;
    address public judgeAddress;
    address public bidderAddress;
    uint256 public offerPriceDecrement;
    uint256 public numBlocksAuctionOpen;
    uint public judgeHoldingAccount;
    bool public itemRecievedAckFlag;
    bool public securityFlag;


    function DDutchAuction(uint256 _reservePrice, address _judgeAddress, uint256 _numBlocksAuctionOpen, uint256 _offerPriceDecrement) DAuction(_reservePrice, _numBlocksAuctionOpen, _judgeAddress) public {
        //TODO: place your code here
         owner = msg.sender;
         offerPriceDecrement = _offerPriceDecrement;
         judgeAddress = _judgeAddress;
         reservePrice = _reservePrice;
         numBlocksAuctionOpen = _numBlocksAuctionOpen;
         securityFlag = false; // used for preventing double finalizing 
         judgeHoldingAccount = 0;
         itemRecievedAckFlag = false;
    }



    function finalize() auctionOver public {
        //TODO: place your code here
        //if judge calls the bid method
        if(msg.sender == judgeAddress && itemRecievedAckFlag == false && securityFlag == false){
          owner.send(judgeHoldingAccount);
          itemRecievedAckFlag = true;
          judgeHoldingAccount = 0;
          securityFlag = true;
        }
        // when the bidder calls the method
        else if(msg.sender == bidderAddress && securityFlag == false){
          itemRecievedAckFlag = true;
          owner.send(judgeHoldingAccount);
          judgeHoldingAccount = 0;
          securityFlag = true;
        } else {
          assert(false);
        }

    }


    function refund(uint256 refundAmount) public auctionOver judgeOnly {
        //TODO: place your code here
        if(itemRecievedAckFlag == false && securityFlag == false){
          securityFlag = true;
          bidderAddress.send(judgeHoldingAccount);
          judgeHoldingAccount = 0;
        }
    }

    modifier biddingOpen {
      ////TODO: place your code here
      if(numBlocksAuctionOpen <= 0){
        assert(false);
      }
      _;
    }

    modifier auctionOver {
      //TODO: place your code here
      require (numBlocksAuctionOpen > 0);
      _;
    }


    modifier judgeOnly {
      //TODO: place your code here
      require(msg.sender == judgeAddress);
      _;
    }
    
     function getCurrentItemPrice() public returns (uint256){
        return reservePrice + (numBlocksAuctionOpen * offerPriceDecrement);
    }
    

    function bid() public biddingOpen payable returns(address) {
        //TODO: place your code here

        bidderAddress = msg.sender;
        numBlocksAuctionOpen -= 1;
        uint256 currentPrice = getCurrentItemPrice();
           if(msg.value >= currentPrice){
                //prevents second bid
                numBlocksAuctionOpen = 0;
                itemRecievedAckFlag = true;
                if(judgeAddress == 0){
                // since there is no judge sending money automatically
                   owner.send(msg.value);
                   return msg.sender;
                }
                else {
                    judgeHoldingAccount = msg.value;
                }

            }
          else{
            bidderAddress.send(msg.value);
            assert(false);
          }

    }




    //TODO: place your code here
}