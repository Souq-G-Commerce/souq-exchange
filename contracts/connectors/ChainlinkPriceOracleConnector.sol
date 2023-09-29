// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../interfaces/IPriceOracleConnector.sol";
import {Errors} from "../libraries/Errors.sol";
import {IAddressesRegistry} from "../interfaces/IAddressesRegistry.sol";
import {IAccessManager} from "../interfaces/IAccessManager.sol";


/**
 * @title ChainlinkPriceOracleConnector
 * @author Souq.Finance
 * @notice The oracle connector stores a mapping of token addresses to oracle addresses
 * and is used to fetch the correct oracle contract and find the price of
 * a given token from chainlink price feeds
 * @notice License: https://souq-peripherals.s3.amazonaws.com/LICENSE.md
 */

contract ChainlinkPriceOracleConnector is IPriceOracleConnector {
    //token address -> oracle address
    mapping(address => address) public oracleFeeds;
    //oracle -> base
    mapping(address => bytes32) public oracleBases;
    address public immutable addressesRegistry;
    address public ETHOracle;

    constructor(address registry, address newETHOracle) {
        require(registry != address(0), Errors.ADDRESS_IS_ZERO);
        require(newETHOracle != address(0), Errors.ADDRESS_IS_ZERO);
        ETHOracle = newETHOracle;
        addressesRegistry = registry;
    }

    function setETHOracle(address newETHOracle) external onlyOracleAdmin {
        require(newETHOracle != address(0), Errors.ADDRESS_IS_ZERO);
        ETHOracle = newETHOracle;
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

    /// @inheritdoc IPriceOracleConnector
    function getTokenPrice(address asset) external view returns (uint256) {
        address oracleContract = oracleFeeds[asset];
        int price;
        (, price, , , ) = AggregatorV3Interface(oracleContract).latestRoundData();
        if(oracleBases[oracleContract] == keccak256(bytes("ETH")))
        {
            (, int ethPrice, , , ) = AggregatorV3Interface(ETHOracle).latestRoundData();
            return (uint256(price) * uint256(ethPrice))/(10**(AggregatorV3Interface(ETHOracle).decimals()+AggregatorV3Interface(oracleContract).decimals()-6));
        }else
        {
            return uint256(price)/(10**(AggregatorV3Interface(oracleContract).decimals()-6));
        }
    }

}
