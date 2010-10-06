require 'test/unit'
$LOAD_PATH << './ext'
require 'lib/rglpk'


class TestRglpk < Test::Unit::TestCase

  def test_create
    assert_instance_of Rglpk::Problem, Rglpk::Problem.new
  end

  def test_name
    p = Rglpk::Problem.new
    p.name = 'test'
    assert_equal 'test', p.name
  end

  def test_obj_fun_name
    p = Rglpk::Problem.new
    p.obj.name = 'test'
    assert_equal 'test', p.obj.name
  end

  def test_obj_fun_dir
    p = Rglpk::Problem.new
    p.obj.dir = Rglpk::GLP_MIN
    assert_equal Rglpk::GLP_MIN, p.obj.dir
    p.obj.dir = Rglpk::GLP_MAX
    assert_equal Rglpk::GLP_MAX, p.obj.dir
    assert_raise(ArgumentError){p.obj.dir = 3}
  end

  def test_add_rows
    p = Rglpk::Problem.new
    p.add_rows(2)
    assert_equal 2, p.rows.size
    p.add_rows(2)
    assert_equal 4, p.rows.size
  end

  def test_add_cols
    p = Rglpk::Problem.new
    p.add_cols(2)
    assert_equal 2, p.cols.size
    p.add_cols(2)
    assert_equal 4, p.cols.size
  end

  def test_set_row_name
    p = Rglpk::Problem.new
    p.add_rows(10)
    p.rows[1].name = 'test'
    assert_equal 'test', p.rows[1].name
    assert_nil p.rows[2].name
  end

  def test_set_col_name
    p = Rglpk::Problem.new
    p.add_cols(2)
    p.cols[0].name = 'test'
    assert_equal 'test', p.cols[0].name
    assert_nil p.cols[1].name
  end

  def test_set_row_bounds
    p = Rglpk::Problem.new
    p.add_rows(2)
    p.rows[1].set_bounds(Rglpk::GLP_FR, nil, nil)
    assert_equal [Rglpk::GLP_FR, nil, nil], p.rows[1].bounds
  end

  def test_set_col_bounds
    p = Rglpk::Problem.new
    p.add_cols(2)
    p.cols[1].set_bounds(Rglpk::GLP_FR, nil, nil)
    assert_equal [Rglpk::GLP_FR, nil, nil], p.cols[1].bounds
  end

  def test_obj_coef
    p = Rglpk::Problem.new
    p.add_cols(2)
    p.obj.set_coef(1, 2)
    assert_equal [2, 0], p.obj.coefs
    p.obj.coefs = [1, 2]
    assert_equal [1, 2], p.obj.coefs
  end

  def test_set_row
    p = Rglpk::Problem.new
    p.add_rows(2)
    assert_raise(RuntimeError){p.rows[1].set([1, 2])}
    p.add_cols(2)
    p.rows[1].set([1, 2])
    assert_equal [1, 2], p.rows[1].get
  end

  def test_set_col
    p = Rglpk::Problem.new
    p.add_cols(2)
    assert_raise(RuntimeError){p.cols[1].set([1, 2])}
    p.add_rows(2)
    p.cols[1].set([1, 2])
    assert_equal [1, 2], p.cols[1].get
  end

  def test_set_mat
    p = Rglpk::Problem.new
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1, 2, 3, 4])
    assert_equal [1, 2], p.rows[0].get
    assert_equal [3, 4], p.rows[1].get
    assert_equal [1, 3], p.cols[0].get
    assert_equal [2, 4], p.cols[1].get
  end

  def test_del_row
    p = Rglpk::Problem.new
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1, 2, 3, 4])
    assert_equal [1, 2], p.rows[0].get
    p.del_rows([1])
    assert_equal [3, 4], p.rows[0].get
    assert_equal [3], p.cols[0].get
  end

  def test_del_col
    p = Rglpk::Problem.new
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1, 2, 3, 4])
    assert_equal [1, 3], p.cols[0].get
    p.del_cols([1])
    assert_equal [2, 4], p.cols[0].get
    assert_equal [2], p.rows[0].get
  end

  def test_nz
    p = Rglpk::Problem.new
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1, 2, 3, 4])
    assert_equal 4, p.nz
  end

  def test_row_get_by_name
    p = Rglpk::Problem.new
    assert_raises(RuntimeError){ p.rows['test'] }
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1, 2, 3, 4])
    assert_raises(ArgumentError){ p.rows['test'] }
    p.rows[0].name = 'test'
    assert_equal [1, 2], p.rows['test'].get
  end

  def test_col_get_by_name
    p = Rglpk::Problem.new
    assert_raises(RuntimeError){ p.cols['test'] }
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1, 2, 3, 4])
    assert_raises(ArgumentError){ p.cols['test'] }
    p.cols[0].name = 'test'
    assert_equal [1, 3], p.cols['test'].get
  end

  def test_solve
    p = Rglpk::Problem.new
    assert_raises(RuntimeError){ p.cols['test'] }
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1, 2, 3, 4])
    p.simplex({:msg_lev => 1})
  end

  class D < Rglpk::Problem
    attr_accessor :species
    def initialize
      @species = []
      super
    end
  end

  def test_derived
    D.new.add_rows(10)
  end
end


module TestProblemKind
  def setup
    @p = Rglpk::Problem.new
    @p.obj.dir = Rglpk::GLP_MAX
    
    cols = @p.add_cols(3)
    cols[0].set_bounds(Rglpk::GLP_LO, 0.0, 0.0)
    cols[1].set_bounds(Rglpk::GLP_LO, 0.0, 0.0)
    cols[2].set_bounds(Rglpk::GLP_LO, 0.0, 0.0)
    
    rows = @p.add_rows(3)
    
    rows[0].set_bounds(Rglpk::GLP_UP, 0, 4)
    rows[1].set_bounds(Rglpk::GLP_UP, 0, 5)
    rows[2].set_bounds(Rglpk::GLP_UP, 0, 6)
    
    @p.obj.coefs = [1, 1, 1]
    
    @p.set_matrix([
      1, 1, 0,
      0, 1, 1,
      1, 0, 1
    ])
    
    @p.cols.each{|c| c.kind = column_kind}
  end
  
  def verify_results(*results)
    if column_kind == Rglpk::GLP_CV
      solution_method = :simplex
      value_method = :get_prim
    else
      solution_method = :mip
      value_method = :mip_val
    end
    
    @p.send(solution_method, {:presolve => Rglpk::GLP_ON})
    
    @p.cols.each_with_index do |col, index|
      assert_equal results[index], col.send(value_method)
    end
  end
end

class BinaryVariables < Test::Unit::TestCase
  include TestProblemKind
  
  def column_kind
    Rglpk::GLP_BV
  end
  
  def test_results
    verify_results(1, 1, 1)
  end
end

class IntegerVariables < Test::Unit::TestCase
  include TestProblemKind
  
  def column_kind
    Rglpk::GLP_IV
  end
  
  def test_results
    verify_results(3, 1, 3)
  end
end

class ContinuousVariables < Test::Unit::TestCase
  include TestProblemKind
  
  def column_kind
    Rglpk::GLP_CV
  end
  
  def test_results
    verify_results(2.5, 1.5, 3.5)
  end
end