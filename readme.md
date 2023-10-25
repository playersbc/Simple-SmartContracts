To deploy contracts use forge
`` create --rpc-url $INFURA_GOERLI_URL \
`` --private-key $PRIVATE_KEY src/V0/CCB.sol:ContractCCB \
`` --etherscan-api-key $ETHERSCAN_API_KEY\
`` --verify


To verify contracts use
`` forge verify-contract <address> <contract_name> <api_key> --chain <chain>

``forge script script/Deploy.s.sol:DeployScript --rpc-url mumbai --broadcast --etherscan-api-key polygon-mumbai --verify -vvvv

Chain Ids
    Mainnet = 1,
    Morden = 2,
    Ropsten = 3,
    Rinkeby = 4,
    Goerli = 5,
    Kovan = 42,
    #[strum(serialize = "xdai")]
    XDai = 100,
    Chiado = 10200,
    Polygon = 137,
    Fantom = 250,
    Dev = 1337,
    AnvilHardhat = 31337,
    FantomTestnet = 4002,
    PolygonMumbai = 80001,
    Avalanche = 43114,
    AvalancheFuji = 43113,
    Sepolia = 11155111,
    Moonbeam = 1284,
    Moonbase = 1287,
    MoonbeamDev = 1281,
    Moonriver = 1285,
    Optimism = 10,
    OptimismGoerli = 420,
    OptimismKovan = 69,
    Arbitrum = 42161,
    ArbitrumTestnet = 421611,
    ArbitrumGoerli = 421613,
    Cronos = 25,
    CronosTestnet = 338,
    #[strum(serialize = "bsc")]
    BinanceSmartChain = 56,
    #[strum(serialize = "bsc-testnet")]
    BinanceSmartChainTestnet = 97,
    Poa = 99,
    Sokol = 77,
    Rsk = 30,
    Oasis = 26863,
    Emerald = 42262,
    EmeraldTestnet = 42261,
    Evmos = 9001,
    EvmosTestnet = 9000,
    Aurora = 1313161554,
    AuroraTestnet = 1313161555,