# Replicator for https://github.com/spree/spree/issues/8569.



Verbatim copy of the issue description here:

## Context
I would like to use order update API to update order contents without necessarily changing state.
For example: when in PAYMENT state, I would like to change my address (shipping rate fixed) but would like the order continue in the PAYMENT state. Or while in PAYMENT state, I would like to change my payment method to a different one before continuing.

The problem is that regardless of what I updated and of the state of the order, using the OrderUpdateAPI always causes the order to return to the ADDRESS state automatically.

## Expected Behavior
The documentation is not clear, but I expect the order state to remain the same when an update does not contain anything critical.

## Actual Behavior
Upon update, the order returns to ADDRESS state.

## To run

1. Change the `default_params :token => "bd64bd062339e4151d5763262db64d08bd771d37d8dcc587"` to your environment of spree.
2. Change country, state and payment ids :

```ruby
@bill_address= {
  firstname: "Ryan",
  lastname: "Bigg",
  address1: "1 Somewhere Lane",
  city: "Somewhere",
  zipcode: 20814,
  phone: 123123123,
  country_id: 232, # United States: change this.
  state_id: 3520 # Maryland: Change this.
}
```

```shell
bundle install
bundle exec rspec
```
