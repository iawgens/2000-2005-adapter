require 'cases/sqlserver_helper'
require 'models/membership'

class BooleanTestSqlserver < ActiveRecord::TestCase
  fixtures :memberships
  
  context 'Testing boolean sql string conditions equals true or false' do

    should 'allow and return true when is_boolean = true' do
      assert_equal memberships(:membership_of_favourite_club), Membership.find(:first, :conditions => 'favourite = true')
      assert_equal memberships(:membership_of_favourite_club), Membership.find(:first, :conditions => "favourite = 'true'")
    end
    
    should 'allow and return false when is_boolean = false' do
      assert_contains Membership.find(:all, :conditions => 'favourite = false'), memberships(:membership_of_boring_club) 
      assert_contains Membership.find(:all, :conditions => "favourite = 'false'"), memberships(:membership_of_boring_club)
    end
    
    should 'allow and return true as default when no value is provided' do
      assert_equal memberships(:membership_of_favourite_club), Membership.find(:first, :conditions => '(favourite)')
    end
    
  end
end