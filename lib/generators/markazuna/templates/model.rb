require 'markazuna/common_model'
<% 	
    fields = {}
    @fields.each_with_index do |field, index|
        name,type = field.split(':')
        type = 'String' if type.nil?
        fields[name] = type
    end    
%>
class <%= class_name %>
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: '<%= plural_name %>'

    # kaminari page setting
    paginates_per 20
	<% 	fields.each do |name, type| %>
    field :<%= name %>, type: <%= type %>, default: ''	<%
	end
	%>
end
