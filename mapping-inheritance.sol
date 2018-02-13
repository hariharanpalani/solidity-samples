pragma solidity ^0.4.18;

contract Owned {
    address owner;
    
    function Owned() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract Courses is Owned {
    struct Instructor {
        uint age;
        string fname;
        string lname;
    }
    
    mapping (address => Instructor) instructors;
    
    address[] public InstructorAccts;
    
    function setInstructor(address _address, uint age, string fname, string lname) onlyOwner public {
        var instructor = instructors[_address];
        
        instructor.age = age;
        instructor.fname = fname;
        instructor.lname = lname;
        
        InstructorAccts.push(_address);
    }
    
    function getInstructors() view public returns(address[]) {
        return InstructorAccts;
    }
    
    function getInstructor(address _address) view public returns(uint, string, string) {
        return (instructors[_address].age, instructors[_address].fname, instructors[_address].lname);
    }
}
