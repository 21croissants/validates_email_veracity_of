require 'test/unit'
require File.dirname(__FILE__) + '/../test_helper'


class DomainTest < Test::Unit::TestCase

  def test_servers_with_no_name
    domain = ValidatesEmailVeracityOf::Domain.new(:timeout => 30)
    assert domain.exchange_servers.empty?, 'Should fail gracefully by returning an empty array of mail servers.'
    assert domain.address_servers.empty?, 'Should fail gracefully by returning an empty array of address servers.'
  end

  def test_with_name_of_gmail_dot_com
    domain = ValidatesEmailVeracityOf::Domain.new('gmail.com', :timeout => 30)
    assert !domain.exchange_servers.empty?, 'Should return mail servers for gmail dot com.'
    assert !domain.address_servers.empty?, 'Should return address servers for gmail dot com.'
  end

  def test_with_nonexistant_name
    domain = ValidatesEmailVeracityOf::Domain.new('idonot-exist.nil.xd', :timeout => 30)
    assert domain.exchange_servers.empty?, 'Should return a blank array.'
    assert domain.address_servers.empty?, 'Should return a blank array.'
  end

  def test_timeout
    domain = ValidatesEmailVeracityOf::Domain.new('nowhere-abcdef.ca', :timeout => 0.0001)
    assert !domain.exchange_servers, 'Should return false by default on mail server timeout.'
    assert !domain.address_servers, 'Should return false by default on address server timeout.'
  end

  def test_timeout_when_fail_on_timeout_is_set
    domain = ValidatesEmailVeracityOf::Domain.new('nowhere-abcdef.ca', :timeout => 0.0001, :fail_on_timeout => true)
    assert_nil domain.exchange_servers, 'Should return nil on mail server timeout.'
    assert_nil domain.address_servers, 'Should return nil on address server timeout.'
  end

end


class EmailAddressTest < Test::Unit::TestCase

  def test_with_invalid_domain
    email = ValidatesEmailVeracityOf::EmailAddress.new('carsten@invalid.com', :invalid_domains => %w[invalid.com])
    assert !email.domain.valid?, 'Should not pass as a valid domain.'
  end

  def test_domain_has_servers_with_no_email_address
    email = ValidatesEmailVeracityOf::EmailAddress.new(:timeout => 30)
    assert !email.domain.has_servers?, 'Should fail gracefully.'
  end

  def test_malformed_email_addresses
    malformed_addresses.each do |address|
      email = ValidatesEmailVeracityOf::EmailAddress.new(address)
      assert_nil email.pattern_is_valid?, 'Should fail pattern validation.'
    end
  end

  def test_well_formed_email_addresses
    well_formed_addresses.each do |address|
      email = ValidatesEmailVeracityOf::EmailAddress.new(address)
      assert email.pattern_is_valid?, 'Should pass pattern validation.'
    end
  end

  def test_itsme_at_heycarsten_dot_com
    email = ValidatesEmailVeracityOf::EmailAddress.new('itsme@heycarsten.com', :timeout => 30)
    assert email.domain.has_servers?, 'Should have servers.'
  end

  def test_nobody_at_carstensnowhereland_dot_ca
    email = ValidatesEmailVeracityOf::EmailAddress.new('nobody@carstensnowhereland.ca', :timeout => 30)
    assert !email.domain.has_servers?, 'Should not have mail servers.'
  end

  def test_an_object_with_no_address
    email = ValidatesEmailVeracityOf::EmailAddress.new
    assert_equal ValidatesEmailVeracityOf::Domain, email.domain.class, 'Should still have a domain object.'
  end

  def test_an_object_with_an_address_but_no_domain
    email = ValidatesEmailVeracityOf::EmailAddress.new('niltor@')
    assert_equal '', email.domain.name, 'Should have a domain object with no name.'
  end

  # The comma is used in address header fields to separate email addresses from each other.
  # Example: tarzan@jungle.org, jane@jungle.org. RFC2822 allowes their use if they are inside
  # double quotes, but this would be very confusing. They are used in source routing, too.
  # Don't use them in the *local* part.
  # see http://www.remote.org/jochen/mail/info/chars.html for details

  def test_local_part_of_email_address
    email = ValidatesEmailVeracityOf::EmailAddress.new(invalid_local_part_address)
    assert_equal 'carsten,comma', email.local_part, 'Should get the local part of the email'
  end

  def test_malformed_local_part
    email = ValidatesEmailVeracityOf::EmailAddress.new(invalid_local_part_address)
    assert_equal false, email.local_part_is_valid?, 'Should fail local part validation.'
  end

end