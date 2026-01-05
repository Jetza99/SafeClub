// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract SafeClub {
    address public owner;

    mapping(address => bool) public isMember;
    address[] public members;

    struct Proposal {
        uint256 amount;
        address payable recipient;
        string description;
        uint256 deadline;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
    }

    Proposal[] public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    bool private locked;



    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

        modifier nonReentrant() {
        require(!locked, "Reentrancy blocked");
        locked = true;
        _;
        locked = false;
    }


    constructor() {
        owner = msg.sender;
        isMember[msg.sender] = true;
        members.push(msg.sender);
    }

    function addMember(address _member) external onlyOwner {
        require(_member != address(0), "Invalid address");
        require(!isMember[_member], "Already a member");

        isMember[_member] = true;
        members.push(_member);
    }

    function removeMember(address _member) external onlyOwner {
        require(isMember[_member], "Not a member");

        isMember[_member] = false;

        // Remove from array (swap & pop)
        for (uint256 i = 0; i < members.length; i++) {
            if (members[i] == _member) {
                members[i] = members[members.length - 1];
                members.pop();
                break;
            }
        }
    }

    function getMembers() external view returns (address[] memory) {
        return members;
    }

// Allow contract to receive ETH
    receive() external payable {}

    fallback() external payable {}

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

        function createProposal(
        uint256 _amount,
        address payable _recipient,
        string calldata _description,
        uint256 _duration
    ) external {
        require(isMember[msg.sender], "Not a member");
        require(_amount > 0, "Amount must be > 0");
        require(_recipient != address(0), "Invalid recipient");
        require(_duration > 0, "Invalid duration");
        require(_amount <= address(this).balance, "Insufficient treasury");

        Proposal memory newProposal = Proposal({
            amount: _amount,
            recipient: _recipient,
            description: _description,
            deadline: block.timestamp + _duration,
            votesFor: 0,
            votesAgainst: 0,
            executed: false
        });

        proposals.push(newProposal);
    }

        function voteOnProposal(uint256 _proposalId, bool _support) external {
        require(isMember[msg.sender], "Not a member");
        require(_proposalId < proposals.length, "Invalid proposal");
        
        Proposal storage proposal = proposals[_proposalId];

        require(block.timestamp <= proposal.deadline, "Voting ended");
        require(!proposal.executed, "Already executed");
        require(!hasVoted[_proposalId][msg.sender], "Already voted");

        hasVoted[_proposalId][msg.sender] = true;

        if (_support) {
            proposal.votesFor += 1;
        } else {
            proposal.votesAgainst += 1;
        }
    }

        function executeProposal(uint256 _proposalId) external nonReentrant {
        require(_proposalId < proposals.length, "Invalid proposal");

        Proposal storage proposal = proposals[_proposalId];

        require(block.timestamp > proposal.deadline, "Voting not ended");
        require(!proposal.executed, "Already executed");
        require(proposal.votesFor > proposal.votesAgainst, "Proposal rejected");
        require(proposal.amount <= address(this).balance, "Insufficient balance");

        // Effects
        proposal.executed = true;

        // Interaction
        (bool success, ) = proposal.recipient.call{value: proposal.amount}("");
        require(success, "ETH transfer failed");
    }



}
