// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    struct AirdropClaim {
        address claimer;
        uint256 amount;
    }

    //* Variables *//
    // address[] s_claimers; // list of the allowed claimers
    mapping(address claimer => bool) private s_hasClaimed; // A mapping that tracks address that either clamied or not
    bytes32 private immutable i_merkleRoot; // the merkle root
    IERC20 private immutable i_airdropToken; // the airdrop token

    bytes32 public constant MESSAGE_TYPEHASH = keccak256("AidropClaim(address claimer, uint256 amount)");

    //* Events *//
    event Claimed(address indexed _claimer, uint256 indexed _amount); // Emitted when the claimer claims the reward

    //* Errors *//
    error MerkleAirdrop__MerkleProofInvalid(); // Used when the merkle proof is invalid
    error MerkleAirdrop__AccountAlreadyClaimed(address _claimer); // Used when the account is already claimed
    error MerkleAirdrop__InvalidSignature(); // Used when the signature is invalid

    //* Modifiers *//
    /**
     * @dev Checks if the account is already claimed
     * @param _claimer - The account to claim the reward
     */
    modifier hasClaimed(address _claimer) {
        if (s_hasClaimed[_claimer]) {
            revert MerkleAirdrop__AccountAlreadyClaimed(_claimer);
        }
        _;
    }

    modifier isSigValid(address _claimer, bytes32 message, uint8 v, bytes32 r, bytes32 s) {
        if (!_isSignatureValid(_claimer, message, v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }
        _;
    }

    /**
     * @param _merkleRoot - deployer passes the merkle root
     * @param _airdropToken - deployer passes the aidrdrop token
     */
    constructor(bytes32 _merkleRoot, IERC20 _airdropToken) EIP712("MerkleAidrop", "1") {
        i_merkleRoot = _merkleRoot;
        i_airdropToken = _airdropToken;
    }

    /**
     *
     * @param _claimer - The account to claim the reward, that needs to be in the list of claimers and the merkle proof (hashed).
     * @param _amount - The amount the claimer wants to claim
     * @param _merkleProof - The merkle proof for the claimer
     */
    function claim(address _claimer, uint256 _amount, bytes32[] calldata _merkleProof, uint8 v, bytes32 r, bytes32 s)
        public
        hasClaimed(_claimer)
        isSigValid(_claimer, getMessageHash(_claimer, _amount), v, r, s)
    {
        // To calculate the leaf we will has the _claimer, _amount and _merkleRoot
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_claimer, _amount))));
        if (!MerkleProof.verify(_merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__MerkleProofInvalid();
        }

        _addClaimerToHasClaimed(_claimer);

        emit Claimed(_claimer, _amount);

        i_airdropToken.safeTransfer(_claimer, _amount);
    }

    // function getClaimers() external view returns (address[] memory) {
    //     return s_claimers;
    // }

    function getMessageHash(address _claimer, uint256 amount) public view returns (bytes32) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({claimer: _claimer, amount: amount}))));
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

    function _isSignatureValid(address _claimer, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == _claimer;
    }

    function _addClaimerToHasClaimed(address _claimer) internal {
        s_hasClaimed[_claimer] = true;
    }
}
