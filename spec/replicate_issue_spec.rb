# The flesh of this file adopted from https://github.com/spree/spree/issues/3774
class Replicator
  include HTTParty
  base_uri 'localhost:3000/api/v1'
  headers = {
    "ACCEPT" => "application/json"
  }
  # debug_output $stdout
  default_params :token => "bd64bd062339e4151d5763262db64d08bd771d37d8dcc587"
end

logger = Logger.new(STDOUT)

RSpec.describe "Order update" do
  context "with an empty order" do
      before do
        response = Replicator.post('/orders')
        @order = response["number"]
        @order_route = "/orders/#{@order}"
        @checkout_route = "/checkouts/#{@order}"

        @bill_address= {
          firstname: "Ryan",
          lastname: "Bigg",
          address1: "1 Somewhere Lane",
          city: "Somewhere",
          zipcode: 20814,
          phone: 123123123,
          country_id: 232, # United States
          state_id: 3520 # Maryland
        }
      end

      context "and then taking it through to the PAYMENT state" do
        before do
          email = "example@mymail.com"
          request = {
            order: {
              email: email
            }
          }
          response = Replicator.put(@order_route, body: request)
          if response["email"] == email
            logger.debug "✓ Email set successfully!"
          else
            logger.debug "#{response}"
          end

          # Assign Line Items to the Order
          request = {
            line_item: {
              variant_id: 17,
              quantity: 1
            }
          }
          response = Replicator.post(@order_route + "/line_items", body: request)
          if response.code == 201
            logger.debug "✓ Line Item created successfully!"
          else
            logger.debug "╳ Line Item could not be created: #{response}"
          end

          response = Replicator.put(@checkout_route + "/next")
          if response.code == 200
            logger.debug "✓ Transitioned to #{response["state"]}!"
          else
            logger.debug "╳ Could not transition #{response}"
          end

          request = {
            order: {
              bill_address: @bill_address
            }
          }
          request[:order][:ship_address] = request[:order][:bill_address]
          response = Replicator.put(@order_route, body: request)
          if response["ship_address"] && response["bill_address"] &&
             response["ship_address"]["firstname"] == request[:order][:ship_address][:firstname] &&
             response["bill_address"]["firstname"] == request[:order][:bill_address][:firstname]
            logger.debug "✓ Added address information!"
          else
            logger.debug "╳ Could not add address information #{response}"
          end


          response = Replicator.put(@checkout_route + "/next")
          if response.code == 200
            logger.debug "✓ Transitioned to #{response["state"]}!"
          else
            logger.debug "╳ Could not transition "
          end

          # No need to select a shipping rate here, because one is automatically selected for you.
          # That, and there is only one to choose from.

          response = Replicator.put(@checkout_route + "/next")
          if response.code == 200
            logger.debug "✓ Transitioned to #{response["state"]}!"
          else
            logger.debug "╳ Could not transition "
          end
        end

        it "remains in the payment state when updating address using the order update API " do
          request = { order: {} }
          response = Replicator.get(@order_route)
          expect(response['state']).to eq("payment")
          request[:order][:ship_address] = @bill_address
          response = Replicator.put(@order_route, body: request)
          expect(response['state']).to eq("payment")

        end

        it "remains in the payment state when updating address using the checkout API " do
            request = { order: {} }
            response = Replicator.get(@order_route)
            expect(response['state']).to eq("payment")
            request[:order][:ship_address] = @bill_address
            response = Replicator.put(@checkout_route, body: request)
            logger.debug response
            expect(response.code).to eq(200)
            expect(response['state']).to eq("payment")
        end
      end
  end
end
