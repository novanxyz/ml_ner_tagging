class Admin::StatisticService
    def create_statistic(statistic_form)
        statistic_form.save
    end

    def update_statistic(statistic_form)
        statistic_form.update
    end

    def delete_statistic(id)
        statistic = find_statistic(id)
        return statistic.delete, Admin::Statistic.page(1).total_pages
    end

    def find_statistic(id)
        Admin::Statistic.find(id)
    end

    def find_dashboard_statistics(query)
        page = query.delete(:page).to_i                        
        statistics  = [
            {"id" => Time.now.to_i ,"label" => "Total Users", :value => Core::User.count , :delta => 0, :stat_time => Time.now },
            {"id" => Time.now.to_i ,"label" => "Total Doctors", :value => Core::Doctor.count , :delta => 0, :stat_time => Time.now },
            {"id" => Time.now.to_i ,"label" => "Total Questions", :value => Core::Question.count , :delta => 0, :stat_time => Time.now},            
            {"id" => Time.now.to_i ,"label" => "Total Magazines", :value => Admin::Magazine.count_magazine , :delta => 0 , :stat_time => Time.now },
        ]
        
        
        return statistics , 1
    end
end
