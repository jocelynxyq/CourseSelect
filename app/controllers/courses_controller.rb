class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update, :open, :close,:chart,:selected]#add open by qiao
  before_action :logged_in, only: :index

  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def open
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: true)
    redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
  end

  def close
    @course=Course.find_by_id(params[:id])
    @course.update_attributes(open: false)
    redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end
  
  def selected
    @course = Course.find_by_id(params[:id])
    @student=@course.users
  end

  def chart
    @course = Course.find_by_id(params[:id])
    @student=@course.users
    @student_department = {}
    @student.each do |stu|
      if !@student_department.has_key?(stu.department)
        @student_department[stu.department] =0
      end
      @student_department[stu.department] += 1
    end
  end

  

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  #-------------------------for students----------------------

  def list
    #-------QiaoCode--------
    @courses = Course.where(:open=>true).paginate(page: params[:page], per_page: 20)
    @course = @courses-current_user.courses
    @course_time = get_course_info(@course, 'course_time')
    @course_exam_type = get_course_info(@course, 'exam_type')
    tmp=[]
    @course.each do |course|
      if course.open==true
        tmp<<course
      end
    end
    @course=tmp
    if request.post?
      @course=course_filter_by_condition(@course, params, ['course_time', 'exam_type'])
    end
  end

  def select
    flash = nil
    ids = params[:course_select]
    if ids
      @course = Course.find(ids)
      fails_course = []
      success_course = []
      @course.each do |course|
        if course.limit_num != nil
          if course.users.length < course.limit_num
            current_user.courses<<course
            success_course << course.name
          else
            fails_course << course.name
          end
        else
          current_user.courses<<course
          success_course << course.name
        end
      end
      if success_course.length !=0
        flash = {:success => ("成功选择课程:  " + success_course.join(','))}
      end
      if fails_course.length !=0
        waring_info = fails_course.join(',') +'  存在选课冲突'
        if flash != nil
          flash[:warning] = waring_info
        else
          flash = {:warning => waring_info}
        end
      end
    else
      flash={:success => "请勾选课程"}
    end
    redirect_to courses_path, flash: flash
  end

  #   @course=Course.find_by_id(params[:id])
  #   if @course.users.length < @course.limit_num
  #     current_user.courses<<@course
  #     flash={:suceess => "成功选择课程: #{@course.name}"}
  #   else 
  #     flash={:danger => "选课失败，#{@course.name} 选课人数已满！"}
  #   end
  #   redirect_to courses_path, flash: flash
  # end

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end
  
  

  #-------------------------for both teachers and students----------------------
  
  def schedule
    @course=current_user.courses
    @user=current_user
    @course_time_table = get_current_curriculum_table(@course,@user)
  end
  
  # 增加outline方法
  def outline
    @course = Course.find_by_id(params[:id])
  end
  
  def index
    @course=current_user.teaching_courses.paginate(page: params[:page], per_page: 20) if teacher_logged_in?
    @course=current_user.courses.paginate(page: params[:page], per_page: 20) if student_logged_in?
  end


  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end
  # 加入课程大纲参数信息
  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week, :outline)
  end


end
