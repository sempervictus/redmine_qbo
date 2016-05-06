#The MIT License (MIT)
#
#Copyright (c) 2016 rick barrette
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# This controller class will handle map management
class VehiclesController < ApplicationController
  unloadable
  
  include AuthHelper
  
  before_filter :require_user
  
  # display a list of all vehicles
  def index
    @vehicles = Vehicle.paginate(:page => params[:page])
  end

  # return an HTML form for creating a new vehicle
  def new
    @vehicle = Vehicle.new
    Customer.skip_callback(:find, :after, :get_details)
    @customers = Customer.all.order(:name)
    Customer.set_callback(:find, :after, :get_details)
  end

  # create a new vehicle
  def create
    @vehicle = Vehicle.new(params[:vehicle])
    if @vehicle.save
      flash[:notice] = "New Vehicle Created"
    else
      render :edit
    end
    flash[:error] = @vehicle.errors.full_messages.to_sentence if @vehicle.errors
    redirect_to @vehicle
  end
  
  # display a specific vehicle
  def show
    @vehicle = Vehicle.find_by_id(params[:id])
    if @vehicle
      @customer = @vehicle.customer.name if @vehicle.customer
    else
      flash[:error] = "Vehicle Not Found"
      @customers = Customer.all.order(:name)
      render :index
    end
  end
  
  # return an HTML form for editing a vehicle
  def edit
    @vehicle = Vehicle.find_by_id(params[:id])
    @customer = @vehicle.customer.id if @vehicle.customer
    @customers = Customer.all.order(:name)
  end
  
  # update a specific vehicle
  def update
    @customers = Customer.all.order(:name)
    @customer = params[:customer]
    @vehicle = Vehicle.find_by_id(params[:id])
    if @vehicle.update_attributes(params[:vehicle])
      flash[:notice] = "Vehicle updated"
      redirect_to @vehicle
    else
      render :edit
    end
    flash[:error] = @vehicle.errors.full_messages.to_sentence if @vehicle.errors
  end  

  # delete a specific vehicle
  def destroy 
    v = Vehicle.find_by_id(params[:id])
    if v?
      v.destroy
      flash[:notice] = "Vehicle deleted successfully"
    else
      flash[:error] = "No Vehicle Found"
    end
    redirect_to action: :index
  end

end
