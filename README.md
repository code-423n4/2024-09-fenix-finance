# ✨ So you want to run an audit

This `README.md` contains a set of checklists for our audit collaboration.

Your audit will use two repos: 
- **an _audit_ repo** (this one), which is used for scoping your audit and for providing information to wardens
- **a _findings_ repo**, where issues are submitted (shared with you after the audit) 

Ultimately, when we launch the audit, this repo will be made public and will contain the smart contracts to be reviewed and all the information needed for audit participants. The findings repo will be made public after the audit report is published and your team has mitigated the identified issues.

Some of the checklists in this doc are for **C4 (🐺)** and some of them are for **you as the audit sponsor (⭐️)**.

---

# Audit setup

## 🐺 C4: Set up repos
- [ ] Create a new private repo named `YYYY-MM-sponsorname` using this repo as a template.
- [ ] Rename this repo to reflect audit date (if applicable)
- [ ] Rename audit H1 below
- [ ] Update pot sizes
  - [ ] Remove the "Bot race findings opt out" section if there's no bot race.
- [ ] Fill in start and end times in audit bullets below
- [ ] Add link to submission form in audit details below
- [ ] Add the information from the scoping form to the "Scoping Details" section at the bottom of this readme.
- [ ] Add matching info to the Code4rena site
- [ ] Add sponsor to this private repo with 'maintain' level access.
- [ ] Send the sponsor contact the url for this repo to follow the instructions below and add contracts here. 
- [ ] Delete this checklist.

# Repo setup

## ⭐️ Sponsor: Add code to this repo

- [ ] Create a PR to this repo with the below changes:
- [ ] Confirm that this repo is a self-contained repository with working commands that will build (at least) all in-scope contracts, and commands that will run tests producing gas reports for the relevant contracts.
- [ ] Please have final versions of contracts and documentation added/updated in this repo **no less than 48 business hours prior to audit start time.**
- [ ] Be prepared for a 🚨code freeze🚨 for the duration of the audit — important because it establishes a level playing field. We want to ensure everyone's looking at the same code, no matter when they look during the audit. (Note: this includes your own repo, since a PR can leak alpha to our wardens!)

## ⭐️ Sponsor: Repo checklist

- [ ] Modify the [Overview](#overview) section of this `README.md` file. Describe how your code is supposed to work with links to any relevent documentation and any other criteria/details that the auditors should keep in mind when reviewing. (Here are two well-constructed examples: [Ajna Protocol](https://github.com/code-423n4/2023-05-ajna) and [Maia DAO Ecosystem](https://github.com/code-423n4/2023-05-maia))
- [ ] Review the Gas award pool amount, if applicable. This can be adjusted up or down, based on your preference - just flag it for Code4rena staff so we can update the pool totals across all comms channels.
- [ ] Optional: pre-record a high-level overview of your protocol (not just specific smart contract functions). This saves wardens a lot of time wading through documentation.
- [ ] [This checklist in Notion](https://code4rena.notion.site/Key-info-for-Code4rena-sponsors-f60764c4c4574bbf8e7a6dbd72cc49b4#0cafa01e6201462e9f78677a39e09746) provides some best practices for Code4rena audit repos.

## ⭐️ Sponsor: Final touches
- [ ] Review and confirm the pull request created by the Scout (technical reviewer) who was assigned to your contest. *Note: any files not listed as "in scope" will be considered out of scope for the purposes of judging, even if the file will be part of the deployed contracts.*
- [ ] Check that images and other files used in this README have been uploaded to the repo as a file and then linked in the README using absolute path (e.g. `https://github.com/code-423n4/yourrepo-url/filepath.png`)
- [ ] Ensure that *all* links and image/file paths in this README use absolute paths, not relative paths
- [ ] Check that all README information is in markdown format (HTML does not render on Code4rena.com)
- [ ] Delete this checklist and all text above the line below when you're ready.

---

# Fenix Finance audit details
- Total Prize Pool: $16,000 in USDC
  - HM awards: $12,600 in USDC
  - QA awards: $500 in USDC
  - Judge awards: $2,400 in USDC
  - Scout awards: $500 in USDC
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts September 18, 2024 20:00 UTC
- Ends September 25, 2024 20:00 UTC

## This is a Private audit

This audit repo and its Discord channel are accessible to **certified wardens only.** Participation in private audits is bound by:

1. Code4rena's [Certified Contributor Terms and Conditions](https://github.com/code-423n4/code423n4.com/blob/main/_data/pages/certified-contributor-terms-and-conditions.md)
2. C4's [Certified Contributor Code of Professional Conduct](https://code4rena.notion.site/Code-of-Professional-Conduct-657c7d80d34045f19eee510ae06fef55)

*All discussions regarding private audits should be considered private and confidential, unless otherwise indicated.*

Please review the following confidentiality requirements carefully, and if anything is unclear, ask questions in the private audit channel in the C4 Discord.

>>DRAG IN CLASSIFIED IMAGE HERE

## Automated Findings / Publicly Known Issues

The 4naly3er report can be found [here](https://github.com/code-423n4/2024-09-fenix-finance/blob/main/4naly3er-report.md).



_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._

- Centralized risk
- Initialize front-running
- User mistake
- Lack of storage reservation slots, for future contracts inheritors
- Failure to call an epoch change method for a significant amount of time, which will lead to skipping epochs
- Locking veNFT vote strength updates during the distribution window 
- Freezing the user's voting power at the time of voting at the beginning of the epoch, which gives them more voting power than they will have actually at the end of the epoch
- The ability to provide arbitrary addresses in the claimBribes, claimRewards, aggregateClaim methods, which will lead to calling certain methods on behalf of VoterUpgradeable
- Stuck emission allocated by the epoch, in case there were no votes during epoch
- Carelessly changing important contract addresses, which can lead to various problems and out-of-sync data between contracts
- The problem of upgrading already deployed contracts to V2 (this will not happen through an upgrade, just new deploy)
- Not supporting the deployment of contracts for other networks other than Blast as they are, the need to remove Blast features

✅ SCOUTS: Please format the response above 👆 so its not a wall of text and its readable.

# Overview

[ ⭐️ SPONSORS: add info here ]

## Links

- **Previous audits:**  https://app.hats.finance/audit-competitions/fenix-finance-0x83dbe5aa378f3ce160ed084daf85f621289fb92f/scope

https://docs.fenixfinance.io/fenix/additional-information/security-and-audits
  - ✅ SCOUTS: If there are multiple report links, please format them in a list.
- **Documentation:** https://docs.fenixfinance.io
- **Website:** 🐺 CA: add a link to the sponsor's website
- **X/Twitter:** 🐺 https://twitter.com/fenixfinance
- **Discord:** 🐺 CA: add a link to the sponsor's Discord

---

# Scope

[ ✅ SCOUTS: add scoping and technical details here ]

### Files in scope
- ✅ This should be completed using the `metrics.md` file
- ✅ Last row of the table should be Total: SLOC
- ✅ SCOUTS: Have the sponsor review and and confirm in text the details in the section titled "Scoping Q amp; A"

*For sponsors that don't use the scoping tool: list all files in scope in the table below (along with hyperlinks) -- and feel free to add notes to emphasize areas of focus.*

| Contract | SLOC | Purpose | Libraries used |  
| ----------- | ----------- | ----------- | ----------- |
| [contracts/folder/sample.sol](https://github.com/code-423n4/repo-name/blob/contracts/folder/sample.sol) | 123 | This contract does XYZ | [`@openzeppelin/*`](https://openzeppelin.com/contracts/) |

### Files out of scope
✅ SCOUTS: List files/directories out of scope

## Scoping Q &amp; A

### General questions
### Are there any ERC20's in scope?: Yes

✅ SCOUTS: If the answer above 👆 is "Yes", please add the tokens below 👇 to the table. Otherwise, update the column with "None".

Any (all possible ERC20s)
FNX, WETH, USDB, BLAST

### Are there any ERC777's in scope?: No

✅ SCOUTS: If the answer above 👆 is "Yes", please add the tokens below 👇 to the table. Otherwise, update the column with "None".



### Are there any ERC721's in scope?: No

✅ SCOUTS: If the answer above 👆 is "Yes", please add the tokens below 👇 to the table. Otherwise, update the column with "None".



### Are there any ERC1155's in scope?: No

✅ SCOUTS: If the answer above 👆 is "Yes", please add the tokens below 👇 to the table. Otherwise, update the column with "None".



✅ SCOUTS: Once done populating the table below, please remove all the Q/A data above.

| Question                                | Answer                       |
| --------------------------------------- | ---------------------------- |
| ERC20 used by the protocol              |       🖊️             |
| Test coverage                           | ✅ SCOUTS: Please populate this after running the test coverage command                          |
| ERC721 used  by the protocol            |            🖊️              |
| ERC777 used by the protocol             |           🖊️                |
| ERC1155 used by the protocol            |              🖊️            |
| Chains the protocol will be deployed on | OtherBlast  |

### ERC20 token behaviors in scope

| Question                                                                                                                                                   | Answer |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| [Missing return values](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#missing-return-values)                                                      |   Out of scope  |
| [Fee on transfer](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#fee-on-transfer)                                                                  |  Out of scope  |
| [Balance changes outside of transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#balance-modifications-outside-of-transfers-rebasingairdrops) | Out of scope    |
| [Upgradeability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#upgradable-tokens)                                                                 |   Out of scope  |
| [Flash minting](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#flash-mintable-tokens)                                                              | Out of scope    |
| [Pausability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#pausable-tokens)                                                                      | Out of scope    |
| [Approval race protections](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#approval-race-protections)                                              | Out of scope    |
| [Revert on approval to zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-approval-to-zero-address)                            | In scope    |
| [Revert on zero value approvals](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-approvals)                                    | In scope    |
| [Revert on zero value transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                    | Out of scope    |
| [Revert on transfer to the zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-transfer-to-the-zero-address)                    | In scope    |
| [Revert on large approvals and/or transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-large-approvals--transfers)                  | Out of scope    |
| [Doesn't revert on failure](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#no-revert-on-failure)                                                   |  Out of scope   |
| [Multiple token addresses](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                          | Out of scope    |
| [Low decimals ( < 6)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#low-decimals)                                                                 |   In scope  |
| [High decimals ( > 18)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#high-decimals)                                                              | In scope    |
| [Blocklists](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#tokens-with-blocklists)                                                                | Out of scope    |

### External integrations (e.g., Uniswap) behavior in scope:


| Question                                                  | Answer |
| --------------------------------------------------------- | ------ |
| Enabling/disabling fees (e.g. Blur disables/enables fees) | No   |
| Pausability (e.g. Uniswap pool gets paused)               |  No   |
| Upgradeability (e.g. Uniswap gets upgraded)               |   No  |


### EIP compliance checklist
`contracts/core/VotingEscrowUpgradeableV2.sol.sol`. Should comply with `EIP-721`

✅ SCOUTS: Please format the response above 👆 using the template below👇

| Question                                | Answer                       |
| --------------------------------------- | ---------------------------- |
| src/Token.sol                           | ERC20, ERC721                |
| src/NFT.sol                             | ERC721                       |


# Additional context

## Main invariants

- The user gained more voting power than expected by his actions
- Attaching veNFT to mVeNFT resulted in the complete loss of the user's veNFT
- The user has blocked the distribution in gauge by his actions
- An action that should have been available only from the owner's side was called from a third-party user


✅ SCOUTS: Please format the response above 👆 so its not a wall of text and its readable.

## Attack ideas (where to focus for bugs)
- Security of user funds 
- Calculation of voting power in combination with permanent lock
- Distribution of emissions between gauge/pools
- VeNFT states and allowed actions during these states
- Detachment and attachment to the mVeNFT
- Permanent lock/unlock

✅ SCOUTS: Please format the response above 👆 so its not a wall of text and its readable.

## All trusted roles in the protocol

- Owner (VotingEscrowUpgradeableV2.sol)
- Owner (ProxyAdmin)
- GOVERNANCE_ROLE (VoterUpgradeableV2.sol)
- VOTER_ADMIN_ROLE (VoterUpgradeableV2.sol)

✅ SCOUTS: Please format the response above 👆 using the template below👇

| Role                                | Description                       |
| --------------------------------------- | ---------------------------- |
| Owner                          | Has superpowers                |
| Administrator                             | Can change fees                       |

## Describe any novel or unique curve logic or mathematical models implemented in the contracts:

N/A

✅ SCOUTS: Please format the response above 👆 so its not a wall of text and its readable.

## Running tests

## Setup
### Getting the code
Clone this repository
```sh
git clone --branch code4arena-04-09-2024 --recursive -j8  https://github.com/Satsyxbt/Fenix
```
or
```sh
git clone https://github.com/Satsyxbt/Fenix
cd fenix
git submodule update --init --recursive
git checkout code4arena-04-09-2024
```

Enter into the directory
```sh
cd fenix
```

Install dependency
```sh
npm install
```

### Running basic tests
To run the existing tests, also need to compile the artifacts of the fenix-dex-v3 library
```
sh
1.
    cd lib/fenix-dex-v3
    npm install

2. 
    cd src/core
    npm install
    npx hardhat compile
3.
    cd src/periphery
    npm install
    npx hardhat compile
```
run tests command
```sh
npm run test
```
or
```sh
npx hardhat test
```


✅ SCOUTS: Please format the response above 👆 using the template below👇

```bash
git clone https://github.com/code-423n4/2023-08-arbitrum
git submodule update --init --recursive
cd governance
foundryup
make install
make build
make sc-election-test
```
To run code coverage
```bash
make coverage
```
To run gas benchmarks
```bash
make gas
```

✅ SCOUTS: Add a screenshot of your terminal showing the gas report
✅ SCOUTS: Add a screenshot of your terminal showing the test coverage




# Scope

*See [scope.txt](https://github.com/code-423n4/2024-09-fenix-finance/blob/main/scope.txt)*

### Files in scope


| File   | Logic Contracts | Interfaces | nSLOC | Purpose | Libraries used |
| ------ | --------------- | ---------- | ----- | -----   | ------------ |
| /contracts/core/VotingEscrowUpgradeableV2.sol | 1| **** | 425 | |@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol|
| /contracts/core/VoterUpgradeableV2.sol | 1| **** | 457 | |@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol<br>@cryptoalgebra/integral-core/contracts/interfaces/IAlgebraFactory.sol|
| /contracts/core/libraries/LibVotingEscrowValidation.sol | 1| **** | 102 | ||
| **Totals** | **3** | **** | **984** | | |

### Files out of scope

*See [out_of_scope.txt](https://github.com/code-423n4/2024-09-fenix-finance/blob/main/out_of_scope.txt)*

| File         |
| ------------ |
| ./contracts/bribes/BribeFactoryUpgradeable.sol |
| ./contracts/bribes/BribeProxy.sol |
| ./contracts/bribes/BribeUpgradeable.sol |
| ./contracts/bribes/interfaces/IBribe.sol |
| ./contracts/bribes/interfaces/IBribeFactory.sol |
| ./contracts/core/Fenix.sol |
| ./contracts/core/FenixRaiseUpgradeable.sol |
| ./contracts/core/MinterUpgradeable.sol |
| ./contracts/core/RFenix.sol |
| ./contracts/core/VeArtProxyUpgradeable.sol |
| ./contracts/core/VeBoostUpgradeable.sol |
| ./contracts/core/VeFnxDistributorUpgradeable.sol |
| ./contracts/core/VeFnxSplitMerklAidropUpgradeable.sol |
| ./contracts/core/VoterUpgradeable.sol |
| ./contracts/core/VoterUpgradeableV1_2.sol |
| ./contracts/core/VotingEscrowUpgradeable.sol |
| ./contracts/core/VotingEscrowUpgradeableV1_2.sol |
| ./contracts/core/interfaces/IFenix.sol |
| ./contracts/core/interfaces/IFenixRaise.sol |
| ./contracts/core/interfaces/IMinter.sol |
| ./contracts/core/interfaces/IRFenix.sol |
| ./contracts/core/interfaces/IVault.sol |
| ./contracts/core/interfaces/IVeArtProxyUpgradeable.sol |
| ./contracts/core/interfaces/IVeBoost.sol |
| ./contracts/core/interfaces/IVeFnxDistributor.sol |
| ./contracts/core/interfaces/IVeFnxSplitMerklAidrop.sol |
| ./contracts/core/interfaces/IVoter.sol |
| ./contracts/core/interfaces/IVoterV1_2.sol |
| ./contracts/core/interfaces/IVoterV2.sol |
| ./contracts/core/interfaces/IVotingEscrow.sol |
| ./contracts/core/interfaces/IVotingEscrowV1_2.sol |
| ./contracts/core/interfaces/IVotingEscrowV2.sol |
| ./contracts/core/libraries/DateTime.sol |
| ./contracts/core/libraries/LibVoterErrors.sol |
| ./contracts/core/libraries/LibVotingEscrowConstants.sol |
| ./contracts/core/libraries/LibVotingEscrowErrors.sol |
| ./contracts/core/libraries/LibVotingEscrowUtils.sol |
| ./contracts/core/libraries/NumberFormatter.sol |
| ./contracts/dexV2/Pair.sol |
| ./contracts/dexV2/PairFactoryUpgradeable.sol |
| ./contracts/dexV2/PairFees.sol |
| ./contracts/dexV2/RouterV2.sol |
| ./contracts/dexV2/UniswapV2PartialRouter.sol |
| ./contracts/dexV2/interfaces/IPair.sol |
| ./contracts/dexV2/interfaces/IPairCallee.sol |
| ./contracts/dexV2/interfaces/IPairFactory.sol |
| ./contracts/dexV2/interfaces/IPairInfo.sol |
| ./contracts/dexV2/interfaces/IRouterV2.sol |
| ./contracts/dexV2/interfaces/IUniswapV2PartialRouter.sol |
| ./contracts/fees/FeesVaultFactoryUpgradeable.sol |
| ./contracts/fees/FeesVaultProxy.sol |
| ./contracts/fees/FeesVaultUpgradeable.sol |
| ./contracts/fees/interfaces/IFeesVault.sol |
| ./contracts/fees/interfaces/IFeesVaultFactory.sol |
| ./contracts/gauges/GaugeFactoryUpgradeable.sol |
| ./contracts/gauges/GaugeProxy.sol |
| ./contracts/gauges/GaugeUpgradeable.sol |
| ./contracts/gauges/PerpetualsGaugeUpgradeable.sol |
| ./contracts/gauges/PerpetualsTradersRewarderUpgradeable.sol |
| ./contracts/gauges/interfaces/IGauge.sol |
| ./contracts/gauges/interfaces/IGaugeFactory.sol |
| ./contracts/gauges/interfaces/IPerpetualsGauge.sol |
| ./contracts/gauges/interfaces/IPerpetualsTradersRewarder.sol |
| ./contracts/gauges/interfaces/IRewardReciever.sol |
| ./contracts/gauges/interfaces/IRewarder.sol |
| ./contracts/integration/AlgebraFNXPriceProviderUpgradeable.sol |
| ./contracts/integration/BlastERC20FactoryManager.sol |
| ./contracts/integration/BlastERC20RebasingManage.sol |
| ./contracts/integration/BlastGovernorClaimableSetup.sol |
| ./contracts/integration/BlastGovernorSetup.sol |
| ./contracts/integration/BlastGovernorUpgradeable.sol |
| ./contracts/integration/BlastRebasingTokensGovernor.sol |
| ./contracts/integration/MerklGaugeMiddleman.sol |
| ./contracts/integration/UpgradeCall.sol |
| ./contracts/integration/interfaces/IBlast.sol |
| ./contracts/integration/interfaces/IBlastERC20FactoryManager.sol |
| ./contracts/integration/interfaces/IBlastERC20RebasingManage.sol |
| ./contracts/integration/interfaces/IBlastFull.sol |
| ./contracts/integration/interfaces/IBlastGovernor.sol |
| ./contracts/integration/interfaces/IBlastPoints.sol |
| ./contracts/integration/interfaces/IBlastRebasingTokensGovernor.sol |
| ./contracts/integration/interfaces/IDistributionCreator.sol |
| ./contracts/integration/interfaces/IERC20Rebasing.sol |
| ./contracts/integration/interfaces/IMerklDistributor.sol |
| ./contracts/integration/interfaces/IMerklGaugeMiddleman.sol |
| ./contracts/integration/interfaces/IPairIntegrationInfo.sol |
| ./contracts/integration/interfaces/IPriceProvider.sol |
| ./contracts/integration/interfaces/IUgradeCall.sol |
| ./contracts/mocks/BaseManagedNFTStrategyUpgradeableMock.sol |
| ./contracts/mocks/BlastERC20FactoryManagerMock.sol |
| ./contracts/mocks/BlastERC20RebasingManageMock.sol |
| ./contracts/mocks/BlastGovernorMock.sol |
| ./contracts/mocks/BlastGovernorSetupMock.sol |
| ./contracts/mocks/BlastMock.sol |
| ./contracts/mocks/BlastPointsMock.sol |
| ./contracts/mocks/CompileMock.sol |
| ./contracts/mocks/CoreMock.sol |
| ./contracts/mocks/ERC20Faucet.sol |
| ./contracts/mocks/ERC20Mock.sol |
| ./contracts/mocks/ERC20RebasingMock.sol |
| ./contracts/mocks/ICHIMock.sol |
| ./contracts/mocks/MDCBlastMock.sol |
| ./contracts/mocks/ManagedNFTManagerMock.sol |
| ./contracts/mocks/MerkleDistributionCreatorShortMock.sol |
| ./contracts/mocks/MinterMock.sol |
| ./contracts/mocks/NumberFormatterMock.sol |
| ./contracts/mocks/PoolMock.sol |
| ./contracts/mocks/SingelTokenBuybackUpgradeableMock.sol |
| ./contracts/mocks/VirtualRewarderCheckpointsMock.sol |
| ./contracts/mocks/VoterEscrowMock.sol |
| ./contracts/mocks/VoterMock.sol |
| ./contracts/mocks/WETH9.sol |
| ./contracts/mocks/interfaces/IBlastMock.sol |
| ./contracts/mocks/interfaces/IERC20RebasingMock.sol |
| ./contracts/nest/BaseManagedNFTStrategyUpgradeable.sol |
| ./contracts/nest/CompoundVeFNXManagedNFTStrategyFactoryUpgradeable.sol |
| ./contracts/nest/CompoundVeFNXManagedNFTStrategyUpgradeable.sol |
| ./contracts/nest/ManagedNFTManagerUpgradeable.sol |
| ./contracts/nest/RouterV2PathProviderUpgradeable.sol |
| ./contracts/nest/SingelTokenBuybackUpgradeable.sol |
| ./contracts/nest/SingelTokenVirtualRewarderUpgradeable.sol |
| ./contracts/nest/StrategyProxy.sol |
| ./contracts/nest/VirtualRewarderProxy.sol |
| ./contracts/nest/interfaces/ICompoundVeFNXManagedNFTStrategy.sol |
| ./contracts/nest/interfaces/ICompoundVeFNXManagedNFTStrategyFactory.sol |
| ./contracts/nest/interfaces/IManagedNFTManager.sol |
| ./contracts/nest/interfaces/IManagedNFTStrategy.sol |
| ./contracts/nest/interfaces/IPairQuote.sol |
| ./contracts/nest/interfaces/IRouterV2PathProvider.sol |
| ./contracts/nest/interfaces/ISingelTokenBuyback.sol |
| ./contracts/nest/interfaces/ISingelTokenVirtualRewarder.sol |
| ./contracts/nest/libraries/VirtualRewarderCheckpoints.sol |
| ./contracts/utils/InterfacesAPI.sol |
| ./contracts/utils/PairAPIUpgradeable.sol |
| ./contracts/utils/RewardAPIUpgradeable.sol |
| ./contracts/utils/UtilsUpgradeable.sol |
| ./contracts/utils/VeNFTAPIUpgradeable.sol |
| Totals: 137 |

## Miscellaneous
Employees of Fenix Finance and employees' family members are ineligible to participate in this audit.

Code4rena's rules cannot be overridden by the contents of this README. In case of doubt, please check with C4 staff.
