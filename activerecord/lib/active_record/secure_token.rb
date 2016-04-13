module ActiveRecord
  module SecureToken
    extend ActiveSupport::Concern

    module ClassMethods
      # Example using #has_secure_token
      #
      #   # Schema: User(token:string, auth_token:string)
      #   class User < ActiveRecord::Base
      #     has_secure_token
      #     has_secure_token :auth_token
      #     has_secure_token :auth_secret, token_length: 80
      #   end
      #
      #   user = User.new
      #   user.save
      #   user.token # => "pX27zsMN2ViQKta1bGfLmVJE"
      #   user.auth_token # => "77TMHrHJFvFDwodq8w7Ev2m7"
      #   user.auth_secret # => "7vUrfsD6K9GazaY8J7Acxsw3E6wU93TMe9DHWuNe5yj9yfwneBRuH1pdFmNCCo4k3XxMiw8H9i1ectQd"
      #   user.regenerate_token # => true
      #   user.regenerate_auth_token # => true
      #   user.regenerate_auth_secret # => true
      #
      # <tt>SecureRandom::base58</tt> is used to generate the 24-character unique token, so collisions are highly unlikely.
      #
      # Note that it's still possible to generate a race condition in the database in the same way that
      # {validates_uniqueness_of}[rdoc-ref:Validations::ClassMethods#validates_uniqueness_of] can.
      # You're encouraged to add a unique index in the database to deal with this even more unlikely scenario.
      def has_secure_token(attribute = :token, opts={})
        # Load securerandom only when has_secure_token is used.
        token_length = opts[:token_length] || 24
        require 'active_support/core_ext/securerandom'
        define_method("regenerate_#{attribute}") { update! attribute => self.class.generate_unique_secure_token(token_length) }
        before_create { self.send("#{attribute}=", self.class.generate_unique_secure_token(token_length)) unless self.send("#{attribute}?")}
      end

      def generate_unique_secure_token(token_length)
        SecureRandom.base58(token_length)
      end
    end
  end
end
