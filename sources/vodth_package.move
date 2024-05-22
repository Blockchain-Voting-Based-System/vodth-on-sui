module vodth::vote{
    use std::string::String;
    use sui::dynamic_object_field as ofield;


    public struct Event has key, store{
        id: UID,
        voted: u64,
        candidates: u64
    }

    public struct Candidate has key, store{
        id: UID,
        voted: u64
    }

    public struct Ballot has key, store{
        id: UID,
        voter: String
    }

    fun init(ctx: &mut TxContext) {
        let admin = Event{
            id: object::new(ctx),
            voted: 0,
            candidates: 0
        };
         transfer::transfer(admin, ctx.sender());
    }

    public fun new_event(ctx: &mut TxContext): Event{
        let event  = Event{
            id: object::new(ctx),
            voted: 0,
            candidates: 0
        };
        event
    }

    public fun new_candidate(event: &mut Event ,ctx: &mut TxContext){
        event.candidates = event.candidates + 1;
        let candidate = Candidate{
            id: object::new(ctx),
            voted: 0
        };
        add_candidate(event, candidate);
    }

    public fun new_ballot(event: &mut Event, candidate_id: ID, voter: String, ctx: &mut TxContext){
        event.voted = event.voted + 1;
        mutate_candidate(ofield::borrow_mut(&mut event.id, candidate_id));
        let ballot = Ballot{
            id: object::new(ctx),
            voter: voter
        };
        add_ballot(ofield::borrow_mut(&mut event.id, candidate_id), ballot);
    }

    public fun mutate_candidate(candidate: &mut Candidate){
        candidate.voted = candidate.voted + 1;
    }

    public entry fun add_candidate(event: &mut Event, candidate: Candidate){
        ofield::add(&mut event.id, object::id(&candidate), candidate);
    }

    public entry fun add_ballot(candidate: &mut Candidate, ballot: Ballot){
        ofield::add(&mut candidate.id, object::id(&ballot), ballot);
    }

    public fun voted(self: &Event): u64{
        return self.voted
    }

    public fun candidates(self: &Event): u64{
        return self.candidates
    }

    public fun cvoted(self: &Candidate): u64{
        return self.voted
    }
    
    # [test]
    fun test_module_init() {
        use sui::test_scenario;

        let admin = @0xAD;
        // let initial_owner = @0xCAFE;

        let mut scenario = test_scenario::begin(admin);
        {
            init(scenario.ctx());
        };

        scenario.next_tx(admin);
        {
            let event = scenario.take_from_sender<Event>();
            assert!(event.voted() == 0, 1);
            assert!(event.candidates() == 0, 1);
            scenario.return_to_sender(event);
        };
        scenario.end();
    }

    # [test]
    fun test_new_event() {
        use sui::test_scenario;

        let admin = @0xAD;
        // let initial_owner = @0xCAFE;

        let mut scenario = test_scenario::begin(admin);
        {
            init(scenario.ctx());
        };

        scenario.next_tx(admin);
        {
            let event = new_event(scenario.ctx());
            transfer::transfer(event, admin);
            let copy_event = scenario.take_from_sender<Event>();
            assert!(copy_event.voted() == 0, 1);
            scenario.return_to_sender(copy_event);
        };
        scenario.end();
    }

    # [test]
    fun test_new_candidate() {
        use sui::test_scenario;

        let admin = @0xAD;

        let mut scenario = test_scenario::begin(admin);
        {
            init(scenario.ctx());
        };

        scenario.next_tx(admin);
        {
            let mut event = scenario.take_from_sender<Event>();
            assert!(event.candidates() == 0, 1);
            event.new_candidate(scenario.ctx());
            assert!(event.candidates() == 1, 2);
            scenario.return_to_sender(event);
        };
        scenario.end();
    }
}