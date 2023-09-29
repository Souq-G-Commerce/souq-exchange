// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

/**
 * @title IDIAOracle
 * @author Souq.Finance
 * @notice The interface for the DIA Price Feed Oracle Contracts
 */
interface IDIAOracle {
    /**
     * @dev Function to get the value and timestamp of a pair key
     * @param key The key string
     * @return tuple uint128, uint128 representing the value and timestamp respectively
     */
    function getValue(string memory key) external view returns (uint128, uint128);
}
