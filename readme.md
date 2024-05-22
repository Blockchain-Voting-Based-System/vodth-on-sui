
# Sui Brief Tutorial

### PUblish the package
```bash
$ sui client publish --gas-budget 5000000
```
### Get active address
```bash
$ sui client active-address
```

### Create a new event

- The below script will create an event object and transfer to the address. 
- When integrating with DApp the event-object-id should be stored for future uses.
- Replace **<active-address>** with the actual address. The address can be obtain by the above script.
- Replace **<package-id>** with the the published package
Ex: **0xa2cfae1dfcf4cf2116c710580757b5db5863fd0985daaacdf074c7b51ae32a42**
```bash
sui client ptb \
        --assign to_address @<active-address> \
        --move-call <package-id>::vote::new_event \
        --assign event \
        --transfer-objects "[event]" to_address \
        --gas-budget 20000000
```
### Add new candidate to the event\ 

This script will look for the provided package and module and call the input function name with the respective arguments.

- Replace **<package-id>** with the the published package 
Ex: **0xa2cfae1dfcf4cf2116c710580757b5db5863fd0985daaacdf074c7b51ae32a42**
- Replace **<event-id>** with the actual event id
```bash
sui client call \
    --package <package-id> \ 
    --module vote \
    --function new_candidate \
    --args <event-id>
```

### Add a new ballot/ Voting
This script will a create a vote for the provied event and candidate. 
- Replace **<package-id>** with the actual package-id
- Replace **<event-id>** with the event object id
- Replace **<candidate-id>** with the candidate object id
```bash
sui client call \
    --package <package-id> \
    --module vote \
    --function new_ballot \
    --args <event-id> <candidate-id> <voter-hash> --gas-budget 50000000
```