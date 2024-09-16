// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {SafeERC20Upgradeable, IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {IAlgebraFactory} from "@cryptoalgebra/integral-core/contracts/interfaces/IAlgebraFactory.sol";

import {BlastGovernorClaimableSetup} from "../integration/BlastGovernorClaimableSetup.sol";
import {IBribe} from "../bribes/interfaces/IBribe.sol";
import {IBribeFactory} from "../bribes/interfaces/IBribeFactory.sol";
import {IGauge} from "../gauges/interfaces/IGauge.sol";
import {IGaugeFactory} from "../gauges/interfaces/IGaugeFactory.sol";
import {IMinter} from "./interfaces/IMinter.sol";
import {IPairInfo} from "../dexV2/interfaces/IPairInfo.sol";
import {IPairFactory} from "../dexV2/interfaces/IPairFactory.sol";
import {IVotingEscrow} from "./interfaces/IVotingEscrow.sol";
import {IVault} from "./interfaces/IVault.sol";
import {IVoter} from "./interfaces/IVoter.sol";
import {IPairIntegrationInfo} from "../integration/interfaces/IPairIntegrationInfo.sol";
import {IManagedNFTManager} from "../nest/interfaces/IManagedNFTManager.sol";
import {IVotingEscrowV1_2} from "./interfaces/IVotingEscrowV1_2.sol";
import {IMerklDistributor} from "../integration/interfaces/IMerklDistributor.sol";
import {IVeFnxSplitMerklAidrop} from "./interfaces/IVeFnxSplitMerklAidrop.sol";

contract VoterUpgradeableV1_2 is IVoter, BlastGovernorClaimableSetup, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bool internal initflag;

    address public _ve; // the ve token that governs these contracts
    address[] internal _factories; // Array with all the pair factories
    address internal base; // $fnx token
    address[] internal _gaugeFactories; // array with all the gauge factories
    address public bribefactory; // bribe factory (internal and external)
    address public minter; // minter mints $fnx each epoch
    address[] public pools; // all pools viable for incentives
    address public admin;
    address public governance;

    uint256 internal index; // gauge index
    uint256 internal constant DURATION = 7 days; // rewards are released over 7 days
    uint256 public VOTE_DELAY; // delay between votes in seconds
    uint256 public constant MAX_VOTE_DELAY = 7 days; // Max vote delay allowed

    mapping(address => uint256) internal supplyIndex; // gauge    => index
    mapping(address => uint256) public claimable; // gauge    => claimable $fnx
    mapping(address => address) public gauges; // pool     => gauge
    mapping(address => uint256) public gaugesDistributionTimestmap; // gauge    => last Distribution Time
    mapping(address => address) public poolForGauge; // gauge    => pool
    mapping(address => address) public internal_bribes; // gauge    => internal bribe (only fees)
    mapping(address => address) public external_bribes; // gauge    => external bribe (real bribes)
    mapping(uint256 => mapping(address => uint256)) public votes; // nft      => pool     => votes
    mapping(uint256 => address[]) public poolVote; // nft      => pools
    mapping(uint256 => mapping(address => uint256)) public weightsPerEpoch; // timestamp => pool => weights
    mapping(uint256 => uint256) internal totalWeightsPerEpoch; // timestamp => total weights
    mapping(uint256 => uint256) public lastVoted; // nft      => timestamp of last vote
    mapping(address => bool) public isGauge; // gauge    => boolean [is a gauge?]
    mapping(address => bool) public isWhitelisted; // token    => boolean [is an allowed token?]
    mapping(address => bool) public isAlive; // gauge    => boolean [is the gauge alive?]
    mapping(address => bool) public isFactory; // factory  => boolean [the pair factory exists?]
    mapping(address => bool) public isGaugeFactory; // g.factory=> boolean [the gauge factory exists?]

    event GaugeCreated(
        address indexed gauge,
        address creator,
        address internal_bribe,
        address indexed external_bribe,
        address indexed pool
    );
    event GaugeKilled(address indexed gauge);
    event GaugeRevived(address indexed gauge);
    event Voted(address indexed voter, uint256 tokenId, uint256 weight);
    event Abstained(uint256 tokenId, uint256 weight);
    event NotifyReward(address indexed sender, address indexed reward, uint256 amount);
    event DistributeReward(address indexed sender, address indexed gauge, uint256 amount);
    event Whitelisted(address indexed whitelister, address indexed token);
    event Blacklisted(address indexed blacklister, address indexed token);

    event SetMinter(address indexed old, address indexed latest);
    event SetBribeFactory(address indexed old, address indexed latest);
    event SetPairFactory(address indexed old, address indexed latest);
    event SetGaugeFactory(address indexed old, address indexed latest);
    event SetBribeFor(bool isInternal, address indexed old, address indexed latest, address indexed gauge);
    event SetVoteDelay(uint256 old, uint256 latest);
    event AddFactories(address indexed pairfactory, address indexed gaugefactory);

    event SetGovernance(address indexed oldGovernance, address indexed newGovernance);
    event SetVoterAdmin(address indexed oldAdmin, address indexed newAdmin);

    constructor(address blastGovernor_) {
        __BlastGovernorClaimableSetup_init(blastGovernor_);
        _disableInitializers();
    }

    address[] public clPools; // all pools viable for incentives

    function initialize(
        address blastGovernor_,
        address __ve,
        address _pairFactory,
        address _gaugeFactory,
        address _bribes
    ) external initializer {
        __BlastGovernorClaimableSetup_init(blastGovernor_);
        __ReentrancyGuard_init();

        admin = msg.sender;
        governance = msg.sender;
        _ve = __ve;
        base = IVotingEscrow(__ve).token();

        _factories.push(_pairFactory);
        isFactory[_pairFactory] = true;

        _gaugeFactories.push(_gaugeFactory);
        isGaugeFactory[_gaugeFactory] = true;

        bribefactory = _bribes;

        minter = msg.sender;

        VOTE_DELAY = 0;
        initflag = false;
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    MODIFIERS
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    modifier VoterAdmin() {
        require(msg.sender == admin, "VOTER_ADMIN");
        _;
    }

    modifier Governance() {
        require(msg.sender == governance, "GOVERNANCE");
        _;
    }

    /// @notice initialize the voter contract
    /// @param  _tokens array of tokens to whitelist
    /// @param  _minter the minter of $fnx
    function _init(address[] memory _tokens, address _minter) external {
        require(msg.sender == admin);
        require(!initflag);
        for (uint256 i = 0; i < _tokens.length; i++) {
            _whitelist(_tokens[i]);
        }
        minter = _minter;
        initflag = true;
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    VoterAdmin
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @notice set vote delay in seconds
    function setVoteDelay(uint256 _delay) external VoterAdmin {
        require(_delay != VOTE_DELAY, "already set");
        require(_delay <= MAX_VOTE_DELAY, "max delay");
        emit SetVoteDelay(VOTE_DELAY, _delay);
        VOTE_DELAY = _delay;
    }

    /// @notice Set a new VoterAdmin
    function setVoterAdmin(address _admin) external VoterAdmin {
        require(_admin != address(0), "addr0");
        emit SetVoterAdmin(admin, _admin);
        admin = _admin;
    }

    /// @notice Set a new Governance
    function setGovernance(address _governance) external Governance {
        require(_governance != address(0), "addr0");
        emit SetGovernance(governance, _governance);
        governance = _governance;
    }

    /// @notice Set a new Minter
    function setMinter(address _minter) external VoterAdmin {
        require(_minter != address(0), "addr0");
        require(_minter.code.length > 0, "!contract");
        emit SetMinter(minter, _minter);
        minter = _minter;
    }

    /// @notice Set a new Bribe Factory
    function setBribeFactory(address _bribeFactory) external VoterAdmin {
        require(_bribeFactory.code.length > 0, "!contract");
        require(_bribeFactory != address(0), "addr0");
        emit SetBribeFactory(bribefactory, _bribeFactory);
        bribefactory = _bribeFactory;
    }

    /// @notice Set a new bribes for a given gauge
    function setNewBribes(address _gauge, address _internal, address _external) external VoterAdmin {
        require(isGauge[_gauge], "!gauge");
        require(_gauge.code.length > 0, "!contract");
        _setInternalBribe(_gauge, _internal);
        _setExternalBribe(_gauge, _external);
    }

    /// @notice Set a new internal bribe for a given gauge
    function setInternalBribeFor(address _gauge, address _internal) external VoterAdmin {
        require(isGauge[_gauge], "!gauge");
        _setInternalBribe(_gauge, _internal);
    }

    /// @notice Set a new External bribe for a given gauge
    function setExternalBribeFor(address _gauge, address _external) external VoterAdmin {
        require(isGauge[_gauge], "!gauge");
        _setExternalBribe(_gauge, _external);
    }

    function _setInternalBribe(address _gauge, address _internal) private {
        require(_internal.code.length > 0, "!contract");
        emit SetBribeFor(true, internal_bribes[_gauge], _internal, _gauge);
        internal_bribes[_gauge] = _internal;
    }

    function _setExternalBribe(address _gauge, address _external) private {
        require(_external.code.length > 0, "!contract");
        emit SetBribeFor(false, internal_bribes[_gauge], _external, _gauge);
        external_bribes[_gauge] = _external;
    }

    function addFactory(address _pairFactory, address _gaugeFactory) external VoterAdmin {
        require(_pairFactory != address(0), "addr0");
        require(_gaugeFactory != address(0), "addr0");
        //require(!isFactory[_pairFactory], "fact");
        //require(!isGaugeFactory[_gaugeFactory], 'gFact');
        require(_pairFactory.code.length > 0, "!contract");
        require(_gaugeFactory.code.length > 0, "!contract");

        _factories.push(_pairFactory);
        _gaugeFactories.push(_gaugeFactory);
        isFactory[_pairFactory] = true;
        isGaugeFactory[_gaugeFactory] = true;
        emit AddFactories(_pairFactory, _gaugeFactory);
    }

    function replaceFactory(address _pairFactory, address _gaugeFactory, uint256 _pos) external VoterAdmin {
        require(_pairFactory != address(0), "addr0");
        require(_gaugeFactory != address(0), "addr0");
        require(isFactory[_pairFactory], "!fact");
        require(isGaugeFactory[_gaugeFactory], "!gFact");
        address oldPF = _factories[_pos];
        address oldGF = _gaugeFactories[_pos];
        isFactory[oldPF] = false;
        isGaugeFactory[oldGF] = false;

        _factories[_pos] = (_pairFactory);
        _gaugeFactories[_pos] = (_gaugeFactory);
        isFactory[_pairFactory] = true;
        isGaugeFactory[_gaugeFactory] = true;

        emit SetGaugeFactory(oldGF, _gaugeFactory);
        emit SetPairFactory(oldPF, _pairFactory);
    }

    function removeFactory(uint256 _pos) external VoterAdmin {
        address oldPF = _factories[_pos];
        address oldGF = _gaugeFactories[_pos];

        require(isFactory[oldPF], "!fact");
        require(isGaugeFactory[oldGF], "!gFact");
        _factories[_pos] = address(0);
        _gaugeFactories[_pos] = address(0);
        isFactory[oldPF] = false;
        isGaugeFactory[oldGF] = false;
        emit SetGaugeFactory(oldGF, address(0));
        emit SetPairFactory(oldPF, address(0));
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    GOVERNANCE
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @notice Whitelist a token for gauge creation
    function whitelist(address[] memory _token) external Governance {
        uint256 i = 0;
        for (i = 0; i < _token.length; i++) {
            _whitelist(_token[i]);
        }
    }

    function _whitelist(address _token) private {
        require(!isWhitelisted[_token], "in");
        require(_token.code.length > 0, "!contract");
        isWhitelisted[_token] = true;
        emit Whitelisted(msg.sender, _token);
    }

    /// @notice Blacklist a malicious token
    function blacklist(address[] memory _token) external Governance {
        uint256 i = 0;
        for (i = 0; i < _token.length; i++) {
            _blacklist(_token[i]);
        }
    }

    function _blacklist(address _token) private {
        require(isWhitelisted[_token], "out");
        isWhitelisted[_token] = false;
        emit Blacklisted(msg.sender, _token);
    }

    /// @notice Kill a malicious gauge
    /// @param  _gauge gauge to kill
    function killGauge(address _gauge) external Governance {
        require(isAlive[_gauge], "killed");
        isAlive[_gauge] = false;

        uint256 _claimable = claimable[_gauge];
        if (_claimable > 0) {
            IERC20Upgradeable(base).safeTransfer(minter, _claimable);
            delete claimable[_gauge];
        }

        uint _time = _epochTimestamp();
        totalWeightsPerEpoch[_time] -= weightsPerEpoch[_time][poolForGauge[_gauge]];

        emit GaugeKilled(_gauge);
    }

    /// @notice Revive a malicious gauge
    /// @param  _gauge gauge to revive
    function reviveGauge(address _gauge) external Governance {
        require(!isAlive[_gauge], "alive");
        require(isGauge[_gauge], "killed");
        isAlive[_gauge] = true;
        emit GaugeRevived(_gauge);
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    USER INTERACTION
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @notice Reset the votes of a given TokenID
    function reset(uint256 _tokenId) external nonReentrant {
        _voteDelay(_tokenId);

        require(IVotingEscrow(_ve).isApprovedOrOwner(msg.sender, _tokenId), "!approved/Owner");
        _reset(_tokenId);
        IVotingEscrow(_ve).abstain(_tokenId);
        lastVoted[_tokenId] = _epochTimestamp() + 1;
    }

    function _reset(uint256 _tokenId) internal {
        address[] storage _poolVote = poolVote[_tokenId];
        uint256 _poolVoteCnt = _poolVote.length;
        uint256 _totalWeight = 0;
        uint256 _time = _epochTimestamp();

        for (uint256 i = 0; i < _poolVoteCnt; i++) {
            address _pool = _poolVote[i];
            uint256 _votes = votes[_tokenId][_pool];
            if (_votes != 0) {
                votes[_tokenId][_pool] -= _votes;

                // if user last vote is < than epochTimestamp then votes are 0! IF not underflow occur
                if (lastVoted[_tokenId] > _time) {
                    weightsPerEpoch[_time][_pool] -= _votes;

                    IBribe(internal_bribes[gauges[_pool]]).withdraw(uint256(_votes), _tokenId);
                    IBribe(external_bribes[gauges[_pool]]).withdraw(uint256(_votes), _tokenId);

                    // if is alive remove _votes, else don't because we already done it in killGauge()
                    if (isAlive[gauges[_pool]]) _totalWeight += _votes;
                }

                emit Abstained(_tokenId, _votes);
            }
        }

        // if user last vote is < than epochTimestamp then _totalWeight is 0! IF not underflow occur
        if (lastVoted[_tokenId] < _time) _totalWeight = 0;

        totalWeightsPerEpoch[_time] -= _totalWeight;
        delete poolVote[_tokenId];
    }

    /// @notice Recast the saved votes of a given TokenID
    function poke(uint256 _tokenId) external nonReentrant {
        _checkStartVoteWindow();
        require(IVotingEscrow(_ve).isApprovedOrOwner(msg.sender, _tokenId), "!approved/Owner");
        _poke(_tokenId);
    }

    /// @notice Vote for pools
    /// @param  _tokenId    veNFT tokenID used to vote
    /// @param  _poolVote   array of LPs addresses to vote  (eg.: [sAMM usdc-usdt   , sAMM busd-usdt, vAMM wbnb-the ,...])
    /// @param  _weights    array of weights for each LPs   (eg.: [10               , 90            , 45             ,...])
    function vote(uint256 _tokenId, address[] calldata _poolVote, uint256[] calldata _weights) external nonReentrant {
        _voteDelay(_tokenId);

        require(IVotingEscrow(_ve).isApprovedOrOwner(msg.sender, _tokenId), "!approved/Owner");
        require(_poolVote.length == _weights.length, "Pool/Weights length !=");

        IManagedNFTManager managedNFTManagerCache = IManagedNFTManager(managedNFTManager);
        require(!managedNFTManagerCache.isDisabledNFT(_tokenId), "disabled managed nft");

        if (!managedNFTManagerCache.isWhitelistedNFT(_tokenId)) {
            _checkEndVoteWindow();
        }

        _vote(_tokenId, _poolVote, _weights);

        lastVoted[_tokenId] = _epochTimestamp() + 1;
    }

    function _vote(uint256 _tokenId, address[] memory _poolVote, uint256[] memory _weights) internal {
        _reset(_tokenId);
        uint256 _poolCnt = _poolVote.length;
        uint256 _weight = IVotingEscrow(_ve).balanceOfNFT(_tokenId);
        uint256 _totalVoteWeight = 0;
        uint256 _totalWeight = 0;
        uint256 _usedWeight = 0;
        uint256 _time = _epochTimestamp();

        for (uint i = 0; i < _poolCnt; i++) {
            if (isAlive[gauges[_poolVote[i]]]) _totalVoteWeight += _weights[i];
        }

        for (uint256 i = 0; i < _poolCnt; i++) {
            address _pool = _poolVote[i];
            address _gauge = gauges[_pool];

            if (isGauge[_gauge] && isAlive[_gauge]) {
                uint256 _poolWeight = (_weights[i] * _weight) / _totalVoteWeight;

                require(votes[_tokenId][_pool] == 0);
                require(_poolWeight != 0);

                poolVote[_tokenId].push(_pool);
                weightsPerEpoch[_time][_pool] += _poolWeight;

                votes[_tokenId][_pool] += _poolWeight;

                IBribe(internal_bribes[_gauge]).deposit(uint256(_poolWeight), _tokenId);
                IBribe(external_bribes[_gauge]).deposit(uint256(_poolWeight), _tokenId);

                _usedWeight += _poolWeight;
                _totalWeight += _poolWeight;
                emit Voted(msg.sender, _tokenId, _poolWeight);
            }
        }
        if (_usedWeight > 0) IVotingEscrow(_ve).voting(_tokenId);
        totalWeightsPerEpoch[_time] += _totalWeight;
    }

    /// @notice claim LP gauge rewards
    function claimRewards(address[] memory _gauges) public {
        for (uint256 i = 0; i < _gauges.length; i++) {
            IGauge(_gauges[i]).getReward(msg.sender);
        }
    }

    /// @notice claim bribes rewards given a TokenID
    function claimBribes(address[] memory _bribes, address[][] memory _tokens, uint256 _tokenId) public {
        require(IVotingEscrow(_ve).isApprovedOrOwner(msg.sender, _tokenId), "!approved/Owner");
        for (uint256 i = 0; i < _bribes.length; i++) {
            IBribe(_bribes[i]).getRewardForOwner(_tokenId, _tokens[i]);
        }
    }

    /// @notice claim fees rewards given a TokenID
    function claimFees(address[] memory _fees, address[][] memory _tokens, uint256 _tokenId) public {
        require(IVotingEscrow(_ve).isApprovedOrOwner(msg.sender, _tokenId), "!approved/Owner");
        for (uint256 i = 0; i < _fees.length; i++) {
            IBribe(_fees[i]).getRewardForOwner(_tokenId, _tokens[i]);
        }
    }

    /// @notice claim bribes rewards given an address
    function claimBribes(address[] memory _bribes, address[][] memory _tokens) public {
        for (uint256 i = 0; i < _bribes.length; i++) {
            IBribe(_bribes[i]).getRewardForAddress(msg.sender, _tokens[i]);
        }
    }

    /// @notice claim fees rewards given an address
    function claimFees(address[] memory _bribes, address[][] memory _tokens) public {
        for (uint256 i = 0; i < _bribes.length; i++) {
            IBribe(_bribes[i]).getRewardForAddress(msg.sender, _tokens[i]);
        }
    }

    /// @notice check if user can vote
    function _voteDelay(uint256 _tokenId) internal view {
        require(block.timestamp > lastVoted[_tokenId] + VOTE_DELAY, "ERR: VOTE_DELAY");
        _checkStartVoteWindow();
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    GAUGE CREATION
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    function createCustomGauge(
        address gauge_,
        address pool_,
        address tokenA_,
        address tokenB_,
        string memory externalBribesName_,
        string memory internalBribesName_
    ) external nonReentrant Governance returns (address gauge, address internalBribe, address externalBribe) {
        require(!isGauge[gauge_]);
        require(gauges[pool_] == address(0));

        gauge = gauge_;
        internalBribe = IBribeFactory(bribefactory).createBribe(tokenA_, tokenB_, internalBribesName_);
        externalBribe = IBribeFactory(bribefactory).createBribe(tokenA_, tokenB_, externalBribesName_);

        IERC20Upgradeable(base).approve(gauge, type(uint256).max);

        // save data
        internal_bribes[gauge] = internalBribe;
        external_bribes[gauge] = externalBribe;
        gauges[pool_] = gauge;
        poolForGauge[gauge] = pool_;
        isGauge[gauge] = true;
        isAlive[gauge] = true;
        pools.push(pool_);

        // update index
        supplyIndex[gauge] = index; // new gauges are set to the default global state

        emit GaugeCreated(gauge, msg.sender, internalBribe, externalBribe, pool_);
    }

    /// @notice create multiple gauges
    function createGauges(
        address[] memory _pool,
        uint256[] memory _gaugeTypes
    ) external nonReentrant Governance returns (address[] memory, address[] memory, address[] memory) {
        require(_pool.length == _gaugeTypes.length, "len mismatch");
        require(_pool.length <= 10, "max 10");
        address[] memory _gauge = new address[](_pool.length);
        address[] memory _int = new address[](_pool.length);
        address[] memory _ext = new address[](_pool.length);

        uint256 i = 0;
        for (i; i < _pool.length; i++) {
            (_gauge[i], _int[i], _ext[i]) = _createGauge(_pool[i], _gaugeTypes[i]);
        }
        return (_gauge, _int, _ext);
    }

    /// @notice create a gauge
    function createGauge(
        address _pool,
        uint256 _gaugeType
    ) external nonReentrant Governance returns (address _gauge, address _internal_bribe, address _external_bribe) {
        (_gauge, _internal_bribe, _external_bribe) = _createGauge(_pool, _gaugeType);
    }

    function _prepareBeforeCreate(
        address _pool,
        uint256 _gaugeType
    ) internal returns (address gaugeFactory, address tokenA, address tokenB, address feeVault, bool isDistributeEmissionToMerkle) {
        require(_gaugeType < _factories.length, "gaugetype");
        require(gauges[_pool] == address(0x0), "!exists");
        require(_pool.code.length > 0, "!contract");

        bool isPair;
        address _factory = _factories[_gaugeType];
        gaugeFactory = _gaugeFactories[_gaugeType];
        require(_factory != address(0), "addr0");
        require(gaugeFactory != address(0), "addr0");

        tokenA = IPairIntegrationInfo(_pool).token0();
        tokenB = IPairIntegrationInfo(_pool).token1();

        // for future implementation add isPair() in factory
        if (_gaugeType == 0) {
            // v2 pairs
            isPair = IPairFactory(_factory).isPair(_pool);
            feeVault = IPairIntegrationInfo(_pool).communityVault();
        } else if (_gaugeType == 1) {
            // v3 pairs
            address poolFromFactory = IAlgebraFactory(_factory).poolByPair(tokenA, tokenB);
            require(_pool == poolFromFactory, "wrong tokens");
            isPair = true;
            isDistributeEmissionToMerkle = true;
            clPools.push(_pool);
            feeVault = IPairIntegrationInfo(_pool).communityVault();
        } else if (_gaugeType == 2) {
            // v3 pairs but with ICHI Vault
            address poolFromFactory = IAlgebraFactory(_factory).poolByPair(tokenA, tokenB);

            address poolFromIchi = IVault(_pool).pool();

            require(poolFromIchi == poolFromFactory, "wrong tokens");
            isDistributeEmissionToMerkle = true;
            clPools.push(_pool);
            feeVault = IPairIntegrationInfo(poolFromFactory).communityVault();
        }

        // gov can create for any pool, even non-Fenix pairs
        if (!(governance == msg.sender)) {
            require(isPair, "!_pool");
            require(isWhitelisted[tokenA] && isWhitelisted[tokenB], "!whitelisted");
            require(tokenA != address(0) && tokenB != address(0), "!pair.tokens");
        }
    }

    /// @notice create a gauge
    /// @param  _pool       LP address
    /// @param  _gaugeType  the type of the gauge you want to create
    /// @dev    To create stable/Volatile pair gaugeType = 0, Concentrated liqudity = 1, ...
    ///         Make sure to use the corrcet gaugeType or it will fail

    function _createGauge(
        address _pool,
        uint256 _gaugeType
    ) internal returns (address _gauge, address _internal_bribe, address _external_bribe) {
        (address gaugeFactory, address tokenA, address tokenB, address feeVault, bool isDistributeEmissionToMerkle) = _prepareBeforeCreate(
            _pool,
            _gaugeType
        );

        string memory symbol;
        if (_gaugeType == 1) {
            symbol = string.concat(IERC20Metadata(tokenA).symbol(), "/", IERC20Metadata(tokenB).symbol());
        } else {
            symbol = IERC20Metadata(_pool).symbol();
        }

        // create internal and external bribe
        string memory _type = string.concat("Fenix LP Fees: ", symbol);
        _internal_bribe = IBribeFactory(bribefactory).createBribe(tokenA, tokenB, _type);

        _type = string.concat("Fenix Bribes: ", symbol);
        _external_bribe = IBribeFactory(bribefactory).createBribe(tokenA, tokenB, _type);

        // create gauge
        _gauge = IGaugeFactory(gaugeFactory).createGauge(
            base,
            _ve,
            _pool,
            address(this),
            _internal_bribe,
            _external_bribe,
            isDistributeEmissionToMerkle,
            feeVault
        );

        // approve spending for $fnx
        IERC20Upgradeable(base).approve(_gauge, type(uint256).max);

        // save data
        internal_bribes[_gauge] = _internal_bribe;
        external_bribes[_gauge] = _external_bribe;
        gauges[_pool] = _gauge;
        poolForGauge[_gauge] = _pool;
        isGauge[_gauge] = true;
        isAlive[_gauge] = true;
        pools.push(_pool);

        // update index
        supplyIndex[_gauge] = index; // new gauges are set to the default global state

        emit GaugeCreated(_gauge, msg.sender, _internal_bribe, _external_bribe, _pool);
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    VIEW FUNCTIONS
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @notice view the total length of the pools
    function length() external view returns (uint256) {
        return pools.length;
    }

    /// @notice view the total length of the pools
    function poolsList() external view returns (address[] memory) {
        return pools;
    }

    /// @notice view the total length of the pools
    function clLength() external view returns (uint256) {
        return clPools.length;
    }

    /// @notice view the total length of the pools
    function clPoolsList() external view returns (address[] memory) {
        return clPools;
    }

    /// @notice view the total length of the voted pools given a tokenId
    function poolVoteLength(uint256 tokenId) external view returns (uint256) {
        return poolVote[tokenId].length;
    }

    function factories() external view returns (address[] memory) {
        return _factories;
    }

    function factoryLength() external view returns (uint256) {
        return _factories.length;
    }

    function gaugeFactories() external view returns (address[] memory) {
        return _gaugeFactories;
    }

    function gaugeFactoriesLength() external view returns (uint256) {
        return _gaugeFactories.length;
    }

    function weights(address _pool) public view returns (uint256) {
        uint256 _time = _epochTimestamp();
        return weightsPerEpoch[_time][_pool];
    }

    function weightsAt(address _pool, uint256 _time) public view returns (uint256) {
        return weightsPerEpoch[_time][_pool];
    }

    function totalWeight() public view returns (uint256) {
        uint256 _time = _epochTimestamp();
        return totalWeightsPerEpoch[_time];
    }

    function totalWeightAt(uint256 _time) public view returns (uint256) {
        return totalWeightsPerEpoch[_time];
    }

    function _epochTimestamp() public view returns (uint256) {
        return IMinter(minter).active_period();
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    DISTRIBUTION
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @notice notify reward amount for gauge
    /// @dev    the function is called by the minter each epoch. Anyway anyone can top up some extra rewards.
    /// @param  amount  amount to distribute
    function notifyRewardAmount(uint256 amount) external {
        require(msg.sender == minter, "!minter");
        IERC20Upgradeable(base).safeTransferFrom(msg.sender, address(this), amount);

        uint256 _totalWeight = totalWeightAt(_epochTimestamp() - 1 weeks); // minter call notify after updates active_period, loads votes - 1 week

        uint256 _ratio = 0;

        if (_totalWeight > 0) _ratio = (amount * 1e18) / _totalWeight; // 1e18 adjustment is removed during claim
        if (_ratio > 0) {
            index += _ratio;
        }

        emit NotifyReward(msg.sender, base, amount);
    }

    /// @notice distribute the LP Fees to the internal bribes
    /// @param  _gauges  gauge address where to claim the fees
    /// @dev    the gauge is the owner of the LPs so it has to claim
    function distributeFees(address[] memory _gauges) external {
        for (uint256 i = 0; i < _gauges.length; i++) {
            if (isGauge[_gauges[i]] && isAlive[_gauges[i]]) {
                IGauge(_gauges[i]).claimFees();
            }
        }
    }

    /// @notice Distribute the emission for ALL gauges
    function distributeAll() external nonReentrant {
        IMinter(minter).update_period();

        uint256 x = 0;
        uint256 stop = pools.length;
        for (x; x < stop; x++) {
            _distribute(gauges[pools[x]]);
        }
    }

    /// @notice distribute the emission for N gauges
    /// @param  start   start index point of the pools array
    /// @param  finish  finish index point of the pools array
    /// @dev    this function is used in case we have too many pools and gasLimit is reached
    function distribute(uint256 start, uint256 finish) public nonReentrant {
        IMinter(minter).update_period();
        for (uint256 x = start; x < finish; x++) {
            _distribute(gauges[pools[x]]);
        }
    }

    /// @notice distribute reward onyl for given gauges
    /// @dev    this function is used in case some distribution fails
    function distribute(address[] memory _gauges) external nonReentrant {
        IMinter(minter).update_period();
        for (uint256 x = 0; x < _gauges.length; x++) {
            _distribute(_gauges[x]);
        }
    }

    /// @notice distribute the emission
    function _distribute(address _gauge) internal {
        uint256 lastTimestamp = gaugesDistributionTimestmap[_gauge];
        uint256 currentTimestamp = _epochTimestamp();
        if (lastTimestamp < currentTimestamp) {
            _updateForAfterDistribution(_gauge); // should set claimable to 0 if killed

            uint256 _claimable = claimable[_gauge];

            // distribute only if claimable is > 0, currentEpoch != lastepoch and gauge is alive
            if (_claimable > 0 && isAlive[_gauge]) {
                claimable[_gauge] = 0;
                gaugesDistributionTimestmap[_gauge] = currentTimestamp;
                IGauge(_gauge).notifyRewardAmount(base, _claimable);
                emit DistributeReward(msg.sender, _gauge, _claimable);
            }
        }
    }

    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    HELPERS
    --------------------------------------------------------------------------------
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @notice update info for gauges
    /// @dev    this function track the gauge index to emit the correct $fnx amount after the distribution
    function _updateForAfterDistribution(address _gauge) private {
        address _pool = poolForGauge[_gauge];
        uint256 _time = _epochTimestamp() - 604800;
        uint256 _supplied = weightsPerEpoch[_time][_pool];

        if (_supplied > 0) {
            uint256 _supplyIndex = supplyIndex[_gauge];
            uint256 _index = index; // get global index0 for accumulated distro
            supplyIndex[_gauge] = _index; // update _gauge current position to global position
            uint256 _delta = _index - _supplyIndex; // see if there is any difference that need to be accrued
            if (_delta > 0) {
                uint256 _share = (_supplied * _delta) / 1e18; // add accrued difference for each supplied token
                if (isAlive[_gauge]) {
                    claimable[_gauge] += _share;
                } else {
                    IERC20Upgradeable(base).safeTransfer(minter, _share);
                }
            }
        } else {
            supplyIndex[_gauge] = index; // new users are set to the default global state
        }
    }

    /*///////////////////////////////////////////////////////////////
                    Managed NFT & Distribution Window Logic 
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the distribution window duration is set or updated.
    /// @param duration New duration of the distribution window in seconds.
    event SetDistributionWindowDuration(uint256 indexed duration);

    /// @notice Emitted when the managed NFT manager is set or updated.
    /// @param managedNFTManager Address of the new managed NFT manager.
    event SetManagedNFTManager(address indexed managedNFTManager);

    /// @notice Emitted when a token is attached to a managed NFT.
    /// @param tokenId ID of the user's token that is being attached.
    /// @param managedTokenId ID of the managed token to which the user's token is attached.
    event AttachToManagedNFT(uint256 indexed tokenId, uint256 indexed managedTokenId);

    /// @notice Emitted when a token is detached from a managed NFT.
    /// @param tokenId ID of the user's token that is being detached.
    event DettachFromManagedNFT(uint256 indexed tokenId);

    /// @dev Constant for a week's duration in seconds, used for time-based calculations.
    uint256 internal constant _WEEK = 86400 * 7;

    /// @notice Address of the managed NFT manager contract.
    address public managedNFTManager;

    /// @notice Current duration of the distribution window, in seconds.
    uint256 public distributionWindowDuration;

    /**
     * @notice Attaches a tokenId to a managed tokenId.
     * @dev Requires the sender to be the owner or approved on the voting escrow contract.
     * @param tokenId_ The user's tokenId to be attached.
     * @param managedTokenId_ The managed tokenId to attach to.
     */
    function attachToManagedNFT(uint256 tokenId_, uint256 managedTokenId_) external nonReentrant {
        require(IVotingEscrow(_ve).isApprovedOrOwner(msg.sender, tokenId_), "!approved/Owner");
        _voteDelay(tokenId_);
        _checkEndVoteWindow();

        IManagedNFTManager(managedNFTManager).onAttachToManagedNFT(tokenId_, managedTokenId_);

        _poke(managedTokenId_);

        emit AttachToManagedNFT(tokenId_, managedTokenId_);
    }

    /**
     * @notice Detaches a tokenId from its managed tokenId.
     * @dev Requires the sender to be the owner or approved. Also adjusts the voting weight post-detachment.
     * @param tokenId_ The user's tokenId to be detached.
     */
    function dettachFromManagedNFT(uint256 tokenId_) external nonReentrant {
        require(IVotingEscrow(_ve).isApprovedOrOwner(msg.sender, tokenId_), "!approved/Owner");
        _voteDelay(tokenId_);
        _checkEndVoteWindow();

        IManagedNFTManager managedNFTManagerCache = IManagedNFTManager(managedNFTManager);

        uint256 managedTokenId = managedNFTManagerCache.getAttachedManagedTokenId(tokenId_);

        managedNFTManagerCache.onDettachFromManagedNFT(tokenId_);

        uint256 weight = IVotingEscrowV1_2(_ve).balanceOfNftIgnoreOwnershipChange(managedTokenId);
        if (weight == 0) {
            _reset(managedTokenId);
            delete lastVoted[managedTokenId];
        } else {
            _poke(managedTokenId);
        }

        emit DettachFromManagedNFT(tokenId_);
    }

    /**
     * @notice Sets the Managed NFT Manager address.
     * @param managedNFTManager_ The address of the Managed NFT Manager.
     */
    function setManagedNFTManager(address managedNFTManager_) external VoterAdmin {
        managedNFTManager = managedNFTManager_;
        emit SetManagedNFTManager(managedNFTManager_);
    }

    /**
     * @notice Sets the duration of the distribution window for voting.
     * @param distributionWindowDuration_ The duration in seconds.
     */
    function setDistributionWindowDuration(uint256 distributionWindowDuration_) external VoterAdmin {
        distributionWindowDuration = distributionWindowDuration_;
        emit SetDistributionWindowDuration(distributionWindowDuration_);
    }

    /**
     * @dev Updates the voting preferences for a given tokenId after changes in the system.
     * @param tokenId_ The tokenId for which to update voting preferences.
     */
    function _poke(uint256 tokenId_) internal {
        address[] memory _poolVote = poolVote[tokenId_];
        uint256[] memory _weights = new uint256[](_poolVote.length);

        for (uint256 i; i < _poolVote.length; ) {
            _weights[i] = votes[tokenId_][_poolVote[i]];
            unchecked {
                i++;
            }
        }

        _vote(tokenId_, _poolVote, _weights);

        lastVoted[tokenId_] = _epochTimestamp() + 1;
    }

    /**
     * @dev Checks if the current time is within the start of the vote window.
     */
    function _checkStartVoteWindow() internal view {
        require(block.timestamp > (block.timestamp - (block.timestamp % _WEEK) + distributionWindowDuration), "distribute window");
    }

    /**
     * @dev Checks if the current time is within the end of the vote window.
     */
    function _checkEndVoteWindow() internal view {
        require(block.timestamp < (block.timestamp - (block.timestamp % _WEEK) + _WEEK - distributionWindowDuration), "distribute window");
    }

    /*///////////////////////////////////////////////////////////////
                    Aggregation Claim 
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Parameters for claiming bribes using a specific tokenId.
     */
    struct AggregateClaimBribesByTokenIdParams {
        uint256 tokenId; ///< The token ID to claim bribes for.
        address[] bribes; ///< The array of bribe contract addresses.
        address[][] tokens; ///< The array of arrays containing token addresses for each bribe.
    }

    /**
     * @dev Parameters for claiming bribes.
     */
    struct AggregateClaimBribesParams {
        address[] bribes; ///< The array of bribe contract addresses.
        address[][] tokens; ///< The array of arrays containing token addresses for each bribe.
    }

    /**
     * @dev Parameters for claiming Merkl data.
     */
    struct AggregateClaimMerklDataParams {
        address[] users; ///< The array of user addresses to claim for.
        address[] tokens; ///< The array of token addresses.
        uint256[] amounts; ///< The array of amounts to claim.
        bytes32[][] proofs; ///< The array of arrays containing Merkle proofs.
    }

    /**
     * @dev Parameters for claiming VeFnx Merkl airdrop data.
     */
    struct AggregateClaimVeFnxMerklAirdrop {
        uint256 amount; ///< The amount to claim.
        bytes32[] proofs; ///< The array of Merkle proofs.
    }

    /**
     * @dev Event emitted when the Merkl Distributor address is set.
     * @param merklDistributor_ The new address of the Merkl Distributor.
     */
    event SetMerklDistributor(address indexed merklDistributor_);

    /**
     * @dev Event emitted when the VeFnx Split Merkl Aidrop address is set.
     * @param veFnxMerklAidrop_ The new address of the VeFnxSplitMerklAidrop.
     */
    event SetVeFnxMerklAidrop(address indexed veFnxMerklAidrop_);

    /**
     * @notice The address of the Merkl Distributor contract.
     */
    address public merklDistributor;

    /**
     * @notice The address of the VeFnx Split Merkl Airdrop contract.
     */
    address public veFnxMerklAidrop;

    /**
     * @notice Sets the Merkl Distributor address.
     * @param merklDistributor_ The new address of the Merkl Distributor.
     */
    function setMerklDistributor(address merklDistributor_) external VoterAdmin {
        merklDistributor = merklDistributor_;
        emit SetMerklDistributor(merklDistributor_);
    }

    /**
     * @notice Sets the VeFnx Split Merkl Aidrop address.
     * @param veFnxMerklAidrop_ The new address of the VeFnxSplitMerklAidrop.
     */
    function setVeFnxMerklAidrop(address veFnxMerklAidrop_) external VoterAdmin {
        veFnxMerklAidrop = veFnxMerklAidrop_;
        emit SetVeFnxMerklAidrop(veFnxMerklAidrop_);
    }

    /**
     * @notice Aggregates multiple claim calls into a single transaction.
     * @param gauges_ The array of gauge addresses to claim rewards from.
     * @param bribes_ The parameters for claiming bribes without token ID.
     * @param bribesByTokenId_ The parameters for claiming bribes with a token ID.
     * @param merkl_ The parameters for claiming Merkl data.
     * @param splitMerklAidrop_ The parameters for claiming VeFnx Merkl airdrop data.
     */
    function aggregateClaim(
        address[] calldata gauges_,
        AggregateClaimBribesParams calldata bribes_,
        AggregateClaimBribesByTokenIdParams calldata bribesByTokenId_,
        AggregateClaimMerklDataParams calldata merkl_,
        AggregateClaimVeFnxMerklAirdrop calldata splitMerklAidrop_
    ) external {
        if (gauges_.length > 0) {
            claimRewards(gauges_);
        }
        if (bribes_.bribes.length > 0) {
            claimBribes(bribes_.bribes, bribes_.tokens);
        }
        if (bribesByTokenId_.bribes.length > 0) {
            claimBribes(bribesByTokenId_.bribes, bribesByTokenId_.tokens, bribesByTokenId_.tokenId);
        }
        if (merkl_.users.length > 0) {
            for (uint256 i; i < merkl_.users.length; ) {
                require(merkl_.users[i] == msg.sender, "users containes no only caller");
                unchecked {
                    i++;
                }
            }
            IMerklDistributor(merklDistributor).claim(merkl_.users, merkl_.tokens, merkl_.amounts, merkl_.proofs);
        }
        if (splitMerklAidrop_.amount > 0) {
            IVeFnxSplitMerklAidrop(veFnxMerklAidrop).claimFor(msg.sender, splitMerklAidrop_.amount, splitMerklAidrop_.proofs);
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
