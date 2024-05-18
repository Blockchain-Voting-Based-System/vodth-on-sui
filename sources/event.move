module vodth_on_sui::event {
  use std::string::String;

  public struct Event has key, store {
    id: UID,
    name: String,
    description: String,
  }

  public fun create(name: String, description: String, ctx: &mut TxContext) {
    let event = Event {
      id: object::new(ctx),
      name,
      description
    };
    transfer::public_freeze_object(event)
  }

  #[test_only] use std::string;
  #[test]
  fun test_create() {
    let name = string::utf8(b"My Event");
    let description = string::utf8(b"Description of my event");
    let ctx = &mut tx_context::dummy();

    let event = Event {
      id: object::new(ctx),
      name,
      description
      };

    assert!(event.name == name, 0);
    assert!(event.description == description, 0);

    let dummy_address = @0xCAFE;
    transfer::public_transfer(event, dummy_address);
  }
}
