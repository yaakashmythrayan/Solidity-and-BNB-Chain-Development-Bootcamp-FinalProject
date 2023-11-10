//SPDX-License-Identifier:MIT
pragma solidity 0.8.19;
import "@openzeppelin/contracts/utils/Counters.sol";

contract FinalProject
{

using Counters for Counters.Counter;
Counters.Counter private _counter;

address private owner;

struct User
{
address walletAddress;
string name;
uint balance;
uint rewards;
uint start;
uint end;
uint lock_period;
uint lock_amount;
Status status;
}

enum Status
{
Not_Started,
Started
}

event UserAdded(address indexed walletAddress,string name);
event Deposit(address indexed walletAddress,uint amount);
event UserLocked(address indexed walletAddress,uint amount,uint lock_period,uint balance);
event UserUnlocked(address indexed walletAddress,uint rewards,uint balance);

mapping(address=>User) private users;

constructor()
{
    owner = msg.sender;
}

modifier onlyOwner()
{
    require(msg.sender==owner,"Only the owner can call this function");
    _;
}

function addUser(string calldata name)external
{
    require(!isUser(msg.sender),"User already exists");
    users[msg.sender]=User(msg.sender,name,0,0,0,0,0,0,Status.Not_Started);
    _counter.increment();

    emit UserAdded(msg.sender,users[msg.sender].name);
}

function deposit()external payable
{
    require(isUser(msg.sender),"User does not exist");
    users[msg.sender].balance += msg.value;

    emit Deposit(msg.sender,msg.value);
}

function lock(uint amount,uint lock_period) external
{
    require(isUser(msg.sender),"User does not exist");
    users[msg.sender].lock_amount=amount;
    users[msg.sender].lock_period=lock_period;

    uint balance=users[msg.sender].balance;

    users[msg.sender].status=Status.Started;
    require(balance>=amount,"User has insufficient balance");

    unchecked
    {
    users[msg.sender].balance-=amount;
    }

    users[msg.sender].start=block.timestamp;
    users[msg.sender].end=lock_period*2592000;    

    emit UserLocked(users[msg.sender].walletAddress,users[msg.sender].lock_amount,users[msg.sender].lock_period,users[msg.sender].balance);
}

function unlock() external
{
    require(isUser(msg.sender),"User does not exist");
    require(isTimeCompleted(msg.sender),"Lock-In Period Not Completed");

    users[msg.sender].rewards+=calculateRewards(users[msg.sender].walletAddress);
    users[msg.sender].balance+=users[msg.sender].lock_amount;
    
    users[msg.sender].status=Status.Not_Started;
    users[msg.sender].start=0;
    users[msg.sender].end=0;
    users[msg.sender].lock_amount=0;
    users[msg.sender].lock_period=0;

    emit UserUnlocked(users[msg.sender].walletAddress,users[msg.sender].rewards,users[msg.sender].balance);
     
}
function calculateRewards(address walletAddress)private view returns(uint256)
{
    return ((users[walletAddress].lock_amount*users[walletAddress].lock_period*12)/(12*100));
}

function isTimeCompleted(address walletAddress)private pure returns(bool a)
{
   /*if((users[walletAddress].start-block.timestamp)==users[walletAddress].end)
   {
      return true;
   }
   else
   {
      return false;
   }*/
   if(walletAddress != address(0))
   {
    return true;
   }
}

function getOwner()external view returns(address)
{
    return owner;
}

function getUser(address walletAddress)external view returns(User memory)
{
    require(isUser(walletAddress),"User does not exist");
    return users[walletAddress];
}

function getCurrentUserCount() external view onlyOwner returns(uint)
{
    return _counter.current();
}

function isUser(address walletAddress)private view returns(bool)
{
    return users[walletAddress].walletAddress != address(0);
}

}
