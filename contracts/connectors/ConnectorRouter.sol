// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {DataTypes} from "../libraries/DataTypes.sol";
import {IConnectorRouter} from "../interfaces/IConnectorRouter.sol";
import {Errors} from "../libraries/Errors.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IAccessManager} from "../interfaces/IAccessManager.sol";
import {IAddressesRegistry} from "../interfaces/IAddressesRegistry.sol";

/**
 * @title ConnectorRouter
 * @author Souq.Finance
 * @notice The main router contract between the Pools/Vaults and the connectors.
 * It provides the addresses of configured connectors such as price oracle connectors,
 * swap exchanges, staking connectors, collection connectors and
 * stablecoin yield connectors.
 * @notice License: https://souq-peripherals.s3.amazonaws.com/LICENSE.md
 */

contract ConnectorRouter is Initializable, UUPSUpgradeable, OwnableUpgradeable, IConnectorRouter {
    uint256 public version;
    //vault => yield distributor
    mapping(address => address) public yieldDistributor;

    //token => staking contract
    mapping(address => address) public stakingContracts;

    //token => swap contract
    mapping(address => address) public swapContracts;

    //token => price oracle connector
    mapping(address => address) public oracleConnectors;

    IAddressesRegistry public addressesRegistry;

    //liquidity pool => collection connector
    mapping(address => address) public collectionConnectors;

    //token => stablecoin yield connector
    mapping(address => address) public stablecoinYieldConnectors;

    /// @inheritdoc IConnectorRouter
    function initialize(address registry) external initializer {
        require(registry != address(0), Errors.ADDRESS_IS_ZERO);
        addressesRegistry = IAddressesRegistry(registry);
        version = 1;
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    /**
     * @dev modifier for when the the msg sender is the connector admin
     */
    modifier connectorAdminOnly() {
        require(IAccessManager(addressesRegistry.getAccessManager()).isConnectorAdmin(msg.sender), Errors.CALLER_NOT_CONNECTOR_ADMIN);
        _;
    }

    /*
     * Yield Distributor Functions
     */

    /// @inheritdoc IConnectorRouter
    function getYieldDistributor(address vaultAddress) external view returns (address) {
        require(yieldDistributor[vaultAddress] != address(0), Errors.YIELD_DISTRIBUTOR_NOT_FOUND);
        return yieldDistributor[vaultAddress];
    }

    /// @inheritdoc IConnectorRouter
    function setYieldDistributor(address vaultAddress, address yieldDistributorAddress) external connectorAdminOnly {
        require(vaultAddress != address(0), Errors.INVALID_VAULT_ADDRESS);
        require(yieldDistributorAddress != address(0), Errors.INVALID_YIELD_DISTRIBUTOR_ADDRESS);
        yieldDistributor[vaultAddress] = yieldDistributorAddress;
        emit YieldDistributorSet(vaultAddress, yieldDistributorAddress);
    }

    /// @inheritdoc IConnectorRouter
    function deleteYieldDistributor(address vaultAddress) external connectorAdminOnly {
        require(yieldDistributor[vaultAddress] != address(0), Errors.YIELD_DISTRIBUTOR_NOT_FOUND);
        delete yieldDistributor[vaultAddress];
        emit YieldDistributorDeleted(vaultAddress);
    }

    /*
     * Staking Functions
     */

    /// @inheritdoc IConnectorRouter
    function getStakingContract(address tokenAddress) external view returns (address) {
        require(stakingContracts[tokenAddress] != address(0), Errors.STAKING_CONTRACT_NOT_FOUND);
        return stakingContracts[tokenAddress];
    }

    /// @inheritdoc IConnectorRouter
    function setStakingContract(address tokenAddress, address stakingContractAddress) external connectorAdminOnly {
        require(tokenAddress != address(0), Errors.INVALID_TOKEN_ADDRESS);
        require(stakingContractAddress != address(0), Errors.INVALID_STAKING_CONTRACT);
        stakingContracts[tokenAddress] = stakingContractAddress;
        emit StakingContractSet(tokenAddress, stakingContractAddress);
    }

    /// @inheritdoc IConnectorRouter
    function deleteStakingContract(address tokenAddress) external connectorAdminOnly {
        require(stakingContracts[tokenAddress] != address(0), Errors.STAKING_CONTRACT_NOT_FOUND);
        delete stakingContracts[tokenAddress];
        emit StakingContractDeleted(tokenAddress);
    }

    /*
     * Swap Contract Functions
     */

    /// @inheritdoc IConnectorRouter
    function getSwapContract(address tokenAddress) external view returns (address) {
        require(swapContracts[tokenAddress] != address(0), Errors.SWAP_CONTRACT_NOT_FOUND);
        return swapContracts[tokenAddress];
    }

    /// @inheritdoc IConnectorRouter
    function setSwapContract(address tokenIn, address tokenOut, address swapContractAddress) external connectorAdminOnly {
        require(tokenOut != address(0), Errors.INVALID_TOKEN_ADDRESS);
        require(swapContractAddress != address(0), Errors.INVALID_ORACLE_CONNECTOR);
        swapContracts[tokenOut] = swapContractAddress;
        IERC20(tokenIn).approve(swapContractAddress, 2 ** 256 - 1);
        emit SwapContractSet(tokenOut, swapContractAddress);
    }

    /// @inheritdoc IConnectorRouter
    function deleteSwapContract(address tokenAddress) external connectorAdminOnly {
        require(swapContracts[tokenAddress] != address(0), Errors.SWAP_CONTRACT_NOT_FOUND);
        delete swapContracts[tokenAddress];
        emit SwapContractDeleted(tokenAddress);
    }

    /*
     * Oracle Connector Functions
     */

    /// @inheritdoc IConnectorRouter
    function getOracleConnectorContract(address tokenAddress) external view returns (address) {
        require(oracleConnectors[tokenAddress] != address(0), Errors.ORACLE_CONNECTOR_NOT_FOUND);
        return oracleConnectors[tokenAddress];
    }

    /// @inheritdoc IConnectorRouter
    function setOracleConnectorContract(address tokenAddress, address oracleConnectorAddress) external connectorAdminOnly {
        require(tokenAddress != address(0), Errors.INVALID_TOKEN_ADDRESS);
        require(oracleConnectorAddress != address(0), Errors.INVALID_ORACLE_CONNECTOR);
        oracleConnectors[tokenAddress] = oracleConnectorAddress;
        emit OracleConnectorSet(tokenAddress, oracleConnectorAddress);
    }

    /// @inheritdoc IConnectorRouter
    function deleteOracleConnectorContract(address tokenAddress) external connectorAdminOnly {
        require(oracleConnectors[tokenAddress] != address(0), Errors.ORACLE_CONNECTOR_NOT_FOUND);
        delete oracleConnectors[tokenAddress];
        emit OracleConnectorDeleted(tokenAddress);
    }

    /*
     * Collection Connector Functions
     */

    /// @inheritdoc IConnectorRouter
    function getCollectionConnectorContract(address collection) external view returns (address) {
        require(collectionConnectors[collection] != address(0), Errors.COLLECTION_CONTRACT_NOT_FOUND);
        return collectionConnectors[collection];
    }

    /// @inheritdoc IConnectorRouter
    function setCollectionConnectorContract(address collection, address collectionConnectorAddress) external connectorAdminOnly {
        require(collection != address(0), Errors.INVALID_COLLECTION_CONTRACT);
        collectionConnectors[collection] = collectionConnectorAddress;
        emit CollectionConnectorSet(collection, collectionConnectorAddress);
    }

    /// @inheritdoc IConnectorRouter
    function deleteCollectionConnectorContract(address collection) external connectorAdminOnly {
        require(collectionConnectors[collection] != address(0), Errors.COLLECTION_CONTRACT_NOT_FOUND);
        delete collectionConnectors[collection];
        emit CollectionConnectorDeleted(collection);
    }

    /*
     * StablecoinYield Connector Functions
     */

    /// @inheritdoc IConnectorRouter
    function getStablecoinYieldConnectorContract(address tokenAddress) external view returns (address) {
        require(stablecoinYieldConnectors[tokenAddress] != address(0), Errors.STABLECOIN_YIELD_CONNECTOR_NOT_FOUND);
        return stablecoinYieldConnectors[tokenAddress];
    }

    /// @inheritdoc IConnectorRouter
    function setStablecoinYieldConnectorContract(address tokenAddress, address stablecoinYieldConnectorAddress) external connectorAdminOnly {
        require(tokenAddress != address(0), Errors.INVALID_TOKEN_ADDRESS);
        require(stablecoinYieldConnectorAddress != address(0), Errors.INVALID_STABLECOIN_YIELD_CONNECTOR);
        stablecoinYieldConnectors[tokenAddress] = stablecoinYieldConnectorAddress;
        emit StablecoinYieldConnectorSet(tokenAddress, stablecoinYieldConnectorAddress);
    }

    /// @inheritdoc IConnectorRouter
    function deleteStablecoinYieldConnectorContract(address tokenAddress) external connectorAdminOnly {
        require(stablecoinYieldConnectors[tokenAddress] != address(0), Errors.STABLECOIN_YIELD_CONNECTOR_NOT_FOUND);
        delete stablecoinYieldConnectors[tokenAddress];
        emit StablecoinYieldConnectorDeleted(tokenAddress);
    }

    /**
     * @dev Internal function to permit the upgrade of the proxy.
     * @param newImplementation The new implementation contract address used for the upgrade.
     */
    function _authorizeUpgrade(address newImplementation) internal override connectorAdminOnly {
        require(newImplementation != address(0), Errors.ADDRESS_IS_ZERO);
        ++version;
    }
}
