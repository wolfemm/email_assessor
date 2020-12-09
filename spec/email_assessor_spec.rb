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

describe EmailAssessor do
  let(:plain_user) { TestUser.new(email: "") }
  let(:disposable_user) { TestUserDisallowDisposable.new(email: "foo@gmail.com") }
  let(:blacklist_user) { TestUserDisallowBlacklisted.new(email: "foo@gmail.com") }
  let(:mx_user) { TestUserMX.new(email: "foo@gmail.com") }

  let(:blacklisted_domains_file_name) { described_class::BLACKLISTED_DOMAINS_FILE_NAME }
  let(:blacklisted_domain) { File.open(blacklisted_domains_file_name, &:readline).chomp }

  let(:disposable_domains_file_name) { described_class::DISPOSABLE_DOMAINS_FILE_NAME }
  let(:disposable_domain) { File.open(disposable_domains_file_name, &:readline).chomp }

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

    it "is invalid if the domain contains emoticons" do
      user.email = "foo🙈@gmail.com"
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
