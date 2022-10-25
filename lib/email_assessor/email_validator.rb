# frozen_string_literal: true
require "email_assessor/address"
require "active_model"
require "active_model/validations"

class EmailValidator < ActiveModel::EachValidator
  def default_options
    { regex: true, disposable: false, mx: false, fastpass: true }
  end

  def validate_each(record, attribute, value)
    return unless value.present?

    options = default_options.merge!(self.options)

    address = EmailAssessor::Address.new(value)

    error(record, attribute) && return unless address.valid?

    # Skip all domain blocklist checks for fastpass domains.
    # The goal is to skip needless validation for common "good" domains such as Gmail, Yahoo, and Outlook.
    # The fastpass domain list is configurable via vendor/fastpass_domains.txt
    validate_domain(record, attribute, address, options) unless options[:fastpass] && address.fastpass?

    # Exit early if validate_domain found a validation error
    return if record.errors.key?(attribute)

    if options[:mx]
      error(record, attribute, error_type(:mx, options)) && return unless address.valid_mx?
    end
  end

  private

  def error(record, attribute, type = options[:message] || :invalid)
    record.errors.add(attribute, type)
  end

  def error_type(validator, options)
    option_value = options[validator]

    if option_value.is_a?(String) || option_value.is_a?(Symbol)
      return option_value
    end

    options[:message] || :invalid
  end

  def validate_domain(record, attribute, address, options)
    if options[:disposable]
      error(record, attribute, error_type(:disposable, options)) && return if address.disposable?
    end

    if options[:blacklist]
      error(record, attribute, error_type(:blacklist, options)) && return if address.blacklisted?
    end

    if options[:educational]
      error(record, attribute, error_type(:educational, options)) && return if address.educational?
    end

    # if options[:domain_not_in]
    #   matched_blocklist = options[:domain_not_in].select do |entry|
    #     unless entry.key?(:blocklist)
    #       fail "domain_not_in entries must be in format { blocklist: \"filename\"[, message: symbol|string] }"
    #     end

    #     next unless address.domain_in_blocklist?(entry[:blocklist])

    #     error(record, attribute, entry[:message])

    #     true
    #   end

    #   return if matched_blocklist
    # end
  end
end
