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
