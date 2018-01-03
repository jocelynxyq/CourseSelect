class GradesController < ApplicationController

  before_action :teacher_logged_in, only: [:update]

  def update
    @grade=Grade.find_by_id(params[:id])
    if @grade.update_attributes!(:grade => params[:grade][:grade])
      flash={:success => "#{@grade.user.name} #{@grade.course.name}的成绩已成功修改为 #{@grade.grade}"}
    else
      flash={:danger => "上传失败.请重试"}
    end
    redirect_to grades_path(course_id: params[:course_id]), flash: flash
  end
#馮嶽璐更改過ｉｎｄｅｘ函數
  def index
    #binding.pry
    if teacher_logged_in?
      @course = Course.find_by_id(params[:course_id])
      @grades = @course.grades.order(created_at: "desc").paginate(page: params[:page], per_page: 20)
    elsif student_logged_in?
      @grades=current_user.grades
      tmp=[]
      @grades.each do |grades|
        if grades.grade != nil
          tmp<<grades
        end
      end
      @grades=tmp
      tmp1=[]
      @grades.each do |grades|
        if grades.grade >= 60
          tmp1<<grades
        end
      end
      @grades1=tmp1

      # @grades1=@grades.where(:grade > 0).paginate(page: params[:page], per_page: 2)
    else
      redirect_to root_path, flash: {:warning=>"请先登陆"}
    end
  end


#导出成绩表
def export
    if teacher_logged_in?
      @course=Course.find_by_id(params[:course_id])
      @grades=@course.grades
    else
      redirect_to root_path, flash: {:warning=>"请先登陆"}
    end

    respond_to do |format|
      format.html
      format.xls {
        require 'spreadsheet'
        book = Spreadsheet::Workbook.new
        sheet1 = book.create_worksheet
        sheet1.row(0).concat %w{学号 姓名 专业 培养单位 课程 成绩}
        @grades.each_with_index do |grade,i|
          #puts(grade.user.num)
          sheet1.row(i+1).push grade.user.num, grade.user.name, grade.user.major, grade.user.department, grade.course.name, grade.grade
        end
        book.write 'wqs.xls'
        send_file 'wqs.xls',:type => "application/vnd.ms-excel", :filename => "#{@course.name}.xls", :stream => false
        return
      }
    end
end

#导出课程表
def exportcourse
    if teacher_logged_in?
      @course=Course.find_by_id(params[:course_id])
      @grades=@course.grades
    else
      redirect_to root_path, flash: {:warning=>"请先登陆"}
    end

    respond_to do |format|
      format.html
      format.xls {
        require 'spreadsheet'
        book = Spreadsheet::Workbook.new
        sheet1 = book.create_worksheet
        sheet1.row(0).concat %w{学号 姓名 专业 培养单位}
        @grades.each_with_index do |grade,i|
          #puts(grade.user.num)
          sheet1.row(i+1).push grade.user.num, grade.user.name, grade.user.major, grade.user.department
        end
        book.write 'wqs.xls'
        send_file 'wqs.xls',:type => "application/vnd.ms-excel", :filename => "#{@course.name}.xls", :stream => false
        return
      }
    end
end


  private

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

end
