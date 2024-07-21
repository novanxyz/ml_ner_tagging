<%
    fields = {}
    @fields.each_with_index do |field, index|
        name,type = field.split(':')
        type = 'String' if type.nil?
        fields[name] = type
    end
    fields['id'] = "Integer" unless fields.key?'id'
    fields_self = fields.keys.map{|f| "#{f}: self:#{f}" }.join(', ')
%>
class <%= class_name %>Form
    include ActiveModel::Model

    attr_accessor(<%= fields.keys %>)

    # Validations
    <%
    fields.each  do |field, type |
        next if field == "id"
    %>
    validates :<%= field %>, presence: true <%
    end
    %>

    def save
        if valid?
            <%= singular_name %> = <%= class_name %>.new(<%= fields_self %>)
            <%= singular_name %>.save
            true
        else
            false
        end
    end

    def update
        if valid?
            <%= singular_name %> = <%= class_name %>.find(self.id)
            <%= singular_name %>.update_attributes!(<%= fields_self %>)
            true
        else
            false
        end
    end
end
