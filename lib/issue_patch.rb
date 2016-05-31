#The MIT License (MIT)
#
#Copyright (c) 2016 rick barrette
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require_dependency 'issue'

# Patches Redmine's Issues dynamically.  
# Adds a relationships
module IssuePatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      belongs_to :customer, primary_key: :id
      belongs_to :qbo_item, primary_key: :id
      belongs_to :qbo_estimate, primary_key: :id
      belongs_to :qbo_invoice, primary_key: :id
      belongs_to :vehicle
      
      alias_method_chain :notified_users, :patch
    end
    
  end
    
  module ClassMethods
    
  end
  
  module InstanceMethods
    
    # Add the customer to the email list
    def notified_users_with_patch
      notified = []
      notified << notified_users_without_patch
      notified << customer if customer
      return notified
    end
  end
  
end    

# Add module to Issue
Issue.send(:include, IssuePatch)
