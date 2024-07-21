/*---------------------------------------------------------------------
  For oldie browser
  load webcomponents bundle, which includes all the necessary polyfills
----------------------------------------------------------------------*/
import '@webcomponents/webcomponentsjs/webcomponents-loader.js'

/*---------------------------------------------------------------------
  Import Components
----------------------------------------------------------------------*/
import './<%= plural_name %>/<%= singular_name %>-list.js'
import './<%= plural_name %>/<%= singular_name %>-form.js'