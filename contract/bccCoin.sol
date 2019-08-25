pragma solidity ^0.5.0;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a,"addieren geht so nicht");
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a,"subtrahieren geht so nicht");
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b,"multiplizieren geht so nicht");
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0,"dividieren geht so nicht");
        c = a / b;
    }
}

// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner,"nur der Eigentümer darf das");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner,"neuer Eigentümer übernommen");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and a
// fixed supply
// ----------------------------------------------------------------------------
contract bccCoin is ERC20Interface, Owned {
    using SafeMath for uint;

    // The keyword "public" makes those variables
    // easily readable from outside.
    address public erfinder;
    mapping (address => uint) public salden;
    mapping(address => mapping(address => uint)) allowed;


    string public name;
    uint public decimals;
    string public  symbol;
    uint geldmenge;
    uint gebuehr=10;

    // Events allow light clients to react to
    // changes efficiently.
    event Transfer(address from, address to, uint betrag);
    event Approval(address from, address to, uint betrag);
    event Verschenkt(address from, address to, uint betrag);

    // This is the constructor whose code is
    // run only when the contract is created.
    constructor() public {
        erfinder = msg.sender;
        symbol = "BCCT";
        decimals = 18;
        name = "First Coin Block-Chain-Community";
        geldmenge = 1000000 * 10**uint(decimals);
        salden[erfinder] = geldmenge;
        emit Transfer(address(0), erfinder, geldmenge);
    }

    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return salden[tokenOwner];
    }


    // transfer = senden
    function transfer (address empfaenger, uint betrag) public returns (bool success)  {
        // summe = betrag + gebuehr;
        require(betrag <= salden[msg.sender], "Insufficient balance.");
        salden[msg.sender] -= betrag;
        uint summe = betrag - gebuehr;
        salden[empfaenger] += summe;
        salden[erfinder] += gebuehr;
        emit Transfer(msg.sender, empfaenger, betrag);(msg.sender, empfaenger, betrag);
        return true;
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        salden[from] = salden[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        salden[to] = salden[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () external payable {
        revert("so geht es ja nicht");
    }

    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    //function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
    //    return ERC20Interface(tokenAddress).transfer(owner, tokens);
    //}





    function totalSupply() public view returns (uint) {
        //todo: return _totalSupply.sub(salden[address(0)]);
        return geldmenge;
    }

    // queryBalance = gibSaldo
    function queryBalance(address teilnehmer) public view returns (uint) {
        return salden[teilnehmer];
    }



    // ------------------------------------------------------------------------
    // spezielle Funktionen
    // ------------------------------------------------------------------------
    function schencken(address empfaenger, uint betrag) public payable {
        emit Verschenkt(msg.sender, empfaenger, betrag);
        salden[msg.sender] -= betrag;
        salden[empfaenger] += betrag;
    }

    function gibDetails () public view returns (string memory, uint,address) {
        return (name,geldmenge,erfinder);
    }

    function erzeugen(uint betrag) public payable {
        require(msg.sender == erfinder,"nur einer darf");
        require(betrag < 1e60,"muss was drin sein");
        salden[erfinder] += betrag;
    }

}
