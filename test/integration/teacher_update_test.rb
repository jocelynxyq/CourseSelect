require 'test_helper'

class TeacherUpdateTest < ActionDispatch::IntegrationTest
  def setup
    @origin_name = "teacher"
    @origin_email = "teacher_test@test.com"
    @origin_department = "计算机与控制学院"
    @origin_password = "password"
    @teacher = User.create(
      name: @origin_name,
      email: @origin_email,
      department:@origin_department,
      password: @origin_password, 
      password_confirmation: @origin_password,
      teacher: true
    )

    assert @teacher.valid? "valid teacher"

    get sessions_login_path
    assert_template 'sessions/new','render login page'
    post sessions_login_path session:{  
      email: "teacher_test@test.com",
      password:"password",
      remember_me: 0
    }
    
    assert(User.find_by_id(session[:user_id]).teacher,"login as teacher")

    @current_user = User.find_by(id: session[:user_id])
  end

  test "teacher update info with right password" do
    get edit_user_path(@current_user)
    assert_template 'users/edit'

    @new_name = "teacher_new"
    @new_email ="teacher_test_new@test.com"
    @new_department = "计算机学院"
    @wrong_password = "password_wrong"

    patch user_path(@current_user), user:{ 
      name:@new_name,
      email:@new_email,
      department:@new_department,
      password:@origin_password
    }

    @current_user = User.find_by(id: session[:user_id])
    assert_equal flash[:info], "更新成功"

    assert_equal @current_user.name, @new_name
    assert_equal @current_user.email, @new_email
    assert_equal @current_user.department, @new_department
  end

  test "teacher update info with wrong password" do
    get edit_user_path(@current_user)
    assert_template 'users/edit'

    @new_name = "teacher_new"
    @new_email ="teacher_test_new@test.com"
    @new_department = "计算机学院"
    @wrong_password = "password_wrong"


    patch user_path(@current_user), user:{ 
      name:@new_name,
      email:@new_email,
      department:@new_department,
      password:@wrong_password
    }
    
    @current_user = User.find_by(id: session[:user_id])
    assert_equal flash[:warning], "更新失败"

    assert_equal @current_user.name, @origin_name
    assert_equal @current_user.email, @origin_email
    assert_equal @current_user.department, @origin_department
  end
end