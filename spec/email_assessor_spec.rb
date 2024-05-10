# frozen_string_literal: true
require "spec_helper"

class TestUser < TestModel
  validates :email, email: true
end

class TestUserMX < TestModel
  validates :email, email: { mx: true }
end

class TestUserDisallowDisposable < TestModel
  validates :email, email: { disposable: true }
end

class TestUserDisallowBlacklisted < TestModel
  validates :email, email: { blacklist: true }
end

class TestUserDisallowEducational < TestModel
  validates :email, email: { educational: :no_educational }
end

describe EmailAssessor do
  let(:blacklisted_domain) { described_class.blacklisted_domains.sample }
  let(:disposable_domain) { described_class.disposable_domains.sample }
  let(:educational_domain) { described_class.educational_domains.sample }

  let(:plain_user) { TestUser.new(email: "") }
  let(:disposable_user) { TestUserDisallowDisposable.new(email: "foo@gmail.com") }
  let(:blacklist_user) { TestUserDisallowBlacklisted.new(email: "foo@gmail.com") }
  let(:educational_user) { TestUserDisallowEducational.new(email: "foo@gmail.com") }
  let(:mx_user) { TestUserMX.new(email: "foo@gmail.com") }

  # it "is valid when email is empty" do
  #   require "benchmark"
  #   Benchmark.bm(7) do |x|
  #     x.report("new") { 10000.times { |i| EmailAssessor.disposable_domains.include_any?(EmailAssessor::DomainTokenSet.parse("test@test.gmail.com")) } }
  #   end
  # end

  describe "basic validation" do
    subject(:user) { plain_user }

    it "is valid when email is empty" do
      is_expected.to be_valid
    end

    it "is invalid if the address starts with a dot" do
      user = TestUser.new(email: ".foo@bar.com")
      expect(user.valid?).to be_falsey
    end

    it "is invalid if the address contains consecutive dots" do
      user = TestUser.new(email: "foo..bar@gmail.com")
      expect(user.valid?).to be_falsey
    end

    it "is invalid if the address ends with a dot" do
      user = TestUser.new(email: "foo.@bar.com")
      expect(user.valid?).to be_falsey
    end

    it "is invalid when domain is missing" do
      user.email = "foo@.com"
      is_expected.to be_invalid
    end

    it "is invalid when domain starts with a dot" do
      user.email = "foo@.example.com"
      is_expected.to be_invalid
    end

    it "is invalid when email is malformed" do
      user.email = "foo@bar"
      is_expected.to be_invalid
    end

    it "is invalid when email contains a trailing symbol" do
      user.email = "foo@bar.com/"
      is_expected.to be_invalid
    end

    it "is invalid if Mail::AddressListsParser raises exception" do
      allow(Mail::Address).to receive(:new).and_raise(Mail::Field::ParseError.new(nil, nil, nil))
      user.email = "foo@gmail.com"
      is_expected.to be_invalid
    end

    it "is invalid if the domain constains consecutives dots" do
      user.email = "foo@bar..com"
      is_expected.to be_invalid
    end

    it "is invalid if the domain contains spaces" do
      user.email = "user@gmail .com"
      is_expected.to be_invalid
    end

    it "is invalid if the domain contains '.@'" do
      user.email = "foo.@gmail.com"
      expect(user.valid?).to be_falsy
    end

    it "is invalid if the domain begins with a hyphen" do
      user.email = "foo@-gmail.com"
      expect(user.valid?).to be_falsy
    end

    it "is invalid if the domain name ends with a hyphen" do
      user.email = "foo@gmail-.com"
      expect(user.valid?).to be_falsy
    end

    %w[+ _ ! / \  '].each do |invalid_character|
      it "is invalid if domain contains a \"#{invalid_character}\" character" do
        user.email = "foo@google#{invalid_character}yahoo.com"
        is_expected.to be_invalid
      end
    end
  end

  describe "disposable domains" do
    subject(:user) { disposable_user }

    it "is valid when email is not in the list of disposable domains" do
      is_expected.to be_valid
    end

    it "is invalid when email is in the list of disposable domains" do
      user.email = "foo@#{disposable_domain}"
      is_expected.to be_invalid
    end

    it "is invalid when email is in the list of disposable domains regardless of case" do
      user.email = "foo@#{disposable_domain.upcase}"
      is_expected.to be_invalid
    end

    it "is invalid when email is in the list of disposable domains regardless of subdomain" do
      user.email = "foo@abc123.#{disposable_domain}"
      is_expected.to be_invalid
    end
  end

  describe "blacklisted domains" do
    subject(:user) { blacklist_user }

    it "is valid when email domain is not in the blacklist" do
      is_expected.to be_valid
    end

    it "is invalid when email domain is in the blacklist" do
      user.email = "foo@#{blacklisted_domain}"
      is_expected.to be_invalid
    end

    it "is invalid when email is in the blacklist regardless of case" do
      user.email = "foo@#{blacklisted_domain.upcase}"
      is_expected.to be_invalid
    end

    it "is invalid when email domain is in the blacklist regardless of subdomain" do
      user.email = "foo@abc123.#{blacklisted_domain}"
      is_expected.to be_invalid
    end
  end

  describe "educational domains" do
    subject(:user) { educational_user }

    it "is valid when email domain is not in the educational blocklist" do
      is_expected.to be_valid
    end

    it "is invalid when email domain is in the educational blocklist" do
      user.email = "foo@#{educational_domain}"
      is_expected.to be_invalid
    end

    it "is invalid when email is in the educational blocklist regardless of case" do
      user.email = "foo@#{educational_domain.upcase}"
      is_expected.to be_invalid
    end

    it "is invalid when email domain is in the educational blocklist regardless of subdomain" do
      user.email = "foo@abc123.#{educational_domain}"
      is_expected.to be_invalid
      expect(user.errors.added?(:email, :no_educational)).to be_truthy
    end
  end


  describe "mx lookup" do
    subject(:user) { mx_user }

    it "is valid if mx records are found" do
      is_expected.to be_valid
    end

    it "is invalid if no mx records are found" do
      user.email = "foo@subdomain.gmail.com"
      is_expected.to be_invalid
    end
  end
end
