module StripeMock
  module RequestHandlers
    module Prices
      def self.included(base)
        base.add_handler 'post /v1/prices',        :create_price
        base.add_handler 'get /v1/prices/(.*)',    :retrieve_price
        base.add_handler 'post /v1/prices/(.*)',   :update_price
        base.add_handler 'get /v1/prices',         :list_prices
        base.add_handler 'delete /v1/prices/(.*)', :destroy_price
      end

      def create_price(_route, _method_url, params, _headers)
        params[:id] ||= new_id('prod')
        validate_create_price_params(params)
        products[params[:id]] = Data.mock_product(params)
      end

      def retrieve_price(route, method_url, _params, _headers)
        id = method_url.match(route).captures.first
        assert_existence :price, id, prices[id]
      end

      def update_price(route, method_url, params, _headers)
        id = method_url.match(route).captures.first
        product = assert_existence :price, id, prices[id]

        product.merge!(params)
      end

      def list_prices(_route, _method_url, params, _headers)
        limit = params[:limit] || 10
        Data.mock_list_object(prices.values.take(limit), params)
      end

      def destroy_price(route, method_url, _params, _headers)
        id = method_url.match(route).captures.first
        assert_existence :price, id, prices[id]

        products.delete(id)
        { id: id, object: 'price', deleted: true }
      end
    end
  end
end
