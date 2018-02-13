pragma solidity ^0.4.18;

contract Coursetro {
    /*string public name = 'Hariharan';
    
    uint public age = 34;
    
    function Coursetro() public {
        name = 'Hariharan';
        age = 34;
    }*/
    
    string name;
    uint age;
    address owner;
    
    function Coursetro() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    event Instructor(string name, uint age);
    
    
    function setInstructor(string _name, uint _age) onlyOwner public  {
        name = _name;
        age = _age;
        Instructor(name, age);
    }
    
    function getInstructor() public constant returns (string, uint) {
        return (name, age);
    }
}
