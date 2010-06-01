require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Octopus" do
  describe "the API" do    
    it "should load the shards.yml file to start working" do
      Octopus.config().should be_kind_of(Hash)
    end
    
    it "should return self after calling the #using method" do
      User.using(:canada).should == User
    end

    it "should allow selecting the shards on scope" do
      User.using(:canada).create!(:name => 'oi')
      User.using(:canada).count.should == 1
      User.using(:master).count.should == 0
    end
    
    it "should allow scoping dinamically" do
      User.using(:canada).using(:master).using(:canada).create!(:name => 'oi')
      User.using(:canada).using(:master).count.should == 0
      User.using(:master).using(:canada).count.should == 1
    end
    
    it "should clean the current_shard after executing the current query" do
      User.using(:canada).create!(:name => "oi")
      User.count.should == 0 
    end
    
    it "should allow passing a block to #using" do
      User.using_shard(:canada) do
        User.create(:name => "oi")
      end
      
      User.using(:canada).count.should == 1
      User.using(:master).count.should == 0
      User.count.should == 0      
    end
    
    it "should allow execute queries inside a model" do
      u = User.new
      u.awesome_queries()
      User.using(:canada).count.should == 1
      User.count.should == 0
    end
    
    it "should support both groups and alone shards" do
      User.using(:alone_shard).create!(:name => "Alone")
      User.using(:alone_shard).count.should == 1
      User.using(:master).count.should == 0
      User.using(:canada).count.should == 0
      User.using(:brazil).count.should == 0
    end
  end
end