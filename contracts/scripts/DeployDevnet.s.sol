// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "@forge-std/Script.sol";
import {PBHEntryPoint} from "../src/PBHEntryPoint.sol";
import {PBHEntryPointImplV1} from "../src/PBHEntryPointImplV1.sol";
import {PBHSignatureAggregator} from "../src/PBHSignatureAggregator.sol";
import {console} from "forge-std/console.sol";
import {EntryPoint} from "@account-abstraction/contracts/core/EntryPoint.sol";
import {IWorldID} from "@world-id-contracts/interfaces/IWorldID.sol";
import {IPBHEntryPoint} from "../src/interfaces/IPBHEntryPoint.sol";
import {IEntryPoint} from "@account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract DeployDevnet is Script {
    address public entryPoint;
    address public pbhEntryPoint;
    address public pbhEntryPointImpl;
    address public pbhSignatureAggregator;

    address public constant WORLD_ID = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    /// @dev The root of the Test tree.
    uint256 constant INITIAL_ROOT = 0x5276AD6D825269EB0B67A2E1589123DED27C8B8EABFA898FF7E878AD61071AD;
    uint256 public constant MAX_PBH_GAS_LIMIT = 10000000;

    function run() public {
        console.log(
            "Deploying: EntryPoint, PBHEntryPoint, PBHEntryPointImplV1, PBHSignatureAggregator"
        );

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        deployEntryPoint();
        deployPBHEntryPoint();
        deployPBHSignatureAggregator();
        updateWorldID();
        vm.stopBroadcast();
    }

    function deployEntryPoint() public {
        entryPoint = address(new EntryPoint());
        console.log("EntryPoint Deployed at: ", entryPoint);
    }

    function deployPBHEntryPoint() public {
        pbhEntryPointImpl = address(new PBHEntryPointImplV1());
        console.log("PBHEntryPointImplV1 Deployed at: ", pbhEntryPointImpl);
        bytes memory initCallData = abi.encodeCall(
            PBHEntryPointImplV1.initialize,
            (
                IWorldID(WORLD_ID),
                IEntryPoint(entryPoint),
                255,
                address(0x123),
                MAX_PBH_GAS_LIMIT
            )
        );
        pbhEntryPoint = address(
            new PBHEntryPoint(pbhEntryPointImpl, initCallData)
        );
        console.log("PBHEntryPoint Deployed at: ", pbhEntryPoint);
    }

    function deployPBHSignatureAggregator() public {
        pbhSignatureAggregator = address(new PBHSignatureAggregator(pbhEntryPoint, WORLD_ID));
        console.log("PBHSignatureAggregator Deployed at: ", pbhSignatureAggregator);
    }

    function updateWorldID() public {
        bytes memory data = abi.encodeWithSelector(
                bytes4(keccak256("receiveRoot(uint256)")),
                INITIAL_ROOT
            );

        (bool success,) = WORLD_ID.call(
            data
        );
        require(success, "Failed to update WorldID root");
    }
}
