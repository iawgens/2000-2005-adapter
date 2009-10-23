require 'cases/sqlserver_helper'

class UnicodeTestSqlserver < ActiveRecord::TestCase
  
  
  context 'Testing basic saves and unicode limits' do

    should 'save and reload simple nchar string' do
      assert nchar_data = SqlServerUnicode.create!(:nchar => 'A')
      assert_equal 'A', SqlServerUnicode.find(nchar_data.id).nchar
    end
    
    should 'save and reload simple nvarchar(max) string' do
      test_string = 'Ken Collins'
      assert nvarcharmax_data = SqlServerUnicode.create!(:nvarchar_max => test_string)
      assert_equal test_string, SqlServerUnicode.find(nvarcharmax_data.id).nvarchar_max
    end if sqlserver_2005? || sqlserver_2008?

    should 'enforce default nchar_10 limit of 10' do
      assert_raise(ActiveRecord::StatementInvalid) { SqlServerUnicode.create!(:nchar => '01234567891') }
    end

    should 'enforce default nvarchar_100 limit of 100' do
      assert_raise(ActiveRecord::StatementInvalid) { SqlServerUnicode.create!(:nvarchar_100 => '0123456789'*10+'1') }
    end

  end

  context 'Testing unicode data' do

    setup do
      @unicode_data = "一二34五六"
      @encoded_unicode_data = "一二34五六".force_encoding('UTF-8') if ruby_19?
      @partial_unicode_data = "一二"
    end

    should 'insert into nvarchar field' do
      assert data = SqlServerUnicode.create!(:nvarchar => @unicode_data)
      assert_equal @unicode_data, data.reload.nvarchar
    end
    
    should 're-encode data on DB reads' do
      assert data = SqlServerUnicode.create!(:nvarchar => @unicode_data)
      assert_equal @encoded_unicode_data, data.reload.nvarchar
    end if ruby_19?
    
    context 'querying unicode columns' do
      
      should 'return result with string conditions' do
        assert data = SqlServerUnicode.create!(:nvarchar => @unicode_data)
        assert_equal data.nvarchar, SqlServerUnicode.find(:first, :conditions => ["nvarchar LIKE ?","%#{@partial_unicode_data}%"]).nvarchar
      end if ActiveRecord::ConnectionAdapters::SQLServerAdapter.enable_default_unicode_types
      
      should 'return result with hash conditions' do
        assert data = SqlServerUnicode.create!(:nvarchar => @unicode_data)
        assert_equal data.nvarchar, SqlServerUnicode.find(:first, :conditions => {:nvarchar => @unicode_data}).nvarchar
      end if ActiveRecord::ConnectionAdapters::SQLServerAdapter.enable_default_unicode_types
      
    end

  end


end
