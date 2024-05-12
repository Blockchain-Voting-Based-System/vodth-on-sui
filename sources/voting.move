module voting_test::voting{

    public struct Ballot has key, store{
        id: UID,
        candidate: u64,
        voter_hash: u64,
        event: u64
    }

    public struct Voting has key{
        id: UID,
        voted: u64
    }


    fun init(ctx: &mut TxContext) {
        let admin = Voting{
            id: object::new(ctx),
            voted: 0
        };
        transfer::transfer(admin, ctx.sender());
    }

    public fun new_ballot(
        voting: &mut Voting,
        candidate: u64,
        voter_hash: u64,
        event: u64,
        ctx: &mut TxContext,
    ): Ballot {
        voting.voted = voting.voted + 1;
        Ballot {
            id: object::new(ctx),
            candidate: candidate,
            voter_hash: voter_hash,
            event: event
        }
    }

    public fun candidate(self: &Ballot): u64 {
        self.candidate
    }

    public fun voter_hash(self: &Ballot): u64 {
        self.voter_hash
    }

    public fun event(self: &Ballot): u64 {
        self.event
    }

    public fun voted(self: &Voting): u64 {
        self.voted
    }

    public fun ballot_create(
        candidate: u64,
        voter_hash: u64,
        event: u64,
        ctx: &mut TxContext,
    ): Ballot {
        Ballot {
            id: object::new(ctx),
            candidate: candidate,
            voter_hash: voter_hash,
            event: event
        }
    }

    # [test]
    fun test_ballot_create(){
        let mut ctx = tx_context::dummy();
        let candidate_address = @0xDEAD;
        let ballot = Ballot{
            id: object::new(&mut ctx),
            candidate: 0xDEAD,
            voter_hash: 0xCAFE ,
            event: 0xBEEF
        };
        assert!(ballot.candidate() == 0xDEAD && ballot.event() == 0xBEEF, 1);
        transfer::public_transfer(ballot, candidate_address);
    }

    # [test]
    fun test_ballot_transaction(){
        use sui::test_scenario;
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let mut scenario = test_scenario::begin(initial_owner);
        {
            let ballot = ballot_create(0xDEEC, 0xFACC, 0xABC, scenario.ctx());
            transfer::public_transfer(ballot, initial_owner);
        };

        scenario.next_tx(initial_owner);
        {
            let ballot = scenario.take_from_sender<Ballot>();
            // Transfer the sword to the final owner
            transfer::public_transfer(ballot, final_owner);
        };

        scenario.next_tx(final_owner);
        {
            let ballot = scenario.take_from_sender<Ballot>();
            assert!(ballot.candidate() == 0xDEEC && ballot.voter_hash() == 0xFACC, 1);
            scenario.return_to_sender(ballot)
        };
        scenario.end();
    }

    # [test]
    fun test_module_init() {
        use sui::test_scenario;

        let admin = @0xAD;
        let initial_owner = @0xCAFE;

        let mut scenario = test_scenario::begin(admin);
        {
            init(scenario.ctx());
        };

        scenario.next_tx(admin);
        {
            let voting = scenario.take_from_sender<Voting>();
            assert!(voting.voted() == 0, 1);
            scenario.return_to_sender(voting);
        };

        scenario.next_tx(admin);
        {
            let mut voting = scenario.take_from_sender<Voting>();
            let ballot = voting.new_ballot(0xDEEC, 0xFACC, 888, scenario.ctx());
            transfer::public_transfer(ballot, initial_owner);
            scenario.return_to_sender(voting);
        };
        scenario.end();
    }
}