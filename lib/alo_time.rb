module AloTime

    def name_of_day(d)
        d = 0 if d == 7
        Date::DAYNAMES[d]
    end

    def alo_time_parse(time_in_string)
        # parse string of time to datetime
        Date.today.to_time + Time.parse(time_in_string).seconds_since_midnight.seconds
    end

end