import { html } from '@polymer/polymer/polymer-element.js';
import { BaseList } from '../../base-list.js'

import '../../markazuna/markazuna-circular-pager.js';
import '../../markazuna/markazuna-search-bar';
import '../../markazuna/markazuna-breadcrumb';

import './<%= singular_name %>-form.js';

<% 	
    fields = {}
    @fields.each_with_index do |field, index|
        name,type = field.split(':')
        type = 'String' if type.nil?
        fields[name] = type
    end
%>
class <%= singular_name.capitalize %>List extends BaseList {
    static get listTemplate() {
        return html`
            <div class="grid-container" width="100%">
                <div class="row list-header">
                    <markazuna-breadcrumb breadcrumb="<%= plural_name.capitalize %>"></markazuna-breadcrumb>                                        
                    <paper-button hidden="[[hideNew]]" class="add-button" icon="icons:add" on-tap="_new"><iron-icon icon="icons:add"></iron-icon></paper-button>
                    <markazuna-search-bar hidden="[[hideSearch]]" placeholder=" Search <%= plural_name %>..." ></markazuna-search-bar>                    
                </div>
                <vaadin-grid id="grid" theme="row-stripes" aria-label="<%= plural_name.capitalize %>" items="[[data]]">
                    <% fields.each do |field, type| %>
                    <vaadin-grid-column width="20%" flex-grow="0">
                        <template class="header">
                            <div class="grid-header-left"><%= field.capitalize %></div>
                        </template>
                        <template>
                            <div class="grid-content-left">[[item.<%= field %>]]</div>
                        </template>
                    </vaadin-grid-column>
                    <% end %>
                    <vaadin-grid-column width="20%" flex-grow="0">
                        <template class="header"><div class="grid-header">Actions</div></template>
                        <template>
                            <div class="grid-header">
                                <iron-icon icon="icons:assignment" on-tap="_view" id="[[item.id]]"></iron-icon>
                                <iron-icon icon="icons:create" on-tap="_edit" id="[[item.id]]"></iron-icon>
                                <iron-icon icon="icons:delete" on-tap="_confirmation" id="[[item.id]]"></iron-icon>                                
                            </div>
                        </template>
                    </vaadin-grid-column>
                </vaadin-grid>
            </div>
            <div class="flex" width="100%">
                <markazuna-circular-pager page="[[page]]" count="[[count]]" range="10" url="<%= @url %>?page=#{page}"></markazuna-circular-pager>
            </div>
        `;
    }

    static get formTemplate() { 
        return html`
            <<%= singular_name %>-form action-url="[[dataUrl]]" form-authenticity-token="[[formAuthenticityToken]]" id="formData"></<%= singular_name %>-form>
        `;
    }

    constructor() {
        super();
        this.title = "<%= plural_name.capitalize %>";
    }

    ready() {
        super.ready();
        document.querySelector('.list-title').innerHTML =("<%= plural_name.capitalize%>");
    }

    _formTitleNew() {
        return 'Create New <%= singular_name.capitalize %>';
    }
    _formTitleView() {
        return 'View <%= singular_name.capitalize %>';
    }

    _formTitleEdit() {
        return 'Edit <%= singular_name.capitalize %>';
    }

    _formTitleCopy() {
        return 'Copy <%= singular_name.capitalize %>';
    }
}
customElements.define('<%= singular_name %>-list', <%= singular_name.capitalize %>List);