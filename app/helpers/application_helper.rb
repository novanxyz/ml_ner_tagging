module ApplicationHelper
    include AloTime
    include MetaDescriptionHelper

    def return_host
        ip_server = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
        hostname = Socket.gethostname
        if ip_server.ip_address == (ENV['IP_SERVER_DEV'] || '192.168.1.130')
            "http://dev-android.alodokter.com"
        elsif ip_server.ip_address == (ENV['IP_SERVER_STAGING'] || '10.148.0.19')
            "http://staging02.alodokter.com"
        else
            "http://www.alodokter.com"
        end
    end

    # division
    def summary_division_access(division)
        if division.rule == 'only'
            return content_tag(:strong, 'Can only access :')
        end
        if division.rule == 'except'
            if division.actions.blank?
                return content_tag(:strong, 'Can access to all page')
            else
                return content_tag(:strong, 'Can access to all page except :')
            end
        end
    end

    # add nested field
    def link_to_add_fields(text_button, f, association)
        new_object = f.object.class.reflect_on_association(association).klass.new
        fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
            render(association.to_s.singularize + "_fields", :f => builder)
        end
        button_tag(type: 'button', class: 'btn btn-info pull-right add-field', data: { association: association, fields: "#{fields}" }) do
            content_tag(:strong, text_button)
        end
    end

    # default image
    def alo_default_image
        'http://res.cloudinary.com/dk0z4ums3/image/upload/v1476930996/magazine_images/default_image.jpg'
    end

    def check_sub_menu(main_menu) 
        main_menu.status == "deeplink" && @main_menu.deeplink == "chat_bersama_dokter" && main_menu.sub_menus.where(is_active: true, is_deleted: false).empty?
    end

    def time_different(time)
        now = Time.now.to_i
        update_time = time.to_time.to_i
        day_of_update = time.strftime("%A")
        today = Time.now.strftime("%A")
        yesterday = 1.day.ago.strftime("%A")
        hour_minute = time.strftime('%H:%M')
        time_ago = time_ago_in_words(time, locale: :id)
        full_date = time.strftime("%d #{get_month_name(time.strftime('%m'))} %Y")
        a = now - update_time
        case a
            when 0..3540
                time_ago
            when 3541..86400
                case
                    when day_of_update == today
                        'Hari ini, '+ hour_minute
                    else
                        'Kemarin, '+ hour_minute
                end
            when 86401..172800
                case
                    when day_of_update == yesterday
                        'Kemarin, '+ hour_minute
                    else
                        time_ago
                end
            when 172801..2592000
                case
                    when (time_ago.include?"hari")
                        time_ago
                    when (time_ago.include?"bulan")
                        full_date
                end
            else
                full_date
        end
    end

    def get_month_name(month)
        I18n.t("date.month_names", locale: :id)[month.to_i]
    end
end
