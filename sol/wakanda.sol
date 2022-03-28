// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract ERC20WKND is IERC20 {
    string public constant name = "ERC20Wakanda";
    string public constant symbol = "WKND";
    uint8 public constant decimals = 0;
    uint8 public constant candidates_count_ = 3;

    uint256 totalSupply_ = 6000000;

    mapping(address => Voter) balances;
    mapping(address => mapping(address => uint256)) allowed;

    Candidate[] public candidates;
    Candidate[candidates_count_] public winning_candidates;

    event NewChallenger(
        address indexed candidate,
        uint256 place,
        uint256 voted
    );

    struct Candidate {
        uint256 voted;
        address addr;
    }
    struct Voter {
        uint256 balance;
        bool registered;
    }

    constructor() {}

    function registerVoter() public {
        require(totalSupply_ > 0 && !balances[msg.sender].registered);
        balances[msg.sender].balance = 1;
        balances[msg.sender].registered = true;
        totalSupply_--;
    }

    function getSenderBalance() public view returns (uint256) {
        return balances[msg.sender].balance;
    }

    function getSender() public view returns (address) {
        return msg.sender;
    }

    function addCandidate(address _newCandidate) public {
        require(!isCandidate(_newCandidate));
        balances[msg.sender].balance = 0;
        candidates.push(Candidate({addr: _newCandidate, voted: 0}));
    }

    function vote(address _candidate) public {
        require(
            balances[msg.sender].registered && balances[msg.sender].balance > 0
        );
        transfer(_candidate, getSenderBalance());
        if (isCandidate(_candidate)) {
            candidates[getCandidate(_candidate)].voted = balanceOf(_candidate);
        }
    }

    function isWinCandidate(address _candidate) public view returns (bool) {
        for (uint256 i = 0; i < winning_candidates.length; i++) {
            if (winning_candidates[i].addr == _candidate) {
                return true;
            }
        }
        return false;
    }

    function isCandidate(address _candidate) public view returns (bool) {
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].addr == _candidate) {
                return true;
            }
        }
        return false;
    }

    function getCandidate(address _candidate) private view returns (uint256) {
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].addr == _candidate) {
                return i;
            }
        }
        return 0;
    }

    function winningCandidates() public returns (Candidate[] memory) {
        Candidate[] memory _winning_candidates = new Candidate[](
            candidates_count_
        );

        if (candidates.length >= candidates_count_) {
            for (uint256 j = candidates.length - 1; j > 0; j--) {
                for (uint256 i = 0; i < j; i++) {
                    if (candidates[i].voted > candidates[i + 1].voted) {
                        Candidate memory temp = candidates[i];
                        candidates[i] = candidates[i + 1];
                        candidates[i + 1] = temp;
                    }
                }
            }

            for (uint256 c = 0; c <= candidates_count_ - 1; c++) {
                if (candidates[candidates.length - 1 - c].voted > 0) {
                    if (
                        !isWinCandidate(candidates[c].addr) ||
                        candidates[candidates.length - 1 - c].addr !=
                        winning_candidates[c].addr
                    ) {
                        emit NewChallenger(
                            candidates[c].addr,
                            c + 1,
                            candidates[c].voted
                        );
                    }

                    _winning_candidates[candidates_count_ - c - 1] = candidates[
                        candidates.length - 1 - c
                    ];
                }
            }

            for (uint256 d = 0; d < _winning_candidates.length; d++) {
                if (
                    _winning_candidates.length > 0 &&
                    _winning_candidates[d].voted > 0
                ) {
                    winning_candidates[d] = Candidate({
                        voted: _winning_candidates[d].voted,
                        addr: _winning_candidates[d].addr
                    });
                }
            }
        }
        return _winning_candidates;
    }

    function totalSupply() public view override returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256)
    {
        return balances[tokenOwner].balance;
    }

    function transfer(address receiver, uint256 numTokens)
        public
        override
        returns (bool)
    {
        require(numTokens <= balances[msg.sender].balance);
        balances[msg.sender].balance = balances[msg.sender].balance - numTokens;
        balances[receiver].balance = balances[receiver].balance + numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens)
        public
        override
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        override
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function transferFrom(
        address owner,
        address buyer,
        uint256 numTokens
    ) public override returns (bool) {
        require(numTokens <= balances[owner].balance);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner].balance = balances[owner].balance - numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender] + numTokens;
        balances[buyer].balance = balances[buyer].balance + numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}
