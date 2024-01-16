use starknet::ContractAddress;

#[starknet::interface]
trait IERC20<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> u8;
    fn total_supply(self: @TContractState) -> u256;
    fn balanceOf(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn transferFrom(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
}

#[starknet::interface]
trait FilMediaMarketplaceTrait<TContractState> {
    fn createUser(ref self: TContractState, _amount: u128);
    fn createArtist(ref self: TContractState, _amount: u128);
    fn listNFT(self: @TContractState) -> u128;
    fn addNFTForArtist(self: @TContractState) -> (u128 , FilMediaMarketplace::targetOption) ;
    fn subcribeToArtist(self: @TContractState) -> (u128 , FilMediaMarketplace::targetOption) ;
    fn cancelSubcribtion(self: @TContractState) -> (u128 , FilMediaMarketplace::targetOption) ;
    fn setTokenId(self: @TContractState) -> (u128 , FilMediaMarketplace::targetOption) ;
    fn checkIfUserIsSubcribed(self: @TContractState) -> ContractAddress;
    fn getSubcribers(self: @TContractState) -> ContractAddress;
    fn getAllArtists(self: @TContractState) -> ContractAddress;
    fn getAnalytics(self: @TContractState) -> ContractAddress;
    fn getTokenId(self: @TContractState) -> ContractAddress;
    fn getMusicNFT(self: @TContractState) -> ContractAddress;
    fn getMusic(self: @TContractState) -> ContractAddress;
    fn getArtist(self: @TContractState) -> ContractAddress;
    fn getUser(self: @TContractState) -> ContractAddress;
    fn getUserBalance(self: @TContractState) -> ContractAddress;
    fn isWalletAnArtist(self: @TContractState) -> ContractAddress;
    fn getUserOrArtistTokenId(self: @TContractState) -> ContractAddress;
    // fn viewTarget(self: @TContractState) -> target;
}

#[starknet::contract]
mod FilMediaMarketplace {
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use starknet::{get_caller_address, ContractAddress, get_contract_address, Zeroable, get_block_timestamp};
    use super::{IERC20Dispatcher, IERC20DispatcherTrait, target};
    use core::traits::Into;
    use piggy_bank::ownership_component::ownable_component;
    component!(path: ownable_component, storage: ownable, event: OwnableEvent);


    #[abi(embed_v0)]
    impl OwnableImpl = ownable_component::Ownable<ContractState>;
    impl OwnableInternalImpl = ownable_component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        token: IERC20Dispatcher,
        balance: u128,
        #[substorage(v0)]
        lastTimeStamp: u128,
    }

    #[derive(Drop, Serde)]
    enum targetOption {
        targetTime,
        targetAmount,
    }

    #[derive(Drop, starknet::Event)]
    struct CreatedUserNFT {
        #[key]
        nft: ContractAddress,
        #[key]
        userTokenId: u128,
        #[key]
        user: ContractAddress,
        Amount: u128,
    }

    #[derive(Drop, starknet::Event)]
    struct CreatedArtistNFT {
        #[key]
        nft: ContractAddress,
        #[key]
        artistTokenId: u128,
        #[key]
        artist: ContractAddress,
    }

  #[derive(Drop, starknet::Event)]
    struct ListedMusicNFT {
        #[key]
        nft: ContractAddress,
        #[key]
        tokenId: u128,
        #[key]
        artistTokenId: u128,
        artist: u128,
        chainid: u128,
    }

  #[derive(Drop, starknet::Event)]
    struct SubcribedToArtist {
        #[key]
        subcriber: ContractAddress,
        #[key]
        artist: ContractAddress,
        #[key]
        chainid: u128,
    }

  #[derive(Drop, starknet::Event)]
    struct CanceledSubcription {
        #[key]
        subcriber: ContractAddress,
        #[key]
        artist: ContractAddress,
        #[key]
        chainid: u128,
    }

    #[constructor]
    fn constructor(ref self: ContractState, _owner: ContractAddress, _token: ContractAddress, _manager: ContractAddress, target: targetOption, targetDetails: u128) {
        self.lastTimeStamp.write(block.timestamp);
    }

    #[external(v0)]
    impl FilMediaMarketplaceImpl of super::FilMediaMarketplaceTrait<ContractState> {
        fn deposit(ref self: ContractState, _amount: u128) {
            let (caller, this, currentBalance) = self.getImportantAddresses();
            self.balance.write(currentBalance + _amount);

            self.token.read().transferFrom(caller, this, _amount.into());

            self.emit(Deposit { from: caller, Amount: _amount});
        }
        
        fn get_balance(self: @ContractState) -> u128 {
            self.balance.read()
        }
    }
}