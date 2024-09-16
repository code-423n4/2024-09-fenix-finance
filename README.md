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
- Total Prize Pool: $18900 in USDC
  - HM awards: $15500 in USDC
  - (remove this line if there is no Analysis pool) Analysis awards: XXX XXX USDC (Notion: Analysis pool)
  - QA awards: $500 in USDC
  - (remove this line if there is no Bot race) Bot Race awards: XXX XXX USDC (Notion: Bot Race pool)
 
  - Judge awards: $2400 in USDC
  - Validator awards: XXX XXX USDC (Notion: Triage fee - final)
  - Scout awards: $500 in USDC
  - (this line can be removed if there is no mitigation) Mitigation Review: XXX XXX USDC (*Opportunity goes to top 3 backstage wardens based on placement in this audit who RSVP.*)
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
## 🐺 C4: Begin Gist paste here (and delete this line)





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

