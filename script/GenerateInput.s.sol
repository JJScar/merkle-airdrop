// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";

/**
 * @title GenerateInput
 * @author Jordan J. Solomon
 * @notice This script generates the input file for the MerkleAirdrop contract
 */
contract GenerateInput is Script {
    uint256 private constant AMOUNT = 25 * 1e18; // The amount to claim
    string[] types = new string[](2); // There will be to types for an input: The address and the amount
    uint256 count; // Number of "leafs"
    string[] claimers = new string[](4); // List of the claimers
    string private constant INPUT_PATH = "/script/target/input.json"; // Where the input generation will end up

    /**
     * @notice Run the script
     * @dev Setting the data for the input file
     */
    function run() public {
        types[0] = "address";
        types[1] = "uint";
        claimers[0] = "0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D";
        claimers[1] = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
        claimers[2] = "0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd";
        claimers[3] = "0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D";
        count = claimers.length;
        string memory input = _createJSON();
        // Writing to the input file with all the data in json format
        vm.writeFile(string.concat(vm.projectRoot(), INPUT_PATH), input);

        console.log("DONE: The output is found at %s", INPUT_PATH);
    }

    function _createJSON() internal view returns (string memory) {
        string memory countString = vm.toString(count); // convert count to string
        string memory amountString = vm.toString(AMOUNT); // convert amount to string
        string memory json = string.concat('{ "types": ["address", "uint"], "count":', countString, ',"values": {');
        for (uint256 i = 0; i < claimers.length; i++) {
            if (i == claimers.length - 1) {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0":',
                    '"',
                    claimers[i],
                    '"',
                    ', "1":',
                    '"',
                    amountString,
                    '"',
                    " }"
                );
            } else {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0":',
                    '"',
                    claimers[i],
                    '"',
                    ', "1":',
                    '"',
                    amountString,
                    '"',
                    " },"
                );
            }
        }
        json = string.concat(json, "} }");

        return json;
    }
}
