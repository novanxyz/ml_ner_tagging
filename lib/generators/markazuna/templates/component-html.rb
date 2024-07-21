<%%= javascript_pack_tag '<%= @component_path %>/<%= plural_name %>', defer: true %>
<style>
    <<%= singular_name %>-list {
        margin: 0;
    }
    .component_container {
        padding: 0;
    }
</style>
<div class="row">
    <div class="col-md-12 col-sm-12 col-xs-12 component_container">
        <<%= singular_name %>-list data-url="<%= @url %>" form-authenticity-token="<%%= form_authenticity_token.to_s %>"></<%= singular_name %>-page>
    </div>
</div>