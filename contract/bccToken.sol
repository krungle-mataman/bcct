pragma solidity >=0.5.0 <0.7.0;

contract bccToken {

    // The keyword "public" makes those variables
    // easily readable from outside.
    address public minter;
    mapping (address => uint) public balances;
    string public name;
    uint public constant decimals=18;
    string public constant symbol="BCCT";
    uint geldmenge;
    uint gebuehr=10;

    // Events allow light clients to react to
    // changes efficiently.
    event Sent(address from, address to, uint amount);
    event Verschenkt(address from, address to, uint amount);

    // This is the constructor whose code is
    // run only when the contract is created.
    constructor(string memory n, uint g) public {
        minter = msg.sender;
        name = n;
        geldmenge = g;
    }

    function mint(address receiver, uint amount) public payable {
        require(msg.sender == minter,"nur einer darf");
        require(amount < 1e60,"muss was drin sein");
        balances[receiver] += amount;
    }

    function send(address receiver, uint amount) public payable  {
        require(amount <= balances[msg.sender], "Insufficient balance.");
        balances[msg.sender] -= amount;
        uint summe = amount - gebuehr;
        balances[receiver] += summe;
        balances[minter] += gebuehr;
        emit Sent(msg.sender, receiver, amount);
    }

    function schencken(address receiver, uint amount) public payable {
        emit Verschenkt(msg.sender, receiver, amount);
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
    }

    function gibDetails () public view returns (string memory, uint,address) {
        return (name,geldmenge,minter);
    }





}
