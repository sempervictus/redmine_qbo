#The MIT License (MIT)
#
#Copyright (c) 2016 rick barrette
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Customer < ActiveRecord::Base
  unloadable
  
  has_many :issues, :foreign_key => 'customers_id'
  has_many :qbo_purchases
  has_many :vehicles
  
  attr_accessible :name, :notes, :email, :primary_phone, :mobile_phone, :skip_details
  
  validates_presence_of :id, :name
  
  after_initialize :pull, unless: :new_record?
  #before_save :create_customer, unless: :new_record?
  after_save  :push, unless: :new_record?
  
  self.primary_key = :id
  
  # returns a human readable string
  def to_s
    return name
  end
  
  # returns the customer's email
  def email
    begin
      return @details.email_address.address
    rescue
      return nil
    end
  end
  
  # returns the customer's primary phone
  def primary_phone
    begin
      return @details.primary_phone.free_form_number
    rescue
      return nil
    end
  end
  
  # Updates the customer's primary phone number
  def primary_phone=(n)
    Quickbooks::Model::TelephoneNumber.new
    pn.free_form_number = n
    @details.primary_phone = pn
  end
  
  # returns the customer's mobile phone
  def mobile_phone
    begin
      return @details.mobile_phone.free_form_number
    rescue
      return nil
    end
  end
  
  # Updates the custome's mobile phone number
  def mobile_phone=(n)
    Quickbooks::Model::TelephoneNumber.new
    pn.free_form_number = n
    @details.mobile_phone = pn
  end
  
  # Updates Both local DB name & QBO display_name
  def name=(s)
    display_name = s
    self.name = s
  end
  
  # Magic Method  
  def method_missing(name, *arguments)  
    value = arguments[0]  
    name = name.to_s  

    # if the method's name ends with '='  
    if name[-1, 1] == "="  
      method_name = name[0..-2]  
      @details[method_name] = value  
    else  
      begin  
        return @details[name]  
      rescue  
        return nil  
      end  
    end  
  end  
  
  # proforms a bruteforce sync operation
  # This needs to be simplified
  def self.sync 
    last = Qbo.first.last_sync
    
    query = "SELECT Id, DisplayName FROM Customer"
    query << " WHERE Metadata.LastUpdatedTime>'#{last}' " if last
    
    customers = Qbo.get_base(:customer).service.query()

    transaction do
      # Update the customer table
      customers.each { |customer|
        qbo_customer = Customer.find_or_create_by(id: customer.id)
        # only update if diffrent
        if qbo_customer.new_record?
          qbo_customer.name = customer.display_name
          qbo_customer.id = customer.id
          qbo_customer.save!
        end
      }
    end
   
    # remove deleted customers
    #where.not(customers.map(&:id)).destroy_all
  end
  
  def self.without_callback(*args, &block)
    skip_callback(*args)
    yield
    set_callback(*args)
  end
  
  private
  
  # pull the details
  def pull
    begin
      #tries ||= 3
      @details = Qbo.get_base(:customer).find_by_id(self.id)
    rescue
      #retry unless (tries -= 1).zero?
      @details = Quickbooks::Model::Customer.new
    end
  end
  
  # Push the updates
  def push
    begin
      #tries ||= 3
      @details = Qbo.get_base(:customer).service.update(@details)
      raise "QBO Fault" if @details.fault?
    rescue Exception => e
      #retry unless (tries -= 1).zero?
      errors.add(e.message)
    end
  end
  
  # Creates a new qbo customer and aquires ID number
  def create_customer
    if new_record?
      begin
        #tries ||= 3
        @details = Qbo.get_base(:customer).service.create(@details)
        raise "QBO Fault" if @details.fault?
        self.id = @details.id
      rescue Exception => e
        #retry unless (tries -= 1).zero?
        errors.add(:id, e.message)
      end
    end
  end
end
