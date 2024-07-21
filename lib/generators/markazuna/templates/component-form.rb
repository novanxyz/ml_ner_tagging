import { PolymerElement, html } from '@polymer/polymer/polymer-element.js';
import '@polymer/iron-icon/iron-icon.js';
import '@polymer/paper-input/paper-input.js';
import '@polymer/paper-input/paper-input-container.js';
import '@polymer/paper-card/paper-card.js';
import '@polymer/iron-ajax/iron-ajax.js';
import '@polymer/iron-input/iron-input.js';
import '@polymer/paper-progress/paper-progress.js';

import '../../markazuna/markazuna-shared-styles.js';
<% 	
    fields = {}
    @fields.each_with_index do |field, index|
        name,type = field.split(':')
        type = 'String' if type.nil?
        fields[name] = type
    end
    fields['id'] = "Integer" unless fields.key?'id'
%>

class <%= singular_name.capitalize %>Form extends PolymerElement {
    static get template() {
        return html`
            <style include="shared-styles">
                :host {
                    display: block;
                    margin-top: 10px;
                }
                .wrapper-btns {
                    margin-top: 15px;
                    text-align: right;
                }
                paper-button {
                    margin-top: 10px;
                }
                paper-button.indigo {
                    background-color: var(--paper-indigo-500);
                    color: white;
                    --paper-button-raised-keyboard-focus: {
                        background-color: var(--paper-pink-a200) !important;
                        color: white !important;
                    };
                }
                paper-button.green {
                    background-color: var(--paper-green-500);
                    color: white;
                }
                paper-button.green[active] {
                    background-color: var(--paper-red-500);
                }
                paper-progress {
                    width: 100%;
                }
                #formContainer {
                    width: var(--user-form-width, 100%);
                    margin: 0 auto;
                    @apply(--user-form);
                }
                .title {
                    margin-bottom: 10px;
                }
                .title > div {
                    display: flex;
                    flex-direction: row;
                    justify-content: flex-start;
                    align-items: center;

                    padding: 5px 0 5px 0;
                    border-bottom: 2px solid #757575;
                    font-size: 16px;
                    font-weight: bold;
                }
                .title iron-icon {
                    padding: 0;
                    padding-right: 2px;
                }
                #id_wrapper {
                    display: none;
                }
            </style>

            <iron-ajax
                id="saveAjax"
                method="post"
                url="[[actionUrl]]"
                content-type="application/json"
                handle-as="json"
                on-response="_onSaveResponse"
                on-error="_onSaveError">
            </iron-ajax>

            <iron-ajax
                    id="updateAjax"
                    method="put"
                    content-type="application/json"
                    handle-as="json"
                    on-response="_onUpdateResponse"
                    on-error="_onUpdateError">
            </iron-ajax>

            <iron-ajax
                    id="editAjax"
                    method="get"
                    content-type="application/json"
                    handle-as="json"
                    on-response="_onEditResponse"
                    on-error="_onEditError">
            </iron-ajax>

            <div class="title">
                <div><iron-icon icon="[[icon]]"></iron-icon>[[title]]</div>
                <paper-progress id="progress" hidden indeterminate></paper-progress>
            </div>

            <div id="formContainer" class="<%= singular_name %> [[_mode]]">
                <template is="dom-if" if="[[_error]]">
                    <p class="alert-error">[[_error]]</p>
                </template>

                <iron-input id="id_wrapper" slot="input" bind-value="{{<%= singular_name %>.id}}">
                    <input id="id" type="hidden" value="{{<%= singular_name %>.id}}">
                </iron-input>

                <% fields.each do |field, type| %>
                    
                    <% if type=='Integer'%>
                        <paper-input placeholder="<%=field.capitalize%>" id="<%= field %>" type="number" value="{{<%= singular_name %>.<%= field %>}}" readonly="[[readonly]]"></paper-input>                    
                    <% elsif type=='Date'%>
                        <paper-input placeholder="<%=field.capitalize%>" id="<%= field %>" type="Date" value="{{<%= singular_name %>.<%= field %>}}" readonly="[[readonly]]"></paper-input>                    
                    <% else %>
                        <paper-input placeholder="<%=field.capitalize%>" id="<%= field %>" type="text" value="{{<%= singular_name %>.<%= field %>}}" readonly="[[readonly]]"></paper-input>                    
                    <% end %>
                <% end %>
                <div class="wrapper-btns">
                    <paper-button class="link" on-tap="_cancel">Cancel</paper-button>
                    <paper-button id="_edit" raised class="indigo" on-tap="_edit" hidden="[[readonly]]">Edit</paper-button>
                    <paper-button id="_save" raised class="indigo" on-tap="_save" hidden="[[!readonly]]">Save</paper-button>
                </div>
            </div>
        `;
    }

    static get properties() {
        return {
            formAuthenticityToken: String,
            actionUrl: {
                type: String,
                value: ''
            },
            <%= singular_name %>: {
                type: Object,
                value: {},
                notify: true
            },
            title: {
                type: String,
                value: ''
            },
            icon: {
                type: String,
                value: ''
            },
            _mode: {
                type: String,
                value: 'new'
            },
            readonly:{
                type: Boolean,
                value: true,
                notify: true,
                reflectToAttribute: true
            },
            _error: String
        };
    }

    constructor() {
        super();
    }

    ready() {
        super.ready();
        if (this.<%=singular_name%>_id){
            this.view(this.<%=singular_name%>_id);
        }
    }

    view(id){
        this.edit(id);
        this._mode = 'view';
        this.readonly = true;
    }

    edit(id) {
        this.$.editAjax.url = this.actionUrl +'/'+ id +'/edit';
        this.$.editAjax.generateRequest();
        this._mode = 'edit';
    }

    copy(id) {
        this.$.editAjax.url = this.actionUrl +'/'+ id +'/edit';
        this.$.editAjax.generateRequest();
        this._mode = 'copy';
    }
    _edit(ev){        
        this.set('readonly',false);        
        this.$._edit.hidden = !this.readonly;
        this.$._save.hidden = this.readonly;
        this.shadowRoot.querySelectorAll('paper-input').forEach(e=>{e.removeAttribute('readonly')}) ;
    }

    _onEditResponse(data) {
        var response = data.detail.response;
        this.<%= singular_name %> = response.payload;
        if (this._mode === 'copy') {
            this.<%= singular_name %>.id = ''; // nullify id, we will save it as new document
        }
        this.dispatchEvent(new CustomEvent('editSuccess', {bubbles: true, composed: true}));
    }

    _onEditError() {
        this._error = 'Edit <%= singular_name.capitalize %> Error';
    }

    _onSaveResponse(e) {
        var response = e.detail.response;
        if (response.status == '200') {
            this._error = '';
            this._mode = 'new';
            this.<%= singular_name %> = {};
            this.dispatchEvent(new CustomEvent('saveSuccess', {bubbles: true, composed: true}));
        }
        else {
            this._error = 'Creating <%= singular_name.capitalize %> Error';
        }
        this.$.progress.hidden = true;
    }

    _onSaveError() {
        this._error = 'Creating <%= singular_name.capitalize %> Error';
        this.$.progress.hidden = true;
    }

    _onUpdateResponse(data) {
        var response = data.detail.response;
        if (response.status == '200') {
            this._error = '';
            this._mode = 'new';
            this.<%= singular_name %> = {};
            this.dispatchEvent(new CustomEvent('saveSuccess', {bubbles: true, composed: true}));
        }
        else {
            this._error = 'Updating <%= singular_name.capitalize %> Error';
        }
        this.$.progress.hidden = true;
    }

    _onUpdateError() {
        this._error = 'Creating <%= singular_name.capitalize %> Error';
        this.$.progress.hidden = true;
    }
    _edit(){
        this._mode = "edit";
        this.readonly = false;
    }

    _save() {
        if (this._mode === 'new' || this._mode === 'copy') {
            this.$.saveAjax.headers['X-CSRF-Token'] = this.formAuthenticityToken;
            this.$.saveAjax.body = this.<%= singular_name %>;
            this.$.saveAjax.generateRequest();
            this.$.progress.hidden = false;
        }
        else {
            this.$.updateAjax.headers['X-CSRF-Token'] = this.formAuthenticityToken;
            this.$.updateAjax.body = this.<%= singular_name %>;
            this.$.updateAjax.url = this.actionUrl +'/'+ this.<%= singular_name %>.id;
            this.$.updateAjax.generateRequest();
            this.$.progress.hidden = false;
        }
    }

    _cancel() {
        this._error = '';
        this._mode = 'new';
        this.<%= singular_name %> = {};
        this.dispatchEvent(new CustomEvent('cancel', {bubbles: true, composed: true}));
    }
}
customElements.define('<%= singular_name %>-form', <%= singular_name.capitalize %>Form);
