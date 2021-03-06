# encoding: UTF-8
require File.dirname(__FILE__) + '/spec_helper'

describe Nimbus::LossFunctions do

  it "method for average" do
    ids = [1,3,5,7]
    values = {1 => 10, 2 => 5, 3 => 21, 4 => 8, 5 => 31, 7 => 11, 85 => 22}

    Nimbus::LossFunctions.average(ids, values).should == 18.25 # (10 + 21 + 31 + 11 = 73)/4
  end

  it "method for mean squared error" do
    ids = [3,7,85]
    values = {1 => 10, 2 => 5, 3 => 21, 4 => 8, 5 => 31, 7 => 11, 85 => 22}

    Nimbus::LossFunctions.mean_squared_error(ids, values).should == 74.0 # (avg(21 + 11 + 22) = 18: sum (x-18)^2
  end

  it "method for quadratic_loss" do
    ids = [1,4]
    values = {1 => 10, 2 => 5, 3 => 21, 4 => 8, 5 => 31, 7 => 11, 85 => 22}

    Nimbus::LossFunctions.quadratic_loss(ids, values).round(5).should == 1
  end

  it "quadratic loss is mean squared error averaged" do
    ids = [1,2,3,4,5,7,85]
    values = {1 => 10, 2 => 5, 3 => 21, 4 => 8, 5 => 31, 7 => 11, 85 => 22}
    Nimbus::LossFunctions.quadratic_loss(ids, values).round(5).should == (Nimbus::LossFunctions.mean_squared_error(ids, values)/7 ).round(5)
  end

  it "method for pseudo Huber error" do
    ids = [3,7,85]
    values = {1 => 10, 2 => 5, 3 => 21, 4 => 8, 5 => 31, 7 => 11, 85 => 22}
    Nimbus::LossFunctions.pseudo_huber_error(ids, values).round(5).should == 11.92337 # (avg(21 + 11 + 22) = 18: log(cosh(x-18))
  end

  it "method for pseudo Huber loss function" do
    ids = [1,4]
    values = {1 => 10, 2 => 5, 3 => 21, 4 => 8, 5 => 31, 7 => 11, 85 => 22}
    Nimbus::LossFunctions.pseudo_huber_loss(ids, values).round(5).should == 0.43378
  end

  it "pseudo Huber loss is pseudo Huber error averaged" do
    ids = [1,2,3,4,5,7,85]
    values = {1 => 10, 2 => 5, 3 => 21, 4 => 8, 5 => 31, 7 => 11, 85 => 22}
    Nimbus::LossFunctions.pseudo_huber_loss(ids, values).round(5).should == (Nimbus::LossFunctions.pseudo_huber_error(ids, values)/7 ).round(5)
  end

  it "method for squared difference" do
    Nimbus::LossFunctions.squared_difference(50, 40).should == 100.0
    Nimbus::LossFunctions.squared_difference(22, 10).should == 144.0
  end

  it "method for majority class" do
    ids     = [1,2,3,4,5,7,85]
    values  = {1 => 'B', 2 => 'C', 3 => 'A', 4 => 'A', 5 => 'C', 7 => 'B', 85 => 'C'} #3C, 2A, 2B
    classes = ['A', 'B', 'C']
    Nimbus::LossFunctions.majority_class(ids, values, classes).should == 'C'
  end

  it "majority class method selects randomly if more than one majority class" do
    ids     = [1,2,3,4,5,7,85,99]
    values  = {1 => 'B', 2 => 'C', 3 => 'A', 4 => 'A', 5 => 'C', 7 => 'B', 85 => 'C', 99 => 'A'} #3C, 3A, 2B
    classes = ['A', 'B', 'C']
    results = []
    20.times do
      results << Nimbus::LossFunctions.majority_class(ids, values, classes)
    end
    results.should include('A')
    results.should include('C')
  end

  it "method for majority class in list" do
    list    = %w(A A A B B B C A B C A B A)
    classes = ['A', 'B', 'C']
    Nimbus::LossFunctions.majority_class_in_list(list, classes).should == 'A'
  end

  it "method for class sizes" do
    ids     = [1,2,3,4,5,7,85]
    values  = {1 => 'B', 2 => 'C', 3 => 'A', 4 => 'A', 5 => 'C', 7 => 'B', 85 => 'C'} #2A, 2B, 3C
    classes = ['A', 'B', 'C']
    Nimbus::LossFunctions.class_sizes(ids, values, classes).should == [2, 2, 3]
  end

  it "method for class sizes in list" do
    list    = %w(A A A B B B C A B C A B A)  # 6A, 5B, 2C
    classes = ['A', 'B', 'C']
    Nimbus::LossFunctions.class_sizes_in_list(list, classes).should == [6, 5, 2]
  end

  it "Gini index" do
    ids     = [1,2,3,4,5,7]
    values  = {1 => 'B', 2 => 'C', 3 => 'A', 4 => 'A', 5 => 'C', 7 => 'C'} #3C, 2A, 1B
    classes = ['A', 'B', 'C']
    # Gini = 1 - ( (3/6)^2 + (2/6)^2 + (1/6)^2 ) = 0.61111
    Nimbus::LossFunctions.gini_index(ids, values, classes).should == 0.61111
  end

end