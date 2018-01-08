require 'test_helper'

class StudentUpdateTest < ActionDispatch::IntegrationTest
  def setup
    @origin_name = "student"
    @origin_email = "student@test.com"
    @origin_num = "2017#{Faker::Number.number(11)}"
    @origin_major = "计算机软件与理论"
    @origin_department = "计算机网络信息中心"
    @origin_password = "password"
    @student = User.create(
        name: @origin_name,
        email:@origin_email,
        num:@origin_num,
        major: @origin_major, 
        department:@origin_department,
        password:@origin_password, 
        password_confirmation:@origin_password
    )

    assert @student.valid? "valid student"

    get sessions_login_path
    assert_template 'sessions/new','render login page'
    post sessions_login_path session:{  
      email: @origin_email,
      password:@origin_password
    }
    assert_not User.find_by_id(session[:user_id]).teacher
    assert_not User.find_by_id(session[:user_id]).admin
    @current_user = User.find_by(id: session[:user_id])
  end

  test "student update info with new info" do
    get edit_user_path(@current_user)
    assert_template 'users/edit'

    @new_name = "student_new"
    @new_email = "student_new@test.com"
    @new_major = "计算机应用与技术"
    @new_department = "计算机网络中心"


    patch user_path(@current_user), user:{ 
      name:@new_name,
      email:@new_email,
      major:@new_major,
      department:@new_department,
      password:@origin_password
    }

    @current_user = User.find_by(id: session[:user_id])
    assert_equal flash[:info], "更新成功"
    assert_equal @current_user.name, @new_name
    assert_equal @current_user.email, @new_email
    assert_equal @current_user.major, @new_major
    assert_equal @current_user.department, @new_department
  end

  test "student update info with wrong password" do
    get edit_user_path(@current_user)
    assert_template 'users/edit'

    @new_name = "student_new"
    @new_email = "student@test.com_new"
    @new_num = "2017#{Faker::Number.number(11)}_new"
    @new_major = "计算机应用与技术"
    @new_department = "计算机网络中心"
    @wrong_password = "password_wrong"


    patch user_path(@current_user), user:{
      name:@new_name,
      email:@new_email,
      num:@new_num,
      major:@new_major,
      department:@new_department,
      password:@wrong_password
    }
    @current_user = User.find_by(id: session[:user_id])
    assert_equal flash[:warning], "更新失败"

    assert_equal @current_user.name, @origin_name
    assert_equal @current_user.email, @origin_email
    assert_equal @current_user.num, @origin_num
    assert_equal @current_user.major, @origin_major
    assert_equal @current_user.department, @origin_department
  end

end