// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "@forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {ZkSyncChainChecker} from "@foundry-devops/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop public merkleAirdrop;
    BagelToken public bagelToken;
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    address public user;
    address public forwarder;
    uint256 public privateKey;

    uint256 public AMOUNT_FOR_USER = 25 * 1e18;
    uint256 public AIRDROP_TOTAL = 100 * 1e18;
    bytes32[] public PROOF = [
        bytes32(uint256(0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a)),
        bytes32(uint256(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576))
    ];

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (merkleAirdrop, bagelToken) = deployer.deployMerkleAirdrop();
        } else {
            bagelToken = new BagelToken();
            merkleAirdrop = new MerkleAirdrop(ROOT, bagelToken);

            bagelToken.mint(address(merkleAirdrop), AIRDROP_TOTAL);
        }

        (user, privateKey) = makeAddrAndKey("user");
        forwarder = makeAddr("forwarder");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = bagelToken.balanceOf(user);

        bytes32 message = merkleAirdrop.getMessageHash(user, AMOUNT_FOR_USER);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, message);

        vm.prank(user);
        merkleAirdrop.claim(user, AMOUNT_FOR_USER, PROOF, v, r, s);

        uint256 endingBalance = bagelToken.balanceOf(user);
        assertEq(endingBalance - startingBalance, AMOUNT_FOR_USER);
    }

    function testForwarderCanClaim() public {
        uint256 startingBalance = bagelToken.balanceOf(user);

        bytes32 message = merkleAirdrop.getMessageHash(user, AMOUNT_FOR_USER);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, message);

        vm.prank(forwarder);
        merkleAirdrop.claim(user, AMOUNT_FOR_USER, PROOF, v, r, s);

        uint256 endingBalance = bagelToken.balanceOf(user);
        assertEq(endingBalance - startingBalance, AMOUNT_FOR_USER);
    }

    function testClaimedUserCannotClaim() public {
        bytes32 message = merkleAirdrop.getMessageHash(user, AMOUNT_FOR_USER);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, message);

        vm.prank(user);
        merkleAirdrop.claim(user, AMOUNT_FOR_USER, PROOF, v, r, s);

        vm.expectRevert();
        merkleAirdrop.claim(user, AMOUNT_FOR_USER, PROOF, v, r, s);
        vm.stopPrank();
    }

    function testNotUserCannotClaim() public {
        address notClaimer;
        uint256 notClaimerPrivateKey;
        (notClaimer, notClaimerPrivateKey) = makeAddrAndKey("notClaimer");
        vm.startPrank(notClaimer);

        bytes32 message = merkleAirdrop.getMessageHash(notClaimer, AMOUNT_FOR_USER);
        // 1. User has to sign a message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(notClaimerPrivateKey, message);

        vm.expectRevert();
        merkleAirdrop.claim(notClaimer, AMOUNT_FOR_USER, PROOF, v, r, s);
        vm.stopPrank();
    }

    function testGetRoot() public view {
        assertEq(merkleAirdrop.getMerkleRoot(), ROOT);
    }

    function testGetToken() public view {
        assertEq(address(merkleAirdrop.getAirdropToken()), address(bagelToken));
    }
}
