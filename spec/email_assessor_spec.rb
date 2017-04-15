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

    it "should be valid when email is empty" do
      is_expected.to be_valid
    end

    it "should not be valid when domain is missing" do
      user.email = "foo@.com"
      is_expected.to be_invalid
    end

    it "should be invalid when email is malformed" do
      user.email = "foo@bar"
      is_expected.to be_invalid
    end

    it "should be invalid when email contains a trailing symbol" do
      user.email = "foo@bar.com/"
      is_expected.to be_invalid
    end

    it "should be invalid if Mail::AddressListsParser raises exception" do
      allow(Mail::Address).to receive(:new).and_raise(Mail::Field::ParseError.new(nil, nil, nil))
      user.email = "foo@gmail.com"
      is_expected.to be_invalid
    end

    it "shouldn't be valid if the domain constains consecutives dots" do
      user.email = "foo@bar..com"
      is_expected.to be_invalid
    end
  end

  describe "disposable domains" do
    subject(:user) { disposable_user }

    it "should be valid when email is not in the list of disposable domains" do
      is_expected.to be_valid
    end

    it "should be invalid when email is in the list of disposable domains" do
      user.email = "foo@#{disposable_domain}"
      is_expected.to be_invalid
    end

    it "should be invalid when email is in the list of disposable domains regardless of subdomain" do
      user.email = "foo@abc123.#{disposable_domain}"
      is_expected.to be_invalid
    end
  end

  describe "blacklisted domains" do
    subject(:user) { blacklist_user }

    it "should be valid when email domain is not in the blacklist" do
      is_expected.to be_valid
    end

    it "should be invalid when email domain is in the blacklist" do
      user.email = "foo@#{blacklisted_domain}"
      is_expected.to be_invalid
    end

    it "should be invalid when email domain is in the blacklist regardless of subdomain" do
      user.email = "foo@abc123.#{blacklisted_domain}"
      is_expected.to be_invalid
    end
  end

  describe "mx lookup" do
    subject(:user) { mx_user }

    it "should be valid if mx records are found" do
      is_expected.to be_valid
    end

    it "should be invalid if no mx records are found" do
      user.email = "foo@subdomain.gmail.com"
      is_expected.to be_invalid
    end
  end
end
