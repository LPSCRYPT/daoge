pragma solidity ^0.7.0;

// Import OpenZeppelin's ERC20 interface defenition
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract daoge {
  address public creator;
  mapping(address => bool) adminList;
  mapping(address => bool) userList;
  struct Proposal {
    address author;
    uint256 timestamp;
    bool removed;
    string content;
    uint256 numID;
  }
  uint256 public proposalNum;
  Proposal[] proposalList;
  mapping(address => uint256) timer;

  string internal constant TIME_LOCKED =
    'You must wait to perform any additional actions.';
  string internal constant NOT_USER = 'You are not a user.';
  string internal constant NOT_ADMIN = 'You are not an admin.';
  string internal constant ALREADY_ADMIN = 'User is already an admin.';
  string internal constant ALREADY_USER = 'User is already registered.';
  string internal constant PROPOSAL_NA = 'PROPOSAL does not exist.';
  string internal constant PROPOSAL_REMOVED =
    'PROPOSAL has been removed by an admin.';
  string internal constant REMOVE_ADMIN = 'You cannot delete an admin account.';
  string internal constant USER_NA = 'User does not exist.';

  event OnboardAdmin(address admin);
  event OnboardUser(address user);
  event NewProposal(
    address author,
    uint256 timestamp,
    string content,
    uint256 proposalID
  );
  event UserRemoved(address removedUser, address removedBy);
  event ProposalRemoved(uint256 proposalID, address removedBy);

  IERC20 public renDoge;

  constructor(IERC20 _token) {
    creator = msg.sender;
    adminList[creator] = true;
    userList[creator] = true;
    emit OnboardAdmin(creator);
    renDoge = _token;
  }

  function addAdmin(address newAdmin) public {
    require(adminList[msg.sender] == true, NOT_ADMIN);
    require(adminList[newAdmin] == false, ALREADY_ADMIN);
    adminList[newAdmin] = true;
    if (!userList[newAdmin]) {
      userList[newAdmin] = true;
    }
    emit OnboardAdmin(newAdmin);
  }

  function addUser(address newUser) public {
    require(userList[msg.sender] == true, NOT_USER);
    require(userList[newUser] == false, ALREADY_USER);
    userList[newUser] = true;
    emit OnboardUser(newUser);
  }

  function addProposal(string memory content) public {
    require(userList[msg.sender] == true, NOT_USER);
    require(renDoge.balanceOf(msg.sender) >= (50000 * (10**18)));
    proposalList.push(
      Proposal(msg.sender, block.timestamp, false, content, proposalNum)
    );
    emit NewProposal(msg.sender, block.timestamp, content, proposalNum);
    proposalNum++;
  }

  function removeUser(address removedUser) public {
    require(adminList[msg.sender] == true, NOT_ADMIN);
    require(adminList[removedUser] == false, REMOVE_ADMIN);
    require(userList[removedUser] == true, USER_NA);
    userList[removedUser] = false;
    emit UserRemoved(removedUser, msg.sender);
  }

  function removeProposal(uint256 proposalID) public {
    require(adminList[msg.sender] == true, NOT_ADMIN);
    require(proposalID >= 0 && proposalID <= proposalNum, PROPOSAL_NA);
    require(proposalList[proposalID].removed == false, PROPOSAL_REMOVED);
    proposalList[proposalID].removed = true;
    proposalList[proposalID].content = PROPOSAL_REMOVED;
    emit ProposalRemoved(proposalID, msg.sender);
  }

  function getProposalById(uint256 proposalID)
    public
    view
    returns (
      address,
      uint256,
      bool,
      string memory,
      uint256
    )
  {
    require(proposalID >= 0 && proposalID <= proposalNum, PROPOSAL_NA);
    return (
      proposalList[proposalID].author,
      proposalList[proposalID].timestamp,
      proposalList[proposalID].removed,
      proposalList[proposalID].content,
      proposalList[proposalID].numID
    );
  }

  function checkUser(address user) public view returns (bool) {
    bool check = false;
    if (userList[user] == true) {
      check = true;
    }
    return check;
  }

  function checkAdmin(address admin) public view returns (bool) {
    bool check = false;
    if (adminList[admin] == true) {
      check = true;
    }
    return check;
  }

  function getproposalNum() public view returns (uint256) {
    return proposalNum;
  }
}
