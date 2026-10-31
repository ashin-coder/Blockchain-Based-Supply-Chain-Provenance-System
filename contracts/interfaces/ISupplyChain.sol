// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ISupplyChain
/// @notice Interface for tracking a product's journey from producer to consumer.
interface ISupplyChain {
    enum Status { Created, InTransit, Received, Delivered, Recalled }

    struct Product {
        uint256 id;
        string  name;
        string  batchId;
        string  origin;
        address producer;
        address currentOwner;
        address pendingOwner;   // recipient while in transit
        Status  status;
        bytes32 metadataHash;   // hash of off-chain product details
        bool    certified;
        uint256 createdAt;
    }

    /// One step in a product's history.
    struct Checkpoint {
        Status  status;
        address actor;
        string  location;
        uint256 timestamp;
    }

    event ParticipantRegistered(address indexed account, bytes32 indexed role, string name);
    event ProductRegistered(uint256 indexed productId, address indexed producer, string batchId);
    event ShipmentStarted(uint256 indexed productId, address indexed from, address indexed to);
    event OwnershipTransferred(uint256 indexed productId, address indexed from, address indexed to);
    event ProductDelivered(uint256 indexed productId, address indexed retailer);
    event ProductCertified(uint256 indexed productId, address indexed regulator, bytes32 certificateHash);
    event ProductRecalled(uint256 indexed productId, address indexed regulator, string reason);

    /// Admin onboards a stakeholder with a role.
    function registerParticipant(address account, bytes32 role, string calldata name) external;

    /// Producer registers a new product and gets its unique ID.
    function registerProduct(
        string calldata name,
        string calldata batchId,
        string calldata origin,
        bytes32 metadataHash
    ) external returns (uint256 productId);

    /// Current owner ships the product to a distributor or retailer.
    function shipProduct(uint256 productId, address to, string calldata location) external;

    /// Recipient confirms arrival and becomes the new owner.
    function receiveProduct(uint256 productId, string calldata location) external;

    /// Retailer records the final sale to a consumer.
    function deliverProduct(uint256 productId, string calldata location) external;

    /// Regulator certifies a product (certificate stored off-chain, hash on-chain).
    function certifyProduct(uint256 productId, bytes32 certificateHash) external;

    /// Regulator recalls a product; no further transfers allowed.
    function recallProduct(uint256 productId, string calldata reason) external;

    function getProduct(uint256 productId) external view returns (Product memory);
    function getHistory(uint256 productId) external view returns (Checkpoint[] memory);

    /// True if the product is certified and not recalled.
    function verifyProduct(uint256 productId) external view returns (bool authentic);
}
