// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Test.sol";
import "../src/TimedToken.sol";

contract TimedTokenTest is Test {
    TimedToken public token;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        token = new TimedToken();
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
    }

    function testInitialState() public view {
        assertEq(token.name(), "TimeToken");
        assertEq(token.symbol(), "TTK");
        assertEq(token.decimals(), 18);
        assertEq(token.TOTAL_SUPPLY(), 100000 * 10**18);
        assertEq(token.REWARD_AMOUNT(), 1 * 10**18);
        assertEq(token.REWARD_INTERVAL(), 48 hours);
        assertEq(token.balanceOf(address(token)), 100000 * 10**18);
        assertEq(token.owner(), owner);
    }

    function testClaimTokens() public {
        vm.prank(user1);
        token.claimTokens();
        assertEq(token.balanceOf(user1), 1 * 10**18);
        assertEq(token.balanceOf(address(token)), 99999 * 10**18);

        // Try to claim again immediately (should fail)
        vm.expectRevert("Claim not available yet");
        vm.prank(user1);
        token.claimTokens();

        // Advance time and claim again
        vm.warp(block.timestamp + 48 hours);
        vm.prank(user1);
        token.claimTokens();
        assertEq(token.balanceOf(user1), 2 * 10**18);
    }

    function testMultipleUsersClaim() public {
        vm.prank(user1);
        token.claimTokens();
        
        vm.prank(user2);
        token.claimTokens();

        assertEq(token.balanceOf(user1), 1 * 10**18);
        assertEq(token.balanceOf(user2), 1 * 10**18);
        assertEq(token.balanceOf(address(token)), 99998 * 10**18);
    }

    function testSetRewardAmount() public {
        uint256 newRewardAmount = 2 * 10**18;
        token.setRewardAmout(newRewardAmount);
        assertEq(token.REWARD_AMOUNT(), newRewardAmount);

        // Test that non-owner can't set reward amount
        vm.prank(user1);
        vm.expectRevert("Only owner can call this function");
        token.setRewardAmout(3 * 10**18);
    }

    function testSetRewardInterval() public {
        uint256 newRewardInterval = 24 hours;
        token.setRewardInterval(newRewardInterval);
        assertEq(token.REWARD_INTERVAL(), newRewardInterval);

        // Test that non-owner can't set reward interval
        vm.prank(user1);
        vm.expectRevert("Only owner can call this function");
        token.setRewardInterval(12 hours);
    }

    function testTransferOwnership() public {
        token.transferOwnership(user1);
        assertEq(token.owner(), user1);

        // Test that old owner can't transfer ownership anymore
        vm.expectRevert("Only owner can call this function");
        token.transferOwnership(user2);

        // Test that new owner can transfer ownership
        vm.prank(user1);
        token.transferOwnership(user2);
        assertEq(token.owner(), user2);
    }

    function testCannotTransferToZeroAddress() public {
        vm.expectRevert("Invalid address");
        token.transferOwnership(address(0));
    }
}
