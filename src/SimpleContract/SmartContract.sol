pragma solidity ^0.4.0;

import './DateTime.sol';

contract SmartContract {
    struct profile {
        address wallet;
        uint summ;
        uint lastMonthSumm;
        bool approve;
    }

    struct releasesAddress {
        address wallet;
        uint amount;
    }

    address owner;
    uint balance;

    uint timestamp;

    profile userA;
    profile userB;

    releasesAddress releasesAddress1;
    releasesAddress releasesAddress2;
    releasesAddress releasesAddress3;

    uint constant firstDayOfMonth = 1;

    modifier allowOnlyOwner() {
        require(owner == msg.sender);
        _;
    }

    function () payable {
        balance += msg.value;
    }

    function destroy() allowOnlyOwner {
        selfdestruct(owner);
    }

    function SmartContract() {
        owner = msg.sender;

        userA.wallet = 0x278d611b934EDFC2d45D5462499243E9D37B5D1B;
        userB.wallet = 0xeDF32850Ed51432E42BDd2e4a764E8F98cef8df1;
        releasesAddress1.wallet = 0x3Ae38314c3263443d3da5Be3e3b3c258af7558C6;
        releasesAddress1.amount = 5 ether;
        releasesAddress2.wallet = 0x032654Df2994839dEa14CDf72adf21387f978A05;
        releasesAddress2.amount = 10 ether;
        releasesAddress3.wallet = 0x1C2fd424ecE804ca1688c91b2A9585bA01534bf6;
        releasesAddress3.amount = 10 ether;
    }

    function balanceContractWei() constant allowOnlyOwner returns (uint) {
        return owner.balance;
    }

    function getBalance() constant allowOnlyOwner returns (uint) {
        return balance;
    }

    function sendEtherToContract(address _address) payable returns (bool) {
        require(
            _address == userA.wallet
            || _address == userB.wallet
        );

        if (_address == userA.wallet) {
            userA.summ += msg.value;
            userA.lastMonthSumm += msg.value;
        } else {
            if (_address == userB.wallet) {
                userB.summ += msg.value;
                userB.lastMonthSumm += msg.value;
            } else {
                return false;
            }
        }

        balance += msg.value;

        owner.transfer(msg.value);

        return true;
    }

    function approveTransactionFromUsers() returns (bool) {
        if (msg.sender == userA.wallet) {
            userA.approve = true;
        } else {
            if (msg.sender == userB.wallet) {
                userB.approve = true;
            } else {
                return false;
            }
        }

        return true;
    }

    function getUserAData() constant returns (address, uint, uint, bool) {
        return (userA.wallet, userA.summ, userA.lastMonthSumm, userA.approve);
    }

    function getUserBData() constant returns (address, uint, uint, bool) {
        return (userB.wallet, userB.summ, userB.lastMonthSumm, userB.approve);
    }

    function updateReleasesAddress1Wallet(address _address) allowOnlyOwner {
        releasesAddress1.wallet = _address;
    }

    function updateReleasesAddress2Wallet(address _address) allowOnlyOwner {
        releasesAddress2.wallet = _address;
    }

    function updateReleasesAddress3Wallet(address _address) allowOnlyOwner {
        releasesAddress3.wallet = _address;
    }

    function updateReleasesAddress1Amount(uint _amount) allowOnlyOwner {
        releasesAddress1.amount = _amount;
    }

    function updateReleasesAddress2Amount(uint _amount) allowOnlyOwner {
        releasesAddress2.amount = _amount;
    }

    function updateReleasesAddress3Amount(uint _amount) allowOnlyOwner {
        releasesAddress3.amount = _amount;
    }

    function updateUserAWallet(address _address) allowOnlyOwner {
        userA.wallet = _address;
    }

    function updateUserBWallet(address _address) allowOnlyOwner {
        userB.wallet = _address;
    }

    function executeContract() {
        DateTime dt = new DateTime();
        if (dt.getDay(now) == firstDayOfMonth && userA.approve == true && userB.approve == true && balance > 100 ether * 0.25) {
            releasesAddress1.wallet.transfer(releasesAddress1.amount);
            releasesAddress2.wallet.transfer(releasesAddress2.amount);
            releasesAddress3.wallet.transfer(releasesAddress2.amount);
            userA.approve == false;
            userB.approve == false;
            userA.lastMonthSumm = 0;
            userB.lastMonthSumm = 0;
            balance -= releasesAddress1.amount;
            balance -= releasesAddress2.amount;
            balance -= releasesAddress3.amount;
            if (balance <= 100 ether * 0.25) {
                //send message notification to users
            }
        }
    }
}