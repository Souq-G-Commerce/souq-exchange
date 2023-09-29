// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

import "../interfaces/IDIAOracle.sol";
import "../interfaces/IPriceOracleConnector.sol";
import {Errors} from "../libraries/Errors.sol";
import {IAddressesRegistry} from "../interfaces/IAddressesRegistry.sol";
import {IAccessManager} from "../interfaces/IAccessManager.sol";

/**
 * @title DIAPriceOracleConnector
 * @author Souq.Finance
 * @notice The oracle connector stores a mapping of token addresses to oracle addresses
 * and a mapping of addresses to keys (such as BTC/USD)
 * and is used to fetch the correct oracle contract and find the price of
 * a given token by its key from the DIA price feeds as per their standard
 * @notice License: https://souq-peripherals.s3.amazonaws.com/LICENSE.md
 */

contract DIAPriceOracleConnector is IPriceOracleConnector {
    //token address -> oracle address
    mapping(address => address) public oracleFeeds;
    //oracle -> key
    mapping(address => string) public oracleKeys;
    //oracle -> base string
    mapping(address => bytes32) public oracleBases;
    address public immutable addressesRegistry;

    event OracleKeySet(address asset, string key);

    constructor(address registry) {
        require(registry != address(0), Errors.ADDRESS_IS_ZERO);
        addressesRegistry = registry;
    }

    /**
     * @dev modifier for when the the msg sender is oracle admin address
     */
    modifier onlyOracleAdmin() {
        require(
            IAccessManager(IAddressesRegistry(addressesRegistry).getAccessManager()).isOracleAdmin(msg.sender),
            Errors.CALLER_NOT_ORACLE_ADMIN
        );
        _;
    }

    /// @inheritdoc IPriceOracleConnector
    function getTokenOracleContract(address asset) external view returns (address) {
        return oracleFeeds[asset];
    }

    /// @inheritdoc IPriceOracleConnector
    function setTokenOracleContract(address asset, address oracleContract, string calldata base) external onlyOracleAdmin {
        require(asset != address(0), Errors.ADDRESS_IS_ZERO);
        require(oracleContract != address(0), Errors.ADDRESS_IS_ZERO);
        oracleFeeds[asset] = oracleContract;
        oracleBases[oracleContract] = keccak256(bytes(base));
        emit OracleContractSet(asset, oracleContract);
    }

    /**
     * @dev Function to get the key string of an asset
     * @param asset The asset address
     * @return string The key string
     */
    function getTokenOracleKey(address asset) external view returns (string memory) {
        return oracleKeys[asset];
    }

    /**
     * @dev Function to set the key string of an asset
     * @param asset The asset address
     * @param key The key string
     */
    function setTokenOracleKey(address asset, string calldata key) external onlyOracleAdmin {
        require(asset != address(0), Errors.ADDRESS_IS_ZERO);
        oracleKeys[asset] = key;
        emit OracleKeySet(asset, key);
    }

    /// @inheritdoc IPriceOracleConnector
    function getTokenPrice(address asset) external view returns (uint256) {
        address oracleContract = oracleFeeds[asset];
        (uint128 value, ) = IDIAOracle(oracleContract).getValue(oracleKeys[asset]);
        return uint256(value)/100;
    }
}
