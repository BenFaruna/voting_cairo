use starknet::{ContractAddress, contract_address_const};

use snforge_std::{declare, ContractClassTrait, cheat_caller_address, CheatSpan};

use voting::voting::IVotingDispatcher;
use voting::voting::IVotingDispatcherTrait;

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap();
    let mut calldata = ArrayTrait::new();

    let owner = contract_address_const::<0xbeef>();

    calldata.append(owner.into());
    let (contract_address, _) = contract.deploy(@calldata).unwrap();
    contract_address
}

#[test]
fn test_contract_deployment() {
    let contract_address = deploy_contract("Voting");

    let dispatcher = IVotingDispatcher { contract_address };
    let owner = dispatcher.get_owner();

    assert(owner == contract_address_const::<0xbeef>(), 'Not owner');
}

#[test]
fn test_set_proposal() {
    let contract_address = deploy_contract("Voting");

    let dispatcher = IVotingDispatcher { contract_address };

    cheat_caller_address(contract_address, 0xbeef.try_into().unwrap(), CheatSpan::TargetCalls(1));

    dispatcher.set_proposal("Proposal 1");

    let proposal_from_contract = dispatcher.get_proposal();
    assert(proposal_from_contract == "Proposal 1", 'Proposal not set');
}

#[test]
fn test_add_candidate() {
    let contract_address = deploy_contract("Voting");

    let dispatcher = IVotingDispatcher { contract_address };

    cheat_caller_address(contract_address, 0xbeef.try_into().unwrap(), CheatSpan::TargetCalls(3));

    dispatcher.add_candidate(contract_address_const::<0xc1>(), 'Candidate 1');

    let candidates = dispatcher.get_candidates();
    assert(candidates.len() == 1, 'Candidate not added');
    // assert(candidates[0].name == 'Candidate 1', 'Candidate not added');

    dispatcher.add_candidate(contract_address_const::<0xc2>(), 'Candidate 2');

    let candidates = dispatcher.get_candidates();
    assert(candidates.len() == 2, 'Candidate not added');
}

// #[test]
// fn test_voting() {
//     let contract_address = deploy_contract("Voting");

//     let dispatcher = IVotingDispatcher { contract_address };

//     add_candidates(@contract_address);
//     add_voters(@contract_address);

//     dispatcher.add_voter(contract_address_const::<0xc1>());
//     dispatcher.add_voter(contract_address_const::<0xc2>());

//     let voters = dispatcher.get_voters();
//     assert(voters.len() == 2, 'Voter not added');
// }

fn add_candidates(contract_address: ContractAddress) {
    let dispatcher = IVotingDispatcher { contract_address };

    cheat_caller_address(contract_address, 0xbeef.try_into().unwrap(), CheatSpan::TargetCalls(3));

    dispatcher.add_candidate(contract_address_const::<0xc1>(), 'Candidate 1');
    dispatcher.add_candidate(contract_address_const::<0xc2>(), 'Candidate 2');
    dispatcher.add_candidate(contract_address_const::<0xc3>(), 'Candidate 3');
}

fn add_voters(contract_address: ContractAddress) {
    let dispatcher = IVotingDispatcher { contract_address };

    cheat_caller_address(contract_address, 0xbeef.try_into().unwrap(), CheatSpan::TargetCalls(3));

    dispatcher.resgister_voter(contract_address_const::<0xc1>());
    dispatcher.resgister_voter(contract_address_const::<0xc2>());
    dispatcher.resgister_voter(contract_address_const::<0xc3>());
}
