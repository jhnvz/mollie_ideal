module MollieIdeal
  class Client
    include HTTParty
    base_uri 'https://secure.mollie.nl/xml/ideal'
    
    def initialize(options = {})
      raise ArgumentError.new("No partner_id supplied") if options[:partnerid].nil?
      
      @options = options
    end
    
    # get banklist
    def banklist
      response = Hashie::Mash.new(self.class.get('', 
        :query => merge_options!(:a => 'banklist'), 
        :format => :xml
      )).response.bank
      
      response.kind_of?(Array) ? response : [response]
    end
    
    # setup a payment and get a payment_url to redirect to
    # required keys: :amount, :bank_id, :returnurl, :reporturl
    # optional keys: :profile_key, :description
    def setup_payment(options = {})
      raise ArgumentError.new("Amount should be at least 1,80EUR") if options[:amount] && options[:amount] < 180
      
      response = Hashie::Mash.new(self.class.get('',
        :query => merge_options!(options.merge(:a => 'fetch')),
        :format => :xml
      )).response
      
      if response.order
        return response.order
      else
        raise MollieException.new(response.item.code, response.item.message, response.item.type)
      end
    end
    
    def check_payment(transaction_id)
      response = Hashie::Mash.new(self.class.get('', 
        :query => merge_options!(
          :a => 'check', 
          :transaction_id => transaction_id
        ), 
        :format => :xml
      )).response
      
      if response.order
        return response.order
      else
        raise MollieException.new(response.item.code, response.item.message, response.item.type) 
      end    
    end
    
    # merge options in query
    def merge_options!(hash)
      hash.merge!(@options)
    end
    
  end
end