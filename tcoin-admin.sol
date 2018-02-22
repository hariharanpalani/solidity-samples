pragma solidity 0.4.18;

contract admined {
    address public admin;
    
    function admined() public {
        admin = msg.sender;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }
    
    function transferAdmin(address newAdmin) public onlyAdmin{
        admin = newAdmin;
    }
}

contract TCoin {
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    bytes32 public currentChallenge;
    uint public timeOfLastProof;
    uint public difficulty = 10 ** 32;
    
    string public name;
    string public symbol;
    uint8 public decimals;
    string public standard = "TCoin v1.0";
    uint256 totalSupply;
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function TCoin(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits) public {
        balanceOf[msg.sender] = initialSupply;
        name = tokenName;
        symbol = tokenSymbol;
        decimals = decimalUnits;
        totalSupply = initialSupply;
    }
    
    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] > _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }
    
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(balanceOf[_from] > _value);
        require(balanceOf[_to] + _value > _value);
        require(_value < allowance[_from][msg.sender]);
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        
        return true;
    }
}

contract TCoinNew is admined, TCoin {
    uint256 sellPrice;
    uint256 buyPrice;
    uint256 minBalance = 5 finney;
    
    mapping (address => bool) public frozenAccount;
    
    event FroozenFund(address target, bool status);
    
    function TCoinNew(uint initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits, address centralAdmin) 
                        TCoin(0, tokenName, tokenSymbol, decimalUnits) public {
        totalSupply = initialSupply;
        
        if(centralAdmin != 0) {
            admin = centralAdmin;
        } else {
            admin = msg.sender;
        }
        balanceOf[admin] = initialSupply;
    }
    
    function mintToken(address target, uint256 value) public {
        balanceOf[target] =value;
        totalSupply-=value;
        Transfer(0, this, value);
        Transfer(this, target, value);
    }
    
    function Freeze(address _address, bool freeze) public {
        require(msg.sender == admin);
        frozenAccount[_address] = freeze;
        FroozenFund(_address, freeze);
    }
    
    function transfer(address _to, uint256 _value) public {
        if(msg.sender.balance < minBalance)
            sell((minBalance - msg.sender.balance) / sellPrice);
        require(!frozenAccount[msg.sender]);
        require(balanceOf[msg.sender] > _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }
    
    function setPrice(uint256 newBuyPrice, uint256 newSellPrice) public onlyAdmin {
        buyPrice = newBuyPrice;
        sellPrice = newSellPrice;
    }
    
    function buy() public payable {
        uint256 amount = (msg.value / (1 ether)) / buyPrice;
        require(balanceOf[this] > amount);
        balanceOf[this] -= amount;
        balanceOf[msg.sender] += amount;
        Transfer(this, msg.sender, amount);
    }
    
    function sell(uint256 amount) public {
        require(balanceOf[msg.sender] > amount);
        balanceOf[this] += amount;
        balanceOf[msg.sender] -= amount;
        if(!msg.sender.send(amount * sellPrice * 1 ether)) {
            revert();
        } else {
            Transfer(msg.sender, this, amount);
        }
    }
    
    function giveBlockReward() public {
        balanceOf[block.coinbase] += 1;
    }
    
    function proofOfWork(uint nonce) public {
        bytes8 n = bytes8(keccak256(nonce, currentChallenge));
        
        require(n > bytes8(difficulty));
        uint timeSinceLastBlock = (now - timeOfLastProof);
        require(timeSinceLastBlock > 5 seconds);
        balanceOf[msg.sender] += timeSinceLastBlock / 60 seconds;
        difficulty = difficulty * 10 minutes / timeOfLastProof + 1;
        timeOfLastProof = now;
        currentChallenge = keccak256(nonce, currentChallenge, block.blockhash(block.number - 1));
    }
}
