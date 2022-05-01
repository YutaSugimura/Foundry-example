// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";
import {MockToken} from "src/MockToken.sol";

contract ContractTest is Test {
  MockToken token;

  function setUp() public {
    token = new MockToken();
  }

  function testInvariantMetadata() public {
    assertEq(token.name(), "Token");
    assertEq(token.symbol(), "TKN");
    assertEq(token.decimals(), 18);
  }

  function testDeposit() public {
    assertEq(token.balanceOf(msg.sender), 0);
    assertEq(token.totalSupply(), 0);

    SafeTransferLib.safeTransferETH(address(token), 1 ether);

    assertEq(token.balanceOf(address(this)), 1 ether);
    assertEq(token.totalSupply(), 1 ether);
  }

  function testFallbackDeposit() public {
    assertEq(token.balanceOf(address(this)), 0);
    assertEq(token.totalSupply(), 0);

    token.deposit{value: 1 ether}();

    assertEq(token.balanceOf(address(this)), 1 ether);
    assertEq(token.totalSupply(), 1 ether);
  }

  function testWithdraw() public {
    token.deposit{value: 1 ether}();
    assertEq(token.balanceOf(address(this)), 1e18);
    assertEq(token.totalSupply(), 1e18);

    token.withdraw(1e18);
    assertEq(token.balanceOf(address(this)), 0);
  }

  function testPartialWithdraw() public {
    token.deposit{value: 1e18}();

    uint256 balanceBeforeWithdraw = address(this).balance;

    token.withdraw(0.5 ether);

    uint256 balanceAfterWithdraw = address(this).balance;

    assertEq(balanceAfterWithdraw, balanceBeforeWithdraw + 0.5 ether);
    assertEq(token.balanceOf(address(this)), 0.5 ether);
    assertEq(token.totalSupply(), 0.5e18);
    }

  receive() external payable {}
}
