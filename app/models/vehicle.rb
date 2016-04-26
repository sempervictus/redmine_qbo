#The MIT License (MIT)
#
#Copyright (c) 2016 rick barrette
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Vehicle < ActiveRecord::Base
  
  unloadable
  belongs_to :qbo_customer
  
  attr_accessible :year, :make, :model, :qbo_customer_id, :notes, :vin
  validates_presence_of :year, :make, :model, :qbo_customer_id
  
  before_save :decode_vin
  
  def to_s
    return "#{year} #{make} #{model}"
  end
  
  private
  
  def decode_vin
    if vin?
      decoder = Edmunds::Vin.new('2dheutzvhxs28dzukx5tgu47')
      vehicle = decoder.full(vin)
      year = vehicle['years'][0]['year']
      make = vehicle['make']['name']
      model = vehicle['model']['name']
    end
  end
end
